// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/log/activity_log.dart';
import 'package:kruftle/src/core/models/stack.dart';
import 'package:kruftle/src/core/settings/settings.dart';

void main() {
  test('defaults are conservative', () {
    const settings = Settings();
    expect(settings.rememberedRisks, isEmpty,
        reason: 'no raw deletion category is enabled out of the box');
    expect(settings.confirmBeforeDelete, isTrue);
    expect(settings.defaultRoots, isEmpty);
  });

  test('round-trips through JSON', () {
    const original = Settings(
      defaultRoots: ['/work', '/Volumes/External/codebase'],
      maxScanDepth: 20,
      cleanConcurrency: 8,
      stepTimeoutSeconds: 60,
      logLevel: LogLevel.debug,
      rememberedRisks: {CleanRisk.dependencies, CleanRisk.cache},
      checkForUpdates: false,
    );

    final restored = Settings.decode(original.encode());

    expect(restored.defaultRoots, original.defaultRoots);
    expect(restored.maxScanDepth, 20);
    expect(restored.cleanConcurrency, 8);
    expect(restored.logLevel, LogLevel.debug);
    expect(restored.rememberedRisks, original.rememberedRisks);
    expect(restored.checkForUpdates, isFalse);
  });

  test('an unknown field is ignored rather than fatal', () {
    final restored = Settings.decode(
      '{"maxScanDepth": 7, "somethingFromAFutureVersion": true}',
    );
    expect(restored.maxScanDepth, 7);
  });

  test('a field of the wrong type falls back to its default', () {
    final restored = Settings.decode('{"maxScanDepth": "twelve"}');
    expect(restored.maxScanDepth, const Settings().maxScanDepth);
  });

  test('an unknown enum value falls back rather than throwing', () {
    final restored = Settings.decode('{"logLevel": "verbose"}');
    expect(restored.logLevel, LogLevel.info);
  });

  test('out-of-range numbers are clamped to something survivable', () {
    expect(Settings.decode('{"cleanConcurrency": 9999}').cleanConcurrency, 32);
    expect(Settings.decode('{"stepTimeoutSeconds": 0}').stepTimeoutSeconds, 10);
    expect(Settings.decode('{"maxScanDepth": -5}').maxScanDepth, 1);
  });

  test('corrupt storage yields defaults instead of a crash', () {
    expect(Settings.decode('not json at all').maxScanDepth,
        const Settings().maxScanDepth);
    expect(Settings.decode(null).cleanConcurrency, 4);
    expect(Settings.decode('').cleanConcurrency, 4);
  });

  test('copyWith changes one field and leaves the rest', () {
    const base = Settings(maxScanDepth: 9, cleanConcurrency: 2);
    final updated = base.copyWith(cleanConcurrency: 6);
    expect(updated.maxScanDepth, 9);
    expect(updated.cleanConcurrency, 6);
  });
}
