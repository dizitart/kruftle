// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/update/install_target.dart';
import 'package:path/path.dart' as p;

/// Which asset a copy of Kruftle asks for is decided entirely here, so this is
/// where a Debian install being offered an AppImage — or a Program Files
/// install being offered an archive it cannot unpack — would be caught.
void main() {
  InstallTarget detect({
    required bool windows,
    required bool macOS,
    required String executable,
    String? appImage,
    bool writable = true,
    bool packaged = false,
  }) => InstallTarget.detect(
    windows: windows,
    macOS: macOS,
    executable: executable,
    appImage: appImage,
    canWrite: (_) => writable,
    packaged: packaged,
  );

  group('macOS', () {
    test('a bundle is replaced from the archive, not the disk image', () {
      // The `.dmg` still works and is still offered, but only for a release
      // published before the archive existed. Mounting a disk image at every
      // update is the thing this feature is for getting rid of.
      final target = detect(
        windows: false,
        macOS: true,
        executable: '/Applications/Kruftle.app/Contents/MacOS/Kruftle',
      );
      expect(target.platform, HostPlatform.macOS);
      expect(target.assetSuffixes, ['.zip', '.dmg']);
      expect(target.swapDirectory, '/Applications/Kruftle.app');
      expect(target.isSelfReplacing, isTrue);
    });

    test('a bare binary has no bundle to replace', () {
      // `flutter run`, or the binary invoked directly. The download is still
      // offered; it is revealed rather than swapped in.
      final target = detect(
        windows: false,
        macOS: true,
        executable: '/tmp/build/kruftle',
      );
      expect(target.assetSuffixes, ['.zip', '.dmg']);
      expect(target.swapDirectory, isNull);
      expect(target.isSelfReplacing, isFalse);
    });
  });

  group('Windows', () {
    const perUser = r'C:\Users\me\AppData\Local\Programs\Kruftle\kruftle.exe';

    test('a per-user install replaces itself from the archive', () {
      final target = detect(windows: true, macOS: false, executable: perUser);
      expect(target.platform, HostPlatform.windows);
      expect(target.assetSuffixes.first, '.zip');
      expect(target.swapDirectory, endsWith('Kruftle'));
      expect(target.isSelfReplacing, isTrue);
    });

    test('it still accepts an installer from a release with no archive', () {
      final target = detect(windows: true, macOS: false, executable: perUser);
      expect(target.assetSuffixes, ['.zip', '.exe']);
    });

    test('a machine-wide install asks for the installer and only that', () {
      // C:\Program Files is not writable by the person running Kruftle, so the
      // swap would fail half-way. Offering an archive here would be a download
      // that quietly does nothing.
      final target = detect(
        windows: true,
        macOS: false,
        executable: r'C:\Program Files\Kruftle\kruftle.exe',
        writable: false,
      );
      expect(target.assetSuffixes, ['.exe']);
      expect(target.isSelfReplacing, isFalse);
    });

    test('an MSIX install asks for nothing, however writable it is', () {
      // A Store install must never fall through to the Inno Setup `.exe` —
      // that would run a second, unpackaged Kruftle install alongside the
      // Store's own copy. `selectAsset` matching nothing is what makes every
      // newer release "blocked" instead, the same way a `.deb` under `/usr`
      // is: an honest "no build for you", not a broken self-update.
      final target = detect(
        windows: true,
        macOS: false,
        executable: perUser,
        packaged: true,
      );
      expect(target.assetSuffixes, isEmpty);
      expect(target.swapDirectory, isNull);
      expect(target.isSelfReplacing, isFalse);
    });
  });

  group('Linux', () {
    test('a running AppImage replaces its own file', () {
      final target = detect(
        windows: false,
        macOS: false,
        executable: '/tmp/.mount_Kruftabc/usr/lib/kruftle/kruftle',
        appImage: '/home/me/Applications/Kruftle.AppImage',
      );
      expect(target.platform, HostPlatform.linux);
      expect(target.assetSuffixes, ['.AppImage']);
      expect(target.appImage, '/home/me/Applications/Kruftle.AppImage');
      expect(target.swapDirectory, isNull);
      expect(target.isSelfReplacing, isTrue);
    });

    test('a tarball install under a home directory replaces its own', () {
      final target = detect(
        windows: false,
        macOS: false,
        executable: '/home/me/Applications/kruftle/kruftle',
      );
      expect(target.assetSuffixes, ['.tar.gz']);
      expect(target.swapDirectory, '/home/me/Applications/kruftle');
      expect(target.isSelfReplacing, isTrue);
    });

    test('a .deb install asks for a .deb, not an AppImage', () {
      // The reported bug: a copy installed from a .deb lives under /usr, where
      // it cannot write, and was being handed an AppImage it had nowhere to
      // put. The only thing that can update it is another .deb.
      final target = detect(
        windows: false,
        macOS: false,
        executable: '/usr/lib/kruftle/kruftle',
        writable: false,
      );
      expect(target.assetSuffixes, ['.deb']);
      expect(target.isSelfReplacing, isFalse);
    });

    test('the AppImage wins even when the directory looks writable', () {
      // An AppImage unpacks itself into a writable temp mount, so the
      // directory test would say yes and be wrong about what to replace.
      final target = detect(
        windows: false,
        macOS: false,
        executable: '/tmp/.mount_Kruftabc/usr/lib/kruftle/kruftle',
        appImage: '/home/me/Kruftle.AppImage',
      );
      expect(target.assetSuffixes, ['.AppImage']);
    });

    test('an empty APPIMAGE is not an AppImage', () {
      final target = detect(
        windows: false,
        macOS: false,
        executable: '/home/me/kruftle/kruftle',
        appImage: '',
      );
      expect(target.assetSuffixes, ['.tar.gz']);
    });
  });

  group('canWriteInto', () {
    late Directory work;
    setUp(() => work = Directory.systemTemp.createTempSync('kruftle-probe'));
    tearDown(() => work.deleteSync(recursive: true));

    test('says yes for a directory this user owns, and leaves nothing', () {
      expect(InstallTarget.canWriteInto(work.path), isTrue);
      expect(
        work.listSync(),
        isEmpty,
        reason: 'the probe cleans up after itself',
      );
    });

    test('says no for a directory that is not there', () {
      expect(
        InstallTarget.canWriteInto(p.join(work.path, 'nope', 'still-nope')),
        isFalse,
      );
    });

    test('says no for a directory this user cannot write', () {
      final locked = Directory(p.join(work.path, 'locked'))..createSync();
      Process.runSync('chmod', ['500', locked.path]);
      addTearDown(() => Process.runSync('chmod', ['700', locked.path]));
      expect(InstallTarget.canWriteInto(locked.path), isFalse);
    });
  }, skip: Platform.isWindows);
}
