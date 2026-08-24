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
  });

  /// Everything a v9.9.9 release would publish.
  const published = [
    'Kruftle-$_version-macos.dmg',
    'Kruftle-$_version-windows-x64-setup.exe',
    'Kruftle-$_version-windows-arm64-setup.exe',
    'Kruftle-$_version-x86_64.AppImage',
    'Kruftle-$_version-aarch64.AppImage',
    'Kruftle-$_version-amd64.deb',
    'Kruftle-$_version-arm64.deb',
    'checksums.txt',
  ];

  Map<String, Object?> asset(String name) => {
    'name': name,
    'browser_download_url': 'https://example.invalid/$name',
    'size': 1,
  };

  String? chosenBy({
    required bool windows,
    required bool macOS,
    required String architecture,
  }) {
    final chosen = Updater(
      currentVersion: const Version(0, 1, 0),
      windows: windows,
      macOS: macOS,
      architecture: architecture,
    ).selectAsset([for (final name in published) asset(name)]);
    return chosen.isEmpty ? null : chosen['name'] as String;
  }

  test('every supported platform and processor finds its own asset', () {
    expect(
      chosenBy(windows: false, macOS: true, architecture: 'arm64'),
      'Kruftle-$_version-macos.dmg',
    );
    expect(
      chosenBy(windows: false, macOS: true, architecture: 'x64'),
      'Kruftle-$_version-macos.dmg',
    );
    expect(
      chosenBy(windows: true, macOS: false, architecture: 'x64'),
      'Kruftle-$_version-windows-x64-setup.exe',
    );
    expect(
      chosenBy(windows: true, macOS: false, architecture: 'arm64'),
      'Kruftle-$_version-windows-arm64-setup.exe',
    );
    expect(
      chosenBy(windows: false, macOS: false, architecture: 'x64'),
      'Kruftle-$_version-x86_64.AppImage',
    );
    expect(
      chosenBy(windows: false, macOS: false, architecture: 'arm64'),
      'Kruftle-$_version-aarch64.AppImage',
    );
  });

  test('no platform is left without an asset', () {
    for (final (windows, macOS) in const [
      (true, false),
      (false, true),
      (false, false),
    ]) {
      for (final architecture in const ['x64', 'arm64']) {
        expect(
          chosenBy(windows: windows, macOS: macOS, architecture: architecture),
          isNotNull,
          reason: 'windows=$windows macOS=$macOS arch=$architecture',
        );
      }
    }
  });

  test('the release workflow publishes a checksum file', () {
    // The updater refuses any asset that is not listed in it, so a release
    // without one installs nothing at all.
    expect(
      _read('.github/workflows/release.yml'),
      contains('sha256sum * > checksums.txt'),
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
