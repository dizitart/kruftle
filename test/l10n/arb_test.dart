// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/l10n/app_localizations.dart';
import 'package:kruftle/src/core/settings/settings.dart';

/// Guards the translation files against the two ways they rot: a key that
/// exists in one language and not another, and a placeholder that was dropped
/// or renamed in translation. Both produce a crash or a `{count}` on screen at
/// runtime rather than a compile error, so they are checked here instead.
void main() {
  final directory = Directory('lib/l10n');
  final template = _readArb('${directory.path}/app_en.arb');

  final translations = directory
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb') && !f.path.endsWith('app_en.arb'))
      .toList();

  test('there is a translation file for every supported locale', () {
    final files = {
      for (final file in [
        ...translations,
        File('${directory.path}/app_en.arb'),
      ])
        RegExp(r'app_(\w+)\.arb$').firstMatch(file.path)!.group(1)!,
    };
    final supported = L.supportedLocales.map((l) => l.languageCode).toSet();

    expect(files, supported);
    expect(
      supported,
      hasLength(10),
      reason: 'the ten most-spoken locales, per PROJECT_PLAN §5b M13',
    );
  });

  test('the core\'s locale list agrees with the generated one', () {
    // `Settings` cannot import Flutter, so it carries its own copy of the
    // supported codes to validate a stored preference against. This is what
    // stops the two drifting apart.
    expect(
      kSupportedLocaleCodes.toSet(),
      L.supportedLocales.map((l) => l.languageCode).toSet(),
    );
  });

  test('English is the template and carries every key', () {
    expect(template.keys, isNotEmpty);
    expect(template['@@locale'], 'en');
  });

  for (final file in translations) {
    final locale = RegExp(r'app_(\w+)\.arb$').firstMatch(file.path)!.group(1)!;

    group(locale, () {
      final translated = _readArb(file.path);

      test('declares its own locale', () {
        expect(translated['@@locale'], locale);
      });

      test('translates every key English defines, and no others', () {
        final expected = _messageKeys(template);
        final actual = _messageKeys(translated);

        expect(
          expected.difference(actual),
          isEmpty,
          reason: 'untranslated keys fall back to English silently',
        );
        expect(
          actual.difference(expected),
          isEmpty,
          reason: 'a key no longer in the template is dead weight',
        );
      });

      test('keeps every placeholder the English string uses', () {
        for (final key in _messageKeys(template)) {
          expect(
            _placeholders(translated[key]! as String),
            _placeholders(template[key]! as String),
            reason:
                'placeholders in "$key" do not match the template; a missing '
                'one throws at runtime and an invented one never resolves',
          );
        }
      });

      test('leaves no message empty', () {
        for (final key in _messageKeys(translated)) {
          expect(
            (translated[key]! as String).trim(),
            isNotEmpty,
            reason: '"$key" is blank',
          );
        }
      });
    });
  }
}

Map<String, Object?> _readArb(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

/// Message keys only — ARB puts metadata under an `@`-prefixed twin.
Set<String> _messageKeys(Map<String, Object?> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

/// Every `{name}` in a message, ignoring the `plural`/`select` machinery so a
/// language with a different set of plural categories still matches.
Set<String> _placeholders(String message) => RegExp(r'\{(\w+)[,}]')
    .allMatches(message)
    .map((m) => m.group(1)!)
    .where((name) => name != 'count' || !message.contains('$name, plural'))
    .toSet();
