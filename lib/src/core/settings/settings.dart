// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import '../log/activity_log.dart';
import '../models/stack.dart';
import '../scan/sizer.dart';

/// Light, dark, or whatever the desktop is set to.
///
/// Deliberately not Flutter's `ThemeMode`: `Settings` lives in the pure-Dart
/// core, which must never import Flutter. The UI maps between the two in one
/// line, which is a cheaper price than dragging the framework into the engine.
enum AppThemeMode { system, light, dark }

/// The languages Kruftle ships translations for.
///
/// Kept beside `Settings` rather than derived from the generated localisation
/// class, again because the core cannot import Flutter. A test asserts the two
/// lists agree, so they cannot drift apart silently.
const kSupportedLocaleCodes = <String>[
  'en',
  'ar',
  'de',
  'es',
  'fr',
  'hi',
  'ja',
  'pt',
  'ru',
  'zh',
];

/// User preferences. Plain data with JSON round-tripping, so the core does not
/// depend on shared_preferences — the UI layer supplies a place to put the
/// string.
class Settings {
  const Settings({
    this.defaultRoots = const [],
    this.maxScanDepth = 12,
    this.scanHiddenDirectories = false,
    this.cleanConcurrency = 4,
    this.stepTimeoutSeconds = 300,
    this.logLevel = LogLevel.info,
    this.logRetentionFiles = 3,
    this.rememberedRisks = const {},
    this.checkForUpdates = true,
    this.confirmBeforeDelete = true,
    this.themeMode = AppThemeMode.system,
    this.localeCode,
    this.reduceMotion = false,
    this.sizeMode = SizeMode.onDisk,
    this.hasSeenTour = false,
    this.lastSeenVersion,
  });

  /// Directories offered on the first wizard step.
  final List<String> defaultRoots;

  final int maxScanDepth;
  final bool scanHiddenDirectories;

  /// Projects cleaned simultaneously.
  final int cleanConcurrency;

  /// Kill a clean command that runs longer than this.
  final int stepTimeoutSeconds;

  final LogLevel logLevel;
  final int logRetentionFiles;

  /// Which raw-deletion categories to pre-tick on the selection screen.
  ///
  /// A convenience only. Safety rail 7 still stands: these are *pre-ticked*,
  /// never silently applied — the user sees and confirms them every run.
  final Set<CleanRisk> rememberedRisks;

  final bool checkForUpdates;

  /// Show the final confirmation dialog before anything is deleted outright.
  final bool confirmBeforeDelete;

  final AppThemeMode themeMode;

  /// Language to render in. Null follows the operating system, which is what
  /// almost everyone wants and what a fresh install does.
  final String? localeCode;

  /// Replace the sweeping animations with plain progress. The platform's own
  /// reduced-motion setting is honoured on top of this, never instead of it.
  final bool reduceMotion;

  /// Whether sizes are the space the filesystem committed or the length of the
  /// files. See [SizeMode].
  final SizeMode sizeMode;

  /// Set once the feature tour has been seen or skipped.
  final bool hasSeenTour;

  /// The version that last ran, so an update can show what changed exactly
  /// once rather than on every launch.
  final String? lastSeenVersion;

  Duration get stepTimeout => Duration(seconds: stepTimeoutSeconds);

  Settings copyWith({
    List<String>? defaultRoots,
    int? maxScanDepth,
    bool? scanHiddenDirectories,
    int? cleanConcurrency,
    int? stepTimeoutSeconds,
    LogLevel? logLevel,
    int? logRetentionFiles,
    Set<CleanRisk>? rememberedRisks,
    bool? checkForUpdates,
    bool? confirmBeforeDelete,
    AppThemeMode? themeMode,
    String? localeCode,
    bool clearLocaleCode = false,
    bool? reduceMotion,
    SizeMode? sizeMode,
    bool? hasSeenTour,
    String? lastSeenVersion,
  }) => Settings(
    defaultRoots: defaultRoots ?? this.defaultRoots,
    maxScanDepth: maxScanDepth ?? this.maxScanDepth,
    scanHiddenDirectories: scanHiddenDirectories ?? this.scanHiddenDirectories,
    cleanConcurrency: cleanConcurrency ?? this.cleanConcurrency,
    stepTimeoutSeconds: stepTimeoutSeconds ?? this.stepTimeoutSeconds,
    logLevel: logLevel ?? this.logLevel,
    logRetentionFiles: logRetentionFiles ?? this.logRetentionFiles,
    rememberedRisks: rememberedRisks ?? this.rememberedRisks,
    checkForUpdates: checkForUpdates ?? this.checkForUpdates,
    confirmBeforeDelete: confirmBeforeDelete ?? this.confirmBeforeDelete,
    themeMode: themeMode ?? this.themeMode,
    // Null is a meaningful value here — "follow the system" — so clearing it
    // needs its own flag rather than the usual `?? this`.
    localeCode: clearLocaleCode ? null : localeCode ?? this.localeCode,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    sizeMode: sizeMode ?? this.sizeMode,
    hasSeenTour: hasSeenTour ?? this.hasSeenTour,
    lastSeenVersion: lastSeenVersion ?? this.lastSeenVersion,
  );

