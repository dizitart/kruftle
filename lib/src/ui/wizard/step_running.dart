// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../l10n/app_localizations.dart';
import '../../core/models/clean.dart';
import '../anim/cleaning_sweep.dart';
import '../state/wizard_controller.dart';
import '../theme.dart';

/// Step 4 — the run. Every step's outcome appears as it happens, so a long run
/// is legible rather than a bar that might be stuck.
class StepRunning extends ConsumerWidget {
  const StepRunning({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final state = ref.watch(wizardProvider);
    final running = state.runningStep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.runningHeading,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l.runningProgress(state.stepsDone, state.stepsTotal),
          style: TextStyle(
            fontSize: 13,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),

        CleaningSweep(value: state.runProgress),

        if (running != null) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${p.basename(running.projectPath)} · ${running.description}',
                    style: context.mono(size: 11.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 18),
        Expanded(child: _OutcomeLog(outcomes: state.finishedSteps)),

        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: ref.read(wizardProvider.notifier).cancelRun,
          icon: const Icon(Icons.stop_rounded, size: 17),
          label: Text(l.runningStop),
        ),
      ],
    );
  }
}

class _OutcomeLog extends StatelessWidget {
  const _OutcomeLog({required this.outcomes});

  final List<StepOutcome> outcomes;

  @override
  Widget build(BuildContext context) {
    final newestFirst = outcomes.reversed.toList();

    return Card(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: newestFirst.length,
        itemBuilder: (context, index) {
          final outcome = newestFirst[index];
          final (icon, color) = statusAppearance(
            outcome.status,
            context.brightness,
          );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(icon, size: 14, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              p.basename(outcome.step.projectPath),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            outcome.step.description,
                            style: context.mono(
                              size: 11,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (outcome.isProblem && outcome.message != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            outcome.message!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.mono(size: 11, color: color),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${outcome.duration.inMilliseconds} ms',
                  style: context.mono(
                    size: 10.5,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The icon and colour for a step's outcome.
///
/// Takes a brightness rather than a `BuildContext` so it stays a pure function
/// — it is called from inside two different list builders, and threading a
/// context through both buys nothing the caller cannot supply in a word.
(IconData, Color) statusAppearance(StepStatus status, Brightness brightness) =>
    switch (status) {
      StepStatus.success => (
        Icons.check_rounded,
        KruftleTheme.freedFor(brightness),
      ),
      StepStatus.skipped => (Icons.remove_rounded, Colors.grey),
      StepStatus.cancelled => (Icons.block_rounded, Colors.grey),
      StepStatus.refused => (
        Icons.shield_outlined,
        KruftleTheme.warnFor(brightness),
      ),
      StepStatus.timedOut => (
        Icons.timer_off_outlined,
        KruftleTheme.dangerFor(brightness),
      ),
      StepStatus.failed => (
        Icons.close_rounded,
        KruftleTheme.dangerFor(brightness),
      ),
    };
