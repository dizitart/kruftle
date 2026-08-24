// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/schedule/background_service.dart';
import '../../core/schedule/notifier.dart';
import '../../core/schedule/schedule.dart';
import 'app_state.dart';

/// Injectable so tests do not need a notification centre, and so a fake clock
/// can be supplied.
final desktopNotifierProvider = Provider<DesktopNotifier>(
  (_) => const SystemNotifier(),
);

final clockProvider = Provider<DateTime Function()>((_) => DateTime.now);

/// Injectable so a test never touches launchd, systemd or Task Scheduler.
final backgroundServiceProvider = Provider<BackgroundService>(
  (_) => const BackgroundService(),
);

/// Everything on screen about the schedule.
class ScheduleState {
  const ScheduleState({
    required this.schedule,
    this.dueSince,
    this.backgroundFailed = false,
  });

  final CleanupSchedule schedule;

  /// Set when a cleanup is owed and the user has not dismissed the notice.
  /// Null means nothing to show.
  final DateTime? dueSince;

  /// Set when the user asked for background runs and the operating system
  /// would not take the job. The switch stays where they put it and the screen
  /// says why, rather than flicking back and leaving them to guess.
  final bool backgroundFailed;

  bool get isDue => dueSince != null;

  ScheduleState copyWith({
    CleanupSchedule? schedule,
    DateTime? dueSince,
    bool clearDue = false,
    bool? backgroundFailed,
  }) => ScheduleState(
    schedule: schedule ?? this.schedule,
    dueSince: clearDue ? null : dueSince ?? this.dueSince,
    backgroundFailed: backgroundFailed ?? this.backgroundFailed,
  );
}

/// Watches the clock while Kruftle is open and raises the reminder.
///
/// The check runs at launch as well as on a timer, which is what makes a run
/// missed while the app was closed still surface — see the ceiling documented
/// on [CleanupSchedule].
class ScheduleController extends Notifier<ScheduleState> {
  Timer? _ticker;

  /// A minute is plenty: the schedule's resolution is a minute, and a timer
  /// this slow costs nothing.
  static const tickInterval = Duration(minutes: 1);

  DateTime Function() get _now => ref.read(clockProvider);

  @override
  ScheduleState build() {
    ref.onDispose(() => _ticker?.cancel());

    final schedule = CleanupSchedule.decode(
      ref.read(sharedPreferencesProvider).getString(CleanupSchedule.storageKey),
    );
    _ticker = Timer.periodic(tickInterval, (_) => check());

    return ScheduleState(
      schedule: schedule,
      dueSince: schedule.isDue(_now()) ? _now() : null,
    );
  }

  /// Raises the reminder if one is owed. Idempotent: a reminder already on
  /// screen is not raised again, and a dismissed one does not come back until
  /// the next occurrence.
  Future<void> check() async {
    if (state.isDue) return;
    if (!state.schedule.isDue(_now())) return;

    state = state.copyWith(dueSince: _now());

    final root = state.schedule.root;
    if (root == null) return;
    await ref
        .read(desktopNotifierProvider)
        .notify(title: 'Kruftle', body: root);
  }

  Future<void> save(CleanupSchedule updated) async {
    // Switching a schedule on starts its clock now, so "weekly from now" means
    // a week from now rather than immediately.
    final started = updated.enabled && updated.lastRun == null
        ? updated.copyWith(lastRun: _now())
        : updated;

    state = ScheduleState(
      schedule: started,
      dueSince: started.isDue(_now()) ? state.dueSince : null,
      backgroundFailed: state.backgroundFailed,
    );
    await ref
        .read(sharedPreferencesProvider)
        .setString(CleanupSchedule.storageKey, started.encode());

    await _syncBackgroundJob(started);
  }

  /// Keeps the operating system's copy of the schedule in step with ours.
  ///
  /// Called on every save rather than only when the switch is touched, because
  /// changing the day or the folder changes what the OS should be running and
  /// a job left on last week's time is worse than no job. Re-registering is
  /// idempotent on all three platforms.
  Future<void> _syncBackgroundJob(CleanupSchedule schedule) async {
    final service = ref.read(backgroundServiceProvider);
    final wanted = schedule.isConfigured && schedule.runInBackground;

    if (!wanted) {
      await service.uninstall();
      state = state.copyWith(backgroundFailed: false);
      return;
    }

    final installed = await service.install(schedule);
    state = state.copyWith(backgroundFailed: !installed);
  }

  Future<void> update(CleanupSchedule Function(CleanupSchedule) change) =>
      save(change(state.schedule));

  /// Hides the reminder without running anything. It returns at the next
  /// occurrence, not immediately.
  Future<void> dismiss() async {
    state = state.copyWith(clearDue: true);
    await save(state.schedule.copyWith(lastRun: _now()));
  }

  /// Records that a cleanup happened, which is what resets the interval.
  Future<void> markRan() async {
    state = state.copyWith(clearDue: true);
    await save(state.schedule.copyWith(lastRun: _now()));
  }

  /// Announces a finished run, when the user asked to be told.
  Future<void> announceFinished({
    required String title,
    required String body,
  }) async {
    if (!state.schedule.notifyOnFinish) return;
    await ref.read(desktopNotifierProvider).notify(title: title, body: body);
  }
}

final scheduleProvider = NotifierProvider<ScheduleController, ScheduleState>(
  ScheduleController.new,
);
