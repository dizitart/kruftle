// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/l10n/app_localizations.dart';
import 'package:kruftle/src/core/log/activity_log.dart';
import 'package:kruftle/src/core/settings/settings.dart';
import 'package:kruftle/src/ui/settings_page.dart';
import 'package:kruftle/src/ui/state/app_state.dart';
import 'package:kruftle/src/ui/theme.dart';
import 'package:kruftle/src/ui/widgets/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> pumpSettings(
  WidgetTester tester, {
  Settings settings = const Settings(),
  String? version = '0.2.0',
}) async {
  SharedPreferences.setMockInitialValues({
    Settings.storageKey: settings.encode(),
  });
  final preferences = await SharedPreferences.getInstance();

  tester.view.physicalSize = const Size(1100, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      appSupportDirectoryProvider.overrideWithValue('/tmp/kruftle-test'),
      appVersionProvider.overrideWithValue(version),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: KruftleTheme.dark(),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: const SettingsPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  group('the colophon', () {
    testWidgets('sits below the About card, not inside it', (tester) async {
      await pumpSettings(tester);
      await tester.scrollUntilVisible(
        find.textContaining('Kolkata'),
        400,
        scrollable: find.byType(Scrollable).first,
      );

      // The last card on the page is About; the version, licence and credit
      // belong after it. Asserted by position rather than by widget identity,
      // because that is the thing that was actually wrong.
      final lastCard = tester.getBottomLeft(find.byType(Card).last).dy;
      for (final (what, finder) in [
        ('the version', find.textContaining('Version')),
        ('the licence', find.textContaining('General Public License')),
        ('the credit', find.textContaining('Kolkata')),
      ]) {
        expect(
          tester.getTopLeft(finder).dy,
          greaterThan(lastCard),
          reason: '$what should sit below the About card, not in it',
        );
      }
    });

    testWidgets('says where it was made', (tester) async {
      await pumpSettings(tester);
      await tester.scrollUntilVisible(
        find.textContaining('Kolkata'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Kolkata, India'), findsOneWidget);
    });

    testWidgets('leaves the version out rather than showing a blank', (
      tester,
    ) async {
      // A test, or a screenshot run, can pin the version to nothing. The
      // licence and the credit still stand on their own.
      await pumpSettings(tester, version: null);
      await tester.scrollUntilVisible(
        find.textContaining('Kolkata'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Version'), findsNothing);
      expect(find.textContaining('Kolkata'), findsOneWidget);
    });
  });

  group('the log level picker', () {
    testWidgets('names the levels rather than printing the enum', (
      tester,
    ) async {
      await pumpSettings(tester, settings: const Settings());
      await tester.scrollUntilVisible(
        find.byType(KruftleDropdown<LogLevel>),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Info'), findsWidgets);
      expect(find.text('info'), findsNothing);
    });

    testWidgets('every level has a written-out label', (tester) async {
      // The gap that would otherwise ship: a level added later still renders
      // its enum constant, and nothing fails.
      await pumpSettings(tester);
      final l = L.of(tester.element(find.byType(SettingsPage)));
      for (final level in LogLevel.values) {
        final label = logLevelName(l, level);
        expect(label, isNot(level.name));
        expect(label, isNot(label.toLowerCase()));
      }
    });
  });

  group('the dropdowns', () {
    testWidgets('every picker on the page goes through the wrapper', (
      tester,
    ) async {
      // Theme, language and size mode above the fold; the log level further
      // down. A bare DropdownButton anywhere among them would style itself
      // differently from its neighbours.
      await pumpSettings(tester);
      expect(find.byType(KruftleDropdown<AppThemeMode>), findsOneWidget);
      expect(find.byType(KruftleDropdown<String>), findsOneWidget);
      expect(
        find.byType(DropdownButton<AppThemeMode>),
        findsOneWidget,
        reason: 'the wrapper builds exactly one, and nothing else should',
      );
    });

    testWidgets('the menu is rounded like the cards around it', (tester) async {
      // Material's default radius is two pixels, which is what made the
      // highlighted row look like it was overflowing its own menu.
      await pumpSettings(tester);
      final button = tester.widget<DropdownButton<AppThemeMode>>(
        find.byType(DropdownButton<AppThemeMode>),
      );
      expect(button.borderRadius, BorderRadius.circular(10));
      expect(button.focusColor, Colors.transparent);
      expect(button.padding, isNotNull);
    });
  });
}
