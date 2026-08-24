// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

enum ScheduleFrequency { daily, weekly, monthly }

/// A standing reminder to clean up.
///
/// **What this is not.** It does not wake a closed Kruftle. Doing that means a
/// launchd plist on macOS, a Task Scheduler entry on Windows and a systemd
/// timer on Linux, each of which has to be installed by the packager,
/// uninstalled cleanly, and kept in step with the app's own settings — three
/// installers' worth of moving parts for a developer tool the user opens on
/// purpose. So: the schedule is checked while Kruftle runs, and a run that was
/// missed while it was closed is offered at the next launch. That is stated
/// here, in the settings screen, and in `PROJECT_PLAN.md` §1, rather than
/// being left for someone to discover.
class CleanupSchedule {
  const CleanupSchedule({
    this.enabled = false,
    this.frequency = ScheduleFrequency.weekly,
    this.hour = 10,
    this.minute = 0,
    this.dayOfWeek = DateTime.monday,
    this.dayOfMonth = 1,
    this.root,
    this.lastRun,
    this.notifyOnFinish = true,
  });

  final bool enabled;
  final ScheduleFrequency frequency;

  /// Local time of day, 0–23 and 0–59.
  final int hour;
  final int minute;

  /// `DateTime.monday`..`DateTime.sunday`, for [ScheduleFrequency.weekly].
  final int dayOfWeek;

  /// 1–31, for [ScheduleFrequency.monthly]. Clamped to the last day of a month
  /// that is shorter — a "31st" schedule fires on the 30th in November and on
  /// the 28th or 29th in February, rather than skipping those months.
  final int dayOfMonth;

  /// Folder to scan. A schedule without one cannot be due, because there is
  /// nothing to remind the user to do.
  final String? root;

  /// When the schedule last fired, or when it was switched on.
  ///
  /// Set on enabling, which is what stops a schedule being due the instant it
  /// is created: "weekly from now" means a week from now, not immediately.
  final DateTime? lastRun;

  final bool notifyOnFinish;

  bool get isConfigured => enabled && (root?.isNotEmpty ?? false);

  /// The first moment at or after [from] that this schedule fires.
  ///
  /// Strictly after: a schedule that just fired is not immediately due again.
  DateTime nextRunAfter(DateTime from) {
    final candidate = switch (frequency) {
      ScheduleFrequency.daily => _atTime(from),
      ScheduleFrequency.weekly => _nextWeekday(from),
      ScheduleFrequency.monthly => _atDayOfMonth(from.year, from.month),
    };
    if (candidate.isAfter(from)) return candidate;

    return switch (frequency) {
      ScheduleFrequency.daily => _atTime(from.add(const Duration(days: 1))),
      // A week on, then re-aligned: adding seven days across a DST boundary
      // can land an hour out, and `_nextWeekday` puts it back on the wall
      // clock the user chose.
      ScheduleFrequency.weekly => _nextWeekday(
        candidate.add(const Duration(days: 1)),
      ),
      ScheduleFrequency.monthly => _atDayOfMonth(
        from.month == 12 ? from.year + 1 : from.year,
        from.month == 12 ? 1 : from.month + 1,
      ),
    };
  }

  /// Whether a cleanup is owed as of [now].
  bool isDue(DateTime now) {
    if (!isConfigured) return false;
    final since = lastRun;
    // No `lastRun` means the schedule was never started properly. Treating it
    // as due would fire the moment the app opens; treating it as not due is
    // the conservative reading, and the UI sets `lastRun` when enabling.
    if (since == null) return false;
    return !nextRunAfter(since).isAfter(now);
  }

  /// Whole days between the last run and [now], for the "it has been N days"
  /// line. Zero when nothing has run.
  int daysSinceLastRun(DateTime now) {
    final since = lastRun;
    if (since == null) return 0;
    final days = now.difference(since).inDays;
    return days < 0 ? 0 : days;
  }

  DateTime _atTime(DateTime day) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  DateTime _nextWeekday(DateTime from) {
    final target = dayOfWeek.clamp(DateTime.monday, DateTime.sunday);
    final ahead = (target - from.weekday + 7) % 7;
    return _atTime(from.add(Duration(days: ahead)));
  }

  /// The chosen day of [month], clamped to the last day the month actually
  /// has.
  DateTime _atDayOfMonth(int year, int month) {
    // Day zero of the following month is the last day of this one, which is
    // how you ask Dart for "how long is February in 2028" without a table.
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, dayOfMonth.clamp(1, lastDay), hour, minute);
  }

  CleanupSchedule copyWith({
    bool? enabled,
    ScheduleFrequency? frequency,
    int? hour,
    int? minute,
    int? dayOfWeek,
    int? dayOfMonth,
    String? root,
    DateTime? lastRun,
    bool? notifyOnFinish,
  }) => CleanupSchedule(
    enabled: enabled ?? this.enabled,
    frequency: frequency ?? this.frequency,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    root: root ?? this.root,
    lastRun: lastRun ?? this.lastRun,
    notifyOnFinish: notifyOnFinish ?? this.notifyOnFinish,
  );

  Map<String, Object?> toJson() => {
    'enabled': enabled,
    'frequency': frequency.name,
    'hour': hour,
    'minute': minute,
    'dayOfWeek': dayOfWeek,
    'dayOfMonth': dayOfMonth,
    'root': root,
    'lastRun': lastRun?.toIso8601String(),
    'notifyOnFinish': notifyOnFinish,
  };

  factory CleanupSchedule.fromJson(Map<String, Object?> json) {
    T? read<T>(String key) => json[key] is T ? json[key]! as T : null;
    const fallback = CleanupSchedule();

    return CleanupSchedule(
      enabled: read<bool>('enabled') ?? fallback.enabled,
      frequency:
          ScheduleFrequency.values
              .where((f) => f.name == read<String>('frequency'))
              .firstOrNull ??
          fallback.frequency,
      hour: read<int>('hour')?.clamp(0, 23) ?? fallback.hour,
      minute: read<int>('minute')?.clamp(0, 59) ?? fallback.minute,
      dayOfWeek:
          read<int>('dayOfWeek')?.clamp(DateTime.monday, DateTime.sunday) ??
          fallback.dayOfWeek,
      dayOfMonth: read<int>('dayOfMonth')?.clamp(1, 31) ?? fallback.dayOfMonth,
      root: read<String>('root'),
      lastRun: DateTime.tryParse(read<String>('lastRun') ?? ''),
      notifyOnFinish: read<bool>('notifyOnFinish') ?? fallback.notifyOnFinish,
    );
  }

  String encode() => jsonEncode(toJson());

  static CleanupSchedule decode(String? source) {
    if (source == null || source.isEmpty) return const CleanupSchedule();
    try {
      return CleanupSchedule.fromJson(
        jsonDecode(source) as Map<String, Object?>,
      );
    } on Object {
      return const CleanupSchedule();
    }
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
