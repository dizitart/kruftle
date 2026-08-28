// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/update/updater.dart';
import '../../core/update/version.dart';
import 'app_state.dart';

enum UpdatePhase {
  idle,
  checking,
  upToDate,
  available,
  downloading,
  ready,
  failed,
}

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

  /// The verified download, waiting to be applied.
  final File? installer;

  /// True once the download is staged and only a restart is left.
  bool get isReady => phase == UpdatePhase.ready;
}

/// Built once so a test can put a different one in its place; the real one
/// holds an HTTP client and there is no reason to make more than one.
final updaterProvider = Provider<Updater>(
  (ref) => Updater(
    currentVersion: Version.tryParse(kAppVersion)!,
    target: ref.read(installTargetProvider),
  ),
);

class UpdateController extends Notifier<UpdateState> {
  @override
  UpdateState build() => const UpdateState();

  Updater _updater() => ref.read(updaterProvider);

  /// [byHand] is a person pressing "check for updates"; without it this is the
  /// check that runs at startup.
  ///
  /// The difference is only in what silence means. A background check that
  /// cannot reach GitHub says nothing and tries again next launch — an app that
  /// nags about its own update server is worse than one that waits. Somebody
  /// who just pressed the button is owed an answer either way, including "no,
  /// and here is why".
  Future<void> check({bool byHand = false}) async {
    if (byHand) state = const UpdateState(phase: UpdatePhase.checking);

    final AvailableUpdate? update;
    try {
      update = await _updater().check();
    } on UpdateFailure catch (e) {
      ref.read(activityLogProvider).info('Update check failed', {
        'reason': e.message,
      });
      state = byHand
          ? UpdateState(phase: UpdatePhase.failed, error: e.message)
          : const UpdateState();
      return;
    }

    if (update == null) {
      state = byHand
          ? const UpdateState(phase: UpdatePhase.upToDate)
          : const UpdateState();
      return;
    }

    ref.read(activityLogProvider).info('Update available', {
      'current': kAppVersion,
      'latest': '${update.version}',
      'asset': update.assetName,
    });
    state = UpdateState(phase: UpdatePhase.available, update: update);
  }

  /// Fetches and verifies the new build. Nothing is replaced yet: the swap
  /// happens on the next restart, which is the user's to ask for.
  Future<void> download() async {
    final update = state.update;
    if (update == null) return;

    state = UpdateState(phase: UpdatePhase.downloading, update: update);
    final updater = _updater();

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
        progress: 1,
      );
    } on UpdateFailure catch (e) {
      ref.read(activityLogProvider).error('Update failed', {
        'reason': e.message,
      });
      state = UpdateState(
        phase: UpdatePhase.failed,
        update: update,
        error: e.message,
      );
    }
  }

  /// Hands the staged build to the helper and gets out of its way.
  ///
  /// The helper cannot replace the files we are running out of while we are
  /// running out of them, so it waits for this process to go and then starts
  /// the new Kruftle itself. Staying alive is exactly the "the app is already
  /// running" failure.
  Future<void> applyAndRestart() async {
    final installer = state.installer;
    if (installer == null) return;
    try {
      if (await _updater().install(installer)) exit(0);
    } on Object catch (e) {
      ref.read(activityLogProvider).error('Update failed', {'reason': '$e'});
      state = UpdateState(
        phase: UpdatePhase.failed,
        update: state.update,
        error: '$e',
      );
    }
  }

  void dismiss() => state = const UpdateState();
}

final updateProvider = NotifierProvider<UpdateController, UpdateState>(
  UpdateController.new,
);
