// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/ui/theme.dart';

import 'wizard_test.dart' show pumpWizard;

/// The light palette has existed since v0.1 but was never selectable, so it had
/// never been looked at. These are the checks that stop it regressing into
/// white-on-white.
void main() {
  for (final brightness in Brightness.values) {
    group(brightness.name, () {
      final theme = brightness == Brightness.dark
          ? KruftleTheme.dark()
          : KruftleTheme.light();

      test('the scheme matches the brightness it was asked for', () {
        expect(theme.colorScheme.brightness, brightness);
        expect(theme.scaffoldBackgroundColor, theme.colorScheme.surface);
      });

      test('body text is legible against the surface it sits on', () {
        // A 3:1 contrast ratio is the floor for large text in WCAG AA; body
        // text wants 4.5:1. Anything below that is a bug you can see.
        expect(
          _contrast(theme.colorScheme.onSurface, theme.colorScheme.surface),
          greaterThan(4.5),
        );
        expect(
          _contrast(
            theme.colorScheme.onSurfaceVariant,
            theme.colorScheme.surface,
          ),
          greaterThan(3.0),
          reason: 'secondary text is smaller but still has to be readable',
        );
      });

      test('the accent colours stay visible on this surface', () {
        for (final (name, color) in [
          ('primary', theme.colorScheme.primary),
          ('freed', KruftleTheme.freedFor(brightness)),
          ('warn', KruftleTheme.warnFor(brightness)),
          ('danger', KruftleTheme.dangerFor(brightness)),
        ]) {
          expect(
            _contrast(color, theme.colorScheme.surface),
            greaterThan(2.0),
            reason: '$name is invisible against the ${brightness.name} surface',
          );
        }
      });

      testWidgets('the wizard renders without overflowing', (tester) async {
        await pumpWizard(tester, (s) => s, brightness: brightness);
        expect(tester.takeException(), isNull);
      });
    });
  }

  test('the two themes are actually different', () {
    expect(
      KruftleTheme.light().colorScheme.surface,
      isNot(KruftleTheme.dark().colorScheme.surface),
    );
  });

  test('each semantic colour has a variant for the other brightness', () {
    // The dark-tuned green measures about 1.7:1 on the light surface, which is
    // why the pairs exist at all. If someone collapses a pair back to one
    // value, this fails before the contrast test does and says why.
    for (final (dark, light) in [
      (KruftleTheme.freed, KruftleTheme.freedLight),
      (KruftleTheme.warn, KruftleTheme.warnLight),
      (KruftleTheme.danger, KruftleTheme.dangerLight),
    ]) {
      expect(dark, isNot(light));
    }
  });
}

/// WCAG relative-luminance contrast ratio between two opaque colours.
double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}

double _luminance(Color color) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}
