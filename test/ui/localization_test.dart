// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/l10n/app_localizations.dart';
import 'package:kruftle/src/core/settings/settings.dart';

import 'wizard_test.dart' show pumpWizard;

void main() {
  group('the wizard renders in', () {
    for (final code in kSupportedLocaleCodes) {
      testWidgets(code, (tester) async {
        await pumpWizard(tester, (s) => s, locale: Locale(code));

        // The step rail is on every screen, so it is the cheapest proof that
        // the delegate resolved and the ARB for this locale actually loaded.
        final context = tester.element(find.byType(Scaffold).first);
        final l = L.of(context);

        expect(find.text(l.railFolder), findsOneWidget);
        expect(find.text(l.sourceHeading), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('a right-to-left locale lays out right to left', (tester) async {
    await pumpWizard(tester, (s) => s, locale: const Locale('ar'));

    final direction = Directionality.of(
      tester.element(find.byType(Scaffold).first),
    );

    expect(
      direction,
      TextDirection.rtl,
      reason: 'Arabic is the reason RTL is in the supported set at all',
    );
  });

  testWidgets('a left-to-right locale is unaffected', (tester) async {
    await pumpWizard(tester, (s) => s, locale: const Locale('ja'));

    expect(
      Directionality.of(tester.element(find.byType(Scaffold).first)),
      TextDirection.ltr,
    );
  });

  testWidgets('two locales do not render the same text', (tester) async {
    // Guards against the delegate silently falling back to English for
    // everything, which would make every other test here pass vacuously.
    await pumpWizard(tester, (s) => s, locale: const Locale('en'));
    final english = L
        .of(tester.element(find.byType(Scaffold).first))
        .sourceHeading;

    await pumpWizard(tester, (s) => s, locale: const Locale('ru'));
    final russian = L
        .of(tester.element(find.byType(Scaffold).first))
        .sourceHeading;

    expect(russian, isNot(english));
    expect(find.text(russian), findsOneWidget);
  });
}
