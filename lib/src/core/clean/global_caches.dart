// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/clean.dart';
import '../models/stack.dart';
import '../scan/sizer.dart';
import '../scan/toolchain.dart';
import 'process_runner.dart';
import 'safety.dart';

/// A cache that lives in the user's home directory rather than in any one
/// project, shared by every project that uses that toolchain.
///
/// These are kept separate from the project scan on purpose. They are not
/// inside the folder the user chose, they are shared state, and emptying one
/// costs a re-download for *every* project on the machine — so they get their
/// own screen and their own confirmation rather than riding along with a
/// per-project cleanup.
class GlobalCache {
  const GlobalCache({
    required this.id,
    required this.displayName,
    required this.description,
    required this.relativePaths,
    this.command,
    this.tool,
    this.windowsPaths = const [],
  });

  final StackId id;
  final String displayName;

  /// What the user gives up by emptying it.
  final String description;

  /// Paths relative to the home directory, POSIX platforms.
  ///
  /// Always written with forward slashes, on every platform, and split into
  /// segments when joined. A literal `AppData\Local\npm-cache` survives
  /// `p.join` on Windows but becomes one nonsense segment anywhere else, which
  /// makes the Windows behaviour impossible to test off Windows.
  final List<String> relativePaths;

  /// Where the same cache lives on Windows, when it differs.
  final List<String> windowsPaths;

  /// The official way to empty it, where the toolchain offers one.
  final CleanCommand? command;

  final String? tool;

  /// Absolute paths that exist on this machine.
  List<String> resolve({String? home, bool? windows}) {
    final isWindows = windows ?? Platform.isWindows;
    final base =
        home ??
        Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'];
    if (base == null) return const [];

    final candidates = isWindows && windowsPaths.isNotEmpty
        ? windowsPaths
        : relativePaths;

    return [
      for (final relative in candidates)
        if (Directory(p.joinAll([base, ...relative.split('/')])).existsSync())
          p.joinAll([base, ...relative.split('/')]),
    ];
  }
}

/// Every global cache Kruftle knows how to empty.
///
/// Same extension model as the stack registry: one entry, no subclass.
const List<GlobalCache> kGlobalCaches = [
  GlobalCache(
    id: StackId.gradle,
    displayName: 'Gradle',
    description:
        'Downloaded dependencies, wrapper distributions and build '
        'caches shared by every Gradle project.',
    relativePaths: ['.gradle/caches', '.gradle/wrapper'],
    tool: 'gradle',
  ),
  GlobalCache(
    id: StackId.rust,
    displayName: 'Cargo registry',
    description:
        'Crate sources and downloads. Re-fetched on the next build '
        'that needs them.',
    relativePaths: ['.cargo/registry', '.cargo/git'],
    tool: 'cargo',
  ),
  GlobalCache(
    id: StackId.maven,
    displayName: 'Maven repository',
    description:
        'The local ~/.m2 repository. Emptying it means re-resolving '
        'every dependency of every Maven project.',
    relativePaths: ['.m2/repository'],
    tool: 'mvn',
  ),
  GlobalCache(
    id: StackId.dart,
    displayName: 'Pub cache',
    description: 'Downloaded Dart and Flutter packages.',
    relativePaths: ['.pub-cache/hosted', '.pub-cache/git'],
    windowsPaths: ['AppData/Local/Pub/Cache/hosted'],
    tool: 'dart',
  ),
  GlobalCache(
    id: StackId.node,
    displayName: 'npm cache',
    description: 'The npm content-addressable download cache.',
    relativePaths: ['.npm/_cacache'],
    windowsPaths: ['AppData/Local/npm-cache'],
    command: CleanCommand('npm', ['cache', 'clean', '--force']),
    tool: 'npm',
  ),
  GlobalCache(
    id: StackId.go,
    displayName: 'Go module cache',
    description:
        'Downloaded modules and the build cache. Go has its own '
        'command for this, which handles the read-only files correctly.',
    relativePaths: ['go/pkg/mod', '.cache/go-build'],
    windowsPaths: ['go/pkg/mod'],
    // Deleting Go's module cache by hand fails: it marks everything
    // read-only on purpose. `go clean` is the only thing that gets it right.
    command: CleanCommand('go', ['clean', '-modcache', '-cache']),
    tool: 'go',
  ),
  GlobalCache(
    id: StackId.xcode,
    displayName: 'Xcode DerivedData',
    description:
        'Xcode build products and indexes. Regenerated on the next '
        'build, at the cost of a slow first one.',
    relativePaths: ['Library/Developer/Xcode/DerivedData'],
  ),
];

/// One global cache as it exists on this machine right now.
class GlobalCacheTarget {
  const GlobalCacheTarget({
    required this.cache,
    required this.paths,
    required this.toolAvailable,
    this.sizeBytes,
  });

  final GlobalCache cache;

  /// Absolute paths that exist. Never empty — a cache with nothing on disk is
  /// not offered at all.
  final List<String> paths;

  /// Whether the official command can be run. Where a cache has a command,
  /// this decides whether it is used instead of deletion.
  final bool toolAvailable;

  final int? sizeBytes;

  bool get usesCommand => cache.command != null && toolAvailable;

  GlobalCacheTarget withSize(int bytes) => GlobalCacheTarget(
    cache: cache,
    paths: paths,
    toolAvailable: toolAvailable,
    sizeBytes: bytes,
  );
}

class GlobalCacheOutcome {
  const GlobalCacheOutcome({
    required this.cache,
    required this.status,
    required this.bytesFreed,
    this.message,
  });

  final GlobalCache cache;
  final StepStatus status;
  final int bytesFreed;
  final String? message;
}

