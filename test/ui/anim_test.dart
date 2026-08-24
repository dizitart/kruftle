// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/l10n/app_localizations.dart';
import 'package:kruftle/src/core/settings/settings.dart';
import 'package:kruftle/src/ui/anim/animated_bytes.dart';
import 'package:kruftle/src/ui/anim/cleaning_sweep.dart';
import 'package:kruftle/src/ui/anim/radar_sweep.dart';
import 'package:kruftle/src/ui/state/app_state.dart';
import 'package:kruftle/src/ui/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Puts one widget on screen with settings and localisation in place.
Future<void> pumpAnimated(
  WidgetTester tester,
  Widget child, {
  bool reduceMotion = false,
  bool platformDisablesAnimations = false,
}) async {
  SharedPreferences.setMockInitialValues({
    if (reduceMotion)
      'kruftle.settings.v1': const Settings(reduceMotion: true).encode(),
  });
  final preferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appSupportDirectoryProvider.overrideWithValue('/tmp/kruftle-test'),
      ],
      child: MaterialApp(
        theme: KruftleTheme.dark(),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: platformDisablesAnimations),
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    ),
  );
}

/// Reads back the painter a `CustomPaint` is currently using.
T painterOf<T extends CustomPainter>(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.byWidgetPredicate((w) => w is CustomPaint && w.painter is T),
  );
  return paint.painter! as T;
}

