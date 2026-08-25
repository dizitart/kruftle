// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/l10n/app_localizations.dart';
import 'package:kruftle/src/core/settings/settings.dart';
import 'package:kruftle/src/ui/already_running_page.dart';

/// The second-instance window is small and cannot be shrunk below 480x300 —
/// see the `WindowOptions` in `main.dart`. It has no scroll view, so a long
/// translation of the notice has to fit, and German is the one that finds out.
void main() {
  for (final code in kSupportedLocaleCodes) {
    testWidgets('the already-open notice fits its window in $code', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(480, 300);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // The window opens before any setting has been read, so it follows the
      // system locale rather than a stored one.
      tester.platformDispatcher.localesTestValue = [Locale(code)];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(const AlreadyRunningApp());
      await tester.pumpAndSettle();

      final l = L.of(tester.element(find.byType(Scaffold)));
      expect(find.text(l.alreadyRunningTitle), findsOneWidget);
      expect(find.text(l.alreadyRunningBody), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
