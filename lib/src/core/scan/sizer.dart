// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'dart:isolate';

/// Measures how much disk a set of directories occupies.
///
/// This is the slow part of a scan — a `target/` directory holds hundreds of
/// thousands of small files — so measurements run on a pool of isolates. The
/// work is genuinely parallel: each isolate does blocking `statSync` calls on a
/// separate directory tree, which is exactly what isolates are for.
class Sizer {
  Sizer({this.concurrency = 0});

  /// Simultaneous isolates. Zero means "one per core", which is the right
  /// default for work that is a mix of syscall latency and page-cache hits.
  final int concurrency;

  int get _workers =>
      concurrency > 0 ? concurrency : Platform.numberOfProcessors;

  /// Byte totals keyed by the paths given. A path that cannot be read is
  /// reported as 0 rather than failing the batch: an unreadable directory is
  /// one we would not have been able to clean either.
  Future<Map<String, int>> measureAll(
    List<String> paths, {
    void Function(String path, int bytes)? onMeasured,
  }) async {
    final results = <String, int>{};
    final queue = List<String>.from(paths);

    Future<void> worker() async {
      while (queue.isNotEmpty) {
        final path = queue.removeAt(0);
        final bytes = await _sizeOnIsolate(path);
        results[path] = bytes;
        onMeasured?.call(path, bytes);
      }
    }

    await Future.wait([
      for (var i = 0; i < _workers.clamp(1, paths.length.clamp(1, 64)); i++)
        worker(),
    ]);

    return results;
  }
}

/// Spawns the measurement isolate from a scope that holds nothing but a path.
///
/// This indirection is load-bearing. A closure sent to an isolate carries its
/// entire enclosing context, so creating it inside the worker loop also tried
/// to send the progress callback — and through it, whatever the caller had
/// closed over. Dart rejects unsendable objects at runtime, not at compile
/// time, so the failure surfaced as a scan that sat at 0% forever.
Future<int> _sizeOnIsolate(String path) =>
    Isolate.run(() => directorySizeSync(path));

/// Total bytes of every regular file at or below [path].
///
/// Runs inside an isolate, so it is deliberately synchronous and top-level.
/// Symlinks are counted as zero and never followed: their content belongs to
/// whatever the link points at, which is not ours to measure or to delete.
int directorySizeSync(String path) {
  final root = Directory(path);
  if (!root.existsSync()) return 0;

  var total = 0;
  final pending = <Directory>[root];

  while (pending.isNotEmpty) {
    final directory = pending.removeLast();
    final List<FileSystemEntity> entries;
    try {
      entries = directory.listSync(followLinks: false);
    } on FileSystemException {
      continue; // unreadable, or deleted while we were walking
    }

    for (final entry in entries) {
      switch (entry) {
        case Directory():
          pending.add(entry);
        case File():
          try {
            total += entry.lengthSync();
          } on FileSystemException {
            continue;
          }
        default:
          continue; // Link, or anything exotic: not ours to count
      }
    }
  }

  return total;
}

/// Human-readable byte count, binary units, at most one decimal.
///
/// Deliberately not `intl`: this is four lines and adding a localisation
/// dependency to format a file size is not a trade worth making.
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const units = ['KiB', 'MiB', 'GiB', 'TiB', 'PiB'];
  var value = bytes / 1024;
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final decimals = value >= 100 ? 0 : 1;
  return '${value.toStringAsFixed(decimals)} ${units[unit]}';
}
