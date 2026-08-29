// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/scan/sizer.dart';
import '../state/update_controller.dart';
import '../theme.dart';

/// Offers an update without getting in the way. Never installs on its own, and
/// never restarts without being asked.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final state = ref.watch(updateProvider);
    if (state.phase == UpdatePhase.idle) return const SizedBox.shrink();

    final controller = ref.read(updateProvider.notifier);
    final update = state.update;
    final failed = state.phase == UpdatePhase.failed;
    final tint = failed ? context.danger : context.colors.primary;

    final message = switch (state.phase) {
      UpdatePhase.checking => l.updateChecking,
      UpdatePhase.upToDate => l.updateUpToDate,
      UpdatePhase.noBuild => l.updateNoBuild(state.blockedVersion ?? ''),
      UpdatePhase.available => l.updateAvailable(
        '${update!.version}',
        formatBytes(update.sizeBytes),
      ),
      UpdatePhase.downloading => l.updateDownloading(
        '${update!.version}',
        (state.progress * 100).round(),
      ),
      // The message has to agree with the button beside it. An update that
      // ends in an installer run is not one a restart finishes.
      UpdatePhase.ready =>
        update!.isSelfReplacing
            ? l.updateReady('${update.version}')
            : l.updateReadyInstall('${update.version}'),
      UpdatePhase.failed => state.error ?? l.updateFailed,
      UpdatePhase.idle => '',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      color: tint.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(
            switch (state.phase) {
              UpdatePhase.failed => Icons.error_outline_rounded,
              UpdatePhase.noBuild => Icons.info_outline_rounded,
              UpdatePhase.upToDate => Icons.check_circle_outline_rounded,
              _ => Icons.arrow_circle_up_rounded,
            },
            size: 17,
            color: tint,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 12.5, color: tint)),
          ),
          if (state.phase == UpdatePhase.checking)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
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
          if (state.phase == UpdatePhase.available)
            TextButton(
              onPressed: controller.download,
              child: Text(l.updateAction),
            ),
          if (state.phase == UpdatePhase.ready)
            TextButton(
              onPressed: controller.applyAndRestart,
              // A `.deb` or a Windows installer is handed to the system rather
              // than swapped in, so it is not a restart that finishes it.
              child: Text(
                update!.isSelfReplacing ? l.updateRestart : l.updateAction,
              ),
            ),
          if (state.phase != UpdatePhase.checking &&
              state.phase != UpdatePhase.downloading)
            IconButton(
              onPressed: controller.dismiss,
              icon: const Icon(Icons.close_rounded, size: 15),
              tooltip: l.actionNotNow,
            ),
        ],
      ),
    );
  }
}
