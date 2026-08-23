// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/log/activity_log.dart';
import '../../core/settings/settings.dart';

/// Filled in by `main()` via a ProviderScope override, because both of these
/// are only obtainable asynchronously and every other provider wants them
/// synchronously.
final appSupportDirectoryProvider = Provider<String>(
  (_) => throw StateError('appSupportDirectoryProvider was not overridden'),
);

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw StateError('sharedPreferencesProvider was not overridden'),
);

const _settingsKey = 'kruftle.settings.v1';

class SettingsController extends Notifier<Settings> {
  @override
  Settings build() => Settings.decode(
    ref.read(sharedPreferencesProvider).getString(_settingsKey),
  );

  Future<void> save(Settings updated) async {
    state = updated;
    ref.read(activityLogProvider).minimumLevel = updated.logLevel;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_settingsKey, updated.encode());
  }

  Future<void> update(Settings Function(Settings) change) =>
      save(change(state));

  /// Keeps the most recently scanned directories at the top of the list on the
  /// first wizard step, capped so it stays a shortcut rather than a history.
  Future<void> rememberRoot(String root) {
    final roots = [root, ...state.defaultRoots.where((r) => r != root)];
    return update((s) => s.copyWith(defaultRoots: roots.take(8).toList()));
  }
}

final settingsProvider = NotifierProvider<SettingsController, Settings>(
  SettingsController.new,
);

final activityLogProvider = Provider<ActivityLog>((ref) {
  return ActivityLog(
    directory: p.join(ref.read(appSupportDirectoryProvider), 'logs'),
    minimumLevel: ref.read(settingsProvider).logLevel,
    keepRotations: ref.read(settingsProvider).logRetentionFiles,
  );
});
