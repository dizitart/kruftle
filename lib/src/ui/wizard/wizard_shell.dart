// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/wizard_controller.dart';
import '../theme.dart';
import 'step_report.dart';
import 'step_review.dart';
import 'step_running.dart';
import 'step_scanning.dart';
import 'step_source.dart';

/// The wizard's frame: a progress rail on the left, the current step's content
/// on the right.
class WizardShell extends ConsumerWidget {
  const WizardShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(wizardProvider.select((s) => s.step));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepRail(current: step),
        const VerticalDivider(width: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: KeyedSubtree(
                key: ValueKey(step),
                child: switch (step) {
                  WizardStep.source => const StepSource(),
                  WizardStep.scanning => const StepScanning(),
                  WizardStep.review => const StepReview(),
                  WizardStep.running => const StepRunning(),
                  WizardStep.report => const StepReport(),
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepRail extends StatelessWidget {
  const _StepRail({required this.current});

  final WizardStep current;

  static const _steps = [
    (WizardStep.source, 'Folder', Icons.folder_outlined),
    (WizardStep.scanning, 'Scan', Icons.radar_rounded),
    (WizardStep.review, 'Review', Icons.checklist_rounded),
    (WizardStep.running, 'Clean', Icons.cleaning_services_outlined),
    (WizardStep.report, 'Report', Icons.summarize_outlined),
  ];

  @override
  Widget build(BuildContext context) => Container(
    width: 168,
    padding: const EdgeInsets.fromLTRB(16, 28, 12, 16),
    color: context.colors.surfaceContainerLowest,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (step, label, icon) in _steps)
          _RailItem(
            label: label,
            icon: icon,
            state: step.index == current.index
                ? _ItemState.active
                : step.index < current.index
                ? _ItemState.done
                : _ItemState.upcoming,
          ),
      ],
    ),
  );
}

enum _ItemState { done, active, upcoming }

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.label,
    required this.icon,
    required this.state,
  });

  final String label;
  final IconData icon;
  final _ItemState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _ItemState.active => context.colors.primary,
      _ItemState.done => KruftleTheme.freed,
      _ItemState.upcoming => context.colors.onSurfaceVariant.withValues(
        alpha: 0.45,
      ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: state == _ItemState.active
            ? color.withValues(alpha: 0.11)
            : null,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Icon(
            state == _ItemState.done ? Icons.check_circle_rounded : icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 11),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: color,
              fontWeight: state == _ItemState.active
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
