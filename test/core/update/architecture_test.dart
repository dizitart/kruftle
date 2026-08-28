// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/update/updater.dart';
import 'package:kruftle/src/core/update/version.dart';

Map<String, Object?> asset(String name) => {
  'name': name,
  'browser_download_url': 'https://example.invalid/$name',
  'size': 1024,
};

Updater on({
  required HostPlatform platform,
  required List<String> suffixes,
  required String architecture,
}) => Updater(
  currentVersion: const Version(0, 1, 0),
  target: InstallTarget(platform: platform, assetSuffixes: suffixes),
  architecture: architecture,
);

String? pick(Updater updater, List<String> names) {
  final chosen = updater.selectAsset([for (final n in names) asset(n)]);
  return chosen.isEmpty ? null : chosen['name'] as String;
}

void main() {
  group('the running architecture is recognised', () {
    test('reports something an asset name could carry', () {
      expect(
        Updater.currentArchitecture(),
        isIn(const ['arm64', 'arm', 'ia32', 'riscv64', 'x64']),
      );
    });
  });

  group('Windows', () {
    // A Program Files install, which can only be updated by its installer.
    final arm = on(
      platform: HostPlatform.windows,
      suffixes: const ['.exe'],
      architecture: 'arm64',
    );
    final x64 = on(
      platform: HostPlatform.windows,
      suffixes: const ['.exe'],
      architecture: 'x64',
    );

    const both = [
      'Kruftle-0.2.0-windows-x64.exe',
      'Kruftle-0.2.0-windows-arm64.exe',
      'checksums.txt',
    ];

    test('each processor takes its own installer', () {
      expect(pick(arm, both), 'Kruftle-0.2.0-windows-arm64.exe');
      expect(pick(x64, both), 'Kruftle-0.2.0-windows-x64.exe');
    });

    test('an arm machine is offered nothing when only x64 was published', () {
      // Worse than nothing would be offering it the x64 build: it looks like
      // it worked right up until it does not run.
      expect(pick(arm, const ['Kruftle-0.2.0-windows-x64.exe']), isNull);
    });

    test('an x64 machine is offered nothing when only arm64 was published', () {
      expect(pick(x64, const ['Kruftle-0.2.0-windows-arm64.exe']), isNull);
    });

    test('an unlabelled installer is taken by either processor', () {
      // Which is what a release built before the split looks like.
      const legacy = ['Kruftle-0.1.0-setup.exe'];
      expect(pick(arm, legacy), 'Kruftle-0.1.0-setup.exe');
      expect(pick(x64, legacy), 'Kruftle-0.1.0-setup.exe');
    });

    test('amd64 counts as x64', () {
      expect(
        pick(x64, const ['Kruftle-0.2.0-windows-amd64.exe']),
        'Kruftle-0.2.0-windows-amd64.exe',
      );
    });

    test('a .dmg or .AppImage is never offered to Windows', () {
      expect(
        pick(x64, const [
          'Kruftle-0.2.0-macos.dmg',
          'Kruftle-0.2.0-linux-x86_64.AppImage',
        ]),
        isNull,
      );
    });
  });

  group('macOS', () {
    final arm = on(
      platform: HostPlatform.macOS,
      suffixes: const ['.dmg'],
      architecture: 'arm64',
    );
    final intel = on(
      platform: HostPlatform.macOS,
      suffixes: const ['.dmg'],
      architecture: 'x64',
    );

    test('the universal .dmg is taken by both processors', () {
      // The macOS bundle carries both architectures, so its name says nothing
      // about a processor and both machines must accept it.
      const release = ['Kruftle-0.2.0-macos.dmg', 'checksums.txt'];
      expect(pick(arm, release), 'Kruftle-0.2.0-macos.dmg');
      expect(pick(intel, release), 'Kruftle-0.2.0-macos.dmg');
    });

    test('a per-processor .dmg would still be matched correctly', () {
      const release = [
        'Kruftle-0.2.0-macos-arm64.dmg',
        'Kruftle-0.2.0-macos-x86_64.dmg',
      ];
      expect(pick(arm, release), 'Kruftle-0.2.0-macos-arm64.dmg');
      expect(pick(intel, release), 'Kruftle-0.2.0-macos-x86_64.dmg');
    });
  });

  group('Linux', () {
    // A running AppImage, which replaces its own file.
    final arm = on(
      platform: HostPlatform.linux,
      suffixes: const ['.AppImage'],
      architecture: 'arm64',
    );
    final x64 = on(
      platform: HostPlatform.linux,
      suffixes: const ['.AppImage'],
      architecture: 'x64',
    );

    const both = [
      'Kruftle-0.2.0-x86_64.AppImage',
      'Kruftle-0.2.0-aarch64.AppImage',
      'Kruftle-0.2.0-amd64.deb',
      'Kruftle-0.2.0-arm64.deb',
      'Kruftle-0.2.0-linux-x86_64.tar.gz',
      'Kruftle-0.2.0-linux-aarch64.tar.gz',
      'checksums.txt',
    ];

    test('aarch64 counts as arm64', () {
      expect(pick(arm, both), 'Kruftle-0.2.0-aarch64.AppImage');
    });

    test('x86_64 counts as x64', () {
      expect(pick(x64, both), 'Kruftle-0.2.0-x86_64.AppImage');
    });

    test('an install asks only for the shape it can actually apply', () {
      // Which shape that is comes from `InstallTarget`, not from the release:
      // a .deb under /usr needs a package manager and root, and a tarball
      // install replaces its own directory. Handing either the other one is
      // how a Debian install ended up downloading an AppImage it had nowhere
      // to put.
      final deb = on(
        platform: HostPlatform.linux,
        suffixes: const ['.deb'],
        architecture: 'x64',
      );
      expect(pick(deb, both), 'Kruftle-0.2.0-amd64.deb');

      final tarball = on(
        platform: HostPlatform.linux,
        suffixes: const ['.tar.gz'],
        architecture: 'arm64',
      );
      expect(pick(tarball, both), 'Kruftle-0.2.0-linux-aarch64.tar.gz');
    });

    test('an arm machine is offered nothing when only x86_64 was built', () {
      expect(pick(arm, const ['Kruftle-0.2.0-x86_64.AppImage']), isNull);
    });
  });

  test('an empty release offers nothing rather than throwing', () {
    final updater = on(
      platform: HostPlatform.macOS,
      suffixes: const ['.dmg'],
      architecture: 'arm64',
    );
    expect(pick(updater, const []), isNull);
    expect(pick(updater, const ['checksums.txt']), isNull);
  });
}
