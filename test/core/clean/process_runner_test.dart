// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/clean/process_runner.dart';
import 'package:kruftle/src/core/models/stack.dart';
import 'package:kruftle/src/core/scan/toolchain.dart';
import 'package:path/path.dart' as p;

/// The bug this file exists for: v0.2.0 planned 96 clean commands against a
/// real codebase and every single one failed with "No such file or directory",
/// freeing nothing. The app had been launched from Finder, which hands it a
/// PATH of `/usr/bin:/bin:/usr/sbin:/sbin` — so `cargo`, `flutter` and `mvn`
/// were unspawnable even though the scanner had just found all three by
/// asking the login shell. Only `make`, which lives in `/usr/bin`, ran.
void main() {
  late Directory temp;

  setUp(() => temp = Directory.systemTemp.createTempSync('kruftle-runner'));
  tearDown(() => temp.deleteSync(recursive: true));

  /// A tool installed somewhere the process PATH does not mention.
  File writeTool(String name) {
    final tool = File(p.join(temp.path, name))
      ..writeAsStringSync('#!/bin/sh\necho ran\n');
    Process.runSync('chmod', ['+x', tool.path]);
    return tool;
  }

  test('runs a tool the process PATH cannot see', () async {
    writeTool('kruftle-fake-tool');
    final runner = SystemProcessRunner(
      toolchain: ToolchainProbe(environment: {'PATH': temp.path}),
    );

    final outcome = await runner.run(
      const CleanCommand('kruftle-fake-tool'),
      workingDirectory: temp.path,
      timeout: const Duration(seconds: 10),
    );

    expect(outcome.succeeded, isTrue, reason: outcome.stderr);
    expect(outcome.stdout.trim(), 'ran');
  }, skip: Platform.isWindows);

  /// The v0.2.1 residue: `npm` itself was resolved and started, then its
  /// script reached for `node` through `#!/usr/bin/env node` and searched the
  /// *child's* PATH — the Finder one — and died with
  /// `env: node: No such file or directory`.
  test('the tool can find its own helpers on PATH too', () async {
    writeTool('kruftle-fake-helper');
    final wrapper = File(p.join(temp.path, 'kruftle-fake-wrapper'))
      ..writeAsStringSync('#!/bin/sh\nexec kruftle-fake-helper\n');
    Process.runSync('chmod', ['+x', wrapper.path]);

    final runner = SystemProcessRunner(
      toolchain: ToolchainProbe(environment: {'PATH': temp.path}),
    );

    final outcome = await runner.run(
      const CleanCommand('kruftle-fake-wrapper'),
      workingDirectory: temp.path,
      timeout: const Duration(seconds: 10),
    );

    expect(outcome.succeeded, isTrue, reason: outcome.stderr);
    expect(outcome.stdout.trim(), 'ran');
  }, skip: Platform.isWindows);

  test('a project wrapper stays relative to the project', () async {
    writeTool('gradlew');
    final runner = SystemProcessRunner(
      toolchain: ToolchainProbe(environment: const {'PATH': ''}),
    );

    final outcome = await runner.run(
      const CleanCommand('./gradlew'),
      workingDirectory: temp.path,
      timeout: const Duration(seconds: 10),
    );

    expect(outcome.succeeded, isTrue, reason: outcome.stderr);
  }, skip: Platform.isWindows);

  test('a tool that really is missing still fails, and says so', () async {
    final runner = SystemProcessRunner(
      toolchain: ToolchainProbe(environment: const {'PATH': ''}),
    );

    final outcome = await runner.run(
      const CleanCommand('kruftle-no-such-tool'),
      workingDirectory: temp.path,
      timeout: const Duration(seconds: 10),
    );

    expect(outcome.succeeded, isFalse);
    expect(outcome.exitCode, 127);
  });
}
