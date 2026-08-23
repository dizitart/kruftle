// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/scan/sizer.dart';
import '../state/wizard_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Step 2 — the walk. Shows what is happening rather than an opaque spinner,
/// because on a large tree this runs for a while and silence looks like a hang.
class StepScanning extends ConsumerWidget {
  const StepScanning({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wizardProvider);
    final sizing = state.sizingProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sizing == null ? 'Looking for projects' : 'Measuring what they hold',
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        PathText(state.root ?? '', size: 12.5),
        const SizedBox(height: 26),

        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: sizing,
            minHeight: 5,
            backgroundColor: context.colors.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            StatTile(
              value: '${state.projects.length}',
              label: 'projects found',
            ),
            const SizedBox(width: 40),
            StatTile(
              value: '${state.directoriesScanned}',
              label: 'directories walked',
            ),
            if (sizing != null) ...[
              const SizedBox(width: 40),
              StatTile(value: '${(sizing * 100).round()}%', label: 'measured'),
            ],
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
          label: const Text('Stop scanning'),
        ),
      ],
    );
  }
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
          'Nothing found yet.',
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
                color: KruftleTheme.freed.withValues(alpha: 0.8),
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
