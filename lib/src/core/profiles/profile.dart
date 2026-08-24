// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import '../models/stack.dart';

/// Why a profile was rejected. One value per rule, so the UI can say which
/// field is wrong rather than "invalid profile".
enum ProfileProblem {
  /// No name, or only whitespace.
  noName,

  /// No marker files, which would make the profile match every directory on
  /// the disk.
  noMarkers,

  /// Neither a command nor an artifact directory: nothing for it to do.
  nothingToDo,

  /// An artifact path that is absolute rather than relative to the project.
  absolutePath,

  /// An artifact path containing `..`, a glob, or anything else that could
  /// reach outside the project it was matched in.
  escapingPath,

  /// A second profile already uses this name.
  duplicateName,
}

class ProfileError {
  const ProfileError(this.problem, [this.detail]);

  final ProfileProblem problem;

  /// The offending value, when there is one to point at.
  final String? detail;

  @override
  bool operator ==(Object other) =>
      other is ProfileError &&
      other.problem == problem &&
      other.detail == detail;

  @override
  int get hashCode => Object.hash(problem, detail);

  @override
  String toString() =>
      detail == null ? problem.name : '${problem.name}: $detail';
}

/// A project type the user has taught Kruftle about.
///
/// This is deliberately the *same shape* as a built-in stack, and converts to
/// one: everything downstream — the scanner, the planner, the cleaner, every
/// safety rail — sees a `StackDefinition` and cannot tell the difference. That
/// is the whole design. A parallel path for "user stacks" would be a second
/// place for the rails to be forgotten.
class CleanupProfile {
  const CleanupProfile({
    required this.name,
    required this.markers,
    this.command,
    this.artifactDirs = const [],
    this.dependencyDirs = const [],
    this.cacheDirs = const [],
    this.excludeGlobs = const [],
    this.enabled = true,
  });

  /// Shown in the results table, and the profile's identity for storage.
  final String name;

  /// A directory containing any of these is a project of this kind. An entry
  /// beginning `*.` matches by extension.
  final List<String> markers;

  /// The whole command line, as the user typed it. Split on whitespace when
  /// converted to a [CleanCommand]; null or blank means there is none.
  final String? command;

  /// Directories this profile may delete, relative to the project root.
  ///
  /// This is an allow-list in exactly the sense safety rail 4 means: nothing
  /// outside it is ever removed, and removal still needs the per-run opt-in
  /// that rail 7 requires. Splitting them by risk is what lets the user's
  /// existing "also delete" choices apply to a custom profile unchanged.
  final List<String> artifactDirs;
  final List<String> dependencyDirs;
  final List<String> cacheDirs;

  /// Glob patterns for paths the scanner must never enter — for any profile
  /// and any built-in stack, not just this one.
  final List<String> excludeGlobs;

  final bool enabled;

  /// The binary the command needs on `PATH`, or null when there is no command.
  String? get toolBinary {
    final parts = command?.trim().split(RegExp(r'\s+')) ?? const [];
    return parts.isEmpty || parts.first.isEmpty ? null : parts.first;
  }

