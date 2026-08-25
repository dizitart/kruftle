// SPDX-License-Identifier: GPL-3.0-or-later
//
// Renders each screen offscreen and writes it to `build/shots/`, so a change
// to the interface can be looked at without a person driving the app.
//
// Not a golden test: nothing here asserts and no image is committed. It is a
// darkroom — the widget tree is the real one, laid out at a real window size,
// and the PNG exists to be looked at.
//
// It lives under `test/` because it is a widget test in everything but name,
// and its filename does not end in `_test.dart`, so the suite skips it unless
// it is named:
//
//   flutter test test/tools/shots.dart
//
// Add `--dart-define=locale=de` for another language and
// `--dart-define=brightness=light` for the light palette.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/l10n/app_localizations.dart';
import 'package:kruftle/src/core/log/activity_log.dart';
import 'package:kruftle/src/core/schedule/background_service.dart';
import 'package:kruftle/src/core/schedule/schedule.dart';
import 'package:kruftle/src/core/settings/settings.dart';
import 'package:kruftle/src/ui/app.dart';
import 'package:kruftle/src/ui/consent_page.dart';
import 'package:kruftle/src/ui/global_caches_page.dart';
import 'package:kruftle/src/ui/profiles_page.dart';
import 'package:kruftle/src/ui/schedule_page.dart';
import 'package:kruftle/src/ui/settings_page.dart';
import 'package:kruftle/src/ui/state/app_state.dart';
import 'package:kruftle/src/ui/state/schedule_controller.dart';
import 'package:kruftle/src/ui/theme.dart';
import 'package:kruftle/src/ui/tour_page.dart';
import 'package:kruftle/src/ui/widgets/common.dart';
import 'package:kruftle/src/ui/wizard/wizard_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _locale = String.fromEnvironment('locale', defaultValue: 'en');
const _brightness = String.fromEnvironment('brightness', defaultValue: 'dark');

/// Takes the job and does nothing with it, so rendering the schedule screen
/// never registers a real launchd agent on the machine doing the rendering.
class _NoBackgroundService implements BackgroundService {
  const _NoBackgroundService();

  @override
  Future<bool> install(CleanupSchedule schedule) async => true;

  @override
  Future<void> uninstall() async {}

  @override
  Future<bool> isInstalled() async => true;
}

/// Real glyphs instead of the test harness's blank boxes.
///
/// `flutter test` renders every unloaded family as a placeholder rectangle,
/// which is fine for asserting a layout and useless for looking at one. These
/// are the machine's own fonts, loaded under the names the app asks for:
/// `ShotSans` is pushed onto the theme, and `SF Mono` is what
/// `KruftleTheme.monoFamily` already resolves to on macOS.
Future<bool> _loadFonts() async {
  const families = {
    'ShotSans': [
      '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
      '/System/Library/Fonts/Supplemental/Arial Bold.ttf',
    ],
    'SF Mono': ['/System/Library/Fonts/Monaco.ttf'],
  };

  // The icon font ships with the SDK rather than with the app, so it is found
  // through the root `flutter test` puts in the environment.
  final iconFont = File(
    '${Platform.environment['FLUTTER_ROOT']}'
    '/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (iconFont.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(Future.value(iconFont.readAsBytesSync().buffer.asByteData()));
    await loader.load();
  }

  for (final entry in families.entries) {
    final files = entry.value.map(File.new).where((f) => f.existsSync());
    if (files.isEmpty) return false;
    final loader = FontLoader(entry.key);
    for (final file in files) {
      loader.addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    }
    await loader.load();
  }
  return true;
}

