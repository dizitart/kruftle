// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/log/activity_log.dart';
import 'package:kruftle/src/core/models/stack.dart';
import 'package:kruftle/src/core/scan/sizer.dart';
import 'package:kruftle/src/core/settings/settings.dart';

void main() {
  test('defaults are conservative', () {
    const settings = Settings();
    expect(
      settings.rememberedRisks,
      isEmpty,
      reason: 'no raw deletion category is enabled out of the box',
    );
    expect(settings.confirmBeforeDelete, isTrue);
    expect(settings.defaultRoots, isEmpty);
    expect(
      settings.themeMode,
      AppThemeMode.system,
      reason: 'an app that ignores the desktop theme is the rude one',
    );
    expect(
      settings.localeCode,
      isNull,
      reason: 'null means "follow the system locale"',
    );
    expect(settings.reduceMotion, isFalse);
    expect(
      settings.sizeMode,
      SizeMode.onDisk,
      reason: 'the honest figure is what the disk actually gives back',
    );
    expect(
      settings.hasSeenTour,
      isFalse,
      reason: 'a fresh install has not seen the tour',
    );
    expect(settings.lastSeenVersion, isNull);
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
      themeMode: AppThemeMode.light,
      localeCode: 'ja',
      reduceMotion: true,
      sizeMode: SizeMode.apparent,
      hasSeenTour: true,
      lastSeenVersion: '0.2.0',
    );

    final restored = Settings.decode(original.encode());

    expect(restored.defaultRoots, original.defaultRoots);
    expect(restored.maxScanDepth, 20);
    expect(restored.cleanConcurrency, 8);
    expect(restored.logLevel, LogLevel.debug);
    expect(restored.rememberedRisks, original.rememberedRisks);
    expect(restored.checkForUpdates, isFalse);
    expect(restored.themeMode, AppThemeMode.light);
    expect(restored.localeCode, 'ja');
    expect(restored.reduceMotion, isTrue);
    expect(restored.sizeMode, SizeMode.apparent);
    expect(restored.hasSeenTour, isTrue);
    expect(restored.lastSeenVersion, '0.2.0');
  });

  test('a settings file written by v0.1 still loads', () {
    // Every v0.2 field is absent here. Losing a preference is a nuisance;
    // refusing to start because an older version wrote the file is a bug
    // report, so each field falls back independently.
    final restored = Settings.decode(
      '{"maxScanDepth": 9, "cleanConcurrency": 6, "checkForUpdates": false}',
    );

    expect(restored.maxScanDepth, 9);
    expect(restored.cleanConcurrency, 6);
    expect(restored.checkForUpdates, isFalse);
    expect(restored.themeMode, AppThemeMode.system);
    expect(restored.localeCode, isNull);
    expect(restored.sizeMode, SizeMode.onDisk);
    expect(restored.hasSeenTour, isFalse);
  });

  test('an unsupported language code is dropped rather than kept', () {
    // The picker only offers supported locales, but a hand-edited or
    // downgraded settings file can carry anything. A code with no ARB behind
    // it must fall back to the system locale, not leave the UI half-English.
    expect(Settings.decode('{"localeCode": "en"}').localeCode, 'en');
    expect(Settings.decode('{"localeCode": "kl"}').localeCode, isNull);
    expect(Settings.decode('{"localeCode": ""}').localeCode, isNull);
    expect(Settings.decode('{"localeCode": 42}').localeCode, isNull);
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
    expect(
      Settings.decode('not json at all').maxScanDepth,
      const Settings().maxScanDepth,
    );
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
