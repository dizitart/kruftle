// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:path/path.dart' as p;

/// One Kruftle per machine.
///
/// Two of them cleaning the same tree is how a build directory ends up half
/// removed by one `cargo clean` while another is still writing it, and a
/// scheduled background run has no way of knowing that a window is open. So
/// both front doors take this lock first.
///
/// An advisory file lock rather than a pid file or a socket: the operating
/// system releases it however the process ends, including a crash or a kill,
/// so there is no stale lock to detect and no port to collide with.
///
/// Note it excludes *processes*, not isolates — POSIX locks are per-process,
/// so a second lock taken inside one Kruftle would be granted. That is the
/// right behaviour here, and the reason the test spawns a real second process.
class InstanceLock {
  const InstanceLock._(this._handle);

  /// Null when the lock file could not be opened at all. Kruftle then starts
  /// unguarded rather than refusing to run: an unwritable support directory
  /// is a problem, but it is not evidence of a second instance.
  final RandomAccessFile? _handle;

  static const fileName = 'kruftle.lock';

  /// Keeps a granted lock reachable for the life of the process.
  ///
  /// A `RandomAccessFile` closes itself when it is garbage collected, and a
  /// closed file is an unlocked file — so a caller that does not keep the
  /// returned lock in a variable would quietly let the next Kruftle in.
  static InstanceLock? _held;

  /// Takes the lock, or returns null when another Kruftle already holds it.
  static InstanceLock? tryAcquire(String directory) {
    // Already ours. Asking twice in one process would be granted anyway —
    // POSIX locks are held per process — and would leak a file descriptor.
    if (_held != null) return _held;

    final RandomAccessFile handle;
    try {
      Directory(directory).createSync(recursive: true);
      handle = File(
        p.join(directory, fileName),
      ).openSync(mode: FileMode.append);
    } on FileSystemException {
      return _held = const InstanceLock._(null);
    }

    try {
      handle.lockSync(FileLock.exclusive);
      return _held = InstanceLock._(handle);
    } on FileSystemException {
      handle.closeSync();
      return null;
    }
  }

  void release() {
    _held = null;
    _handle?.unlockSync();
    _handle?.closeSync();
  }
}
