// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:path/path.dart' as p;

/// Whether a stack's official clean command can actually be run here.
enum ToolStatus {
  /// Binary found on PATH. The official clean command will be used.
  available,

  /// Binary not found. The user is offered allow-listed deletion instead, or
  /// a link to install the SDK.
  missing,

  /// The stack declares no tool, so there is nothing to probe.
  notApplicable,
}

/// Resolves whether build tools exist on this machine.
///
/// The subtlety this class exists for: a GUI application launched from Finder
/// or the Windows shell does **not** inherit the PATH from the user's login
/// shell. `flutter`, `cargo` and friends are installed by shell rc files, so a
/// naive `Process.run('which', ...)` reports every SDK as missing and the app
/// silently offers raw deletion for everything. We therefore ask the user's
/// actual login shell what its PATH is, once, and search that.
class ToolchainProbe {
  ToolchainProbe({Map<String, String>? environment, bool? windows})
    : _environment = environment ?? Platform.environment,
      _windows = windows ?? Platform.isWindows;

  final Map<String, String> _environment;
  final bool _windows;

  /// The probe every part of the app shares.
  ///
  /// One instance, because the answer is the same everywhere and the login
  /// shell it has to start is slow. The cleaner needs the same resolved paths
  /// the scanner used, or it spawns a bare `flutter` the process PATH cannot
  /// find — see `SystemProcessRunner`.
  static final ToolchainProbe shared = ToolchainProbe();

  final Map<String, String?> _cache = {};
  List<String>? _searchPath;

  /// Absolute path to [binary], or null when it is not installed.
  ///
  /// Results are cached for the lifetime of the probe: a scan asks about the
  /// same dozen binaries hundreds of times.
  Future<String?> locate(String binary) async {
    if (_cache.containsKey(binary)) return _cache[binary];
    final resolved = await _search(binary);
    _cache[binary] = resolved;
    return resolved;
  }

  /// Every directory the probe searches, in order.
  ///
  /// Handed to clean commands as their `PATH`. Resolving the executable is not
  /// enough: `npm run clean` starts, then its script spawns `node` through a
  /// `#!/usr/bin/env node` shebang, which searches the *child's* PATH — the
  /// Finder one — and dies with "env: node: No such file or directory".
  Future<String> searchPathValue() async =>
      (await _path()).join(_windows ? ';' : ':');

  Future<ToolStatus> status(String? binary) async {
    if (binary == null) return ToolStatus.notApplicable;
    return await locate(binary) != null
        ? ToolStatus.available
        : ToolStatus.missing;
  }

  Future<String?> _search(String binary) async {
    final candidates = _windows
        ? [for (final ext in _windowsExtensions) '$binary$ext', binary]
        : [binary];

    for (final dir in await _path()) {
      for (final candidate in candidates) {
        final full = p.join(dir, candidate);
        if (File(full).existsSync()) return full;
      }
    }
    return null;
  }

  List<String> get _windowsExtensions =>
      (_environment['PATHEXT'] ?? '.EXE;.CMD;.BAT;.COM')
          .split(';')
          .where((e) => e.isNotEmpty)
          .toList();

  Future<List<String>> _path() async {
    if (_searchPath != null) return _searchPath!;
    final separator = _windows ? ';' : ':';
    final entries = <String>{
      ...?_environment['PATH']?.split(separator),
      if (!_windows) ...await _loginShellPath(),
    }..removeWhere((e) => e.isEmpty);
    return _searchPath = entries.toList();
  }

  /// Ask the login shell for its PATH. Failure is not an error: we simply fall
  /// back to the inherited PATH, which is what a terminal launch already gives
  /// us.
  Future<List<String>> _loginShellPath() async {
    final shell = _environment['SHELL'];
    if (shell == null || shell.isEmpty) return const [];
    try {
      final result = await Process.run(shell, [
        '-lic',
        'printf %s "\$PATH"',
      ]).timeout(const Duration(seconds: 5));
      if (result.exitCode != 0) return const [];
      return (result.stdout as String).trim().split(':');
    } on Object {
      // A shell that refuses to start, hangs, or prints nothing usable is not
      // worth failing the whole scan over.
      return const [];
    }
  }
}
