// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/clean/safety.dart';
import 'package:kruftle/src/core/models/project.dart';
import 'package:kruftle/src/core/models/stack.dart';
import 'package:kruftle/src/core/scan/project_scanner.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tmp;
  late String root;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('kruftle_scan');
    root = Directory(p.join(tmp.path, 'codebase')).path;
    Directory(root).createSync();
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  /// Creates a file, making parents as needed.
  void file(String relative, [String content = '']) {
    final f = File(p.join(root, relative));
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(content);
  }

  void dir(String relative) =>
      Directory(p.join(root, relative)).createSync(recursive: true);

  Future<List<DetectedProject>> scanProjects({int maxDepth = 12}) async {
    final events = await ProjectScanner()
        .scan(ScanRequest(root: root, maxDepth: maxDepth))
        .toList();
    return events.whereType<ProjectFound>().map((e) => e.project).toList();
  }

  Set<StackId> stacksOf(DetectedProject project) =>
      project.stacks.map((s) => s.stackId).toSet();

  DetectedProject named(List<DetectedProject> projects, String name) =>
      projects.firstWhere((x) => x.name == name);

  group('discovery', () {
    test('finds a rust crate that has build output', () async {
      file('engine/Cargo.toml');
      file('engine/target/debug/binary', 'x' * 100);

      final projects = await scanProjects();
      expect(projects, hasLength(1));
      expect(projects.single.name, 'engine');
      expect(stacksOf(projects.single), {StackId.rust});
      expect(projects.single.allArtifacts.single.relative, 'target');
    });

    test('ignores a project with nothing to clean', () async {
      file('pristine/Cargo.toml');
      file('pristine/src/main.rs');

      expect(await scanProjects(), isEmpty);
    });

    test('finds sibling projects of different stacks', () async {
      file('api/pom.xml');
      dir('api/target');
      file('web/package.json');
      dir('web/node_modules');
      file('cli/go.mod');
      dir('cli/bin');

      final projects = await scanProjects();
      expect(projects.map((x) => x.name).toSet(), {'api', 'web', 'cli'});
    });

    test('reports every stack in a polyglot project', () async {
      file('app/pubspec.yaml');
      dir('app/macos');
      dir('app/build');
      file('app/build.gradle');

      final projects = await scanProjects();
      expect(stacksOf(named(projects, 'app')),
          containsAll([StackId.flutter, StackId.gradle]));
    });
  });

  group('descent rules', () {
    test('finds a project nested inside another project', () async {
      // The real case this exists for: a Flutter app with a Rust FFI crate.
      // `flutter clean` will not touch the crate's target/.
      file('app/pubspec.yaml');
      dir('app/ios');
      dir('app/build');
      file('app/rust/Cargo.toml');
      dir('app/rust/target');

      final projects = await scanProjects();
      expect(projects.map((x) => x.name).toSet(), {'app', 'rust'});
      expect(named(projects, 'rust').depth,
          greaterThan(named(projects, 'app').depth));
    });

    test('never descends into node_modules', () async {
      file('web/package.json');
      dir('web/node_modules');
      // A dependency that is itself a package — thousands of these exist in a
      // real node_modules and none of them are the user's projects.
      file('web/node_modules/left-pad/package.json');
      dir('web/node_modules/left-pad/node_modules');

      final projects = await scanProjects();
      expect(projects, hasLength(1));
      expect(projects.single.name, 'web');
    });

    test('never descends into a build output directory', () async {
      file('app/Cargo.toml');
      // Cargo vendors sources into target/; they must not become projects.
      file('app/target/package/dep-1.0/Cargo.toml');
      dir('app/target/package/dep-1.0/target');

      final projects = await scanProjects();
      expect(projects, hasLength(1));
      expect(projects.single.name, 'app');
    });

    test('skips hidden directories by default', () async {
      file('.cache/thing/Cargo.toml');
      dir('.cache/thing/target');

      expect(await scanProjects(), isEmpty);
    });

    test('respects maxDepth', () async {
      file('a/b/c/d/e/Cargo.toml');
      dir('a/b/c/d/e/target');

      expect(await scanProjects(maxDepth: 2), isEmpty);
      expect(await scanProjects(maxDepth: 6), hasLength(1));
    });
  });

  group('symlinks — rail 3', () {
    test('does not descend a symlinked directory', () async {
      final outside = Directory(p.join(tmp.path, 'elsewhere'))..createSync();
      File(p.join(outside.path, 'Cargo.toml')).writeAsStringSync('');
      Directory(p.join(outside.path, 'target')).createSync();

      Link(p.join(root, 'linked')).createSync(outside.path);

      expect(await scanProjects(), isEmpty);
    });

    test('survives a symlink cycle instead of looping forever', () async {
      file('app/Cargo.toml');
      dir('app/target');
      Link(p.join(root, 'app', 'loop')).createSync(root);

      final projects = await scanProjects();
      expect(projects, hasLength(1));
    }, timeout: const Timeout(Duration(seconds: 20)));

    test('does not report a symlinked artifact directory as cleanable', () async {
      final outside = Directory(p.join(tmp.path, 'shared_target'))..createSync();
      file('app/Cargo.toml');
      Link(p.join(root, 'app', 'target')).createSync(outside.path);

      // The crate exists but its only artifact is a link, so there is nothing
      // safe to clean and the project is not offered.
      expect(await scanProjects(), isEmpty);
    });
  });

  group('command resolution during a scan', () {
    test('resolves the gradle wrapper from the project directory', () async {
      file('svc/build.gradle');
      file('svc/gradlew');
      dir('svc/build');

      final projects = await scanProjects();
      final gradle = named(projects, 'svc')
          .stacks
          .firstWhere((s) => s.stackId == StackId.gradle);
      expect(gradle.command, const CleanCommand('./gradlew', ['clean']));
    });

    test('resolves the node package manager from the lockfile', () async {
      file('web/package.json');
      file('web/pnpm-lock.yaml');
      dir('web/node_modules');

      final projects = await scanProjects();
      expect(named(projects, 'web').stacks.single.command?.executable, 'pnpm');
    });
  });

  group('refusals', () {
    test('refuses to scan a forbidden root', () async {
      final events =
          await ProjectScanner().scan(const ScanRequest(root: '/')).toList();
      expect(events.single, isA<ScanFailed>());
      expect(
        (events.single as ScanFailed).violation,
        SafetyViolation.forbiddenRoot,
      );
    });

    test('refuses to scan a directory that does not exist', () async {
      final events = await ProjectScanner()
          .scan(ScanRequest(root: p.join(root, 'nope')))
          .toList();
      expect((events.single as ScanFailed).violation,
          SafetyViolation.notADirectory);
    });
  });

  group('cancellation', () {
    test('stops walking when the subscription is cancelled', () async {
      for (var i = 0; i < 60; i++) {
        file('p$i/Cargo.toml');
        dir('p$i/target');
      }

      var seen = 0;
      final subscription = ProjectScanner()
          .scan(ScanRequest(root: root))
          .listen(null);
      subscription.onData((_) async {
        seen++;
        if (seen == 3) await subscription.cancel();
      });

      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(seen, lessThan(60),
          reason: 'the walk must stop, not run to completion');
    });
  });

  group('progress', () {
    test('emits the directory being scanned and a running count', () async {
      file('app/Cargo.toml');
      dir('app/target');

      final events =
          await ProjectScanner().scan(ScanRequest(root: root)).toList();
      final progress = events.whereType<ScanningDirectory>().toList();

      expect(progress, isNotEmpty);
      expect(progress.first.path, root);
      expect(progress.map((e) => e.path), contains(p.join(root, 'app')));
    });
  });
}