void main() {
  Directory('build/shots').createSync(recursive: true);
  final key = GlobalKey();
  var fonts = false;

  setUpAll(() async => fonts = await _loadFonts());

  /// PNG encoding runs on the real event loop, which the widget tester's fake
  /// one otherwise never advances — without `runAsync` the future for
  /// `toByteData` simply never completes and the test hangs until the suite
  /// times out.
  Future<void> capture(WidgetTester tester, String name) async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File(
        'build/shots/$name.png',
      ).writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  Future<void> shoot(
    WidgetTester tester,
    String name,
    Widget screen, {
    Settings settings = const Settings(),
    CleanupSchedule? schedule,
    Size size = const Size(1160, 840),
    Duration settle = const Duration(milliseconds: 600),
    Future<void> Function(WidgetTester)? then,
    bool whole = false,
  }) async {
    SharedPreferences.setMockInitialValues({
      Settings.storageKey: settings.encode(),
      if (schedule != null) CleanupSchedule.storageKey: schedule.encode(),
    });
    final preferences = await SharedPreferences.getInstance();

    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          appSupportDirectoryProvider.overrideWithValue('/tmp/kruftle-shots'),
          appVersionProvider.overrideWithValue('0.3.0'),
          backgroundServiceProvider.overrideWithValue(
            const _NoBackgroundService(),
          ),
        ],
        child: RepaintBoundary(
          key: key,
          child: whole
              ? const KruftleApp()
              : MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme:
                      (_brightness == 'light'
                              ? KruftleTheme.light()
                              : KruftleTheme.dark())
                          .copyWith(
                            textTheme: fonts
                                ? (_brightness == 'light'
                                          ? KruftleTheme.light()
                                          : KruftleTheme.dark())
                                      .textTheme
                                      .apply(fontFamily: 'ShotSans')
                                : null,
                          ),
                  locale: const Locale(_locale),
                  localizationsDelegates: L.localizationsDelegates,
                  supportedLocales: L.supportedLocales,
                  home: screen,
                ),
        ),
      ),
    );

    // `pumpAndSettle` never returns against the app's looping animations, so
    // time is advanced by hand instead. See PROGRESS.md §6.
    await tester.pump();
    await tester.pump(settle);

    await capture(tester, name);
    if (then != null) await then(tester);
  }

  testWidgets('settings, top and colophon', (tester) async {
    await shoot(
      tester,
      'settings-top',
      const SettingsPage(),
      then: (tester) async {
        await tester.drag(find.byType(ListView), const Offset(0, -2400));
        await tester.pump(const Duration(milliseconds: 400));
        await capture(tester, 'settings-colophon');
      },
    );
  });

  testWidgets('settings, a dropdown menu open', (tester) async {
    await shoot(
      tester,
      'settings-menu-closed',
      const SettingsPage(),
      then: (tester) async {
        await tester.drag(find.byType(ListView), const Offset(0, -1250));
        await tester.pump(const Duration(milliseconds: 400));
        await capture(tester, 'settings-logging');
        await tester.tap(find.byType(KruftleDropdown<LogLevel>));
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await capture(tester, 'settings-menu-open');
      },
    );
  });

  testWidgets('schedule', (tester) async {
    await shoot(
      tester,
      'schedule-on',
      const SchedulePage(),
      schedule: CleanupSchedule(
        enabled: true,
        runInBackground: true,
        root: '/Volumes/External/codebase',
        lastRun: DateTime(2026, 8, 20, 10),
      ),
    );
  });

  testWidgets('schedule, switched off', (tester) async {
    await shoot(tester, 'schedule-off', const SchedulePage());
  });

  testWidgets('global caches', (tester) async {
    await shoot(
      tester,
      'caches',
      const GlobalCachesPage(),
      settle: const Duration(seconds: 25),
    );
  });

  testWidgets('profiles', (tester) async {
    await shoot(tester, 'profiles', const ProfilesPage());
  });

  testWidgets('tour', (tester) async {
    await shoot(tester, 'tour', const TourScreen());
  });

  testWidgets('the consent gate', (tester) async {
    await shoot(tester, 'consent', const ConsentScreen());
  });

  testWidgets('the whole window, title bar included', (tester) async {
    // `KruftleApp` rather than a screen, because the title bar is private to
    // it and the alignment of its buttons is the thing being looked at.
    // `hasAcceptedLegal` and `hasSeenTour` are what get past the two
    // first-run gates.
    await shoot(
      tester,
      'window',
      const SizedBox.shrink(),
      settings: const Settings(
        hasAcceptedLegal: true,
        hasSeenTour: true,
        checkForUpdates: false,
        defaultRoots: ['/Volumes/External/codebase'],
      ),
      whole: true,
    );
  });

  testWidgets('wizard, the source step', (tester) async {
    await shoot(
      tester,
      'wizard-source',
      const Scaffold(body: WizardShell()),
      settings: const Settings(defaultRoots: ['/Volumes/External/codebase']),
    );
  });
}
