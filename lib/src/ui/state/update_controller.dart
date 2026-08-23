// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;

import '../../core/update/updater.dart';
import '../../core/update/version.dart';
import 'app_state.dart';

enum UpdatePhase { idle, available, downloading, ready, failed }

class UpdateState {
  const UpdateState({
    this.phase = UpdatePhase.idle,
    this.update,
    this.progress = 0,
    this.error,
    this.installer,
  });

  final UpdatePhase phase;
  final AvailableUpdate? update;
  final double progress;
  final String? error;
  final File? installer;
}

class UpdateController extends Notifier<UpdateState> {
  @override
  UpdateState build() => const UpdateState();

  Future<void> check() async {
    final info = await PackageInfo.fromPlatform();
    final current = Version.tryParse(info.version);
    if (current == null) return;

    final update = await Updater(currentVersion: current).check();
    if (update == null) return;

    ref.read(activityLogProvider).info('Update available', {
      'current': '$current',
      'latest': '${update.version}',
    });
    state = UpdateState(phase: UpdatePhase.available, update: update);
  }

  Future<void> downloadAndInstall() async {
    final update = state.update;
    if (update == null) return;

    state = UpdateState(phase: UpdatePhase.downloading, update: update);
    final info = await PackageInfo.fromPlatform();
    final current = Version.tryParse(info.version)!;
    final updater = Updater(currentVersion: current);

    try {
      final installer = await updater.download(
        update,
        directory: p.join(ref.read(appSupportDirectoryProvider), 'updates'),
        onProgress: (received, total) {
          if (total > 0) {
            state = UpdateState(
              phase: UpdatePhase.downloading,
              update: update,
              progress: received / total,
            );
          }
        },
      );

      state = UpdateState(
        phase: UpdatePhase.ready,
        update: update,
        installer: installer,
      );
      await updater.install(installer);
    } on UpdateFailure catch (e) {
      ref.read(activityLogProvider).error('Update failed', {'reason': e.message});
      state = UpdateState(
        phase: UpdatePhase.failed,
        update: update,
        error: e.message,
      );
    }
  }

  void dismiss() => state = const UpdateState();
}

final updateProvider =
    NotifierProvider<UpdateController, UpdateState>(UpdateController.new);