  Map<String, Object?> toJson() => {
    'defaultRoots': defaultRoots,
    'maxScanDepth': maxScanDepth,
    'scanHiddenDirectories': scanHiddenDirectories,
    'cleanConcurrency': cleanConcurrency,
    'stepTimeoutSeconds': stepTimeoutSeconds,
    'logLevel': logLevel.name,
    'logRetentionFiles': logRetentionFiles,
    'rememberedRisks': rememberedRisks.map((r) => r.name).toList(),
    'checkForUpdates': checkForUpdates,
    'confirmBeforeDelete': confirmBeforeDelete,
    'themeMode': themeMode.name,
    'localeCode': localeCode,
    'reduceMotion': reduceMotion,
    'sizeMode': sizeMode.name,
    'hasSeenTour': hasSeenTour,
    'lastSeenVersion': lastSeenVersion,
  };

  /// Rebuilds from stored JSON.
  ///
  /// Every field falls back to its default independently, so a settings file
  /// written by an older or newer version loads instead of throwing. Losing one
  /// preference is a nuisance; refusing to start is a bug report.
  factory Settings.fromJson(Map<String, Object?> json) {
    T? read<T>(String key) => json[key] is T ? json[key]! as T : null;
    const fallback = Settings();

    return Settings(
      defaultRoots:
          read<List<Object?>>('defaultRoots')?.whereType<String>().toList() ??
          fallback.defaultRoots,
      maxScanDepth:
          read<int>('maxScanDepth')?.clamp(1, 64) ?? fallback.maxScanDepth,
      scanHiddenDirectories:
          read<bool>('scanHiddenDirectories') ?? fallback.scanHiddenDirectories,
      cleanConcurrency:
          read<int>('cleanConcurrency')?.clamp(1, 32) ??
          fallback.cleanConcurrency,
      stepTimeoutSeconds:
          read<int>('stepTimeoutSeconds')?.clamp(10, 3600) ??
          fallback.stepTimeoutSeconds,
      logLevel:
          _enumByName(LogLevel.values, read<String>('logLevel')) ??
          fallback.logLevel,
      logRetentionFiles:
          read<int>('logRetentionFiles')?.clamp(0, 50) ??
          fallback.logRetentionFiles,
      rememberedRisks:
          read<List<Object?>>('rememberedRisks')
              ?.whereType<String>()
              .map((n) => _enumByName(CleanRisk.values, n))
              .nonNulls
              .toSet() ??
          fallback.rememberedRisks,
      checkForUpdates:
          read<bool>('checkForUpdates') ?? fallback.checkForUpdates,
      confirmBeforeDelete:
          read<bool>('confirmBeforeDelete') ?? fallback.confirmBeforeDelete,
      themeMode:
          _enumByName(AppThemeMode.values, read<String>('themeMode')) ??
          fallback.themeMode,
      // A code we ship no translation for would leave the UI half-English, so
      // it is dropped rather than honoured.
      localeCode: kSupportedLocaleCodes.contains(read<String>('localeCode'))
          ? read<String>('localeCode')
          : fallback.localeCode,
      reduceMotion: read<bool>('reduceMotion') ?? fallback.reduceMotion,
      sizeMode:
          _enumByName(SizeMode.values, read<String>('sizeMode')) ??
          fallback.sizeMode,
      hasSeenTour: read<bool>('hasSeenTour') ?? fallback.hasSeenTour,
      lastSeenVersion:
          read<String>('lastSeenVersion') ?? fallback.lastSeenVersion,
    );
  }

  String encode() => jsonEncode(toJson());

  static Settings decode(String? source) {
    if (source == null || source.isEmpty) return const Settings();
    try {
      return Settings.fromJson(jsonDecode(source) as Map<String, Object?>);
    } on Object {
      return const Settings();
    }
  }
}

T? _enumByName<T extends Enum>(List<T> values, String? name) {
  if (name == null) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}
