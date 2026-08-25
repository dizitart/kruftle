// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/stack.dart';
import '../scan/toolchain.dart';

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
  SystemProcessRunner({ToolchainProbe? toolchain})
    : _toolchain = toolchain ?? ToolchainProbe.shared;

  /// Resolves `flutter` to the absolute path the scanner found it at.
  ///
  /// A GUI application launched from Finder or the shell's Dock does not
  /// inherit the login shell's PATH, so `Process.start('flutter', ...)` fails
  /// with ENOENT for every SDK installed by a shell rc file — while the probe,
  /// which asks the login shell, has known where it is all along.
  final ToolchainProbe _toolchain;

  final Set<Process> _live = {};

  @override
  Future<ProcessOutcome> run(
    CleanCommand command, {
    required String workingDirectory,
    required Duration timeout,
  }) async {
    // A wrapper checked into the project (`./gradlew`) is already a path, and
    // is meant to be resolved against the working directory, not the PATH.
    final executable = _isPath(command.executable)
        ? command.executable
        : await _toolchain.locate(command.executable) ?? command.executable;

    // Never hand a child an empty PATH: that is worse than the one we inherit.
    final path = await _toolchain.searchPathValue();

    final Process process;
    try {
      process = await Process.start(
        executable,
        command.args,
        workingDirectory: workingDirectory,
        // The tool's own children look themselves up on PATH — an npm script
        // reaching for `node`, a Gradle wrapper reaching for `java`. Resolving
        // only the executable we spawn leaves those one level down to fail.
        environment: {if (path.isNotEmpty) 'PATH': path},
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

  bool _isPath(String executable) =>
      executable.contains('/') || executable.contains(p.separator);

  @override
  Future<void> killAll() async {
    for (final process in _live.toList()) {
      process.kill(ProcessSignal.sigkill);
    }
    _live.clear();
  }
}
