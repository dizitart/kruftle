// SPDX-License-Identifier: GPL-3.0-or-later
// Verifies the updater against the real GitHub Releases API, not a mock.
// Usage: dart run tool/check_update.dart [pretend-current-version]
import 'dart:io';

import 'package:kruftle/src/core/update/updater.dart';
import 'package:kruftle/src/core/update/version.dart';

Future<void> main(List<String> args) async {
  final current = Version.tryParse(args.isEmpty ? '0.0.1' : args.first)!;

  for (final (label, windows, macOS) in [
    ('macOS', false, true),
    ('Windows', true, false),
    ('Linux', false, false),
  ]) {
    final update = await Updater(
      currentVersion: current,
      windows: windows,
      macOS: macOS,
    ).check();

    if (update == null) {
      stdout.writeln('$label: no update offered above $current');
      continue;
    }
    stdout.writeln(
      '$label: ${update.version}  ${update.assetName}  '
      '${(update.sizeBytes / (1 << 20)).toStringAsFixed(1)} MiB  '
      'sha256=${update.sha256.substring(0, 16)}…',
    );
  }
}
