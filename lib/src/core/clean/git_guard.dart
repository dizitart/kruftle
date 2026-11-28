// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:path/path.dart' as p;

/// Safety rail 6.
///
/// A directory named `build/` or `bin/` is *usually* build output, but some
/// projects commit one — a Go repo that checks in its binaries, a Java project
/// that vendors a jar. Deleting a tracked directory destroys work that is not
/// regenerable by rebuilding, so anything git tracks is flagged and left out of
/// the default selection.
class GitGuard {
  const GitGuard();

  /// The subset of [relatives] that git tracks inside [projectPath].
  ///
  /// One `git` invocation per project, not per directory. A project that is not
  /// in a work tree, or a machine with no git, yields an empty set — the guard
  /// simply has nothing to say, which is the correct answer rather than a
  /// reason to fail.
  Future<Set<String>> trackedAmong(
    String projectPath,
    Iterable<String> relatives,
  ) async {
    if (relatives.isEmpty) return const {};

    final ProcessResult result;
    try {
      result = await Process.run('git', [
        '-C',
        projectPath,
        'ls-files',
        '--',
        ...relatives,
      ]).timeout(const Duration(seconds: 10));
    } on Object {
      return const {};
    }

    if (result.exitCode != 0) return const {};

    final tracked = <String>{};
    for (final line in (result.stdout as String).split('\n')) {
      final entry = line.trim();
      if (entry.isEmpty) continue;
      // `ls-files` lists the files inside a tracked directory, so we match by
      // which requested prefix each reported path falls under.
      for (final relative in relatives) {
        if (entry == relative || p.isWithin(relative, entry)) {
          tracked.add(relative);
        }
      }
    }
    return tracked;
  }

  /// Directories named one of [names], at any depth inside [projectPath],
  /// that hold at least one git-tracked file. Returned relative to
  /// [projectPath], e.g. `build` or `app/build`.
  ///
  /// A clean command is not limited to the directories we detected: a root
  /// `gradle clean` also clears every subproject's `build/`. So before a
  /// command runs, the whole tree is asked, not just the top-level artifact.
  /// Fails open to an empty set exactly like [trackedAmong].
  Future<Set<String>> trackedDirsNamed(
    String projectPath,
    Iterable<String> names,
  ) async {
    final wanted = names.where((n) => n.isNotEmpty).toSet();
    if (wanted.isEmpty) return const {};

    final ProcessResult result;
    try {
      result = await Process.run('git', [
        '-C',
        projectPath,
        'ls-files',
        '--',
        // A leading `**/` also matches zero directories, so this covers the
        // top-level directory as well as nested ones.
        for (final name in wanted) ':(glob)**/$name/**',
      ]).timeout(const Duration(seconds: 10));
    } on Object {
      return const {};
    }

    if (result.exitCode != 0) return const {};

    final dirs = <String>{};
    for (final line in (result.stdout as String).split('\n')) {
      final entry = line.trim();
      if (entry.isEmpty) continue;
      final parts = p.posix.split(entry);
      // Every ancestor directory with a wanted name is tracked content.
      for (var i = 0; i < parts.length - 1; i++) {
        if (wanted.contains(parts[i])) {
          dirs.add(p.joinAll(parts.sublist(0, i + 1)));
        }
      }
    }
    return dirs;
  }
}
