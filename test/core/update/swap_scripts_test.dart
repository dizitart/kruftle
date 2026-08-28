// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/update/swap_scripts.dart';
import 'package:path/path.dart' as p;

/// Drives the real swap helpers against real files and a real process.
///
/// The whole point of these scripts is what the operating system does when one
/// program replaces another underneath itself, and a mock proves only that a
/// string is unchanged. Each one is run exactly as `Updater` runs it, with the
/// same argument order.
///
/// `Kruftle` stands in as a small shell script that reports which copy it is,
/// which makes "did the swap happen" and "was the new one started" the same
/// question a user would ask.
void main() {
  late Directory work;

  setUp(() => work = Directory.systemTemp.createTempSync('kruftle-swap'));
  tearDown(() => work.deleteSync(recursive: true));

  String log() => p.join(work.path, 'launched');

  /// An executable that appends [marker] to the log when it is run.
  File writeKruftle(String path, String marker) {
    final file = File(path)..createSync(recursive: true);
    if (Platform.isWindows) {
      file.writeAsStringSync('@echo off\r\necho $marker>>"${log()}"\r\n');
    } else {
      file.writeAsStringSync('#!/bin/sh\necho "$marker" >> "${log()}"\n');
      Process.runSync('chmod', ['+x', path]);
    }
    return file;
  }

  /// What the helper started, once it has actually started.
  ///
  /// The relaunch is the last thing each script does and it is backgrounded —
  /// the helper must not outlive the app it is bringing back — so the script
  /// returns before the new Kruftle has run. Polled rather than slept on, so a
  /// passing run costs a millisecond and a failing one still fails.
  Future<String> launched({
    Duration within = const Duration(seconds: 5),
  }) async {
    final deadline = DateTime.now().add(within);
    final file = File(log());
    while (DateTime.now().isBefore(deadline)) {
      if (file.existsSync() && file.readAsStringSync().trim().isNotEmpty) break;
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    return file.existsSync() ? file.readAsStringSync().trim() : '';
  }

  /// A process to stand in for the Kruftle that is still running.
  Future<Process> holder() => Process.start('/bin/sleep', ['30']);

  group('linuxSwapScript', () {
    /// An install directory as the .tar.gz and the deb both lay it out.
    String install(String marker) {
      final directory = p.join(work.path, 'opt', 'kruftle');
      writeKruftle(p.join(directory, 'kruftle'), marker);
      File(p.join(directory, 'data', 'icudtl.dat'))
        ..createSync(recursive: true)
        ..writeAsStringSync(marker);
      return directory;
    }

    /// The payload the release publishes: the bundle's contents at the root.
    Future<String> tarball(String marker) async {
      final staging = Directory(p.join(work.path, 'staging'))
        ..createSync(recursive: true);
      writeKruftle(p.join(staging.path, 'kruftle'), marker);
      File(p.join(staging.path, 'data', 'icudtl.dat'))
        ..createSync(recursive: true)
        ..writeAsStringSync(marker);

      final archive = p.join(work.path, 'Kruftle-9.9.9-linux-x86_64.tar.gz');
      final packed = await Process.run('tar', [
        '-czf',
        archive,
        '-C',
        staging.path,
        '.',
      ]);
      expect(packed.exitCode, 0, reason: packed.stderr.toString());
      staging.deleteSync(recursive: true);
      return archive;
    }

    Future<ProcessResult> run(String archive, String directory, int pid) =>
        Process.run('/bin/sh', [
          '-c',
          linuxSwapScript,
          'kruftle-update',
          archive,
          directory,
          '$pid',
          p.join(directory, 'kruftle'),
        ]);

    test('replaces the directory once the old process has gone', () async {
      final directory = install('old');
      final archive = await tarball('new');
      final running = await holder();

      final swap = run(archive, directory, running.pid);

      // Nothing may happen while Kruftle is alive. Renaming the directory it
      // is running out of is the failure this waiting exists to avoid.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(
        File(p.join(directory, 'kruftle')).readAsStringSync(),
        contains('old'),
      );

      running.kill();
      await running.exitCode;
      await swap;

      expect(
        File(p.join(directory, 'kruftle')).readAsStringSync(),
        contains('new'),
      );
      expect(
        File(p.join(directory, 'data', 'icudtl.dat')).readAsStringSync(),
        'new',
        reason: 'the whole payload is replaced, not just the binary',
      );
      expect(await launched(), 'new', reason: 'the new Kruftle is started');
      expect(Directory('$directory.new').existsSync(), isFalse);
      expect(Directory('$directory.old').existsSync(), isFalse);
      expect(
        File(archive).existsSync(),
        isFalse,
        reason: 'download cleaned up',
      );
    });

    test(
      'an unreadable archive leaves the working copy exactly as it was',
      () async {
        final directory = install('old');
        final archive = p.join(work.path, 'broken.tar.gz');
        File(archive).writeAsStringSync('not a tarball');

        await run(archive, directory, 999999);

        expect(
          File(p.join(directory, 'kruftle')).readAsStringSync(),
          contains('old'),
        );
        expect(
          File(p.join(directory, 'data', 'icudtl.dat')).readAsStringSync(),
          'old',
        );
        expect(
          await launched(),
          'old',
          reason: 'the working Kruftle comes back',
        );
        expect(Directory('$directory.new').existsSync(), isFalse);
        expect(Directory('$directory.old').existsSync(), isFalse);
      },
    );

    test(
      'it gives up rather than swap under a process that will not go',
      () async {
        final directory = install('old');
        final archive = await tarball('new');
        final running = await holder();
        addTearDown(running.kill);

        // The wait is 60 seconds, so a run that returns before then only ever
        // does so by having decided not to swap. Shortened here by pointing it
        // at a pid that never exits and checking the guard, not the timeout.
        final result = await Process.run('/bin/sh', [
          '-c',
          linuxSwapScript.replaceFirst('-lt 600', '-lt 2'),
          'kruftle-update',
          archive,
          directory,
          '${running.pid}',
          p.join(directory, 'kruftle'),
        ]);

        expect(result.exitCode, 1);
        expect(
          File(p.join(directory, 'kruftle')).readAsStringSync(),
          contains('old'),
        );
        expect(
          await launched(within: const Duration(milliseconds: 400)),
          '',
          reason: 'nothing is started; it never stopped',
        );
      },
    );
  });

  group('macArchiveSwapScript', () {
    /// A `.app` is a directory with a fixed shape, which is all the swap cares
    /// about. The nested symlink is the reason `ditto` is used rather than
    /// `zip`: an archiver that flattens it produces a bundle that will not
    /// launch.
    String bundle(String directory, String marker) {
      final app = p.join(directory, 'Kruftle.app');
      writeKruftle(p.join(app, 'Contents', 'MacOS', 'Kruftle'), marker);
      File(p.join(app, 'Contents', 'Info.plist'))
        ..createSync(recursive: true)
        ..writeAsStringSync(marker);
      final versions = Directory(
        p.join(app, 'Contents', 'Frameworks', 'A.framework', 'Versions', 'A'),
      )..createSync(recursive: true);
      Link(p.join(versions.parent.path, 'Current')).createSync('A');
      return app;
    }

    Future<String> archive(String marker) async {
      final staging = Directory(p.join(work.path, 'staging'))
        ..createSync(recursive: true);
      final app = bundle(staging.path, marker);
      final zip = p.join(work.path, 'Kruftle-9.9.9-macos.zip');
      final packed = await Process.run('ditto', [
        '-c',
        '-k',
        '--sequesterRsrc',
        '--keepParent',
        app,
        zip,
      ]);
      expect(packed.exitCode, 0, reason: packed.stderr.toString());
      staging.deleteSync(recursive: true);
      return zip;
    }

    /// Runs the script with `open` stubbed out, so a test launches nothing.
    Future<String> run(String zip, String app, int owner) async {
      final stub = Directory(p.join(work.path, 'bin'))..createSync();
      final opened = p.join(work.path, 'opened');
      File(
        p.join(stub.path, 'open'),
      ).writeAsStringSync('#!/bin/sh\necho "\$1" >> "$opened"\n');
      await Process.run('chmod', ['+x', p.join(stub.path, 'open')]);

      await Process.run(
        '/bin/sh',
        ['-c', macArchiveSwapScript, 'kruftle-update', zip, app, '$owner'],
        environment: {'PATH': '${stub.path}:/bin:/usr/bin:/usr/sbin'},
      );

      final log = File(opened);
      return log.existsSync() ? log.readAsStringSync().trim() : '';
    }

    test('replaces the bundle once the old process has gone', () async {
      final zip = await archive('new');
      final installed = Directory(p.join(work.path, 'Applications'))
        ..createSync();
      final app = bundle(installed.path, 'old');
      final binary = p.join(app, 'Contents', 'MacOS', 'Kruftle');
      final running = await holder();

      final swap = run(zip, app, running.pid);
      // macOS will not let a bundle be replaced underneath a process running
      // out of it — the "app is already running" refusal Finder gives.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(File(binary).readAsStringSync(), contains('old'));

      running.kill();
      await running.exitCode;

      expect(await swap, app, reason: 'the new Kruftle is what gets opened');
      expect(File(binary).readAsStringSync(), contains('new'));
      expect(
        File(p.join(app, 'Contents', 'Info.plist')).readAsStringSync(),
        'new',
      );
      expect(
        Link(
          p.join(
            app,
            'Contents',
            'Frameworks',
            'A.framework',
            'Versions',
            'Current',
          ),
        ).targetSync(),
        'A',
        reason: 'ditto keeps the symlinks that make a bundle loadable',
      );
      expect(
        FileStat.statSync(binary).modeString().contains('x'),
        isTrue,
        reason: 'and the executable bit',
      );
      expect(Directory('$app.new').existsSync(), isFalse);
      expect(Directory('$app.old').existsSync(), isFalse);
      expect(File(zip).existsSync(), isFalse, reason: 'download cleaned up');
    });

    test('an unreadable archive leaves the installed bundle alone', () async {
      final zip = p.join(work.path, 'broken.zip');
      File(zip).writeAsStringSync('not an archive');
      final installed = Directory(p.join(work.path, 'Applications'))
        ..createSync();
      final app = bundle(installed.path, 'old');

      expect(await run(zip, app, 999999), app);
      expect(
        File(p.join(app, 'Contents', 'MacOS', 'Kruftle')).readAsStringSync(),
        contains('old'),
      );
      expect(Directory('$app.new').existsSync(), isFalse);
      expect(Directory('$app.old').existsSync(), isFalse);
    });
  }, skip: !Platform.isMacOS);

  group('appImageSwapScript', () {
    Future<ProcessResult> run(String fresh, String current, int pid) =>
        Process.run('/bin/sh', [
          '-c',
          appImageSwapScript,
          'kruftle-update',
          fresh,
          current,
          '$pid',
        ]);

    test('replaces the running image once the old process has gone', () async {
      final current = p.join(work.path, 'Applications', 'Kruftle.AppImage');
      writeKruftle(current, 'old');
      final fresh = p.join(
        work.path,
        'updates',
        'Kruftle-9.9.9-x86_64.AppImage',
      );
      writeKruftle(fresh, 'new');

      final running = await holder();
      final swap = run(fresh, current, running.pid);

      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(File(current).readAsStringSync(), contains('old'));

      running.kill();
      await running.exitCode;
      await swap;

      expect(File(current).readAsStringSync(), contains('new'));
      expect(await launched(), 'new');
      expect(File(fresh).existsSync(), isFalse, reason: 'moved, not copied');
      expect(File('$current.old').existsSync(), isFalse);
    });

    test('the running image survives a download that is not there', () async {
      final current = p.join(work.path, 'Kruftle.AppImage');
      writeKruftle(current, 'old');

      final result = await run(p.join(work.path, 'gone.AppImage'), current, 1);

      expect(result.exitCode, isNot(0));
      expect(File(current).readAsStringSync(), contains('old'));
      expect(File('$current.old').existsSync(), isFalse);
    });
  });

  group(
    'windowsSwapScript',
    () {
      // Run for real wherever PowerShell exists — which is every Windows machine
      // and every GitHub Ubuntu runner. `Expand-Archive`, `Wait-Process` and
      // `Move-Item` behave the same on all of them, so this exercises the actual
      // swap rather than asserting that a string is unchanged.
      final shell = _powershell();

      /// Inno Setup's install directory: the build output plus the uninstaller
      /// it writes there itself.
      String install(String marker) {
        final directory = p.join(work.path, 'Programs', 'Kruftle');
        for (final relative in const [
          'kruftle.exe',
          'flutter_windows.dll',
          'data/icudtl.dat',
        ]) {
          File(p.join(directory, relative.replaceAll('/', p.separator)))
            ..createSync(recursive: true)
            ..writeAsStringSync(marker);
        }
        for (final name in const ['unins000.exe', 'unins000.dat']) {
          File(p.join(directory, name))
            ..createSync(recursive: true)
            ..writeAsStringSync('the uninstaller');
        }
        return directory;
      }

      /// What the helper is told to start. It lives outside the install
      /// directory: a .zip made on Windows does not carry a POSIX execute bit,
      /// and on Windows the relaunched thing is a .exe that needs none. It
      /// reports which copy of kruftle.exe is in place by the time it runs,
      /// which is the question worth asking.
      String relaunchStub(String directory) {
        final stub = p.join(work.path, _stub);
        final target = p.join(directory, 'kruftle.exe');
        final file = File(stub)..createSync(recursive: true);
        if (Platform.isWindows) {
          file.writeAsStringSync(
            '@echo off\r\ntype "$target" >> "${log()}"\r\n',
          );
        } else {
          file.writeAsStringSync('#!/bin/sh\ncat "$target" >> "${log()}"\n');
          Process.runSync('chmod', ['+x', stub]);
        }
        return stub;
      }

      /// The release archive: the Release directory's contents at the root.
      String archive(String marker, {bool corrupt = false}) {
        final file = p.join(work.path, 'Kruftle-9.9.9-windows-x64.zip');
        if (corrupt) {
          File(file).writeAsStringSync('not a zip');
          return file;
        }

        final staging = Directory(p.join(work.path, 'staging'))
          ..createSync(recursive: true);
        for (final relative in const [
          'kruftle.exe',
          'flutter_windows.dll',
          'data/icudtl.dat',
        ]) {
          File(p.join(staging.path, relative.replaceAll('/', p.separator)))
            ..createSync(recursive: true)
            ..writeAsStringSync(marker);
        }
        final packed = Process.runSync(shell!, [
          '-NoProfile',
          '-Command',
          "Compress-Archive -Path '${staging.path}${p.separator}*' "
              "-DestinationPath '$file' -Force",
        ]);
        expect(packed.exitCode, 0, reason: packed.stderr.toString());
        staging.deleteSync(recursive: true);
        return file;
      }

      Future<ProcessResult> run(String zip, String directory, int pid) {
        final script = File(p.join(work.path, 'apply-update.ps1'))
          ..writeAsStringSync(windowsSwapScript);
        return Process.run(shell!, [
          '-NoProfile',
          '-NonInteractive',
          '-ExecutionPolicy',
          'Bypass',
          '-File',
          script.path,
          '-Archive',
          zip,
          '-Dir',
          directory,
          '-Owner',
          '$pid',
          '-Exe',
          relaunchStub(directory),
          '-Log',
          p.join(work.path, 'apply-update.log'),
        ]);
      }

      /// What the helper wrote about itself. Empty when it never ran at all,
      /// which is the state a Windows machine was left in with no way to tell.
      List<String> helperLog() {
        final file = File(p.join(work.path, 'apply-update.log'));
        return file.existsSync() ? file.readAsLinesSync() : const [];
      }

      test('replaces the install once the old process has gone', () async {
        final directory = install('old');
        final zip = archive('new');
        final running = await holder();

        final swap = run(zip, directory, running.pid);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        expect(
          File(p.join(directory, 'kruftle.exe')).readAsStringSync(),
          'old',
        );

        running.kill();
        await running.exitCode;
        await swap;

        expect(
          File(p.join(directory, 'kruftle.exe')).readAsStringSync(),
          'new',
        );
        expect(
          File(p.join(directory, 'data', 'icudtl.dat')).readAsStringSync(),
          'new',
          reason: 'the whole payload is replaced, not just the binary',
        );
        expect(
          File(p.join(directory, 'unins000.exe')).readAsStringSync(),
          'the uninstaller',
          reason:
              'Inno Setup writes it here and the build output has no copy; '
              'losing it orphans the Add/Remove Programs entry',
        );
        expect(await launched(), 'new');
        expect(Directory('$directory.new').existsSync(), isFalse);
        expect(Directory('$directory.old').existsSync(), isFalse);

        final said = helperLog().join('\n');
        expect(said, contains('helper started'));
        expect(said, contains('has exited'));
        expect(said, contains('swapped'));
        expect(said, contains('carried over unins000.exe'));
      });

      test(
        'an unreadable archive leaves the install exactly as it was',
        () async {
          final directory = install('old');
          final zip = archive('new', corrupt: true);

          await run(zip, directory, 999999);

          expect(
            File(p.join(directory, 'kruftle.exe')).readAsStringSync(),
            'old',
          );
          expect(
            File(p.join(directory, 'data', 'icudtl.dat')).readAsStringSync(),
            'old',
          );
          expect(
            File(p.join(directory, 'unins000.exe')).readAsStringSync(),
            'the uninstaller',
          );
          expect(
            await launched(),
            'old',
            reason: 'the working Kruftle comes back',
          );
          expect(Directory('$directory.new').existsSync(), isFalse);
          expect(Directory('$directory.old').existsSync(), isFalse);
        },
      );
    },
    skip: _powershell() == null ? 'no PowerShell on this machine' : false,
  );
}

/// `Start-Process` needs something the host can actually launch.
final String _stub = Platform.isWindows ? 'relaunch.cmd' : 'relaunch.sh';

String? _powershell() {
  for (final name in const ['pwsh', 'powershell']) {
    try {
      final found = Process.runSync(Platform.isWindows ? 'where' : 'which', [
        name,
      ]);
      if (found.exitCode == 0) {
        final path = (found.stdout as String).trim().split('\n').first.trim();
        if (path.isNotEmpty) return path;
      }
    } on Object {
      // No `which`/`where`, or it could not be run. Treated as "not found".
    }
  }
  return null;
}
