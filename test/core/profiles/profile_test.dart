// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/models/stack.dart';
import 'package:kruftle/src/core/profiles/profile.dart';

DirListing listing({
  Set<String> files = const {},
  Set<String> dirs = const {},
}) => DirListing(files: files, directories: dirs);

CleanupProfile unreal({
  String name = 'Unreal Engine',
  List<String>? markers,
  String? command = 'make clean',
  List<String> artifactDirs = const ['Binaries', 'Intermediate'],
  List<String> dependencyDirs = const [],
  List<String> cacheDirs = const [],
  List<String> excludeGlobs = const [],
  bool enabled = true,
}) => CleanupProfile(
  name: name,
  markers: markers ?? const ['*.uproject'],
  command: command,
  artifactDirs: artifactDirs,
  dependencyDirs: dependencyDirs,
  cacheDirs: cacheDirs,
  excludeGlobs: excludeGlobs,
  enabled: enabled,
);

void main() {
  group('validation', () {
    test('a complete profile is accepted', () {
      expect(unreal().validate(), isEmpty);
      expect(unreal().isValid, isTrue);
    });

    test('a nameless profile is rejected', () {
      expect(
        unreal(name: '   ').validate(),
        contains(const ProfileError(ProfileProblem.noName)),
      );
    });

    test('a profile with no markers is rejected', () {
      // It would match every directory on the disk, and then offer to delete
      // a directory called "Binaries" in every one of them.
      expect(
        unreal(markers: const []).validate(),
        contains(const ProfileError(ProfileProblem.noMarkers)),
      );
      expect(
        unreal(markers: const ['  ']).validate(),
        contains(const ProfileError(ProfileProblem.noMarkers)),
      );
    });

    test('a profile that would do nothing is rejected', () {
      expect(
        unreal(command: null, artifactDirs: const []).validate(),
        contains(const ProfileError(ProfileProblem.nothingToDo)),
      );
    });

    test('a command alone is enough', () {
      expect(unreal(artifactDirs: const []).validate(), isEmpty);
    });

    test('directories alone are enough', () {
      expect(unreal(command: null).validate(), isEmpty);
    });

    test('a duplicate name is rejected', () {
      expect(
        unreal().validate(existingNames: {'Unreal Engine'}),
        contains(
          const ProfileError(ProfileProblem.duplicateName, 'Unreal Engine'),
        ),
      );
      expect(unreal().validate(existingNames: {'Something else'}), isEmpty);
    });
  });

  group('safety rails apply to custom profiles', () {
    /// Rail 4 says raw deletion is allow-listed by exact directory name:
    /// never a glob, never a user-supplied pattern, never a file. A profile is
    /// the one place a user could try to supply one, so each of these is
    /// rejected before the profile can ever reach a scan.
    for (final escape in const [
      '../../etc',
      '..',
      'build/../../..',
      'a/../../b',
      r'..\\windows',
    ]) {
      test('rejects "$escape", which could reach outside the project', () {
        final errors = unreal(artifactDirs: [escape]).validate();
        expect(
          errors.map((e) => e.problem),
          contains(ProfileProblem.escapingPath),
        );
        expect(
          unreal(artifactDirs: [escape]).toStackDefinition(),
          isNull,
          reason: 'an invalid profile must never become a stack',
        );
      });
    }

    for (final absolute in const ['/etc', '/', r'C:\Windows', '/Users/me']) {
      test('rejects the absolute path "$absolute"', () {
        expect(
          unreal(artifactDirs: [absolute]).validate().map((e) => e.problem),
          contains(ProfileProblem.absolutePath),
        );
      });
    }

    for (final glob in const ['*', 'build/*', '**', 'out?', 'src/*.o']) {
      test('rejects the pattern "$glob" — rail 4 wants exact names', () {
        expect(
          unreal(artifactDirs: [glob]).validate().map((e) => e.problem),
          contains(ProfileProblem.escapingPath),
        );
      });
    }

    test('rejects a path that starts at the home directory', () {
      expect(
        unreal(
          artifactDirs: const ['~/Library'],
        ).validate().map((e) => e.problem),
        contains(ProfileProblem.escapingPath),
      );
    });

    test('an escaping dependency or cache directory is caught too', () {
      // Every list is an allow-list, so every list is checked. Only checking
      // the first would be exactly the kind of gap this test exists to close.
      expect(
        unreal(
          dependencyDirs: const ['../vendor'],
        ).validate().map((e) => e.problem),
        contains(ProfileProblem.escapingPath),
      );
      expect(
        unreal(cacheDirs: const ['/tmp']).validate().map((e) => e.problem),
        contains(ProfileProblem.absolutePath),
      );
    });

    test('an invalid profile is dropped from the registry entirely', () {
      final set = ProfileSet([
        unreal(),
        unreal(name: 'Bad', artifactDirs: const ['../..']),
      ]);
      expect(set.stacks.map((s) => s.displayName), ['Unreal Engine']);
    });

    test('a disabled profile takes no part in a scan', () {
      final set = ProfileSet([unreal(enabled: false)]);
      expect(set.stacks, isEmpty);
      expect(set.excludeGlobs, isEmpty);
    });

    test('deletion still needs the per-run opt-in (rail 7)', () {
      // A custom profile's directories carry a `CleanRisk` exactly like a
      // built-in stack's, which is what puts them behind the confirmation
      // gate. A profile cannot mark its own deletions as needing no consent.
      final stack = unreal(
        artifactDirs: const ['Binaries'],
        dependencyDirs: const ['ThirdParty'],
        cacheDirs: const ['DerivedDataCache'],
      ).toStackDefinition()!;

      expect(
        stack.artifactsAtRisk(const {}),
        isEmpty,
        reason: 'nothing is at risk when the user has opted into nothing',
      );
      expect(
        stack
            .artifactsAtRisk(const {CleanRisk.buildOutput})
            .map((a) => a.relative),
        ['Binaries'],
      );
      expect(
        stack
            .artifactsAtRisk(const {CleanRisk.dependencies})
            .map((a) => a.relative),
        ['ThirdParty'],
      );
      expect(
        stack.artifactsAtRisk(const {CleanRisk.cache}).map((a) => a.relative),
        ['DerivedDataCache'],
      );
    });
  });

  group('conversion to a stack', () {
    test('runs the command with the exact argv the user typed', () {
      final stack = unreal(command: 'make  -j8   clean').toStackDefinition()!;

      expect(stack.cleanCommand, const CleanCommand('make', ['-j8', 'clean']));
      expect(stack.tool?.binary, 'make');
    });

    test('no command means no tool to probe for', () {
      final stack = unreal(command: null).toStackDefinition()!;
      expect(stack.cleanCommand, isNull);
      expect(stack.tool, isNull);
    });

    test('a blank command is the same as none', () {
      final stack = unreal(command: '   ').toStackDefinition()!;
      expect(stack.cleanCommand, isNull);
      expect(stack.tool, isNull);
    });

    test('matches a marker by exact name', () {
      final stack = unreal(markers: const ['Makefile']).toStackDefinition()!;
      expect(stack.detect(listing(files: {'Makefile'})), isTrue);
      expect(stack.detect(listing(files: {'Cargo.toml'})), isFalse);
    });

    test('matches a *.ext marker by extension', () {
      final stack = unreal().toStackDefinition()!;
      expect(stack.detect(listing(files: {'MyGame.uproject'})), isTrue);
      expect(stack.detect(listing(files: {'uproject'})), isFalse);
      expect(stack.detect(listing(files: {'notes.txt'})), isFalse);
    });

    test('matches a marker directory as well as a marker file', () {
      final stack = unreal(markers: const ['Assets']).toStackDefinition()!;
      expect(stack.detect(listing(dirs: {'Assets'})), isTrue);
    });

    test('sorts below every built-in stack', () {
      // A directory that is genuinely a Gradle project and also matches
      // someone's profile should still read as Gradle first.
      expect(unreal().toStackDefinition()!.priority, lessThan(0));
    });

    test('each directory list keeps its own risk', () {
      final stack = unreal(
        artifactDirs: const ['Binaries'],
        dependencyDirs: const ['ThirdParty'],
        cacheDirs: const ['DDC'],
      ).toStackDefinition()!;

      expect(
        {for (final a in stack.artifacts) a.relative: a.risk},
        {
          'Binaries': CleanRisk.buildOutput,
          'ThirdParty': CleanRisk.dependencies,
          'DDC': CleanRisk.cache,
        },
      );
    });
  });

  group('ProfileSet', () {
    test('round-trips through JSON', () {
      final original = ProfileSet([
        unreal(),
        unreal(name: 'Godot', markers: const ['project.godot'], command: null),
      ]);

      final restored = ProfileSet.decode(original.encode())!;

      expect(restored.profiles, hasLength(2));
      expect(restored.profiles.first.name, 'Unreal Engine');
      expect(restored.profiles.first.command, 'make clean');
      expect(restored.profiles.last.markers, ['project.godot']);
      expect(restored.profiles.last.command, isNull);
    });

    test('refuses JSON that is not a Kruftle export', () {
      // So an import can say "that is the wrong file" instead of quietly
      // importing nothing and looking broken.
      expect(ProfileSet.decode('{"profiles": []}'), isNull);
      expect(ProfileSet.decode('[]'), isNull);
      expect(ProfileSet.decode('not json'), isNull);
      expect(ProfileSet.decode(''), isNull);
      expect(ProfileSet.decode(null), isNull);
    });

    test('corrupt storage yields an empty set rather than a crash', () {
      expect(ProfileSet.decodeOrEmpty('garbage').profiles, isEmpty);
      expect(ProfileSet.decodeOrEmpty(null).profiles, isEmpty);
    });

    test('adding a profile with an existing name replaces it', () {
      final set = ProfileSet([
        unreal(),
      ]).withProfile(unreal(command: 'make distclean'));

      expect(set.profiles, hasLength(1));
      expect(set.profiles.single.command, 'make distclean');
    });

    test('adding a new name appends', () {
      final set = ProfileSet([unreal()]).withProfile(unreal(name: 'Godot'));
      expect(set.profiles.map((p) => p.name), ['Unreal Engine', 'Godot']);
    });

    test('removing by name', () {
      final set = ProfileSet([unreal(), unreal(name: 'Godot')]);
      expect(set.without('Godot').profiles.map((p) => p.name), [
        'Unreal Engine',
      ]);
      expect(set.without('Nothing').profiles, hasLength(2));
    });

    test('exclude globs are pooled across every enabled profile', () {
      final set = ProfileSet([
        unreal(excludeGlobs: const ['**/vendor/**']),
        unreal(name: 'Godot', excludeGlobs: const ['**/.import/**']),
        unreal(
          name: 'Off',
          excludeGlobs: const ['**/never/**'],
          enabled: false,
        ),
      ]);

      expect(set.excludeGlobs, ['**/vendor/**', '**/.import/**']);
    });
  });
}