void main() {
  group('RadarSweep', () {
    testWidgets('keeps turning frame after frame', (tester) async {
      await pumpAnimated(tester, const RadarSweep(blipCount: 5));

      final first = painterOf<RadarPainter>(tester).turn;
      await tester.pump(const Duration(milliseconds: 300));
      final second = painterOf<RadarPainter>(tester).turn;
      await tester.pump(const Duration(milliseconds: 300));
      final third = painterOf<RadarPainter>(tester).turn;

      expect(second, isNot(first));
      expect(third, isNot(second));
      expect(painterOf<RadarPainter>(tester).animating, isTrue);
    });

    testWidgets('stops dead when the app is set to reduce motion', (
      tester,
    ) async {
      await pumpAnimated(
        tester,
        const RadarSweep(blipCount: 5),
        reduceMotion: true,
      );

      final first = painterOf<RadarPainter>(tester).turn;
      await tester.pump(const Duration(milliseconds: 900));
      final second = painterOf<RadarPainter>(tester).turn;

      expect(second, first, reason: 'the controller must not be repeating');
      expect(painterOf<RadarPainter>(tester).animating, isFalse);
    });

    testWidgets('stops when the platform asks for reduced motion', (
      tester,
    ) async {
      // The OS setting is honoured on its own — a user who set it there should
      // not have to find Kruftle's switch as well.
      await pumpAnimated(
        tester,
        const RadarSweep(blipCount: 5),
        platformDisablesAnimations: true,
      );

      final first = painterOf<RadarPainter>(tester).turn;
      await tester.pump(const Duration(milliseconds: 900));

      expect(painterOf<RadarPainter>(tester).turn, first);
      expect(painterOf<RadarPainter>(tester).animating, isFalse);
    });

    testWidgets('a still radar still shows what was found', (tester) async {
      await pumpAnimated(
        tester,
        const RadarSweep(blipCount: 12),
        reduceMotion: true,
      );

      // Reduced motion means less movement, not less information.
      expect(painterOf<RadarPainter>(tester).visibleBlips, 12);
    });

    test('blip count is capped so a huge scan stays cheap to paint', () {
      const painter = RadarPainter(
        turn: 0,
        blips: 5000,
        sweepColor: Colors.amber,
        ringColor: Colors.grey,
        blipColor: Colors.green,
      );
      expect(painter.visibleBlips, RadarPainter.maxBlips);
    });

    test('repaints only when something it draws has changed', () {
      const base = RadarPainter(
        turn: 0.5,
        blips: 3,
        sweepColor: Colors.amber,
        ringColor: Colors.grey,
        blipColor: Colors.green,
      );

      expect(base.shouldRepaint(base), isFalse);
      expect(
        base.shouldRepaint(
          const RadarPainter(
            turn: 0.6,
            blips: 3,
            sweepColor: Colors.amber,
            ringColor: Colors.grey,
            blipColor: Colors.green,
          ),
        ),
        isTrue,
      );
    });
  });

  group('CleaningSweep', () {
    testWidgets('the band keeps travelling', (tester) async {
      await pumpAnimated(
        tester,
        const SizedBox(width: 300, child: CleaningSweep(value: 0.5)),
      );
      await tester.pump(const Duration(milliseconds: 700)); // let value settle

      final first = painterOf<CleaningPainter>(tester).phase;
      await tester.pump(const Duration(milliseconds: 400));

      expect(painterOf<CleaningPainter>(tester).phase, isNot(first));
    });

    testWidgets('reduced motion leaves a plain determinate bar', (
      tester,
    ) async {
      await pumpAnimated(
        tester,
        const SizedBox(width: 300, child: CleaningSweep(value: 0.4)),
        reduceMotion: true,
      );
      await tester.pump(const Duration(milliseconds: 400));

      final painter = painterOf<CleaningPainter>(tester);
      expect(painter.animating, isFalse);
      expect(painter.phase, 0);
      expect(
        painter.value,
        closeTo(0.4, 0.001),
        reason: 'the progress itself must still be shown, and immediately',
      );
    });

    testWidgets('progress arrives without waiting for a tween', (tester) async {
      await pumpAnimated(
        tester,
        const SizedBox(width: 300, child: CleaningSweep(value: 1)),
        reduceMotion: true,
      );
      expect(painterOf<CleaningPainter>(tester).value, 1);
    });
  });

  group('AnimatedBytes', () {
    testWidgets('counts up rather than jumping', (tester) async {
      await pumpAnimated(tester, const AnimatedBytes(10 * 1024 * 1024));

      await tester.pump(const Duration(milliseconds: 100));
      final midway = tester.widget<Text>(find.byType(Text)).data!;

      await tester.pump(const Duration(seconds: 1));
      final settled = tester.widget<Text>(find.byType(Text)).data!;

      expect(midway, isNot(settled));
      expect(settled, '10.0 MiB');
    });

    testWidgets('reduced motion shows the final figure at once', (
      tester,
    ) async {
      await pumpAnimated(
        tester,
        const AnimatedBytes(10 * 1024 * 1024),
        reduceMotion: true,
      );
      await tester.pump();

      expect(tester.widget<Text>(find.byType(Text)).data, '10.0 MiB');
    });

    testWidgets('AnimatedCount settles on the exact integer', (tester) async {
      await pumpAnimated(tester, const AnimatedCount(37));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.widget<Text>(find.byType(Text)).data, '37');
    });
  });

  group('MeasuringShimmer', () {
    testWidgets('pulses while measuring', (tester) async {
      await pumpAnimated(tester, const MeasuringShimmer());

      Color colourNow() {
        final container = tester.widget<Container>(find.byType(Container));
        return (container.decoration! as BoxDecoration).color!;
      }

      final first = colourNow();
      await tester.pump(const Duration(milliseconds: 400));

      expect(colourNow(), isNot(first));
    });

    testWidgets('holds a single tone under reduced motion', (tester) async {
      await pumpAnimated(tester, const MeasuringShimmer(), reduceMotion: true);

      Color colourNow() =>
          (tester.widget<Container>(find.byType(Container)).decoration!
                  as BoxDecoration)
              .color!;

      final first = colourNow();
      await tester.pump(const Duration(milliseconds: 800));

      expect(colourNow(), first);
    });
  });

  testWidgets('no animation leaves a ticker running after disposal', (
    tester,
  ) async {
    // A repeating controller schedules a frame forever. Leaving one alive
    // behind a closed screen is a battery cost with nothing on screen to show
    // for it, and the test framework fails the test if one outlives its state.
    await pumpAnimated(
      tester,
      const Column(
        children: [
          RadarSweep(blipCount: 3),
          SizedBox(width: 200, child: CleaningSweep(value: 0.3)),
          MeasuringShimmer(),
        ],
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await pumpAnimated(tester, const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.takeException(), isNull);
  });
}