/// The only paths Kruftle will ever remove from the home directory.
///
/// The project safety rails deliberately refuse anything under `$HOME`, which
/// is correct for a per-project scan and useless here. This is the narrow,
/// separate gate for the global caches: a target must be a path the registry
/// itself produced, must genuinely sit inside the home directory, and must not
/// be the home directory or a link.
SafetyViolation? checkGlobalCacheTarget(
  String target, {
  String? home,
  bool? windows,
  List<GlobalCache> registry = kGlobalCaches,
  bool Function(String)? isLink,
  bool Function(String)? directoryExists,
}) {
  final isWindows = windows ?? Platform.isWindows;
  final base =
      home ??
      Platform.environment['HOME'] ??
      Platform.environment['USERPROFILE'];
  if (base == null) return SafetyViolation.outsideRoot;

  final permitted = {
    for (final cache in registry)
      for (final path in cache.resolve(home: base, windows: isWindows))
        p.canonicalize(path),
  };
  if (!permitted.contains(p.canonicalize(target))) {
    return SafetyViolation.notAllowListed;
  }

  final link = isLink ?? (String q) => Link(q).existsSync();
  if (link(target)) return SafetyViolation.symlink;

  final exists = directoryExists ?? (String q) => Directory(q).existsSync();
  if (!exists(target)) return SafetyViolation.notADirectory;

  if (p.canonicalize(target) == p.canonicalize(base)) {
    return SafetyViolation.forbiddenRoot;
  }
  if (!p.isWithin(p.canonicalize(base), p.canonicalize(target))) {
    return SafetyViolation.outsideRoot;
  }

  return null;
}

/// Surveys and empties the global caches.
class GlobalCacheCleaner {
  GlobalCacheCleaner({
    ProcessRunner? runner,
    Sizer? sizer,
    ToolchainProbe? toolchain,
    this.registry = kGlobalCaches,
    this.stepTimeout = const Duration(minutes: 10),
  }) : _runner = runner ?? SystemProcessRunner(),
       _sizer = sizer ?? Sizer(),
       _toolchain = toolchain ?? ToolchainProbe();

  final ProcessRunner _runner;
  final Sizer _sizer;
  final ToolchainProbe _toolchain;
  final List<GlobalCache> registry;
  final Duration stepTimeout;

  /// Which caches exist here, and whether their tool is installed. Sizes are
  /// measured separately, because they are slow.
  Future<List<GlobalCacheTarget>> survey({String? home, bool? windows}) async {
    final targets = <GlobalCacheTarget>[];
    for (final cache in registry) {
      final paths = cache.resolve(home: home, windows: windows);
      if (paths.isEmpty) continue;
      targets.add(
        GlobalCacheTarget(
          cache: cache,
          paths: paths,
          toolAvailable:
              cache.tool == null ||
              await _toolchain.status(cache.tool) == ToolStatus.available,
        ),
      );
    }
    return targets;
  }

  Future<List<GlobalCacheTarget>> measure(
    List<GlobalCacheTarget> targets, {
    void Function(GlobalCacheTarget)? onMeasured,
  }) async {
    final sizes = await _sizer.measureAll([
      for (final target in targets) ...target.paths,
    ]);

    return [
      for (final target in targets)
        target.withSize(
          target.paths.fold(0, (sum, path) => sum + (sizes[path] ?? 0)),
        ),
    ];
  }

  /// Empties [targets], preferring each toolchain's own command.
  Future<List<GlobalCacheOutcome>> clean(
    List<GlobalCacheTarget> targets, {
    String? home,
    bool? windows,
  }) async {
    final outcomes = <GlobalCacheOutcome>[];

    for (final target in targets) {
      final before = await _sizer.measureAll(target.paths);
      final beforeBytes = before.values.fold(0, (a, b) => a + b);

      if (target.usesCommand) {
        final result = await _runner.run(
          target.cache.command!,
          // Run somewhere harmless: these commands act on the user's home
          // configuration, not on whatever directory we happen to be in.
          workingDirectory: Directory.systemTemp.path,
          timeout: stepTimeout,
        );
        final after = await _sizer.measureAll(target.paths);
        outcomes.add(
          GlobalCacheOutcome(
            cache: target.cache,
            status: result.timedOut
                ? StepStatus.timedOut
                : result.succeeded
                ? StepStatus.success
                : StepStatus.failed,
            bytesFreed: _freed(beforeBytes, after),
            message: result.succeeded ? null : result.stderr.trim(),
          ),
        );
        continue;
      }

      SafetyViolation? refusal;
      for (final path in target.paths) {
        final violation = checkGlobalCacheTarget(
          path,
          home: home,
          windows: windows,
          registry: registry,
        );
        if (violation != null) {
          refusal = violation;
          continue;
        }
        try {
          await Directory(path).delete(recursive: true);
        } on FileSystemException catch (e) {
          refusal = null;
          outcomes.add(
            GlobalCacheOutcome(
              cache: target.cache,
              status: StepStatus.failed,
              bytesFreed: 0,
              message: e.message,
            ),
          );
          break;
        }
      }

      if (outcomes.isNotEmpty && outcomes.last.cache == target.cache) continue;

      final after = await _sizer.measureAll(target.paths);
      outcomes.add(
        GlobalCacheOutcome(
          cache: target.cache,
          status: refusal != null ? StepStatus.refused : StepStatus.success,
          bytesFreed: _freed(beforeBytes, after),
          message: refusal?.message,
        ),
      );
    }

    return outcomes;
  }

  int _freed(int before, Map<String, int> after) {
    final remaining = after.values.fold(0, (a, b) => a + b);
    final freed = before - remaining;
    return freed < 0 ? 0 : freed;
  }
}
