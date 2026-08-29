// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/update/swap_scripts.dart';
import 'package:path/path.dart' as p;

/// Starts the Windows update helper the way `Updater` starts it, and only that.
///
/// `swap_scripts_test.dart` proves the script does the right thing when it runs.
/// This proves it runs. The two were never the same question, and the gap
/// between them is where every Windows update went: the helper was launched as
/// `powershell.exe` with `ProcessStartMode.detached`, which on Windows means
/// `DETACHED_PROCESS` — no console — and Windows PowerShell's host exits
/// immediately without one. No swap, no relaunch, not even a line in the
/// helper's own log, because the log is written by the script that never ran.
///
/// So this test asserts nothing about the swap's cleverness and everything
/// about the launch: detached, from Dart, on real Windows, with the real
/// [windowsHelperCommand] and [windowsHelperEnvironment]. It fails on the old
/// launcher and passes on this one. It has to run on Windows — `cmd.exe` is the
/// fix and Ubuntu does not have one — which is why CI now tests there too.
void main() {
  // `cmd.exe` is the fix, and only Windows has one. Everything below asserts
  // what a real Windows process does when it starts a detached child.
  final notWindows = Platform.isWindows
      ? false
      : 'the Windows helper launch can only be exercised on Windows';

  late Directory work;

  setUp(() => work = Directory.systemTemp.createTempSync('kruftle-launch'));
  tearDown(() {
    try {
      work.deleteSync(recursive: true);
    } on Object {
      // The helper may still hold the directory for a moment. A temp directory
      // that outlives one test run is not worth failing it over.
    }
  });

  /// An install directory as Inno Setup leaves it: the build output plus the
  /// uninstaller it writes there itself.
  String install(String marker) {
    final directory = p.join(work.path, 'Programs', 'Kruftle');
    for (final relative in const ['kruftle.exe', r'data\icudtl.dat']) {
      File(p.join(directory, relative))
        ..createSync(recursive: true)
        ..writeAsStringSync(marker);
    }
    File(p.join(directory, 'unins000.exe'))
      ..createSync(recursive: true)
      ..writeAsStringSync('the uninstaller');
    return directory;
  }

  /// The release payload: the Release directory's contents at the archive root.
  String archive(String marker) {
    final staging = Directory(p.join(work.path, 'staging'))
      ..createSync(recursive: true);
    for (final relative in const ['kruftle.exe', r'data\icudtl.dat']) {
      File(p.join(staging.path, relative))
        ..createSync(recursive: true)
        ..writeAsStringSync(marker);
    }
    final file = p.join(work.path, 'Kruftle-9.9.9-windows-x64.zip');
    final packed = Process.runSync('powershell', [
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      "Compress-Archive -Path '${staging.path}\\*' -DestinationPath '$file'",
    ]);
    expect(packed.exitCode, 0, reason: packed.stderr.toString());
    staging.deleteSync(recursive: true);
    return file;
  }

  /// Stands in for the Kruftle being replaced: it records which copy of
  /// `kruftle.exe` is in place by the time the helper starts it. It lives
  /// outside the install directory, which the swap renames wholesale.
  String relaunchStub(String directory) {
    final stub = p.join(work.path, 'relaunch.cmd');
    File(stub)
      ..createSync(recursive: true)
      ..writeAsStringSync(
        '@echo off\r\n'
        'type "${p.join(directory, 'kruftle.exe')}" > "${p.join(work.path, 'launched')}"\r\n',
      );
    return stub;
  }

  /// Polls for [test] rather than sleeping on it: the helper is detached, so
  /// there is no exit code to await.
  ///
  /// The deadline is generous because every step here is a PowerShell cold
  /// start on a runner that may be busy with the rest of the suite; an idle
  /// machine gets through both tests in about five seconds, and only a real
  /// failure ever waits this long.
  Future<bool> until(
    bool Function() test, {
    Duration within = const Duration(seconds: 45),
  }) async {
    final deadline = DateTime.now().add(within);
    while (DateTime.now().isBefore(deadline)) {
      if (test()) return true;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return test();
  }

  test(
    'the helper actually runs when started the way Updater starts it',
    () async {
      final directory = install('old');
      final zip = archive('new');
      final log = p.join(work.path, 'apply-update.log');
      final script = File(p.join(work.path, 'apply-update.ps1'))
        ..writeAsStringSync(windowsSwapScript);

      // The Kruftle the helper is waiting for. A real process, because "has it
      // exited yet" is the one thing the helper asks the operating system.
      final owner = await Process.start('powershell', [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        'Start-Sleep -Seconds 60',
      ]);
      addTearDown(owner.kill);

      await Process.start(
        windowsHelperCommand.first,
        windowsHelperCommand.sublist(1),
        environment: windowsHelperEnvironment(
          script: script.path,
          archive: zip,
          directory: directory,
          owner: owner.pid,
          executable: relaunchStub(directory),
          log: log,
        ),
        mode: ProcessStartMode.detached,
      );

      // It has to be alive and doing nothing: renaming the directory Kruftle is
      // running out of is the failure all this waiting exists to avoid.
      expect(
        await until(() => File(log).existsSync()),
        isTrue,
        reason: 'the helper never started at all — nothing wrote the log',
      );
      expect(
        File(p.join(directory, 'kruftle.exe')).readAsStringSync(),
        'old',
        reason: 'nothing may be replaced while Kruftle is still running',
      );

      owner.kill();
      await owner.exitCode;

      expect(
        await until(
          () =>
              File(p.join(directory, 'kruftle.exe')).readAsStringSync() ==
              'new',
        ),
        isTrue,
        reason: 'the swap never happened: ${File(log).readAsStringSync()}',
      );
      expect(
        File(p.join(directory, 'data', 'icudtl.dat')).readAsStringSync(),
        'new',
        reason: 'the whole payload is replaced, not just the binary',
      );
      expect(
        File(p.join(directory, 'unins000.exe')).readAsStringSync(),
        'the uninstaller',
        reason: 'losing it orphans the Add/Remove Programs entry',
      );
      expect(
        await until(() => File(p.join(work.path, 'launched')).existsSync()),
        isTrue,
        reason: 'the new Kruftle is started',
      );
      expect(
        File(p.join(work.path, 'launched')).readAsStringSync(),
        contains('new'),
      );

      final said = File(log).readAsStringSync();
      expect(said, contains('helper started'));
      expect(said, contains('has exited'));
      expect(said, contains('swapped'));
    },
    skip: notWindows,
    // Unpacking and two directory renames on a cold CI runner, plus the
    // helper's own polling. Generous, because a slow machine is not a bug.
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'a helper started without an owner says so instead of waiting',
    () async {
      final log = p.join(work.path, 'apply-update.log');
      final script = File(p.join(work.path, 'apply-update.ps1'))
        ..writeAsStringSync(windowsSwapScript);

      await Process.start(
        windowsHelperCommand.first,
        windowsHelperCommand.sublist(1),
        environment: windowsHelperEnvironment(
          script: script.path,
          archive: p.join(work.path, 'nothing.zip'),
          directory: p.join(work.path, 'nowhere'),
          owner: 0,
          executable: p.join(work.path, 'nothing.exe'),
          log: log,
        ),
        mode: ProcessStartMode.detached,
      );

      expect(
        await until(
          () =>
              File(log).existsSync() &&
              File(log).readAsStringSync().contains('no process id'),
        ),
        isTrue,
        reason: 'pid 0 is the idle process, which never exits',
      );
    },
    skip: notWindows,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
