// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The cleanup engine must stay pure Dart: it is where all the logic and all
/// the risk lives, and it has to be testable without a widget tree (and
/// reusable from a future headless mode). This test is the enforcement.
void main() {
  test('lib/src/core contains no Flutter imports', () {
    final offenders = <String>[];
    final core = Directory('lib/src/core');

    for (final entity in core.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(
          r'''^\s*import\s+['"]package:flutter''',
        ).hasMatch(lines[i])) {
          offenders.add('${entity.path}:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'lib/src/core must not depend on Flutter. Offending imports:\n'
          '${offenders.join('\n')}',
    );
  });
}
