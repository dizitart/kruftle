// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:path/path.dart' as p;

import '../clean/safety.dart';
import '../models/project.dart';
import '../models/stack.dart';
import '../registry/stack_registry.dart';
import 'toolchain.dart';

/// Turns a user-typed glob into a regular expression, or null when it is not
/// usable.
///
/// Supports the three forms people actually type: `*` for a path segment,
/// `**` for any number of segments, and `?` for one character. Everything else
/// is escaped, so a pattern with a `.` or a `(` in it means the literal
/// character rather than quietly becoming a regex metacharacter.
///
/// A pattern that will not compile is dropped rather than raised: an exclude
/// list is a convenience, and one bad line should not stop a scan.
RegExp? compileGlob(String pattern) {
  final trimmed = pattern.trim();
  if (trimmed.isEmpty) return null;

  final buffer = StringBuffer();
  for (var i = 0; i < trimmed.length; i++) {
    final char = trimmed[i];
    if (char == '*') {
      if (i + 1 < trimmed.length && trimmed[i + 1] == '*') {
        buffer.write('.*');
        i++;
      } else {
        buffer.write('[^/\\\\]*');
      }
    } else if (char == '?') {
      buffer.write('[^/\\\\]');
    } else if (char == '/' || char == r'\') {
      // A pattern is written with forward slashes whatever platform it will
      // run on — an exclude list is the sort of thing people paste between
      // machines — so either separator in the pattern matches either on disk.
      buffer.write('[/\\\\]');
    } else {
      buffer.write(RegExp.escape(char));
    }
  }

  try {
    // Anchored at the end only: a pattern names a path suffix, so
    // `**/vendor/**` and `vendor` both do what a person expects.
    return RegExp('(^|/|\\\\)?$buffer\$');
  } on FormatException {
    return null;
  }
}

/// What the user asked us to scan.
class ScanRequest {
  const ScanRequest({
    required this.root,
    this.maxDepth = 12,
    this.followHiddenDirectories = false,
    this.excludeGlobs = const [],
  });

  final String root;

  /// Paths never entered, whichever stack might have claimed them.
  ///
  /// Only ever *reduces* what is scanned, so it cannot be used to reach
  /// somewhere the rails would otherwise refuse — the worst a bad pattern can
  /// do is hide a project the user wanted to find.
  final List<String> excludeGlobs;

  /// Guard against pathological trees. Depth is counted from [root].
  final int maxDepth;

  /// Hidden directories are skipped by default: they hold VCS metadata, editor
  /// state and tool caches, not projects the user is working on.
  final bool followHiddenDirectories;
}

/// Progress emitted while walking, so the UI can show something honest during
/// a scan that may take a minute on a large tree.
sealed class ScanEvent {
  const ScanEvent();
}

class ScanningDirectory extends ScanEvent {
  const ScanningDirectory(this.path, this.projectsFound);

  final String path;
  final int projectsFound;
}

class ProjectFound extends ScanEvent {
  const ProjectFound(this.project);

  final DetectedProject project;
}

class ScanFailed extends ScanEvent {
  const ScanFailed(this.violation);

  final SafetyViolation violation;
}

/// Walks a directory tree and reports every project it recognises.
///
/// Cancellation is simply cancelling the returned stream's subscription: the
/// generator suspends at its next `yield` and the walk stops. There is no
/// separate cancellation token to keep in sync.
class ProjectScanner {
  ProjectScanner({StackRegistry? registry, ToolchainProbe? toolchain})
    : _registry = registry ?? const StackRegistry(),
      _toolchain = toolchain ?? ToolchainProbe();

  final StackRegistry _registry;
  final ToolchainProbe _toolchain;

  /// Directory names never descended into, whatever else is true of them.
  ///
  /// `node_modules` is here because it contains tens of thousands of
  /// `package.json` files, every one of which would otherwise be reported as a
  /// separate Node project.
  static const _neverDescend = {
    '.git',
    '.hg',
    '.svn',
    'node_modules',
    '.venv',
    'venv',
    '__pycache__',
  };

