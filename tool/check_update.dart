// SPDX-License-Identifier: GPL-3.0-or-later
// Verifies the updater against the real GitHub Releases API, not a mock.
//
//   dart run tool/check_update.dart [version]            # check only
//   dart run tool/check_update.dart [version] --download # also fetch + verify
//
// Every install shape is asked in turn, because they no longer want the same
// asset: a copy that can write next to itself takes the plain archive and
// swaps it in, and one that cannot is offered its own packaging's installer.
import 'dart:io';

import 'package:kruftle/src/core/update/updater.dart';
import 'package:kruftle/src/core/update/version.dart';

/// The shapes a released Kruftle is actually installed in.
const _shapes = <String, InstallTarget>{
  'macOS .app': InstallTarget(
    assetSuffixes: ['.dmg'],
    swapDirectory: '/Applications/Kruftle.app',
  ),
  'Windows, per-user': InstallTarget(
    assetSuffixes: ['.zip', '.exe'],
    swapDirectory: r'C:\Users\me\AppData\Local\Programs\Kruftle',
  ),
  'Windows, Program Files': InstallTarget(assetSuffixes: ['.exe']),
  'Linux AppImage': InstallTarget(
    assetSuffixes: ['.AppImage'],
    appImage: '/home/me/Applications/Kruftle.AppImage',
  ),
  'Linux tarball': InstallTarget(
    assetSuffixes: ['.tar.gz'],
    swapDirectory: '/home/me/kruftle',
  ),
  'Linux .deb': InstallTarget(assetSuffixes: ['.deb']),
};

Future<void> main(List<String> args) async {
  final download = args.contains('--download');
  final positional = args.where((a) => !a.startsWith('--')).toList();
  final current = Version.tryParse(
    positional.isEmpty ? '0.0.1' : positional.first,
  )!;

  stdout.writeln('running $kAppVersion, asking as $current\n');

  for (final (label, target) in _shapes.entries.map((e) => (e.key, e.value))) {
    for (final architecture in const ['x64', 'arm64']) {
      final updater = Updater(
        currentVersion: current,
        target: target,
        architecture: architecture,
      );

      final AvailableUpdate? update;
      try {
        update = await updater.check();
      } on UpdateFailure catch (e) {
        stderr.writeln('$label ($architecture): FAILED — ${e.message}');
        exitCode = 1;
        continue;
      }

      if (update == null) {
        stdout.writeln('$label ($architecture): nothing above $current');
        exitCode = 1;
        continue;
      }
      stdout.writeln(
        '$label ($architecture): ${update.version}  ${update.assetName}  '
        '${(update.sizeBytes / (1 << 20)).toStringAsFixed(1)} MiB  '
        'sha256=${update.sha256.substring(0, 16)}…  '
        '${update.isSelfReplacing ? 'swapped in place' : 'runs an installer'}',
      );

      if (!download) continue;
      final directory = Directory.systemTemp.createTempSync('kruftle_update');
      try {
        final file = await updater.download(update, directory: directory.path);
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
}
