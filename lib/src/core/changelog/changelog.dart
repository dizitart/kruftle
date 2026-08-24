// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

/// What changed in one release.
class ChangelogEntry {
  const ChangelogEntry({
    required this.version,
    required this.date,
    this.added = const [],
    this.changed = const [],
    this.fixed = const [],
  });

  final String version;
  final String date;

  final List<String> added;
  final List<String> changed;
  final List<String> fixed;

  bool get isEmpty => added.isEmpty && changed.isEmpty && fixed.isEmpty;

  factory ChangelogEntry.fromJson(Map<String, Object?> json) {
    List<String> lines(String key) =>
        (json[key] as List<Object?>? ?? const []).whereType<String>().toList();

    return ChangelogEntry(
      version: json['version'] as String? ?? '',
      date: json['date'] as String? ?? '',
      added: lines('added'),
      changed: lines('changed'),
      fixed: lines('fixed'),
    );
  }
}

/// Every release, newest first.
///
/// **Release notes are English.** The screen around them is translated, but
/// the entries themselves are not: it would mean translating every line of
/// every release for ever, which no project this size sustains and which goes
/// stale into something worse than English. The parser does accept a
/// `"text": {"de": …}` shape should that ever change, and falls back to the
/// plain string, so the format does not have to be redesigned later.
class Changelog {
  const Changelog(this.entries);

  final List<ChangelogEntry> entries;

  static const empty = Changelog([]);

  /// The format marker, so a mangled or unrelated asset is reported rather
  /// than parsed into an empty list that looks like "no changes".
  static const formatKey = 'kruftle.changelog';

  ChangelogEntry? get latest => entries.isEmpty ? null : entries.first;

  ChangelogEntry? forVersion(String version) =>
      entries.where((e) => e.version == version).firstOrNull;

  /// Everything newer than [version], which is what a "what's new" panel shows
  /// after an update that skipped a release or two.
  List<ChangelogEntry> since(String? version) {
    if (version == null) return entries;
    final index = entries.indexWhere((e) => e.version == version);
    return index < 0 ? entries : entries.take(index).toList();
  }

  /// Null when the text is not a Kruftle changelog at all.
  static Changelog? decode(String? source) {
    if (source == null || source.trim().isEmpty) return null;
    try {
      final json = jsonDecode(source) as Map<String, Object?>;
      if (json[formatKey] is! int) return null;
      return Changelog([
        for (final entry in json['versions'] as List<Object?>? ?? const [])
          ChangelogEntry.fromJson(entry! as Map<String, Object?>),
      ]);
    } on Object {
      return null;
    }
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
