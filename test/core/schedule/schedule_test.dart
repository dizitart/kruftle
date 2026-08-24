// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/schedule/schedule.dart';

CleanupSchedule daily({int hour = 10, int minute = 0}) => CleanupSchedule(
  enabled: true,
  frequency: ScheduleFrequency.daily,
  hour: hour,
  minute: minute,
  root: '/work',
);

CleanupSchedule weekly({int dayOfWeek = DateTime.monday, int hour = 10}) =>
    CleanupSchedule(
      enabled: true,
      frequency: ScheduleFrequency.weekly,
      dayOfWeek: dayOfWeek,
      hour: hour,
      root: '/work',
    );

CleanupSchedule monthly({int dayOfMonth = 1, int hour = 10}) => CleanupSchedule(
  enabled: true,
  frequency: ScheduleFrequency.monthly,
  dayOfMonth: dayOfMonth,
  hour: hour,
  root: '/work',
);

void main() {
  group('daily', () {
    test('later today when the time has not passed', () {
      expect(
        daily().nextRunAfter(DateTime(2026, 8, 24, 9, 30)),
        DateTime(2026, 8, 24, 10),
      );
    });

    test('tomorrow when it has', () {
      expect(
        daily().nextRunAfter(DateTime(2026, 8, 24, 10, 30)),
        DateTime(2026, 8, 25, 10),
      );
    });

    test('exactly on the minute counts as passed, not as due again', () {
      // Otherwise a schedule that just fired is instantly due again and the
      // user is nagged in a loop.
      expect(
        daily().nextRunAfter(DateTime(2026, 8, 24, 10)),
        DateTime(2026, 8, 25, 10),
      );
    });

    test('rolls over a month end', () {
      expect(
        daily().nextRunAfter(DateTime(2026, 8, 31, 11)),
        DateTime(2026, 9, 1, 10),
      );
    });

    test('rolls over a year end', () {
      expect(
        daily().nextRunAfter(DateTime(2026, 12, 31, 23, 59)),
        DateTime(2027, 1, 1, 10),
      );
    });
  });

  group('weekly', () {
    test('later this week', () {
      // 2026-08-24 is a Monday.
      expect(
        weekly(
          dayOfWeek: DateTime.friday,
        ).nextRunAfter(DateTime(2026, 8, 24, 9)),
        DateTime(2026, 8, 28, 10),
      );
    });

    test('later today when today is the day and the time has not passed', () {
      expect(
        weekly().nextRunAfter(DateTime(2026, 8, 24, 9)),
        DateTime(2026, 8, 24, 10),
      );
    });

    test('a week on when today is the day and the time has passed', () {
      expect(
        weekly().nextRunAfter(DateTime(2026, 8, 24, 11)),
        DateTime(2026, 8, 31, 10),
      );
    });

    test('wraps backwards across the weekend', () {
      // Saturday, looking for the next Monday.
      expect(
        weekly().nextRunAfter(DateTime(2026, 8, 29, 12)),
        DateTime(2026, 8, 31, 10),
      );
    });

    test('every weekday lands on the weekday it was asked for', () {
      for (var day = DateTime.monday; day <= DateTime.sunday; day++) {
        final next = weekly(
          dayOfWeek: day,
        ).nextRunAfter(DateTime(2026, 8, 24, 12));
        expect(next.weekday, day, reason: 'asked for weekday $day');
        expect(next.isAfter(DateTime(2026, 8, 24, 12)), isTrue);
      }
    });
  });

  group('monthly', () {
    test('later this month', () {
      expect(
        monthly(dayOfMonth: 28).nextRunAfter(DateTime(2026, 8, 24)),
        DateTime(2026, 8, 28, 10),
      );
    });

    test('next month when the day has passed', () {
      expect(
        monthly(dayOfMonth: 1).nextRunAfter(DateTime(2026, 8, 24)),
        DateTime(2026, 9, 1, 10),
      );
    });

    test('December rolls into January of the next year', () {
      expect(
        monthly(dayOfMonth: 1).nextRunAfter(DateTime(2026, 12, 24)),
        DateTime(2027, 1, 1, 10),
      );
    });

    test('the 31st fires on the 30th in a 30-day month', () {
      // Rather than skipping the month, which is what a naive implementation
      // does and what a user would report as "it never ran in November".
      expect(
        monthly(dayOfMonth: 31).nextRunAfter(DateTime(2026, 11, 1)),
        DateTime(2026, 11, 30, 10),
      );
    });

    test('the 31st fires on the 28th in a non-leap February', () {
      expect(
        monthly(dayOfMonth: 31).nextRunAfter(DateTime(2026, 2, 1)),
        DateTime(2026, 2, 28, 10),
      );
    });

    test('the 31st fires on the 29th in a leap February', () {
      expect(
        monthly(dayOfMonth: 31).nextRunAfter(DateTime(2028, 2, 1)),
        DateTime(2028, 2, 29, 10),
      );
      expect(
        monthly(dayOfMonth: 29).nextRunAfter(DateTime(2028, 2, 1)),
        DateTime(2028, 2, 29, 10),
      );
    });

    test('a leap day schedule still fires every month', () {
      // Twelve consecutive advances, none of them skipping or repeating.
      var at = DateTime(2028, 1, 1);
      final fired = <DateTime>[];
      for (var i = 0; i < 12; i++) {
        at = monthly(dayOfMonth: 29).nextRunAfter(at);
        fired.add(at);
      }

      expect(fired, hasLength(12));
      expect(fired.map((d) => d.month).toSet(), {
        for (var m = 1; m <= 12; m++) m,
      }, reason: 'no month may be skipped');
      for (var i = 1; i < fired.length; i++) {
        expect(fired[i].isAfter(fired[i - 1]), isTrue);
      }
    });
  });

  group('advancing never stalls', () {
    test('every frequency always moves forward', () {
      // The failure this guards against is an infinite loop in the caller:
      // `nextRunAfter` returning something not strictly after its input.
      for (final schedule in [daily(), weekly(), monthly(dayOfMonth: 31)]) {
        var at = DateTime(2026, 1, 1, 0, 0);
        for (var i = 0; i < 400; i++) {
          final next = schedule.nextRunAfter(at);
          expect(
            next.isAfter(at),
            isTrue,
            reason: '${schedule.frequency.name} stalled at $at',
          );
          at = next;
        }
      }
    });

    test('a spring-forward gap does not trap the schedule', () {
      // In many zones 02:30 does not exist on the DST transition day. Dart
      // normalises such a DateTime rather than throwing, and what matters is
      // only that the result still moves forward.
      final schedule = daily(hour: 2, minute: 30);
      var at = DateTime(2026, 3, 7, 12);
      for (var i = 0; i < 10; i++) {
        final next = schedule.nextRunAfter(at);
        expect(next.isAfter(at), isTrue);
        at = next;
      }
    });

    test('the wall-clock hour survives a weekly step across a DST boundary', () {
      // Adding seven times twenty-four hours lands an hour out; re-aligning to
      // the weekday puts the user's chosen time back.
      final schedule = weekly(dayOfWeek: DateTime.sunday, hour: 9);
      var at = DateTime(2026, 2, 1, 12);
      for (var i = 0; i < 20; i++) {
        at = schedule.nextRunAfter(at);
        expect(at.hour, 9, reason: 'drifted at $at');
        expect(at.weekday, DateTime.sunday);
      }
    });
  });

  group('isDue', () {
    test('not due before the interval has elapsed', () {
      final schedule = daily().copyWith(lastRun: DateTime(2026, 8, 24, 10));
      expect(schedule.isDue(DateTime(2026, 8, 24, 18)), isFalse);
    });

    test('due once the next occurrence has passed', () {
      final schedule = daily().copyWith(lastRun: DateTime(2026, 8, 24, 10));
      expect(schedule.isDue(DateTime(2026, 8, 25, 10)), isTrue);
      expect(schedule.isDue(DateTime(2026, 8, 26, 9)), isTrue);
    });

    test('a schedule that was never started is not due', () {
      // Otherwise switching it on fires the reminder in the same breath.
      expect(daily().isDue(DateTime(2030, 1, 1)), isFalse);
    });

    test('a disabled schedule is never due', () {
      final schedule = daily().copyWith(
        enabled: false,
        lastRun: DateTime(2020),
      );
      expect(schedule.isDue(DateTime(2030, 1, 1)), isFalse);
    });

    test('a schedule with no folder is never due', () {
      const schedule = CleanupSchedule(enabled: true);
      expect(
        schedule.copyWith(lastRun: DateTime(2020)).isDue(DateTime(2030)),
        isFalse,
        reason: 'there would be nothing to remind the user to do',
      );
    });

    test('a run missed while the app was closed is still due', () {
      // The whole reason the check happens at launch as well as on a timer.
      final schedule = weekly().copyWith(lastRun: DateTime(2026, 1, 1, 10));
      expect(schedule.isDue(DateTime(2026, 8, 24, 10)), isTrue);
    });
  });

  group('daysSinceLastRun', () {
    test('counts whole days', () {
      final schedule = daily().copyWith(lastRun: DateTime(2026, 8, 20, 10));
      expect(schedule.daysSinceLastRun(DateTime(2026, 8, 24, 11)), 4);
    });

    test('is zero when nothing has run', () {
      expect(daily().daysSinceLastRun(DateTime(2026, 8, 24)), 0);
    });

    test('never goes negative when the clock moves backwards', () {
      final schedule = daily().copyWith(lastRun: DateTime(2026, 8, 24));
      expect(schedule.daysSinceLastRun(DateTime(2026, 8, 20)), 0);
    });
  });

  group('storage', () {
    test('round-trips through JSON', () {
      final original = monthly(dayOfMonth: 15, hour: 7).copyWith(
        minute: 45,
        lastRun: DateTime(2026, 8, 24, 7, 45),
        notifyOnFinish: false,
      );

      final restored = CleanupSchedule.decode(original.encode());

      expect(restored.frequency, ScheduleFrequency.monthly);
      expect(restored.dayOfMonth, 15);
      expect(restored.hour, 7);
      expect(restored.minute, 45);
      expect(restored.root, '/work');
      expect(restored.lastRun, DateTime(2026, 8, 24, 7, 45));
      expect(restored.notifyOnFinish, isFalse);
    });

    test('defaults are off and harmless', () {
      const schedule = CleanupSchedule();
      expect(schedule.enabled, isFalse);
      expect(schedule.root, isNull);
      expect(schedule.isConfigured, isFalse);
    });

    test('nonsense values are clamped rather than fatal', () {
      final restored = CleanupSchedule.decode(
        '{"hour": 99, "minute": -4, "dayOfMonth": 44, "dayOfWeek": 0}',
      );
      expect(restored.hour, 23);
      expect(restored.minute, 0);
      expect(restored.dayOfMonth, 31);
      expect(restored.dayOfWeek, DateTime.monday);
    });

    test('corrupt storage yields the default schedule', () {
      expect(CleanupSchedule.decode('not json').enabled, isFalse);
      expect(CleanupSchedule.decode(null).enabled, isFalse);
      expect(CleanupSchedule.decode('').enabled, isFalse);
    });

    test('an unknown frequency falls back rather than throwing', () {
      expect(
        CleanupSchedule.decode('{"frequency": "fortnightly"}').frequency,
        ScheduleFrequency.weekly,
      );
    });
  });
}
