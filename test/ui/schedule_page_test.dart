// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/l10n/app_localizations.dart';
import 'package:kruftle/src/core/schedule/background_service.dart';
import 'package:kruftle/src/core/schedule/schedule.dart';
import 'package:kruftle/src/ui/schedule_page.dart';
import 'package:kruftle/src/ui/state/app_state.dart';
import 'package:kruftle/src/ui/state/schedule_controller.dart';
import 'package:kruftle/src/ui/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records rather than registering, so no test touches launchd.
class _Recording implements BackgroundService {
  var refuse = false;

  @override
  Future<bool> install(CleanupSchedule schedule) async => !refuse;

  @override
  Future<void> uninstall() async {}

  @override
  Future<bool> isInstalled() async => !refuse;
}

/// What the screen claims about the background job.
///
/// The claim is the whole feature: nobody is watching when a background
/// cleanup fires, so the line on this screen is the only evidence the user
/// ever gets that one is going to. It must never be reassuring when it is not
/// true.
void main() {
  Future<void> pump(
    WidgetTester tester,
    CleanupSchedule schedule, {
    _Recording? service,
  }) async {
    SharedPreferences.setMockInitialValues({
      CleanupSchedule.storageKey: schedule.encode(),
    });
    final preferences = await SharedPreferences.getInstance();

    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          appSupportDirectoryProvider.overrideWithValue('/tmp/kruftle-test'),
          backgroundServiceProvider.overrideWithValue(service ?? _Recording()),
        ],
        child: MaterialApp(
          theme: KruftleTheme.dark(),
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          home: const SchedulePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const configured = CleanupSchedule(
    enabled: true,
    root: '/work',
    runInBackground: true,
  );

  testWidgets('says it is registered once there is something to register', (
    tester,
  ) async {
    await pump(tester, configured);
    expect(find.textContaining('Registered with the system'), findsOneWidget);
  });

  testWidgets('claims nothing when no folder has been chosen', (tester) async {
    // The bug this stops: `runInBackground` on with no root reads as
    // "Registered with the system scheduler", while `isConfigured` is false so
    // nothing was ever handed to the operating system. The screen would be
    // promising a cleanup that could not happen.
    await pump(tester, configured.copyWith(root: ''));
    expect(find.textContaining('Registered with the system'), findsNothing);
    expect(find.textContaining('refused'), findsNothing);
  });

  testWidgets('says nothing at all while the switch is off', (tester) async {
    await pump(tester, configured.copyWith(runInBackground: false));
    expect(find.textContaining('Registered with the system'), findsNothing);
  });

  testWidgets('reports a refusal instead of a registration', (tester) async {
    final service = _Recording()..refuse = true;
    await pump(tester, configured, service: service);

    // The screen has to re-save for the controller to try an install, which is
    // what the user's own toggle does. The switches are, in order, the
    // reminder, the finish notification and the background run; touching the
    // middle one re-saves without changing the background choice.
    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();

    expect(find.textContaining('refused'), findsOneWidget);
    expect(find.textContaining('Registered with the system'), findsNothing);
  });

  testWidgets('the whole schedule card is hidden while it is switched off', (
    tester,
  ) async {
    await pump(tester, const CleanupSchedule());
    expect(find.textContaining('Run even when Kruftle'), findsNothing);
  });
}
