// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/clean/safety.dart';
import '../state/app_state.dart';
import '../state/wizard_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Step 1 — pick the directory to scan.
class StepSource extends ConsumerWidget {
  const StepSource({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wizardProvider);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(wizardProvider.notifier);

    Future<void> browse() async {
      final chosen = await getDirectoryPath(
        confirmButtonText: 'Scan this folder',
      );
      if (chosen != null) await controller.startScan(chosen);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Which directory should Kruftle look through?',
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Everything underneath it is examined. Nothing is touched until you '
          'say so.',
          style: TextStyle(
            fontSize: 13.5,
            height: 1.5,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 28),

        if (state.error != null) ...[
          NoticeBanner(
            message: state.error!,
            icon: Icons.block_rounded,
            color: KruftleTheme.danger,
          ),
          const SizedBox(height: 20),
        ],

        _DropTarget(onBrowse: browse),

        if (settings.defaultRoots.isNotEmpty) ...[
          const SizedBox(height: 28),
          const PanelLabel('Recent'),
          const SizedBox(height: 10),
          for (final root in settings.defaultRoots.take(5))
            _RecentRoot(
              path: root,
              onOpen: () => controller.startScan(root),
              onForget: () => ref
                  .read(settingsProvider.notifier)
                  .update(
                    (s) => s.copyWith(
                      defaultRoots: s.defaultRoots
                          .where((r) => r != root)
                          .toList(),
                    ),
                  ),
            ),
        ],
      ],
    );
  }
}

class _DropTarget extends StatelessWidget {
  const _DropTarget({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onBrowse,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 44),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.outlineVariant, width: 1.5),
        color: context.colors.surfaceContainerLowest,
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 38,
            color: context.colors.primary,
          ),
          const SizedBox(height: 14),
          const Text(
            'Choose a folder',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Your codebase root, or any folder holding projects',
            style: TextStyle(
              fontSize: 12.5,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

class _RecentRoot extends StatelessWidget {
  const _RecentRoot({
    required this.path,
    required this.onOpen,
    required this.onForget,
  });

  final String path;
  final VoidCallback onOpen;
  final VoidCallback onForget;

  @override
  Widget build(BuildContext context) {
    final refused = checkScanRoot(path);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: refused == null ? onOpen : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  refused == null
                      ? Icons.folder_rounded
                      : Icons.folder_off_rounded,
                  size: 16,
                  color: refused == null
                      ? context.colors.onSurfaceVariant
                      : KruftleTheme.danger,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.basename(path),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      PathText(path, size: 11),
                      if (refused != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          refused.message,
                          style: const TextStyle(
                            fontSize: 11,
                            color: KruftleTheme.danger,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onForget,
                  icon: const Icon(Icons.close_rounded, size: 15),
                  tooltip: 'Remove from recents',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
