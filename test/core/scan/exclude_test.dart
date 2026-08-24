// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/models/stack.dart';
import 'package:kruftle/src/core/profiles/profile.dart';
import 'package:kruftle/src/core/registry/stack_registry.dart';
import 'package:kruftle/src/core/scan/project_scanner.dart';
import 'package:path/path.dart' as p;

void main() {
  group('compileGlob', () {
    bool matches(String pattern, String path) =>
        compileGlob(pattern)?.hasMatch(path) ?? false;

    test('a bare name matches that path segment at the end', () {
      expect(matches('vendor', '/a/b/vendor'), isTrue);
      expect(matches('vendor', '/a/vendor'), isTrue);
      expect(matches('vendor', '/a/b/vendors'), isFalse);
      expect(matches('vendor', '/a/vendor/c'), isFalse);
    });

    test('** spans any number of segments', () {
      expect(matches('**/vendor', '/a/b/c/vendor'), isTrue);
      expect(matches('**/vendor/**', '/a/vendor/x/y'), isTrue);
    });

    test('* stops at a separator', () {
      expect(matches('build-*', '/a/build-debug'), isTrue);
      expect(
        matches('build-*', '/a/build-debug/inner'),
        isFalse,
        reason: 'a single star must not cross a directory boundary',
      );
    });

    test('? matches exactly one character', () {
      expect(matches('out?', '/a/out1'), isTrue);
      expect(matches('out?', '/a/out'), isFalse);
      expect(matches('out?', '/a/out12'), isFalse);
    });

    test('a dot is a literal dot, not "any character"', () {
      // The bug this prevents: `.git` compiled naively as a regex would also
      // match `xgit`, and the user would wonder why a directory vanished.
      expect(matches('.git', '/a/.git'), isTrue);
      expect(matches('.git', '/a/xgit'), isFalse);
    });

    test('regex metacharacters in a pattern are taken literally', () {
      expect(matches(r'a(b)c', '/x/a(b)c'), isTrue);
      expect(matches(r'a+b', '/x/a+b'), isTrue);
      expect(matches(r'a+b', '/x/aab'), isFalse);
    });

    test('an empty or blank pattern compiles to nothing', () {
      expect(compileGlob(''), isNull);
      expect(compileGlob('   '), isNull);
    });

    test('either separator in a pattern matches either on disk', () {
      // Exclude lists get pasted between machines, so a pattern written with
      // forward slashes has to work on Windows and vice versa.
      expect(matches('**/vendor', r'C:\a\b\vendor'), isTrue);
      expect(matches(r'**\vendor', '/a/b/vendor'), isTrue);
      expect(matches(r'**\vendor', r'C:\a\vendor'), isTrue);
      expect(matches('vendor/bundle', r'C:\a\vendor\bundle'), isTrue);
    });
  });

  group('the scanner honours exclude patterns', () {
    late Directory tmp;

    setUp(() {
      tmp = Directory.systemTemp.createTempSync('kruftle_exclude');
      // Two Rust crates, one of them inside a `vendor/` directory.
      for (final relative in ['mine', 'vendor/theirs']) {
        final root = Directory(p.join(tmp.path, relative))
          ..createSync(recursive: true);
        File(p.join(root.path, 'Cargo.toml')).writeAsStringSync('');
        Directory(p.join(root.path, 'target')).createSync();
        File(p.join(root.path, 'target', 'out.bin')).writeAsStringSync('x');
      }
    });

    tearDown(() => tmp.deleteSync(recursive: true));

    Future<List<String>> scan({List<String> exclude = const []}) async {
      final found = <String>[];
      await for (final event in ProjectScanner().scan(
        ScanRequest(root: tmp.path, excludeGlobs: exclude),
      )) {
        if (event is ProjectFound) {
          found.add(p.relative(event.project.path, from: tmp.path));
        }
      }
      return found..sort();
    }

    test('finds both crates when nothing is excluded', () async {
      expect(await scan(), ['mine', p.join('vendor', 'theirs')]);
    });

    test('an excluded directory is not entered', () async {
      expect(await scan(exclude: ['**/vendor']), ['mine']);
    });

    test('a pattern that matches nothing changes nothing', () async {
      expect(await scan(exclude: ['**/nowhere']), [
        'mine',
        p.join('vendor', 'theirs'),
      ]);
    });

    test('an unusable pattern is ignored rather than fatal', () async {
      // One bad line in an exclude list should not stop a scan.
      expect(await scan(exclude: ['', '   ']), [
        'mine',
        p.join('vendor', 'theirs'),
      ]);
    });
  });

  group('custom profiles take part in a real scan', () {
    late Directory tmp;

    setUp(() {
      tmp = Directory.systemTemp.createTempSync('kruftle_profile_scan');
      final game = Directory(p.join(tmp.path, 'MyGame'))..createSync();
      File(p.join(game.path, 'MyGame.uproject')).writeAsStringSync('');
      Directory(p.join(game.path, 'Binaries')).createSync();
      File(p.join(game.path, 'Binaries', 'a.dll')).writeAsStringSync('x');
    });

    tearDown(() => tmp.deleteSync(recursive: true));

    test('a profile finds a project no built-in stack would', () async {
      const profile = CleanupProfile(
        name: 'Unreal Engine',
        markers: ['*.uproject'],
        artifactDirs: ['Binaries'],
      );

      final withoutProfile = <String>[];
      await for (final event in ProjectScanner().scan(
        ScanRequest(root: tmp.path),
      )) {
        if (event is ProjectFound) withoutProfile.add(event.project.name);
      }
      expect(
        withoutProfile,
        isEmpty,
        reason: 'no built-in stack knows what a .uproject is',
      );

      final withProfile = <DetectedProjectSummary>[];
      await for (final event in ProjectScanner(
        registry: StackRegistry.withCustom(const ProfileSet([profile]).stacks),
      ).scan(ScanRequest(root: tmp.path))) {
        if (event is ProjectFound) {
          withProfile.add(
            DetectedProjectSummary(
              event.project.name,
              event.project.stacks.single.displayName,
              event.project.stacks.single.stackId,
              event.project.allArtifacts.map((a) => a.relative).toList(),
            ),
          );
        }
      }

      expect(withProfile, hasLength(1));
      expect(withProfile.single.name, 'MyGame');
      expect(withProfile.single.stackName, 'Unreal Engine');
      expect(withProfile.single.stackId, StackId.custom);
      expect(withProfile.single.artifacts, ['Binaries']);
    });

    test(
      'a profile whose directory does not exist reports no project',
      () async {
        const profile = CleanupProfile(
          name: 'Unreal Engine',
          markers: ['*.uproject'],
          artifactDirs: ['Intermediate'],
        );

        final found = <String>[];
        await for (final event in ProjectScanner(
          registry: StackRegistry.withCustom(
            const ProfileSet([profile]).stacks,
          ),
        ).scan(ScanRequest(root: tmp.path))) {
          if (event is ProjectFound) found.add(event.project.name);
        }

        expect(
          found,
          isEmpty,
          reason: 'a pristine checkout has nothing to clean',
        );
      },
    );

    test('a custom profile contributes its binary to the tool probe', () async {
      const profile = CleanupProfile(
        name: 'Unreal Engine',
        markers: ['*.uproject'],
        command: 'unrealbuildtool clean',
        artifactDirs: ['Binaries'],
      );

      final scanner = ProjectScanner(
        registry: StackRegistry.withCustom(const ProfileSet([profile]).stacks),
      );
      final tools = await scanner.toolAvailability();

      expect(tools.keys, contains('unrealbuildtool'));
      expect(tools.keys, contains('cargo'));
    });
  });
}

/// Flattened so the expectations read as data rather than as a chain of
/// property accesses.
class DetectedProjectSummary {
  const DetectedProjectSummary(
    this.name,
    this.stackName,
    this.stackId,
    this.artifacts,
  );

  final String name;
  final String stackName;
  final StackId stackId;
  final List<String> artifacts;
}
