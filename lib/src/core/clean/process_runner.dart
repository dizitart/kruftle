// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import '../models/stack.dart';

/// The result of running one clean command.
class ProcessOutcome {
  const ProcessOutcome({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    this.timedOut = false,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
  final bool timedOut;

  bool get succeeded => exitCode == 0 && !timedOut;
}

/// Runs clean commands. An interface so the cleaner can be tested without
/// spawning a real `cargo`, and so tests can assert on the exact argv rather
/// than on side effects.
abstract interface class ProcessRunner {
  Future<ProcessOutcome> run(
    CleanCommand command, {
    required String workingDirectory,
    required Duration timeout,
  });

  /// Kill everything still running. Called when the user cancels.
  Future<void> killAll();
}

class SystemProcessRunner implements ProcessRunner {
  final Set<Process> _live = {};

  @override
  Future<ProcessOutcome> run(
    CleanCommand command, {
    required String workingDirectory,
    required Duration timeout,
  }) async {
    final Process process;
    try {
      process = await Process.start(
        command.executable,
        command.args,
        workingDirectory: workingDirectory,
        // A wrapper script such as ./gradlew needs a shell on Windows; on
        // POSIX we exec directly so no argument is ever re-parsed by a shell.
        runInShell: Platform.isWindows,
      );
    } on ProcessException catch (e) {
      return ProcessOutcome(exitCode: 127, stdout: '', stderr: e.message);
    }

    _live.add(process);
    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();
    final drained = Future.wait([
      process.stdout.forEach(
        (d) => stdoutBuffer.write(String.fromCharCodes(d)),
      ),
      process.stderr.forEach(
        (d) => stderrBuffer.write(String.fromCharCodes(d)),
      ),
    ]);

    try {
      final code = await process.exitCode.timeout(timeout);
      await drained;
      return ProcessOutcome(
        exitCode: code,
        stdout: stdoutBuffer.toString(),
        stderr: stderrBuffer.toString(),
      );
    } on TimeoutException {
      // A hung build tool must not hold the whole run hostage. Kill it, record
      // the failure, carry on with the next project.
      process.kill(ProcessSignal.sigkill);
      return ProcessOutcome(
        exitCode: -1,
        stdout: stdoutBuffer.toString(),
        stderr: stderrBuffer.toString(),
        timedOut: true,
      );
    } finally {
      _live.remove(process);
    }
  }

  @override
  Future<void> killAll() async {
    for (final process in _live.toList()) {
      process.kill(ProcessSignal.sigkill);
    }
    _live.clear();
  }
}
