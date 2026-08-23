// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import '../log/activity_log.dart';
import '../models/stack.dart';

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
  }) =>
      Settings(
        defaultRoots: defaultRoots ?? this.defaultRoots,
        maxScanDepth: maxScanDepth ?? this.maxScanDepth,
        scanHiddenDirectories:
            scanHiddenDirectories ?? this.scanHiddenDirectories,
        cleanConcurrency: cleanConcurrency ?? this.cleanConcurrency,
        stepTimeoutSeconds: stepTimeoutSeconds ?? this.stepTimeoutSeconds,
        logLevel: logLevel ?? this.logLevel,
        logRetentionFiles: logRetentionFiles ?? this.logRetentionFiles,
        rememberedRisks: rememberedRisks ?? this.rememberedRisks,
        checkForUpdates: checkForUpdates ?? this.checkForUpdates,
        confirmBeforeDelete: confirmBeforeDelete ?? this.confirmBeforeDelete,
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
      maxScanDepth: read<int>('maxScanDepth')?.clamp(1, 64) ?? fallback.maxScanDepth,
      scanHiddenDirectories:
          read<bool>('scanHiddenDirectories') ?? fallback.scanHiddenDirectories,
      cleanConcurrency:
          read<int>('cleanConcurrency')?.clamp(1, 32) ?? fallback.cleanConcurrency,
      stepTimeoutSeconds: read<int>('stepTimeoutSeconds')?.clamp(10, 3600) ??
          fallback.stepTimeoutSeconds,
      logLevel: _enumByName(LogLevel.values, read<String>('logLevel')) ??
          fallback.logLevel,
      logRetentionFiles:
          read<int>('logRetentionFiles')?.clamp(0, 50) ?? fallback.logRetentionFiles,
      rememberedRisks: read<List<Object?>>('rememberedRisks')
              ?.whereType<String>()
              .map((n) => _enumByName(CleanRisk.values, n))
              .nonNulls
              .toSet() ??
          fallback.rememberedRisks,
      checkForUpdates: read<bool>('checkForUpdates') ?? fallback.checkForUpdates,
      confirmBeforeDelete:
          read<bool>('confirmBeforeDelete') ?? fallback.confirmBeforeDelete,
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
