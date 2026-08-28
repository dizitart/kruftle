// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/update/install_target.dart';
import 'package:kruftle/src/core/update/swap_scripts.dart';
import 'package:path/path.dart' as p;

/// Drives the real script against a real disk image and a real process, because
/// the whole point of it is what the operating system does — a mock would prove
/// only that the string is unchanged.
void main() {
  group('bundlePath', () {
    test('finds the .app a bundled executable runs out of', () {
      expect(
        InstallTarget.bundlePath(
          '/Applications/Kruftle.app/Contents/MacOS/Kruftle',
        ),
        '/Applications/Kruftle.app',
      );
    });

    test('reports nothing for a binary that is not in a bundle', () {
      expect(InstallTarget.bundlePath('/tmp/build/kruftle'), isNull);
      expect(InstallTarget.bundlePath('/usr/local/bin/kruftle'), isNull);
    });
  });

  group('macSwapScript', () {
    late Directory work;

    setUp(() => work = Directory.systemTemp.createTempSync('kruftle-swap'));
    tearDown(() => work.deleteSync(recursive: true));

    /// A `.app` is just a directory, which is all the swap cares about.
    String writeBundle(String directory, String marker) {
      final bundle = p.join(directory, 'Kruftle.app');
      final binary = File(p.join(bundle, 'Contents', 'MacOS', 'Kruftle'))
        ..createSync(recursive: true)
        ..writeAsStringSync(marker);
      return binary.path;
    }

    /// Runs the script with `open` stubbed out, so a test never launches
    /// anything, and returns what it asked `open` to launch.
    Future<String> runSwap(String dmg, String app, int pid) async {
      final stub = Directory(p.join(work.path, 'bin'))..createSync();
      final log = p.join(work.path, 'opened');
      final open = File(p.join(stub.path, 'open'))
        ..writeAsStringSync('#!/bin/sh\necho "\$1" >> "$log"\n');
      await Process.run('chmod', ['+x', open.path]);

      await Process.run(
        '/bin/sh',
        ['-c', macSwapScript, 'kruftle-update', dmg, app, '$pid'],
        environment: {'PATH': '${stub.path}:/bin:/usr/bin:/usr/sbin'},
      );

      final opened = File(log);
      return opened.existsSync() ? opened.readAsStringSync().trim() : '';
    }

    test('replaces the bundle once the old process has gone', () async {
      // The new Kruftle, packaged exactly as the release workflow packages it.
      final staging = Directory(p.join(work.path, 'staging'))..createSync();
      writeBundle(staging.path, 'new');
      final dmg = p.join(work.path, 'Kruftle-9.9.9-macos.dmg');
      final packed = await Process.run('hdiutil', [
        'create',
        '-volname',
        'Kruftle',
        '-srcfolder',
        staging.path,
        '-ov',
        '-format',
        'UDZO',
        dmg,
      ]);
      expect(packed.exitCode, 0, reason: packed.stderr.toString());

      // The old one, installed, with a process still holding it.
      final installed = Directory(p.join(work.path, 'Applications'))
        ..createSync();
      final binary = writeBundle(installed.path, 'old');
      final app = InstallTarget.bundlePath(binary)!;
      final holder = await Process.start('/bin/sleep', ['30']);

      final swap = runSwap(dmg, app, holder.pid);
      // Nothing may happen while it is running: that is the bug this fixes.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(File(binary).readAsStringSync(), 'old');

      holder.kill();
      await holder.exitCode;

      expect(await swap, app, reason: 'the new Kruftle is what gets started');
      expect(File(binary).readAsStringSync(), 'new');
      expect(Directory('$app.old').existsSync(), isFalse);
      expect(Directory('$app.new').existsSync(), isFalse);
    });

    test(
      'leaves the installed bundle alone when the image is unusable',
      () async {
        final dmg = p.join(work.path, 'broken.dmg');
        File(dmg).writeAsStringSync('not a disk image');

        final installed = Directory(p.join(work.path, 'Applications'))
          ..createSync();
        final binary = writeBundle(installed.path, 'old');

        // Falls back to showing the disk image, exactly as it used to.
        expect(
          await runSwap(dmg, InstallTarget.bundlePath(binary)!, 999999),
          dmg,
        );
        expect(File(binary).readAsStringSync(), 'old');
      },
    );
  }, skip: !Platform.isMacOS);
}
