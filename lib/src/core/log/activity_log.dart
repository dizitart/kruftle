// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

enum LogLevel {
  debug,
  info,
  warning,
  error;

  bool operator >=(LogLevel other) => index >= other.index;
}

/// One recorded action.
class LogEntry {
  const LogEntry({
    required this.time,
    required this.level,
    required this.message,
    this.data = const {},
  });

  final DateTime time;
  final LogLevel level;
  final String message;

  /// Structured context — project path, command, exit code, bytes. Kept as
  /// data rather than interpolated into the message so exported logs can be
  /// filtered and aggregated by whatever the user analyses them with.
  final Map<String, Object?> data;

  Map<String, Object?> toJson() => {
        'time': time.toIso8601String(),
        'level': level.name,
        'message': message,
        if (data.isNotEmpty) 'data': data,
      };

  static LogEntry fromJson(Map<String, Object?> json) => LogEntry(
        time: DateTime.parse(json['time']! as String),
        level: LogLevel.values.byName(json['level']! as String),
        message: json['message']! as String,
        data: (json['data'] as Map<String, Object?>?) ?? const {},
      );

  /// Human-readable single line, which is also the export format.
  @override
  String toString() {
    final context =
        data.isEmpty ? '' : '  ${data.entries.map((e) => '${e.key}=${e.value}').join(' ')}';
    return '${time.toIso8601String()}  ${level.name.toUpperCase().padRight(7)}  '
        '$message$context';
  }
}

/// Append-only activity log, one JSON object per line.
///
/// JSONL rather than a single JSON array so a crashed or killed run still
/// leaves a readable file, and so appending never means rewriting.
class ActivityLog {
  ActivityLog({
    required this.directory,
    this.minimumLevel = LogLevel.info,
    this.maxBytes = 5 * 1024 * 1024,
    this.keepRotations = 3,
  });

  /// Where log files live. Injected rather than discovered, so the core stays
  /// free of Flutter's path_provider and tests can use a temp dir.
  final String directory;

  LogLevel minimumLevel;

  /// Rotate once the active file passes this size.
  final int maxBytes;

  /// How many rotated files to keep. Older ones are removed.
  final int keepRotations;

  File get file => File(p.join(directory, 'kruftle.log.jsonl'));

  final _buffered = <LogEntry>[];

  /// Entries from this session, for the in-app log view. The file is the
  /// durable record; this is just what is on screen.
  List<LogEntry> get entries => List.unmodifiable(_buffered);

  void log(LogLevel level, String message, [Map<String, Object?> data = const {}]) {
    if (!(level >= minimumLevel)) return;
    final entry = LogEntry(
      time: DateTime.now(),
      level: level,
      message: message,
      data: data,
    );
    _buffered.add(entry);
    _append(entry);
  }

  void debug(String m, [Map<String, Object?> d = const {}]) =>
      log(LogLevel.debug, m, d);
  void info(String m, [Map<String, Object?> d = const {}]) =>
      log(LogLevel.info, m, d);
  void warning(String m, [Map<String, Object?> d = const {}]) =>
      log(LogLevel.warning, m, d);
  void error(String m, [Map<String, Object?> d = const {}]) =>
      log(LogLevel.error, m, d);

  void _append(LogEntry entry) {
    try {
      Directory(directory).createSync(recursive: true);
      _rotateIfNeeded();
      file.writeAsStringSync(
        '${jsonEncode(entry.toJson())}\n',
        mode: FileMode.append,
      );
    } on FileSystemException {
      // A log that cannot be written must never take the app down with it.
    }
  }

  void _rotateIfNeeded() {
    if (!file.existsSync() || file.lengthSync() < maxBytes) return;

    for (var i = keepRotations - 1; i >= 1; i--) {
      final older = File('${file.path}.$i');
      if (older.existsSync()) older.renameSync('${file.path}.${i + 1}');
    }
    file.renameSync('${file.path}.1');

    final expired = File('${file.path}.${keepRotations + 1}');
    if (expired.existsSync()) expired.deleteSync();
  }

  /// Everything on disk, oldest first. Malformed lines are skipped rather than
  /// aborting the read: a truncated final line after a crash is expected.
  List<LogEntry> readAll() {
    if (!file.existsSync()) return const [];
    final entries = <LogEntry>[];
    for (final line in file.readAsLinesSync()) {
      if (line.trim().isEmpty) continue;
      try {
        entries.add(
          LogEntry.fromJson(jsonDecode(line) as Map<String, Object?>),
        );
      } on FormatException {
        continue;
      }
    }
    return entries;
  }

  /// Writes a plain-text copy to [destination] for sharing or analysis.
  File export(String destination) {
    final out = File(destination)..parent.createSync(recursive: true);
    out.writeAsStringSync(readAll().map((e) => '$e').join('\n'));
    return out;
  }

  void clear() {
    _buffered.clear();
    if (file.existsSync()) file.deleteSync();
  }
}
