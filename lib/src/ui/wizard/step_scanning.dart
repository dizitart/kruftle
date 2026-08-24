// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/scan/sizer.dart';
import '../anim/animated_bytes.dart';
import '../anim/radar_sweep.dart';
import '../state/wizard_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Step 2 — the walk. Shows what is happening rather than an opaque spinner,
/// because on a large tree this runs for a while and silence looks like a hang.
class StepScanning extends ConsumerWidget {
  const StepScanning({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final state = ref.watch(wizardProvider);
    final sizing = state.sizingProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sizing == null ? l.scanningLooking : l.scanningMeasuring,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        PathText(state.root ?? '', size: 12.5),
        const SizedBox(height: 26),

        // The radar carries the "something is happening" job while the walk
        // runs, which has no percentage to report; the counters beside it
        // carry the detail.
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RadarSweep(blipCount: state.projects.length, progress: sizing),
            const SizedBox(width: 34),
            Expanded(
              child: Wrap(
                spacing: 40,
                runSpacing: 18,
                children: [
                  _Counter(
                    value: state.projects.length,
                    label: l.scanningProjectsFound,
                  ),
                  _Counter(
                    value: state.directoriesScanned,
                    label: l.scanningDirectoriesWalked,
                  ),
                  if (sizing != null)
                    StatTile(
                      value: '${(sizing * 100).round()}%',
                      label: l.scanningMeasured,
                    ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(7),
          ),
          width: double.infinity,
          child: PathText(state.currentPath ?? '', size: 11.5),
        ),

        const SizedBox(height: 22),
        Expanded(child: _FoundList(state: state)),

        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: ref.read(wizardProvider.notifier).cancelScan,
          icon: const Icon(Icons.stop_rounded, size: 17),
          label: Text(l.scanningStop),
        ),
      ],
    );
  }
}

/// A [StatTile] whose figure counts rather than jumps.
class _Counter extends StatelessWidget {
  const _Counter({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      AnimatedCount(
        value,
        style: const TextStyle(
          fontSize: 20,
          height: 1.1,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          color: context.colors.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class _FoundList extends StatelessWidget {
  const _FoundList({required this.state});

  final WizardState state;

  @override
  Widget build(BuildContext context) {
    final recent = state.projects.reversed.take(40).toList();
    if (recent.isEmpty) {
      return Center(
        child: Text(
          L.of(context).scanningNothingYet,
          style: TextStyle(
            fontSize: 12.5,
            color: context.colors.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: recent.length,
      itemBuilder: (context, index) {
        final project = recent[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 14,
                color: context.freed.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  project.name,
                  style: const TextStyle(fontSize: 12.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              for (final stack in project.stacks.take(3)) ...[
                Tag(stack.displayName),
                const SizedBox(width: 5),
              ],
              const SizedBox(width: 6),
              SizedBox(
                width: 74,
                child: Text(
                  project.estimatedBytes > 0
                      ? formatBytes(project.estimatedBytes)
                      : '—',
                  textAlign: TextAlign.right,
                  style: context.mono(size: 11.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