  Stream<ScanEvent> scan(ScanRequest request) async* {
    final violation = checkScanRoot(request.root);
    if (violation != null) {
      yield ScanFailed(violation);
      return;
    }

    final excluded = [
      for (final pattern in request.excludeGlobs) ?compileGlob(pattern),
    ];

    var found = 0;
    final queue = <(Directory, int)>[(Directory(request.root), 0)];

    while (queue.isNotEmpty) {
      final (directory, depth) = queue.removeAt(0);
      if (depth > request.maxDepth) continue;

      yield ScanningDirectory(directory.path, found);

      final listing = await _list(directory);
      if (listing == null) continue; // unreadable: permissions, or raced away

      final matched = _registry.detect(listing);
      if (matched.isNotEmpty) {
        final project = await _describe(directory, matched, listing, depth);
        if (project.hasArtifacts) {
          found++;
          yield ProjectFound(project);
        }
      }

      // Keep descending even inside a detected project: monorepos nest, and a
      // Flutter app's `rust/` crate or `android/` module has its own build
      // output that the parent's clean command will not touch. We just never
      // descend into the artifact directories themselves.
      final skip = {
        ..._neverDescend,
        for (final stack in matched)
          for (final artifact in stack.artifacts)
            p.split(artifact.relative).first,
      };

      for (final name in listing.directories) {
        if (skip.contains(name)) continue;
        if (!request.followHiddenDirectories && name.startsWith('.')) continue;

        final child = p.join(directory.path, name);
        // Rail 3: never descend a symlink. Link cycles are how a tree walk
        // turns into an infinite loop.
        if (Link(child).existsSync()) continue;
        if (excluded.any((glob) => glob.hasMatch(child))) continue;

        queue.add((Directory(child), depth + 1));
      }
    }
  }

  /// One listing per directory, reused for detection, command resolution and
  /// artifact discovery.
  Future<DirListing?> _list(Directory directory) async {
    final files = <String>{};
    final directories = <String>{};
    try {
      await for (final entity in directory.list(followLinks: false)) {
        final name = p.basename(entity.path);
        if (entity is Directory) {
          directories.add(name);
        } else {
          files.add(name);
        }
      }
    } on FileSystemException {
      return null;
    }
    return DirListing(files: files, directories: directories);
  }

  Future<DetectedProject> _describe(
    Directory directory,
    List<StackDefinition> matched,
    DirListing listing,
    int depth,
  ) async {
    final stacks = <StackMatch>[];
    for (final definition in matched) {
      stacks.add(
        StackMatch(
          stackId: definition.id,
          displayName: definition.displayName,
          command: definition.commandFor(listing),
          artifacts: _existingArtifacts(directory.path, definition),
          toolBinary: definition.tool?.binary,
          installUrl: definition.tool?.installUrl,
        ),
      );
    }
    return DetectedProject(path: directory.path, stacks: stacks, depth: depth);
  }

  /// Only artifacts that are actually on disk. A pristine checkout has nothing
  /// to clean, and reporting it as a cleanup candidate is noise.
  List<ArtifactHit> _existingArtifacts(
    String projectPath,
    StackDefinition definition,
  ) {
    final hits = <ArtifactHit>[];
    for (final artifact in definition.artifacts) {
      final full = p.join(projectPath, artifact.relative);
      if (!Directory(full).existsSync()) continue;
      if (Link(full).existsSync()) continue; // rail 3
      hits.add(
        ArtifactHit(
          absolutePath: full,
          relative: artifact.relative,
          risk: artifact.risk,
        ),
      );
    }
    return hits;
  }

  /// Whether each tool a registered stack needs is installed, keyed by binary
  /// name.
  ///
  /// Keyed by binary rather than by [StackId] because that is what is actually
  /// being asked — and because several stacks legitimately share one binary
  /// (`make` serves both Make and Autotools), while a custom profile has no
  /// distinct `StackId` of its own to key by at all.
  ///
  /// Asked once per scan, after the walk, because probing a login shell is
  /// slow and the answer does not vary per project.
  Future<Map<String, ToolStatus>> toolAvailability() async {
    final statuses = <String, ToolStatus>{};
    for (final stack in _registry.stacks) {
      final binary = stack.tool?.binary;
      if (binary == null || statuses.containsKey(binary)) continue;
      statuses[binary] = await _toolchain.status(binary);
    }
    return statuses;
  }
}
