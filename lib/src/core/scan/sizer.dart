// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'dart:isolate';

import '../disk/native_disk.dart';

/// Measures how much disk a set of directories occupies.
///
/// This is the slow part of a scan — a `target/` directory holds hundreds of
/// thousands of small files — so measurements run on a pool of isolates. The
/// work is genuinely parallel: each isolate does blocking `statSync` calls on a
/// separate directory tree, which is exactly what isolates are for.
class Sizer {
  Sizer({this.concurrency = 0, this.mode = SizeMode.onDisk});

  /// Simultaneous isolates. Zero means "one per core", which is the right
  /// default for work that is a mix of syscall latency and page-cache hits.
  final int concurrency;

  /// Which of the two honest answers to "how big is this" to give.
  final SizeMode mode;

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
        final bytes = await _sizeOnIsolate(path, mode);
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

/// Which number to report for a directory's size.
enum SizeMode {
  /// The sum of file lengths — what the files logically contain.
  ///
  /// Always available, and the only option on Windows.
  apparent,

  /// The blocks the filesystem has actually committed, from `st_blocks`.
  ///
  /// This is what `du` reports and what the user gets back when the directory
  /// goes away, which is not the same figure: a tree of small files costs more
  /// than its contents because of block rounding, and a compressed APFS volume
  /// costs considerably less. Falls back to [apparent] wherever the native
  /// call is unavailable.
  onDisk,
}

/// Spawns the measurement isolate from a scope that holds nothing but a path
/// and a mode.
///
/// This indirection is load-bearing. A closure sent to an isolate carries its
/// entire enclosing context, so creating it inside the worker loop also tried
/// to send the progress callback — and through it, whatever the caller had
/// closed over. Dart rejects unsendable objects at runtime, not at compile
/// time, so the failure surfaced as a scan that sat at 0% forever.
Future<int> _sizeOnIsolate(String path, SizeMode mode) =>
    Isolate.run(() => directorySizeSync(path, mode: mode));

/// Total bytes of every regular file at or below [path].
///
/// Runs inside an isolate, so it is deliberately synchronous and top-level.
/// Symlinks are counted as zero and never followed: their content belongs to
/// whatever the link points at, which is not ours to measure or to delete.
int directorySizeSync(String path, {SizeMode mode = SizeMode.onDisk}) {
  final root = Directory(path);
  if (!root.existsSync()) return 0;

  // Resolved once per isolate rather than per file: the lookup does a symbol
  // resolution and a self-check against a scratch file, which is far more
  // expensive than the call it guards.
  final native =
      mode == SizeMode.onDisk && NativeDisk.shared.supportsAllocatedSize
      ? NativeDisk.shared
      : null;

  var total = 0;
  final pending = <Directory>[root];

  // A directory is itself an allocation — a large one, for a directory with
  // many entries — so it counts too when we are measuring real blocks. `du`
  // includes it, and matching `du` is the whole point of this mode.
  if (native != null) total += native.allocatedSize(root.path) ?? 0;

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
          if (native != null) total += native.allocatedSize(entry.path) ?? 0;
        case File():
          try {
            total += native != null
                ? (native.allocatedSize(entry.path) ?? entry.lengthSync())
                : entry.lengthSync();
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
