// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/scan/sizer.dart';
import '../state/update_controller.dart';
import '../theme.dart';

/// Offers an update without getting in the way. Never installs on its own.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateProvider);
    if (state.phase == UpdatePhase.idle) return const SizedBox.shrink();

    final controller = ref.read(updateProvider.notifier);
    final update = state.update!;
    final failed = state.phase == UpdatePhase.failed;
    final tint = failed ? KruftleTheme.danger : context.colors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      color: tint.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(
            failed ? Icons.error_outline_rounded : Icons.arrow_circle_up_rounded,
            size: 17,
            color: tint,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              switch (state.phase) {
                UpdatePhase.available =>
                  'Kruftle ${update.version} is available '
                      '(${formatBytes(update.sizeBytes)}).',
                UpdatePhase.downloading =>
                  'Downloading ${update.version}… '
                      '${(state.progress * 100).round()}%',
                UpdatePhase.ready =>
                  'Kruftle ${update.version} is verified and ready. '
                      'The installer has been opened.',
                UpdatePhase.failed => state.error ?? 'The update failed.',
                UpdatePhase.idle => '',
              },
              style: TextStyle(fontSize: 12.5, color: tint),
            ),
          ),
          if (state.phase == UpdatePhase.downloading)
            SizedBox(
              width: 90,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: state.progress,
                  minHeight: 4,
                ),
              ),
            ),
          if (state.phase == UpdatePhase.available) ...[
            TextButton(
              onPressed: controller.downloadAndInstall,
              child: const Text('Update'),
            ),
            IconButton(
              onPressed: controller.dismiss,
              icon: const Icon(Icons.close_rounded, size: 15),
              tooltip: 'Not now',
            ),
          ],
          if (failed)
            IconButton(
              onPressed: controller.dismiss,
              icon: const Icon(Icons.close_rounded, size: 15),
            ),
        ],
      ),
    );
  }
}
