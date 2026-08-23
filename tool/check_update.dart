// SPDX-License-Identifier: GPL-3.0-or-later
// Verifies the updater against the real GitHub Releases API, not a mock.
//
//   dart run tool/check_update.dart [version]            # check only
//   dart run tool/check_update.dart [version] --download # also fetch + verify
import 'dart:io';

import 'package:kruftle/src/core/update/updater.dart';
import 'package:kruftle/src/core/update/version.dart';

Future<void> main(List<String> args) async {
  final download = args.contains('--download');
  final positional = args.where((a) => !a.startsWith('--')).toList();
  final current = Version.tryParse(
    positional.isEmpty ? '0.0.1' : positional.first,
  )!;

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

    if (!download) continue;
    final directory = Directory.systemTemp.createTempSync('kruftle_update');
    try {
      final file = await Updater(
        currentVersion: current,
        windows: windows,
        macOS: macOS,
      ).download(update, directory: directory.path);
      stdout.writeln(
        '  downloaded and SHA-256 verified: '
        '${(file.lengthSync() / (1 << 20)).toStringAsFixed(1)} MiB',
      );
    } on UpdateFailure catch (e) {
      stderr.writeln('  REFUSED: ${e.message}');
      exitCode = 1;
    } finally {
      directory.deleteSync(recursive: true);
    }
  }
}
