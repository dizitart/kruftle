// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/schedule/notifier.dart';
import '../../core/schedule/schedule.dart';
import 'app_state.dart';

const _scheduleKey = 'kruftle.schedule.v1';

/// Injectable so tests do not need a notification centre, and so a fake clock
/// can be supplied.
final desktopNotifierProvider = Provider<DesktopNotifier>(
  (_) => const SystemNotifier(),
);

final clockProvider = Provider<DateTime Function()>((_) => DateTime.now);

/// Everything on screen about the schedule.
class ScheduleState {
  const ScheduleState({required this.schedule, this.dueSince});

  final CleanupSchedule schedule;

  /// Set when a cleanup is owed and the user has not dismissed the notice.
  /// Null means nothing to show.
  final DateTime? dueSince;

  bool get isDue => dueSince != null;

  ScheduleState copyWith({
    CleanupSchedule? schedule,
    DateTime? dueSince,
    bool clearDue = false,
  }) => ScheduleState(
    schedule: schedule ?? this.schedule,
    dueSince: clearDue ? null : dueSince ?? this.dueSince,
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
      ref.read(sharedPreferencesProvider).getString(_scheduleKey),
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
    );
    await ref
        .read(sharedPreferencesProvider)
        .setString(_scheduleKey, started.encode());
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
