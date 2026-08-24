// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/log/activity_log.dart';
import '../../core/profiles/profile.dart';
import '../../core/registry/stack_registry.dart';
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

/// The running version, from the bundle. Overridden in `main()` for the same
/// reason as the two above: `PackageInfo.fromPlatform()` is asynchronous and
/// the widgets that want the version want it synchronously.
///
/// Null in a test that does not supply one, which the callers treat as "say
/// nothing" rather than as an error.
final appVersionProvider = Provider<String?>((_) => null);

const _settingsKey = 'kruftle.settings.v1';

/// Profiles are stored under their own key rather than inside `Settings`.
///
/// They are exported and shared as a file, so they already have their own
/// serialisation with its own format marker; nesting that inside the settings
/// blob would mean two encodings of the same thing.
const _profilesKey = 'kruftle.profiles.v1';

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

  /// Records that the changelog for [version] has been offered, so the
  /// "what's new" notice appears once per update and not on every launch.
  Future<void> markVersionSeen(String version) =>
      update((s) => s.copyWith(lastSeenVersion: version));

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

class ProfilesController extends Notifier<ProfileSet> {
  @override
  ProfileSet build() => ProfileSet.decodeOrEmpty(
    ref.read(sharedPreferencesProvider).getString(_profilesKey),
  );

  Future<void> save(ProfileSet updated) async {
    state = updated;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_profilesKey, updated.encode());
  }

  Future<void> put(CleanupProfile profile) => save(state.withProfile(profile));

  Future<void> remove(String name) => save(state.without(name));

  /// Merges an imported set in, replacing same-named profiles.
  Future<void> import(ProfileSet incoming) async {
    var merged = state;
    for (final profile in incoming.profiles) {
      merged = merged.withProfile(profile);
    }
    await save(merged);
  }
}

final profilesProvider = NotifierProvider<ProfilesController, ProfileSet>(
  ProfilesController.new,
);

/// The built-in stacks plus whatever the user has taught Kruftle.
///
/// Everything that scans reads the registry from here, so a profile the user
/// just saved is in effect on the very next scan without anything having to be
/// reloaded.
final registryProvider = Provider<StackRegistry>(
  (ref) => StackRegistry.withCustom(ref.watch(profilesProvider).stacks),
);

final activityLogProvider = Provider<ActivityLog>((ref) {
  return ActivityLog(
    directory: p.join(ref.read(appSupportDirectoryProvider), 'logs'),
    minimumLevel: ref.read(settingsProvider).logLevel,
    keepRotations: ref.read(settingsProvider).logRetentionFiles,
  );
});