  /// Everything wrong with this profile, in field order. Empty means valid.
  ///
  /// [existingNames] is every *other* profile's name, for the duplicate check.
  List<ProfileError> validate({Set<String> existingNames = const {}}) {
    final errors = <ProfileError>[];

    if (name.trim().isEmpty) {
      errors.add(const ProfileError(ProfileProblem.noName));
    }
    if (existingNames.contains(name.trim())) {
      errors.add(ProfileError(ProfileProblem.duplicateName, name.trim()));
    }

    if (markers.where((m) => m.trim().isNotEmpty).isEmpty) {
      errors.add(const ProfileError(ProfileProblem.noMarkers));
    }

    final allDirs = [
      ...artifactDirs,
      ...dependencyDirs,
      ...cacheDirs,
    ].where((d) => d.trim().isNotEmpty).toList();

    if ((command?.trim().isEmpty ?? true) && allDirs.isEmpty) {
      errors.add(const ProfileError(ProfileProblem.nothingToDo));
    }

    for (final dir in allDirs) {
      final trimmed = dir.trim();
      if (trimmed.startsWith('/') || RegExp(r'^[A-Za-z]:').hasMatch(trimmed)) {
        errors.add(ProfileError(ProfileProblem.absolutePath, trimmed));
      } else if (_escapes(trimmed)) {
        errors.add(ProfileError(ProfileProblem.escapingPath, trimmed));
      }
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;

  /// True for a path that could reach outside the project it was matched in,
  /// or that is not a literal path at all.
  ///
  /// Globs are rejected outright, not expanded. Rail 4 says the allow-list is
  /// exact directory names — a pattern is a thing whose meaning depends on
  /// what happens to be on the disk, which is not something to hand a
  /// recursive delete.
  static bool _escapes(String path) {
    if (path.contains('*') || path.contains('?')) return true;
    if (path.startsWith('~')) return true;
    return path
        .split(RegExp(r'[/\\]'))
        .any((segment) => segment == '..' || segment.trim().isEmpty);
  }

  /// The stack definition this profile becomes.
  ///
  /// Returns null for a profile that does not validate, so an invalid one that
  /// somehow reached storage cannot take part in a scan.
  StackDefinition? toStackDefinition() {
    if (!isValid) return null;

    final markerSet = markers
        .map((m) => m.trim())
        .where((m) => m.isNotEmpty)
        .toSet();
    final binary = toolBinary;

    return StackDefinition(
      id: StackId.custom,
      displayName: name.trim(),
      markers: markerSet,
      matches: (listing) => _matches(listing, markerSet),
      tool: binary == null ? null : ToolProbe(binary: binary),
      cleanCommand: _commandOf(command),
      artifacts: [
        for (final dir in artifactDirs.map((d) => d.trim()))
          if (dir.isNotEmpty) ArtifactPath(dir),
        for (final dir in dependencyDirs.map((d) => d.trim()))
          if (dir.isNotEmpty) ArtifactPath(dir, risk: CleanRisk.dependencies),
        for (final dir in cacheDirs.map((d) => d.trim()))
          if (dir.isNotEmpty) ArtifactPath(dir, risk: CleanRisk.cache),
      ],
      // Below every built-in, so a directory that is both a real Gradle
      // project and someone's custom profile still reads as Gradle first.
      priority: -1,
    );
  }

  /// A directory matches when it holds any marker, by exact name or — for a
  /// `*.ext` marker — by extension.
  static bool _matches(DirListing listing, Set<String> markers) {
    for (final marker in markers) {
      if (marker.startsWith('*.')) {
        final extension = marker.substring(1);
        if (listing.files.any((f) => f.endsWith(extension))) return true;
        if (listing.directories.any((d) => d.endsWith(extension))) return true;
      } else if (listing.has(marker)) {
        return true;
      }
    }
    return false;
  }

  static CleanCommand? _commandOf(String? line) {
    final parts =
        line
            ?.trim()
            .split(RegExp(r'\s+'))
            .where((p) => p.isNotEmpty)
            .toList() ??
        const [];
    if (parts.isEmpty) return null;
    return CleanCommand(parts.first, parts.skip(1).toList());
  }

  CleanupProfile copyWith({
    String? name,
    List<String>? markers,
    String? command,
    bool clearCommand = false,
    List<String>? artifactDirs,
    List<String>? dependencyDirs,
    List<String>? cacheDirs,
    List<String>? excludeGlobs,
    bool? enabled,
  }) => CleanupProfile(
    name: name ?? this.name,
    markers: markers ?? this.markers,
    command: clearCommand ? null : command ?? this.command,
    artifactDirs: artifactDirs ?? this.artifactDirs,
    dependencyDirs: dependencyDirs ?? this.dependencyDirs,
    cacheDirs: cacheDirs ?? this.cacheDirs,
    excludeGlobs: excludeGlobs ?? this.excludeGlobs,
    enabled: enabled ?? this.enabled,
  );

  Map<String, Object?> toJson() => {
    'name': name,
    'markers': markers,
    'command': command,
    'artifactDirs': artifactDirs,
    'dependencyDirs': dependencyDirs,
    'cacheDirs': cacheDirs,
    'excludeGlobs': excludeGlobs,
    'enabled': enabled,
  };

  factory CleanupProfile.fromJson(Map<String, Object?> json) {
    List<String> strings(String key) =>
        (json[key] as List<Object?>? ?? const []).whereType<String>().toList();

    return CleanupProfile(
      name: json['name'] as String? ?? '',
      markers: strings('markers'),
      command: json['command'] as String?,
      artifactDirs: strings('artifactDirs'),
      dependencyDirs: strings('dependencyDirs'),
      cacheDirs: strings('cacheDirs'),
      excludeGlobs: strings('excludeGlobs'),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

/// The whole set of user profiles, with its own JSON so it can be exported and
/// shared without carrying the rest of the user's settings with it.
class ProfileSet {
  const ProfileSet(this.profiles);

  final List<CleanupProfile> profiles;

  static const empty = ProfileSet([]);

  /// The format marker in an export file, so an import can tell a Kruftle
  /// profile export from any other JSON the user happens to pick.
  static const formatKey = 'kruftle.profiles';
  static const formatVersion = 1;

  /// Enabled, valid profiles as stack definitions, ready to merge into the
  /// registry.
  List<StackDefinition> get stacks => [
    for (final profile in profiles)
      if (profile.enabled) ?profile.toStackDefinition(),
  ];

  /// Every exclude pattern from every enabled profile.
  ///
  /// Deliberately global rather than per-profile: "never look in `vendor/`"
  /// is a statement about the user's disk, not about one project type, and a
  /// scanner that honoured it only while evaluating one profile would descend
  /// there anyway for all the others.
  List<String> get excludeGlobs => [
    for (final profile in profiles)
      if (profile.enabled) ...profile.excludeGlobs,
  ];

  ProfileSet withProfile(CleanupProfile profile) {
    final index = profiles.indexWhere((p) => p.name == profile.name);
    if (index < 0) return ProfileSet([...profiles, profile]);
    return ProfileSet([
      for (var i = 0; i < profiles.length; i++)
        if (i == index) profile else profiles[i],
    ]);
  }

  ProfileSet without(String name) =>
      ProfileSet(profiles.where((p) => p.name != name).toList());

  Map<String, Object?> toJson() => {
    formatKey: formatVersion,
    'profiles': [for (final profile in profiles) profile.toJson()],
  };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  /// Parses stored or exported JSON.
  ///
  /// Returns null — rather than an empty set — when the text is not a Kruftle
  /// profile export at all, so an import can tell the user they picked the
  /// wrong file instead of silently importing nothing.
  static ProfileSet? decode(String? source) {
    if (source == null || source.trim().isEmpty) return null;
    try {
      final json = jsonDecode(source) as Map<String, Object?>;
      if (json[formatKey] is! int) return null;
      return ProfileSet([
        for (final entry in json['profiles'] as List<Object?>? ?? const [])
          CleanupProfile.fromJson(entry! as Map<String, Object?>),
      ]);
    } on Object {
      return null;
    }
  }

  /// For settings storage, where a corrupt value should not stop the app
  /// starting.
  static ProfileSet decodeOrEmpty(String? source) => decode(source) ?? empty;
}
