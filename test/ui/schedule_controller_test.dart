// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/schedule/notifier.dart';
import 'package:kruftle/src/core/schedule/schedule.dart';
import 'package:kruftle/src/ui/state/app_state.dart';
import 'package:kruftle/src/ui/state/schedule_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A clock the test moves by hand, so nothing here waits on real time.
class FakeClock {
  FakeClock(this._now);

  DateTime _now;

  DateTime call() => _now;

  void advance(Duration by) => _now = _now.add(by);
  void set(DateTime to) => _now = to;
}

Future<(ProviderContainer, FakeClock, RecordingNotifier)> harness({
  CleanupSchedule? stored,
  DateTime? now,
}) async {
  SharedPreferences.setMockInitialValues({
    if (stored != null) 'kruftle.schedule.v1': stored.encode(),
  });
  final preferences = await SharedPreferences.getInstance();
  final clock = FakeClock(now ?? DateTime(2026, 8, 24, 12));
  final notifier = RecordingNotifier();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      appSupportDirectoryProvider.overrideWithValue('/tmp/kruftle-test'),
      clockProvider.overrideWithValue(clock.call),
      desktopNotifierProvider.overrideWithValue(notifier),
    ],
  );
  addTearDown(container.dispose);
  return (container, clock, notifier);
}

const _weekly = CleanupSchedule(
  enabled: true,
  frequency: ScheduleFrequency.weekly,
  dayOfWeek: DateTime.monday,
  hour: 10,
  root: '/work',
);

void main() {
  test('nothing is due on a fresh install', () async {
    final (container, _, notifier) = await harness();

    expect(container.read(scheduleProvider).isDue, isFalse);
    expect(container.read(scheduleProvider).schedule.enabled, isFalse);
    expect(notifier.sent, isEmpty);
  });

  test(
    'enabling a schedule starts its clock rather than firing at once',
    () async {
      // "Weekly from now" has to mean a week from now. A reminder that appears
      // the instant you switch it on is a bug people uninstall over.
      final (container, _, notifier) = await harness();

      await container.read(scheduleProvider.notifier).save(_weekly);

      expect(container.read(scheduleProvider).schedule.lastRun, isNotNull);
      expect(container.read(scheduleProvider).isDue, isFalse);
      expect(notifier.sent, isEmpty);
    },
  );

  test('a reminder appears once the interval has passed', () async {
    final (container, clock, notifier) = await harness();
    await container.read(scheduleProvider.notifier).save(_weekly);

    clock.advance(const Duration(days: 3));
    await container.read(scheduleProvider.notifier).check();
    expect(container.read(scheduleProvider).isDue, isFalse);

    clock.advance(const Duration(days: 5));
    await container.read(scheduleProvider.notifier).check();

    expect(container.read(scheduleProvider).isDue, isTrue);
    expect(notifier.sent, hasLength(1));
    expect(notifier.sent.single.body, contains('/work'));
  });

  test('a reminder is raised only once, not on every tick', () async {
    final (container, clock, notifier) = await harness();
    await container.read(scheduleProvider.notifier).save(_weekly);

    clock.advance(const Duration(days: 10));
    for (var i = 0; i < 5; i++) {
      await container.read(scheduleProvider.notifier).check();
    }

    expect(notifier.sent, hasLength(1));
  });

  test('a run missed while the app was closed surfaces at launch', () async {
    // The whole reason the ceiling is acceptable: the reminder is not lost,
    // it just arrives when Kruftle is next opened.
    final (container, _, _) = await harness(
      stored: _weekly.copyWith(lastRun: DateTime(2026, 1, 1, 10)),
      now: DateTime(2026, 8, 24, 12),
    );

    expect(
      container.read(scheduleProvider).isDue,
      isTrue,
      reason: 'the state is due the moment the controller is built',
    );
  });

  test('dismissing hides it until the next occurrence', () async {
    final (container, clock, _) = await harness();
    final controller = container.read(scheduleProvider.notifier);

    await controller.save(_weekly);
    clock.advance(const Duration(days: 10));
    await controller.check();
    expect(container.read(scheduleProvider).isDue, isTrue);

    await controller.dismiss();
    expect(container.read(scheduleProvider).isDue, isFalse);

    // Still not back a day later…
    clock.advance(const Duration(days: 1));
    await controller.check();
    expect(container.read(scheduleProvider).isDue, isFalse);

    // …but back once the next week has elapsed.
    clock.advance(const Duration(days: 8));
    await controller.check();
    expect(container.read(scheduleProvider).isDue, isTrue);
  });

  test('running a cleanup resets the interval', () async {
    final (container, clock, _) = await harness();
    final controller = container.read(scheduleProvider.notifier);

    await controller.save(_weekly);
    clock.advance(const Duration(days: 10));
    await controller.check();

    await controller.markRan();

    expect(container.read(scheduleProvider).isDue, isFalse);
    expect(
      container.read(scheduleProvider).schedule.lastRun,
      DateTime(2026, 9, 3, 12),
    );
  });

  test('a disabled schedule never raises anything', () async {
    final (container, clock, notifier) = await harness(
      stored: _weekly.copyWith(enabled: false, lastRun: DateTime(2020)),
    );

    clock.advance(const Duration(days: 400));
    await container.read(scheduleProvider.notifier).check();

    expect(container.read(scheduleProvider).isDue, isFalse);
    expect(notifier.sent, isEmpty);
  });

  test('a schedule with no folder never raises anything', () async {
    final (container, clock, notifier) = await harness(
      stored: const CleanupSchedule(
        enabled: true,
      ).copyWith(lastRun: DateTime(2020)),
    );

    clock.advance(const Duration(days: 400));
    await container.read(scheduleProvider.notifier).check();

    expect(container.read(scheduleProvider).isDue, isFalse);
    expect(notifier.sent, isEmpty);
  });

  test('the finish notification is only sent when asked for', () async {
    final (container, _, notifier) = await harness();
    final controller = container.read(scheduleProvider.notifier);

    await controller.save(_weekly.copyWith(notifyOnFinish: false));
    await controller.announceFinished(title: 'Kruftle', body: '1 GiB');
    expect(notifier.sent, isEmpty);

    await controller.save(
      container.read(scheduleProvider).schedule.copyWith(notifyOnFinish: true),
    );
    await controller.announceFinished(title: 'Kruftle', body: '1 GiB');
    expect(notifier.sent.single.body, '1 GiB');
  });

  test('the schedule survives a restart', () async {
    final (container, _, _) = await harness();
    await container
        .read(scheduleProvider.notifier)
        .save(_weekly.copyWith(dayOfWeek: DateTime.friday, hour: 18));

    // A second container over the same preferences is what a relaunch is.
    final preferences = await SharedPreferences.getInstance();
    final reopened = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appSupportDirectoryProvider.overrideWithValue('/tmp/kruftle-test'),
        clockProvider.overrideWithValue(() => DateTime(2026, 8, 24, 12)),
        desktopNotifierProvider.overrideWithValue(RecordingNotifier()),
      ],
    );
    addTearDown(reopened.dispose);

    final restored = reopened.read(scheduleProvider).schedule;
    expect(restored.enabled, isTrue);
    expect(restored.dayOfWeek, DateTime.friday);
    expect(restored.hour, 18);
    expect(restored.root, '/work');
  });
}
