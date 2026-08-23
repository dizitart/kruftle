// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/clean/global_caches.dart';
import 'package:kruftle/src/core/clean/process_runner.dart';
import 'package:kruftle/src/core/clean/safety.dart';
import 'package:kruftle/src/core/models/clean.dart';
import 'package:kruftle/src/core/models/stack.dart';
import 'package:kruftle/src/core/scan/sizer.dart';
import 'package:kruftle/src/core/scan/toolchain.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory home;

  setUp(() => home = Directory.systemTemp.createTempSync('kruftle_home'));
  tearDown(() => home.deleteSync(recursive: true));

  GlobalCache cacheNamed(String name) =>
      kGlobalCaches.firstWhere((c) => c.displayName == name);

  test('reports only paths that exist on this machine', () {
    Directory(
      p.join(home.path, '.cargo', 'registry'),
    ).createSync(recursive: true);

    final resolved = cacheNamed(
      'Cargo registry',
    ).resolve(home: home.path, windows: false);

    expect(resolved, hasLength(1));
    expect(resolved.single, endsWith(p.join('.cargo', 'registry')));
  });

  test('reports nothing when the toolchain was never used here', () {
    expect(
      cacheNamed('Maven repository').resolve(home: home.path, windows: false),
      isEmpty,
    );
  });

  test('uses the Windows location where it differs', () {
    Directory(
      p.join(home.path, 'AppData', 'Local', 'npm-cache'),
    ).createSync(recursive: true);
    Directory(
      p.join(home.path, '.npm', '_cacache'),
    ).createSync(recursive: true);

    final npm = cacheNamed('npm cache');
    expect(
      npm.resolve(home: home.path, windows: true).single,
      contains('npm-cache'),
    );
    expect(
      npm.resolve(home: home.path, windows: false).single,
      contains('_cacache'),
    );
  });

  test('a cache with no home directory resolves to nothing, not a crash', () {
    expect(
      cacheNamed('Gradle').resolve(home: null, windows: false),
      isA<List<String>>(),
    );
  });

  group('checkGlobalCacheTarget', () {
    String make(String relative) {
      final dir = Directory(p.joinAll([home.path, ...relative.split('/')]))
        ..createSync(recursive: true);
      return dir.path;
    }

    test('permits a path the registry itself produced', () {
      final target = make('.cargo/registry');
      expect(
        checkGlobalCacheTarget(target, home: home.path, windows: false),
        isNull,
      );
    });

    test('refuses the home directory itself', () {
      expect(
        checkGlobalCacheTarget(home.path, home: home.path, windows: false),
        SafetyViolation.notAllowListed,
      );
    });

    test('refuses a toolchain directory the registry never names', () {
      // ~/.cargo holds the installed toolchain; only ~/.cargo/registry is ours.
      final target = make('.cargo');
      make('.cargo/registry');
      expect(
        checkGlobalCacheTarget(target, home: home.path, windows: false),
        SafetyViolation.notAllowListed,
      );
    });

    test('refuses anything outside the home directory', () {
      expect(
        checkGlobalCacheTarget('/etc', home: home.path, windows: false),
        SafetyViolation.notAllowListed,
      );
    });

    test('refuses a symlink even when the name is allow-listed', () {
      final elsewhere = Directory(p.join(home.path, 'elsewhere'))..createSync();
      Directory(p.join(home.path, '.cargo')).createSync(recursive: true);
      Link(p.join(home.path, '.cargo', 'registry')).createSync(elsewhere.path);

      expect(
        checkGlobalCacheTarget(
          p.join(home.path, '.cargo', 'registry'),
          home: home.path,
          windows: false,
        ),
        SafetyViolation.symlink,
      );
    });
  });

  group('GlobalCacheCleaner', () {
    void seed(String relative, int bytes) {
      final dir = Directory(p.joinAll([home.path, ...relative.split('/')]))
        ..createSync(recursive: true);
      File(
        p.join(dir.path, 'blob.bin'),
      ).writeAsBytesSync(List.filled(bytes, 0));
    }

    test('surveys only caches that exist here', () async {
      seed('.cargo/registry', 512);

      final targets = await GlobalCacheCleaner(
        toolchain: ToolchainProbe(environment: const {}),
      ).survey(home: home.path, windows: false);

      expect(targets.map((t) => t.cache.displayName), ['Cargo registry']);
      expect(targets.single.paths, hasLength(1));
    });

    test('measures a cache across all of its directories', () async {
      seed('.cargo/registry', 400);
      seed('.cargo/git', 600);

      final cleaner = GlobalCacheCleaner(
        toolchain: ToolchainProbe(environment: const {}),
        sizer: Sizer(mode: SizeMode.apparent),
      );
      final measured = await cleaner.measure(
        await cleaner.survey(home: home.path, windows: false),
      );

      expect(measured.single.sizeBytes, 1000);
    });

    test('deletes a cache with no official command', () async {
      seed('Library/Developer/Xcode/DerivedData', 2048);

      final cleaner = GlobalCacheCleaner(
        toolchain: ToolchainProbe(environment: const {}),
        sizer: Sizer(mode: SizeMode.apparent),
      );
      final targets = await cleaner.survey(home: home.path, windows: false);
      final outcomes = await cleaner.clean(
        targets,
        home: home.path,
        windows: false,
      );

      expect(outcomes.single.status, StepStatus.success);
      expect(outcomes.single.bytesFreed, 2048);
      expect(
        Directory(
          p.join(home.path, 'Library/Developer/Xcode/DerivedData'),
        ).existsSync(),
        isFalse,
      );
    });

    test('prefers the official command over deleting, and does not delete '
        'when it runs', () async {
      seed('go/pkg/mod', 4096);
      final runner = _RecordingRunner();

      final cleaner = GlobalCacheCleaner(
        runner: runner,
        toolchain: ToolchainProbe(environment: const {}),
        registry: [
          kGlobalCaches.firstWhere((c) => c.displayName == 'Go module cache'),
        ],
      );
      final targets = [
        GlobalCacheTarget(
          cache: cleaner.registry.single,
          paths: [p.join(home.path, 'go', 'pkg', 'mod')],
          toolAvailable: true,
        ),
      ];

      await cleaner.clean(targets, home: home.path, windows: false);

      expect(runner.commands.single.toString(), 'go clean -modcache -cache');
      expect(
        Directory(p.join(home.path, 'go', 'pkg', 'mod')).existsSync(),
        isTrue,
        reason: 'go clean owns those read-only files; we never delete them',
      );
    });

    test('falls back to deletion when the tool is not installed', () async {
      seed('.npm/_cacache', 1024);
      final runner = _RecordingRunner();

      final cleaner = GlobalCacheCleaner(
        runner: runner,
        toolchain: ToolchainProbe(environment: const {}),
        registry: [
          kGlobalCaches.firstWhere((c) => c.displayName == 'npm cache'),
        ],
        sizer: Sizer(mode: SizeMode.apparent),
      );
      final outcomes = await cleaner.clean(
        [
          GlobalCacheTarget(
            cache: cleaner.registry.single,
            paths: [p.join(home.path, '.npm', '_cacache')],
            toolAvailable: false,
          ),
        ],
        home: home.path,
        windows: false,
      );

      expect(runner.commands, isEmpty);
      expect(outcomes.single.bytesFreed, 1024);
    });
  });

  group('registry invariants', () {
    test('Go is cleaned by its own command, never by deletion', () {
      // Go marks everything in the module cache read-only on purpose, so a
      // recursive delete fails partway and leaves it corrupt.
      expect(cacheNamed('Go module cache').command, isNotNull);
    });

    test('every cache has a description explaining the cost', () {
      for (final cache in kGlobalCaches) {
        expect(cache.displayName, isNotEmpty);
        expect(cache.description, isNotEmpty, reason: cache.displayName);
        expect(cache.relativePaths, isNotEmpty, reason: cache.displayName);
      }
    });

    test('no cache path is absolute or escapes the home directory', () {
      for (final cache in kGlobalCaches) {
        for (final relative in [
          ...cache.relativePaths,
          ...cache.windowsPaths,
        ]) {
          expect(relative, isNot(startsWith('/')), reason: cache.displayName);
          expect(relative, isNot(contains('..')), reason: cache.displayName);
          expect(relative, isNot(contains('*')), reason: cache.displayName);
        }
      }
    });

    test('no cache targets a whole toolchain directory', () {
      // ~/.cargo holds the toolchain itself, ~/.m2 holds settings.xml. Only
      // the cache subdirectories inside them are ever a target.
      const wholeHomes = {
        '.cargo',
        '.m2',
        '.gradle',
        '.npm',
        'go',
        '.pub-cache',
      };
      for (final cache in kGlobalCaches) {
        for (final relative in cache.relativePaths) {
          expect(
            wholeHomes.contains(relative),
            isFalse,
            reason: '${cache.displayName} would delete $relative wholesale',
          );
        }
      }
    });
  });
}

/// Records invocations instead of running anything.
class _RecordingRunner implements ProcessRunner {
  final commands = <CleanCommand>[];

  @override
  Future<ProcessOutcome> run(
    CleanCommand command, {
    required String workingDirectory,
    required Duration timeout,
  }) async {
    commands.add(command);
    return const ProcessOutcome(exitCode: 0, stdout: '', stderr: '');
  }

  @override
  Future<void> killAll() async {}
}
