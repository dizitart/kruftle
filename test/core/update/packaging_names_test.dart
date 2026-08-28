// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/update/updater.dart';
import 'package:kruftle/src/core/update/version.dart';

/// The names the release workflow and packaging scripts actually produce, for
/// version 9.9.9.
///
/// This is the seam where a release goes quietly wrong: the packaging changes
/// an asset's name, the updater stops recognising it, and nobody notices until
/// a user reports that updates stopped working. The names below are read out
/// of the scripts rather than typed here, so they cannot drift.
const _version = '9.9.9';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('the packaging scripts still produce the names they used to', () {
    // If these substrings disappear, the derived names below are wrong and
    // every expectation in this file is testing fiction.
    final linux = _read('packaging/linux/build-packages.sh');
    expect(linux, contains(r'Kruftle-$VERSION-$APPIMAGE_ARCH.AppImage'));
    expect(linux, contains(r'Kruftle-$VERSION-$DEB_ARCH.deb'));
    expect(linux, contains(r'Kruftle-$VERSION-linux-$APPIMAGE_ARCH.tar.gz'));
    expect(linux, contains('APPIMAGE_ARCH=x86_64'));
    expect(linux, contains('APPIMAGE_ARCH=aarch64'));
    expect(linux, contains('DEB_ARCH=amd64'));
    expect(linux, contains('DEB_ARCH=arm64'));

    final inno = _read('packaging/windows/kruftle.iss');
    expect(
      inno,
      contains(
        'OutputBaseFilename=Kruftle-{#AppVersion}-windows-'
        '{#TargetArch}-setup',
      ),
    );

    final release = _read('.github/workflows/release.yml');
    expect(release, contains(r'Kruftle-$VERSION-macos.dmg'));
    expect(
      release,
      contains(r'Kruftle-$VERSION-macos.zip'),
      reason: 'the archive a macOS update applies without a disk image',
    );
    expect(
      release,
      contains('ditto -c -k'),
      reason: 'zip would not preserve the bundle',
    );
    expect(
      release,
      contains(r'Kruftle-$env:VERSION-windows-$env:ARCH.zip'),
      reason: 'the archive the updater applies on Windows',
    );
  });

  /// Everything a v9.9.9 release would publish.
  const published = [
    'Kruftle-$_version-macos.dmg',
    'Kruftle-$_version-macos.zip',
    'Kruftle-$_version-windows-x64-setup.exe',
    'Kruftle-$_version-windows-arm64-setup.exe',
    'Kruftle-$_version-windows-x64.zip',
    'Kruftle-$_version-windows-arm64.zip',
    'Kruftle-$_version-x86_64.AppImage',
    'Kruftle-$_version-aarch64.AppImage',
    'Kruftle-$_version-amd64.deb',
    'Kruftle-$_version-arm64.deb',
    'Kruftle-$_version-linux-x86_64.tar.gz',
    'Kruftle-$_version-linux-aarch64.tar.gz',
    'checksums.txt',
  ];

  Map<String, Object?> asset(String name) => {
    'name': name,
    'browser_download_url': 'https://example.invalid/$name',
    'size': 1,
  };

  String? chosenBy(
    InstallTarget target,
    String architecture, [
    List<String>? from,
  ]) {
    final chosen = Updater(
      currentVersion: const Version(0, 1, 0),
      target: target,
      architecture: architecture,
    ).selectAsset([for (final name in from ?? published) asset(name)]);
    return chosen.isEmpty ? null : chosen['name'] as String;
  }

  /// Every shape a released Kruftle is actually installed in, and what
  /// `InstallTarget.detect` decides for it.
  final shapes = <String, InstallTarget>{
    'macOS .app': InstallTarget.detect(
      macOS: true,
      windows: false,
      executable: '/Applications/Kruftle.app/Contents/MacOS/Kruftle',
      canWrite: (_) => true,
    ),
    'Windows per-user': InstallTarget.detect(
      macOS: false,
      windows: true,
      executable: r'C:\Users\me\AppData\Local\Programs\Kruftle\kruftle.exe',
      canWrite: (_) => true,
    ),
    'Windows Program Files': InstallTarget.detect(
      macOS: false,
      windows: true,
      executable: r'C:\Program Files\Kruftle\kruftle.exe',
      canWrite: (_) => false,
    ),
    'Linux AppImage': InstallTarget.detect(
      macOS: false,
      windows: false,
      executable: '/tmp/.mount_Kruftxyz/usr/lib/kruftle/kruftle',
      appImage: '/home/me/Applications/Kruftle.AppImage',
      canWrite: (_) => true,
    ),
    'Linux tarball': InstallTarget.detect(
      macOS: false,
      windows: false,
      executable: '/home/me/kruftle/kruftle',
      canWrite: (_) => true,
    ),
    'Linux .deb': InstallTarget.detect(
      macOS: false,
      windows: false,
      executable: '/usr/lib/kruftle/kruftle',
      canWrite: (_) => false,
    ),
  };

  test('every install shape and processor finds its own asset', () {
    const expected = {
      // The archive, not the disk image: an update should not look like an
      // installation.
      ('macOS .app', 'x64'): 'Kruftle-$_version-macos.zip',
      ('macOS .app', 'arm64'): 'Kruftle-$_version-macos.zip',
      // Per-user Windows and a Linux tarball or AppImage replace themselves,
      // so they take the plain archive and never run an installer.
      ('Windows per-user', 'x64'): 'Kruftle-$_version-windows-x64.zip',
      ('Windows per-user', 'arm64'): 'Kruftle-$_version-windows-arm64.zip',
      ('Linux tarball', 'x64'): 'Kruftle-$_version-linux-x86_64.tar.gz',
      ('Linux tarball', 'arm64'): 'Kruftle-$_version-linux-aarch64.tar.gz',
      ('Linux AppImage', 'x64'): 'Kruftle-$_version-x86_64.AppImage',
      ('Linux AppImage', 'arm64'): 'Kruftle-$_version-aarch64.AppImage',
      // These two live where this user cannot write, so the only thing that
      // can update them is their own packaging's installer. Offering a .deb
      // install an AppImage — which is what used to happen — gave it a file
      // it had nowhere to put.
      ('Windows Program Files', 'x64'):
          'Kruftle-$_version-windows-x64-setup.exe',
      ('Windows Program Files', 'arm64'):
          'Kruftle-$_version-windows-arm64-setup.exe',
      ('Linux .deb', 'x64'): 'Kruftle-$_version-amd64.deb',
      ('Linux .deb', 'arm64'): 'Kruftle-$_version-arm64.deb',
    };

    for (final MapEntry(key: (shape, architecture), value: name)
        in expected.entries) {
      expect(
        chosenBy(shapes[shape]!, architecture),
        name,
        reason: '$shape on $architecture',
      );
    }
  });

  test('no install shape is left without an asset', () {
    for (final MapEntry(key: shape, value: target) in shapes.entries) {
      for (final architecture in const ['x64', 'arm64']) {
        expect(
          chosenBy(target, architecture),
          isNotNull,
          reason: '$shape on $architecture',
        );
      }
    }
  });

  test('a Windows build never takes the macOS archive', () {
    // Both are `.zip`, and the macOS one names no processor because it is
    // universal — which is exactly the shape an unlabelled asset has, so
    // without a platform check a Windows build whose own archive was missing
    // from a release would take it and unpack a .app over Program Files.
    const noWindowsZip = [
      'Kruftle-$_version-macos.zip',
      'Kruftle-$_version-windows-x64-setup.exe',
      'checksums.txt',
    ];
    expect(
      chosenBy(shapes['Windows per-user']!, 'x64', noWindowsZip),
      'Kruftle-$_version-windows-x64-setup.exe',
    );
  });

  test('a release older than the archives still offers its installer', () {
    // Every release up to 0.2.3 carried only installers. A Windows copy that
    // prefers the .zip must still find the .exe, or updating from one of those
    // would offer nothing at all.
    const legacy = [
      'Kruftle-$_version-windows-x64-setup.exe',
      'Kruftle-$_version-windows-arm64-setup.exe',
      'checksums.txt',
    ];
    expect(
      chosenBy(shapes['Windows per-user']!, 'arm64', legacy),
      'Kruftle-$_version-windows-arm64-setup.exe',
    );

    // And macOS falls back to the disk image the same way.
    expect(
      chosenBy(shapes['macOS .app']!, 'arm64', const [
        'Kruftle-$_version-macos.dmg',
        'checksums.txt',
      ]),
      'Kruftle-$_version-macos.dmg',
    );
  });

  test('the release workflow publishes a checksum file', () {
    // The updater refuses any asset that is not listed in it, so a release
    // without one installs nothing at all.
    expect(
      _read('.github/workflows/release.yml'),
      contains('sha256sum * > checksums.txt'),
    );
  });

  test('the release workflow refuses a tag pubspec disagrees with', () {
    // `kAppVersion` is what the updater compares against. A build whose tag
    // says 0.3.0 while the constant still says 0.2.9 would ship an app that
    // offers itself its own release, forever.
    expect(
      _read('.github/workflows/release.yml'),
      contains('does not match pubspec.yaml'),
    );
  });

  test('both CI workflows build every architecture that is released', () {
    final release = _read('.github/workflows/release.yml');
    final ci = _read('.github/workflows/ci.yml');

    for (final runner in const [
      'windows-latest',
      'windows-11-arm',
      'ubuntu-22.04-arm',
    ]) {
      expect(release, contains(runner), reason: 'release misses $runner');
      expect(ci, contains(runner), reason: 'CI misses $runner');
    }
  });
}
