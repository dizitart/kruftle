// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../core/schedule/schedule.dart';
import 'state/schedule_controller.dart';
import 'theme.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final schedule = ref.watch(scheduleProvider).schedule;
    final controller = ref.read(scheduleProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.scheduleTitle),
        titleTextStyle: context.text.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 40),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: Column(
                children: [
                  _Row(
                    label: l.scheduleEnable,
                    help: l.scheduleEnableHelp,
                    trailing: Switch(
                      value: schedule.enabled,
                      onChanged: (v) =>
                          controller.update((s) => s.copyWith(enabled: v)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (schedule.enabled) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                child: Column(
                  children: [
                    _Row(
                      label: l.scheduleFrequency,
                      trailing: DropdownButton<ScheduleFrequency>(
                        value: schedule.frequency,
                        underline: const SizedBox.shrink(),
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.onSurface,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: ScheduleFrequency.daily,
                            child: Text(l.scheduleDaily),
                          ),
                          DropdownMenuItem(
                            value: ScheduleFrequency.weekly,
                            child: Text(l.scheduleWeekly),
                          ),
                          DropdownMenuItem(
                            value: ScheduleFrequency.monthly,
                            child: Text(l.scheduleMonthly),
                          ),
                        ],
                        onChanged: (v) => v == null
                            ? null
                            : controller.update(
                                (s) => s.copyWith(frequency: v),
                              ),
                      ),
                    ),

                    if (schedule.frequency == ScheduleFrequency.weekly)
                      _Row(
                        label: l.scheduleDayOfWeek,
                        trailing: DropdownButton<int>(
                          value: schedule.dayOfWeek,
                          underline: const SizedBox.shrink(),
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colors.onSurface,
                          ),
                          items: [
                            for (var day = 1; day <= 7; day++)
                              DropdownMenuItem(
                                value: day,
                                child: Text(weekdayName(context, day)),
                              ),
                          ],
                          onChanged: (v) => v == null
                              ? null
                              : controller.update(
                                  (s) => s.copyWith(dayOfWeek: v),
                                ),
                        ),
                      ),

                    if (schedule.frequency == ScheduleFrequency.monthly)
                      _Row(
                        label: l.scheduleDayOfMonth,
                        trailing: DropdownButton<int>(
                          value: schedule.dayOfMonth,
                          underline: const SizedBox.shrink(),
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colors.onSurface,
                          ),
                          items: [
                            for (var day = 1; day <= 31; day++)
                              DropdownMenuItem(value: day, child: Text('$day')),
                          ],
                          onChanged: (v) => v == null
                              ? null
                              : controller.update(
                                  (s) => s.copyWith(dayOfMonth: v),
                                ),
                        ),
                      ),

                    _Row(
                      label: l.scheduleTimeOfDay,
                      trailing: TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: schedule.hour,
                              minute: schedule.minute,
                            ),
                          );
                          if (picked == null) return;
                          await controller.update(
                            (s) => s.copyWith(
                              hour: picked.hour,
                              minute: picked.minute,
                            ),
                          );
                        },
                        child: Text(
                          '${schedule.hour.toString().padLeft(2, '0')}:'
                          '${schedule.minute.toString().padLeft(2, '0')}',
                          style: context.mono(size: 13),
                        ),
                      ),
                    ),

                    _Row(
                      label: l.scheduleFolder,
                      trailing: TextButton.icon(
                        onPressed: () async {
                          final chosen = await getDirectoryPath();
                          if (chosen == null) return;
                          await controller.update(
                            (s) => s.copyWith(root: chosen),
                          );
                        },
                        icon: const Icon(Icons.folder_open_rounded, size: 15),
                        label: Text(
                          schedule.root ?? l.scheduleChooseFolder,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    _Row(
                      label: l.scheduleNotifyOnFinish,
                      trailing: Switch(
                        value: schedule.notifyOnFinish,
                        onChanged: (v) => controller.update(
                          (s) => s.copyWith(notifyOnFinish: v),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),
            Text(
              schedule.lastRun == null
                  ? l.scheduleNeverRun
                  : l.scheduleLastRun(formatWhen(context, schedule.lastRun!)),
              style: TextStyle(
                fontSize: 12,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            if (schedule.isConfigured && schedule.lastRun != null) ...[
              const SizedBox(height: 4),
              Text(
                l.scheduleNextRun(
                  formatWhen(context, schedule.nextRunAfter(schedule.lastRun!)),
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Date and weekday names for the locale in use.
///
/// `intl` is already a dependency — `flutter_localizations` brings it — and it
/// ships the symbols for every locale Kruftle supports. Adding seven weekday
/// names per language to the ARB would be seventy strings to render something
/// the SDK already knows.
String formatWhen(BuildContext context, DateTime at) =>
    DateFormat.yMMMd(_localeOf(context)).add_jm().format(at);

String weekdayName(BuildContext context, int weekday) {
  // 2026-08-24 is a Monday, so adding `weekday - 1` days lands on the weekday
  // asked for, whatever it is. Cheaper than a lookup table that has to agree
  // with `DateTime`'s numbering.
  final day = DateTime(2026, 8, 23 + weekday);
  return DateFormat.EEEE(_localeOf(context)).format(day);
}

String _localeOf(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.trailing, this.help});

  final String label;
  final String? help;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              if (help != null) ...[
                const SizedBox(height: 3),
                Text(
                  help!,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: trailing,
        ),
      ],
    ),
  );
}

/// The reminder itself, shown above the wizard when a cleanup is owed.
class ScheduleDueBanner extends ConsumerWidget {
  const ScheduleDueBanner({super.key, required this.onScan});

  final void Function(String root) onScan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final state = ref.watch(scheduleProvider);
    final root = state.schedule.root;
    if (!state.isDue || root == null) return const SizedBox.shrink();

    final controller = ref.read(scheduleProvider.notifier);
    final days = state.schedule.daysSinceLastRun(ref.read(clockProvider)());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      color: context.colors.primary.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 17, color: context.colors.primary),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              l.scheduleDueBody(days, root),
              style: TextStyle(fontSize: 12.5, color: context.colors.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.markRan();
              onScan(root);
            },
            child: Text(l.scheduleDueAction),
          ),
          TextButton(
            onPressed: controller.dismiss,
            child: Text(l.scheduleDueDismiss),
          ),
        ],
      ),
    );
  }
}
