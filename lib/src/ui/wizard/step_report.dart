// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../l10n/app_localizations.dart';
import '../../core/models/clean.dart';
import '../../core/scan/sizer.dart';
import '../anim/animated_bytes.dart';
import '../anim/motion.dart';
import '../state/app_state.dart';
import '../state/wizard_controller.dart';
import '../theme.dart';
import '../viz/disk_gauge.dart';
import '../widgets/common.dart';
import 'step_running.dart' show statusAppearance;

/// Step 5 — what actually happened.
class StepReport extends ConsumerWidget {
  const StepReport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
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
                    report.cancelled ? l.reportStopped : l.reportDone,
                    style: context.text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.reportRanFor(
                      _duration(report.duration),
                      report.projectsTouched,
                    ),
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
                _ReclaimedTile(
                  bytes: report.bytesFreed,
                  label: l.reportReclaimed,
                ),
                const SizedBox(width: 48),
                StatTile(
                  value: '${report.count(StepStatus.success)}',
                  label: l.reportStepsCompleted,
                ),
                const SizedBox(width: 40),
                StatTile(
                  value: '${report.problems.length}',
                  label: l.reportFailed,
                  color: report.problems.isEmpty ? null : context.danger,
                ),
                const SizedBox(width: 40),
                StatTile(
                  value: '${report.count(StepStatus.skipped)}',
                  label: l.reportNothingToDo,
                ),
                if (report.count(StepStatus.refused) > 0) ...[
                  const SizedBox(width: 40),
                  StatTile(
                    value: '${report.count(StepStatus.refused)}',
                    label: l.reportRefused,
                    color: context.warn,
                  ),
                ],
              ],
            ),
          ),
        ),

        if (report.volumeBefore != null && report.volumeAfter != null) ...[
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
              child: DiskGaugeCard(
                before: report.volumeBefore!,
                after: report.volumeAfter!,
                heading: l.reportDiskHeading(
                  p.basename(state.root ?? ''),
                  formatBytes(report.volumeAfter!.availableBytes),
                  formatBytes(report.volumeAfter!.totalBytes),
                ),
                beforeLabel: l.reportDiskBefore,
                afterLabel: l.reportDiskAfter,
              ),
            ),
          ),
        ],

        if (report.bytesFreed < report.estimatedBytes) ...[
          const SizedBox(height: 14),
          NoticeBanner(
            message: l.reportUnderEstimate(formatBytes(report.estimatedBytes)),
            icon: Icons.info_outline_rounded,
          ),
        ],

        if (report.count(StepStatus.refused) > 0) ...[
          const SizedBox(height: 14),
          NoticeBanner(
            message: l.reportRefusedNotice(report.count(StepStatus.refused)),
            icon: Icons.shield_outlined,
            color: context.warn,
          ),
        ],

        const SizedBox(height: 22),
        if (report.problems.isNotEmpty) ...[
          PanelLabel(l.reportWhatWentWrong),
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
              label: Text(l.reportScanAgain),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: controller.restart,
              child: Text(l.reportAnotherFolder),
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

/// The headline figure. The one place in the app that gets a flourish: it is
/// the answer to the question the user opened Kruftle to ask.
class _ReclaimedTile extends StatelessWidget {
  const _ReclaimedTile({required this.bytes, required this.label});

  final int bytes;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      AnimatedBytes(
        bytes,
        duration: const Duration(milliseconds: 900),
        curve: Motion.celebrate,
        style: TextStyle(
          fontSize: 34,
          height: 1.1,
          fontWeight: FontWeight.w700,
          color: context.freed,
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
          final (icon, color) = statusAppearance(
            outcome.status,
            context.brightness,
          );

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
                        outcome.message ?? L.of(context).reportNoDetail,
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

      showToast(
        context,
        L.of(context).reportLogExported(p.basename(file.path)),
        action: SnackBarAction(
          label: L.of(context).actionShow,
          onPressed: () => _reveal(file),
        ),
      );
    },
    icon: const Icon(Icons.download_rounded, size: 17),
    label: Text(L.of(context).reportExportLog),
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
