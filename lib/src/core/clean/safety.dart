// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:path/path.dart' as p;

/// Why a path was refused.
///
/// Every value here corresponds to a safety rail in `PROJECT_PLAN.md` §4 and
/// has a dedicated test. These rails fail *closed*: anything not positively
/// proven safe is refused.
enum SafetyViolation {
  /// A system or home directory that must never be scanned or cleaned.
  forbiddenRoot,

  /// Too close to a filesystem root for a mistake to be survivable.
  tooShallow,

  /// The path does not exist, or is not a directory.
  notADirectory,

  /// Resolved outside the root the user actually chose.
  outsideRoot,

  /// Not a directory name any matched stack declares as its build output.
  notAllowListed,

  /// A symlink. We never delete through one, because the target is somewhere
  /// we were not given permission to touch.
  symlink;

  String get message => switch (this) {
    forbiddenRoot =>
      'This is a system or home directory. Kruftle will not touch it.',
    tooShallow => 'This path is too close to the filesystem root to be safe.',
    notADirectory => 'This is not a directory that exists.',
    outsideRoot => 'This path resolves outside the directory you chose.',
    notAllowListed =>
      'This is not a known build output directory for any detected stack.',
    symlink => 'This is a symbolic link. Kruftle never deletes through links.',
  };

  /// Whether the user may proceed past this refusal by confirming it.
  ///
  /// Only [tooShallow] is. Depth is a guess at intent, not a fact about
  /// danger, and it guesses wrong on a mounted volume or a mapped network
  /// drive, where `Z:\` or `Z:\codebase` is a perfectly ordinary place to
  /// keep a codebase. Every other violation names something that stays unsafe
  /// however certain the user is, so none of them can be waived.
  bool get isOverridable => this == tooShallow;
}

/// Absolute paths that may never be a scan root or a delete target, whatever
/// the user asks.
///
/// Comparison is case-insensitive on Windows and macOS, both of which have
/// case-insensitive filesystems by default.
Set<String> forbiddenRoots({String? home, bool windows = false}) {
  final userHome = home ?? _homeDirectory();
  return {
    if (windows) ...const {
      r'C:\',
      r'C:\Windows',
      r'C:\Users',
      r'C:\Program Files',
      r'C:\Program Files (x86)',
      r'C:\ProgramData',
    } else ...const {
      '/',
      '/bin',
      '/boot',
      '/dev',
      '/etc',
      '/home',
      '/Library',
      '/opt',
      '/private',
      '/proc',
      '/sbin',
      '/srv',
      '/sys',
      '/System',
      '/tmp',
      '/usr',
      '/Users',
      '/var',
      '/Volumes',
      '/Applications',
    },
    ?userHome,
  };
}

String? _homeDirectory() =>
    Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

/// Rail 2 + 3: is this directory acceptable as the root of a scan?
///
/// [exists] is injectable so the rule itself can be tested without building a
/// filesystem for every case.
/// [allowShallow] waives the depth rail — and only that rail — for a user who
/// has been shown the path and confirmed it anyway. Forbidden roots are
/// checked first and are never waived.
SafetyViolation? checkScanRoot(
  String path, {
  String? home,
  bool? windows,
  bool allowShallow = false,
  bool Function(String)? directoryExists,
}) {
  final isWindows = windows ?? Platform.isWindows;
  final normalized = _normalize(path, windows: isWindows);

  final forbidden = forbiddenRoots(
    home: home,
    windows: isWindows,
  ).map((r) => _normalize(r, windows: isWindows));
  if (forbidden.contains(normalized)) return SafetyViolation.forbiddenRoot;

  if (!allowShallow && _depth(normalized, windows: isWindows) < 2) {
    return SafetyViolation.tooShallow;
  }

  final exists = directoryExists ?? (String q) => Directory(q).existsSync();
  if (!exists(path)) return SafetyViolation.notADirectory;

  return null;
}

/// Rails 1, 3, 4, 5: is this specific directory safe to delete outright?
///
/// [target] must be a directory that is (a) inside [scanRoot] after symlink
/// resolution, (b) not itself a link, and (c) named by [allowedRelatives],
/// which comes from the matched stack's declared artifact paths. Nothing else
/// is ever deleted.
SafetyViolation? checkDeleteTarget({
  required String scanRoot,
  required String projectRoot,
  required String target,
  required Set<String> allowedRelatives,
  bool? windows,
  String Function(String)? resolve,
  bool Function(String)? isLink,
  bool Function(String)? directoryExists,
}) {
  final isWindows = windows ?? Platform.isWindows;

  final relative = p.relative(target, from: projectRoot);
  if (!_containsRelative(allowedRelatives, relative, windows: isWindows)) {
    return SafetyViolation.notAllowListed;
  }

  final linkCheck = isLink ?? (String q) => Link(q).existsSync();
  if (linkCheck(target)) return SafetyViolation.symlink;

  final exists = directoryExists ?? (String q) => Directory(q).existsSync();
  if (!exists(target)) return SafetyViolation.notADirectory;

  // Containment is checked *after* resolution, so a link planted mid-path
  // cannot smuggle the target outside the tree the user consented to.
  final resolver =
      resolve ?? (String q) => Directory(q).resolveSymbolicLinksSync();
  final resolvedTarget = _normalize(resolver(target), windows: isWindows);
  final resolvedRoot = _normalize(resolver(scanRoot), windows: isWindows);

  if (resolvedTarget == resolvedRoot) return SafetyViolation.outsideRoot;
  if (!p.isWithin(resolvedRoot, resolvedTarget)) {
    return SafetyViolation.outsideRoot;
  }

  final forbidden = forbiddenRoots(
    windows: isWindows,
  ).map((r) => _normalize(r, windows: isWindows));
  if (forbidden.contains(resolvedTarget)) return SafetyViolation.forbiddenRoot;

  return null;
}

bool _containsRelative(
  Set<String> allowed,
  String relative, {
  required bool windows,
}) {
  final needle = _normalize(relative, windows: windows);
  return allowed.map((a) => _normalize(a, windows: windows)).contains(needle);
}

/// Canonical form for comparison: no trailing separator, forward slashes, and
/// case-folded on the platforms whose filesystems are case-insensitive.
String _normalize(String path, {required bool windows}) {
  var normalized = p.normalize(path).replaceAll(r'\', '/');
  if (normalized.length > 1 && normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return windows || Platform.isMacOS ? normalized.toLowerCase() : normalized;
}

/// Number of non-empty path segments, ignoring any drive or root prefix.
int _depth(String normalized, {required bool windows}) {
  var body = normalized;
  if (windows && RegExp('^[a-z]:').hasMatch(body)) body = body.substring(2);
  return body.split('/').where((s) => s.isNotEmpty).length;
}
