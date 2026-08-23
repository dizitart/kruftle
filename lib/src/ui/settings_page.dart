// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/log/activity_log.dart';
import '../core/models/stack.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'widgets/common.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final log = ref.read(activityLogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        titleTextStyle: context.text.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
        children: [
          _Section(
            title: 'Scanning',
            children: [
              _SliderRow(
                label: 'Maximum depth',
                help: 'How far below the chosen folder to look. Deeper finds '
                    'more nested projects and takes longer.',
                value: settings.maxScanDepth.toDouble(),
                min: 2,
                max: 32,
                format: (v) => '${v.round()} levels',
                onChanged: (v) => controller
                    .update((s) => s.copyWith(maxScanDepth: v.round())),
              ),
              _SwitchRow(
                label: 'Include hidden directories',
                help: 'Folders beginning with a dot. Usually editor state and '
                    'tool caches rather than projects.',
                value: settings.scanHiddenDirectories,
                onChanged: (v) => controller
                    .update((s) => s.copyWith(scanHiddenDirectories: v)),
              ),
            ],
          ),

          _Section(
            title: 'Cleaning',
            children: [
              _SliderRow(
                label: 'Projects at once',
                help: 'Clean commands that run in parallel. More is faster '
                    'until the disk becomes the bottleneck. '
                    '${Platform.numberOfProcessors} cores available.',
                value: settings.cleanConcurrency.toDouble(),
                min: 1,
                max: 16,
                format: (v) => '${v.round()}',
                onChanged: (v) => controller
                    .update((s) => s.copyWith(cleanConcurrency: v.round())),
              ),
              _SliderRow(
                label: 'Step timeout',
                help: 'A clean command that runs longer than this is killed '
                    'and reported, so one stuck build tool cannot hold up the '
                    'whole run.',
                value: settings.stepTimeoutSeconds.toDouble(),
                min: 30,
                max: 1800,
                divisions: 59,
                format: (v) => v < 120
                    ? '${v.round()} seconds'
                    : '${(v / 60).round()} minutes',
                onChanged: (v) => controller
                    .update((s) => s.copyWith(stepTimeoutSeconds: v.round())),
              ),
              _SwitchRow(
                label: 'Confirm before deleting',
                help: 'Show a summary dialog whenever a run will delete '
                    'directories outright rather than only running clean '
                    'commands.',
                value: settings.confirmBeforeDelete,
                onChanged: (v) => controller
                    .update((s) => s.copyWith(confirmBeforeDelete: v)),
              ),
            ],
          ),

          _Section(
            title: 'Pre-select these deletion categories',
            subtitle: 'A convenience only. Every run still shows them ticked '
                'and still asks before deleting anything.',
            children: [
              for (final (risk, label) in const [
                (CleanRisk.buildOutput, 'Build output when the SDK is missing'),
                (CleanRisk.dependencies, 'Downloaded dependencies'),
                (CleanRisk.cache, 'Tool caches'),
              ])
                _SwitchRow(
                  label: label,
                  value: settings.rememberedRisks.contains(risk),
                  onChanged: (v) => controller.update((s) {
                    final risks = Set<CleanRisk>.of(s.rememberedRisks);
                    v ? risks.add(risk) : risks.remove(risk);
                    return s.copyWith(rememberedRisks: risks);
                  }),
                ),
            ],
          ),

          _Section(
            title: 'Logging',
            children: [
              _DropdownRow<LogLevel>(
                label: 'Detail',
                value: settings.logLevel,
                items: {
                  for (final level in LogLevel.values) level: level.name,
                },
                onChanged: (v) {
                  controller.update((s) => s.copyWith(logLevel: v));
                },
              ),
              _SliderRow(
                label: 'Log files kept',
                help: 'Older files are removed once the active log is rotated.',
                value: settings.logRetentionFiles.toDouble(),
                min: 0,
                max: 20,
                format: (v) => v == 0 ? 'none' : '${v.round()}',
                onChanged: (v) => controller
                    .update((s) => s.copyWith(logRetentionFiles: v.round())),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(child: PathText(log.file.path, size: 11)),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () => _revealLog(log),
                      icon: const Icon(Icons.folder_open_rounded, size: 15),
                      label: const Text('Show'),
                    ),
                    TextButton(
                      onPressed: log.clear,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          _Section(
            title: 'Updates',
            children: [
              _SwitchRow(
                label: 'Check for updates automatically',
                help: 'Kruftle asks GitHub Releases on launch and offers a '
                    'verified download. It never installs without asking.',
                value: settings.checkForUpdates,
                onChanged: (v) =>
                    controller.update((s) => s.copyWith(checkForUpdates: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _revealLog(ActivityLog log) {
    final directory = log.file.parent.path;
    final (command, args) = Platform.isMacOS
        ? ('open', [directory])
        : Platform.isWindows
            ? ('explorer', [directory])
            : ('xdg-open', [directory]);
    Process.run(command, args);
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelLabel(title),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Column(children: children),
              ),
            ),
          ],
        ),
      );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.help,
  });

  final String label;
  final String? help;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
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
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      );
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.format,
    required this.onChanged,
    this.help,
    this.divisions,
  });

  final String label;
  final String? help;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label, style: const TextStyle(fontSize: 13)),
                ),
                Text(
                  format(value),
                  style: context.mono(size: 12, color: context.colors.primary),
                ),
              ],
            ),
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
            Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions ?? (max - min).round(),
              onChanged: onChanged,
            ),
          ],
        ),
      );
}

class _DropdownRow<T> extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
            DropdownButton<T>(
              value: value,
              underline: const SizedBox.shrink(),
              style: TextStyle(fontSize: 13, color: context.colors.onSurface),
              items: [
                for (final entry in items.entries)
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
              ],
              onChanged: (v) => v == null ? null : onChanged(v),
            ),
          ],
        ),
      );
}
