// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/models/stack.dart';
import 'package:kruftle/src/core/registry/stack_registry.dart';

DirListing listing({Set<String> files = const {}, Set<String> dirs = const {}}) =>
    DirListing(files: files, directories: dirs);

void main() {
  const registry = StackRegistry();

  group('detection', () {
    /// Each case: a directory's contents, and the stacks that must be found.
    /// Table-driven so adding a language means adding a row, not a test.
    const cases = <(String, Set<String>, Set<String>, Set<StackId>)>[
      ('rust crate', {'Cargo.toml'}, {'src'}, {StackId.rust}),
      ('go module', {'go.mod'}, {}, {StackId.go}),
      ('zig project', {'build.zig'}, {}, {StackId.zig}),
      ('maven project', {'pom.xml'}, {}, {StackId.maven}),
      ('gradle kotlin dsl', {'build.gradle.kts'}, {}, {StackId.gradle}),
      ('node package', {'package.json'}, {}, {StackId.node}),
      ('python poetry', {'pyproject.toml'}, {}, {StackId.python}),
      ('ruby gem', {'Gemfile'}, {}, {StackId.ruby}),
      ('elixir mix', {'mix.exs'}, {}, {StackId.elixir}),
      ('cmake project', {'CMakeLists.txt'}, {}, {StackId.cmake}),
      ('makefile only', {'Makefile'}, {}, {StackId.make}),
      ('dotnet csproj', {'App.csproj'}, {}, {StackId.dotnet}),
      ('swift package', {'Package.swift'}, {}, {StackId.swift}),
      ('plain dart package', {'pubspec.yaml'}, {'lib'}, {StackId.dart}),
      (
        'flutter app',
        {'pubspec.yaml'},
        {'lib', 'macos', 'windows'},
        {StackId.flutter},
      ),
    ];

    for (final (name, files, dirs, expected) in cases) {
      test('detects $name', () {
        final found = registry
            .detect(listing(files: files, dirs: dirs))
            .map((s) => s.id)
            .toSet();
        expect(found, expected);
      });
    }

    test('xcode project detected from the .xcodeproj bundle directory', () {
      final found = registry
          .detect(listing(dirs: {'Runner.xcodeproj'}))
          .map((s) => s.id);
      expect(found, contains(StackId.xcode));
    });

    test('flutter and dart are mutually exclusive', () {
      final flutterApp = listing(files: {'pubspec.yaml'}, dirs: {'android'});
      final ids = registry.detect(flutterApp).map((s) => s.id).toSet();
      expect(ids, contains(StackId.flutter));
      expect(ids, isNot(contains(StackId.dart)));
    });

    test('reports every stack in a polyglot project, highest priority first', () {
      // A Flutter app with a native Gradle build and a Rust FFI crate.
      final polyglot = listing(
        files: {'pubspec.yaml', 'build.gradle', 'Cargo.toml', 'Makefile'},
        dirs: {'android', 'ios'},
      );
      final ids = registry.detect(polyglot).map((s) => s.id).toList();

      expect(ids, containsAll([StackId.flutter, StackId.gradle, StackId.rust, StackId.make]));
      expect(ids.first, StackId.flutter, reason: 'highest priority leads');
    });

    test('an empty directory matches nothing', () {
      expect(registry.detect(listing()), isEmpty);
      expect(registry.isProjectRoot(listing()), isFalse);
    });

    test('a directory holding only source files is not a project root', () {
      expect(
        registry.isProjectRoot(listing(files: {'main.rs', 'README.md'})),
        isFalse,
      );
    });
  });

  group('clean command resolution', () {
    test('prefers the gradle wrapper over a global gradle', () {
      final withWrapper = listing(files: {'build.gradle', 'gradlew'});
      expect(
        gradleFor(registry, withWrapper),
        const CleanCommand('./gradlew', ['clean']),
      );
      expect(
        gradleFor(registry, listing(files: {'build.gradle'})),
        const CleanCommand('gradle', ['clean']),
      );
    });

    test('prefers the maven wrapper over a global mvn', () {
      expect(
        registry
            .byId(StackId.maven)!
            .commandFor(listing(files: {'pom.xml', 'mvnw'})),
        const CleanCommand('./mvnw', ['clean']),
      );
    });

    test('picks the node package manager named by the lockfile', () {
      final node = registry.byId(StackId.node)!;
      String managerFor(Set<String> files) =>
          node.commandFor(listing(files: files))!.executable;

      expect(managerFor({'package.json', 'pnpm-lock.yaml'}), 'pnpm');
      expect(managerFor({'package.json', 'yarn.lock'}), 'yarn');
      expect(managerFor({'package.json', 'bun.lockb'}), 'bun');
      expect(managerFor({'package.json', 'package-lock.json'}), 'npm');
      expect(managerFor({'package.json'}), 'npm',
          reason: 'npm is the ecosystem default when no lockfile is present');
    });

    test('python offers a clean only when setuptools can provide one', () {
      final python = registry.byId(StackId.python)!;
      expect(
        python.commandFor(listing(files: {'setup.py'})),
        const CleanCommand('python3', ['setup.py', 'clean', '--all']),
      );
      expect(python.commandFor(listing(files: {'pyproject.toml'})), isNull);
    });

    test('stacks with a fixed command ignore directory contents', () {
      expect(
        registry.byId(StackId.rust)!.commandFor(listing()),
        const CleanCommand('cargo', ['clean']),
      );
    });
  });

  group('registry invariants', () {
    test('stack ids are unique', () {
      final ids = kStacks.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every StackId in the enum is registered', () {
      final registered = kStacks.map((s) => s.id).toSet();
      expect(
        StackId.values.toSet().difference(registered),
        isEmpty,
        reason: 'an enum value without a definition can never be detected',
      );
    });

    test('every stack has either a clean command or artifact paths', () {
      for (final stack in kStacks) {
        final hasCommand =
            stack.cleanCommand != null || stack.resolveCleanCommand != null;
        expect(
          hasCommand || stack.artifacts.isNotEmpty,
          isTrue,
          reason: '${stack.displayName} can neither clean nor delete anything',
        );
      }
    });

    test('no artifact path is absolute, a glob, or escapes the project root', () {
      for (final stack in kStacks) {
        for (final artifact in stack.artifacts) {
          expect(artifact.relative, isNot(startsWith('/')));
          expect(artifact.relative, isNot(contains('..')));
          expect(artifact.relative, isNot(contains('*')));
          expect(artifact.relative, isNot(contains('?')));
          expect(artifact.relative, isNotEmpty);
        }
      }
    });

    test('dependency directories are never marked as plain build output', () {
      // node_modules and venvs cost real time to restore; they must stay behind
      // the opt-in gate.
      const mustBeOptIn = {'node_modules', '.venv', 'venv', 'deps', 'vendor/bundle'};
      for (final stack in kStacks) {
        for (final artifact in stack.artifacts) {
          if (mustBeOptIn.contains(artifact.relative)) {
            expect(
              artifact.risk,
              CleanRisk.dependencies,
              reason: '${artifact.relative} in ${stack.displayName}',
            );
          }
        }
      }
    });

    test('every stack declares a display name and at least one marker', () {
      for (final stack in kStacks) {
        expect(stack.displayName, isNotEmpty);
        expect(stack.markers, isNotEmpty, reason: '${stack.id} is undetectable');
      }
    });
  });
}

CleanCommand? gradleFor(StackRegistry registry, DirListing listing) =>
    registry.byId(StackId.gradle)!.commandFor(listing);
