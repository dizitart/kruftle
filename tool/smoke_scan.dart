// SPDX-License-Identifier: GPL-3.0-or-later
// Developer smoke test: scan a real tree and print what Kruftle sees.
// Usage: dart run tool/smoke_scan.dart <dir>
import 'dart:io';

import 'package:kruftle/src/core/scan/project_scanner.dart';

Future<void> main(List<String> args) async {
  final root = args.isEmpty ? Directory.current.path : args.first;
  final scanner = ProjectScanner();
  final stopwatch = Stopwatch()..start();
  var scanned = 0;
  final found = <String>[];

  await for (final event in scanner.scan(ScanRequest(root: root))) {
    switch (event) {
      case ScanningDirectory():
        scanned++;
      case ProjectFound(:final project):
        final stacks = project.stacks.map((s) => s.displayName).join(', ');
        final artifacts = project.allArtifacts.map((a) => a.relative).join(' ');
        found.add('  ${project.name.padRight(28)} $stacks  [$artifacts]');
      case ScanFailed(:final violation):
        stderr.writeln('refused: ${violation.message}');
        exit(1);
    }
  }

  stopwatch.stop();
  found.sort();
  stdout.writeln(found.join('\n'));
  stdout.writeln(
    '\n${found.length} projects with artifacts, '
    '$scanned dirs walked, ${stopwatch.elapsedMilliseconds} ms',
  );

  final tools = await scanner.toolAvailability();
  stdout.writeln(
    '\ntoolchains: ${tools.entries.map((e) => '${e.key}=${e.value.name}').join(' ')}',
  );
}
