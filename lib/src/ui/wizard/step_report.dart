// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/models/clean.dart';
import '../../core/scan/sizer.dart';
import '../state/app_state.dart';
import '../state/wizard_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'step_running.dart' show statusAppearance;

/// Step 5 — what actually happened.
class StepReport extends ConsumerWidget {
  const StepReport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wizardProvider);
    final report = state.report;
    if (report == null) return const SizedBox.shrink();

    final controller = ref.read(wizardProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.cancelled ? 'Stopped' : 'Done',
                    style: context.text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ran for ${_duration(report.duration)} across '
                    '${report.projectsTouched} projects.',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _ExportButton(),
          ],
        ),
        const SizedBox(height: 26),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatTile(
                  value: formatBytes(report.bytesFreed),
                  label: 'reclaimed',
                  emphasis: true,
                  color: KruftleTheme.freed,
                ),
                const SizedBox(width: 48),
                StatTile(
                  value: '${report.count(StepStatus.success)}',
                  label: 'steps completed',
                ),
                const SizedBox(width: 40),
                StatTile(
                  value: '${report.problems.length}',
                  label: 'failed',
                  color: report.problems.isEmpty ? null : KruftleTheme.danger,
                ),
                const SizedBox(width: 40),
                StatTile(
                  value: '${report.count(StepStatus.skipped)}',
                  label: 'nothing to do',
                ),
                if (report.count(StepStatus.refused) > 0) ...[
                  const SizedBox(width: 40),
                  StatTile(
                    value: '${report.count(StepStatus.refused)}',
                    label: 'refused',
                    color: KruftleTheme.warn,
                  ),
                ],
              ],
            ),
          ),
        ),

        if (report.bytesFreed < report.estimatedBytes) ...[
          const SizedBox(height: 14),
          NoticeBanner(
            message:
                'The dry run estimated ${formatBytes(report.estimatedBytes)}. '
                'Clean commands decide for themselves what to remove — some '
                'keep caches a rebuild can reuse, which is usually what you '
                'want.',
            icon: Icons.info_outline_rounded,
          ),
        ],

        if (report.count(StepStatus.refused) > 0) ...[
          const SizedBox(height: 14),
          NoticeBanner(
            message:
                '${report.count(StepStatus.refused)} '
                '${report.count(StepStatus.refused) == 1 ? 'target was' : 'targets were'} '
                'refused by a safety check and left untouched.',
            icon: Icons.shield_outlined,
            color: KruftleTheme.warn,
          ),
        ],

        const SizedBox(height: 22),
        if (report.problems.isNotEmpty) ...[
          const PanelLabel('What went wrong'),
          const SizedBox(height: 10),
          Expanded(child: _Problems(report: report)),
        ] else
          const Spacer(),

        const SizedBox(height: 20),
        Row(
          children: [
            FilledButton.icon(
              onPressed: () => controller.startScan(state.root!),
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('Scan again'),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: controller.restart,
              child: const Text('Another folder'),
            ),
          ],
        ),
      ],
    );
  }

  String _duration(Duration d) => d.inMinutes >= 1
      ? '${d.inMinutes}m ${d.inSeconds % 60}s'
      : '${(d.inMilliseconds / 1000).toStringAsFixed(1)}s';
}

class _Problems extends StatelessWidget {
  const _Problems({required this.report});

  final CleanReport report;

  @override
  Widget build(BuildContext context) {
    final problems = report.problems.toList();

    return Card(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: problems.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final outcome = problems[index];
          final (icon, color) = statusAppearance(outcome.status);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 15, color: color),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.basename(outcome.step.projectPath),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      PathText(outcome.step.projectPath, size: 10.5),
                      const SizedBox(height: 6),
                      SelectableText(
                        outcome.message ?? 'No detail reported.',
                        style: context.mono(size: 11.5, color: color),
                      ),
                    ],
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

class _ExportButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => OutlinedButton.icon(
    onPressed: () async {
      final location = await getSaveLocation(
        suggestedName:
            'kruftle-${DateTime.now().toIso8601String().split('T').first}.log',
      );
      if (location == null) return;

      final file = ref.read(activityLogProvider).export(location.path);
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Log exported to ${p.basename(file.path)}'),
          behavior: SnackBarBehavior.floating,
          width: 420,
          action: SnackBarAction(label: 'Show', onPressed: () => _reveal(file)),
        ),
      );
    },
    icon: const Icon(Icons.download_rounded, size: 17),
    label: const Text('Export log'),
  );

  void _reveal(File file) {
    final (command, args) = Platform.isMacOS
        ? ('open', ['-R', file.path])
        : Platform.isWindows
        ? ('explorer', ['/select,', file.path])
        : ('xdg-open', [file.parent.path]);
    Process.run(command, args);
  }
}
