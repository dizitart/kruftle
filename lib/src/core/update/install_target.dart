// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:path/path.dart' as p;

/// How this copy of Kruftle is installed, and therefore what it is able to
/// replace itself with.
///
/// Kruftle updates itself the way VS Code does: it fetches the new build as a
/// plain archive, unpacks it beside the one that is running, and swaps the two
/// once the process has gone. No installer runs, nothing is dragged anywhere,
/// and the next launch is the new version.
///
/// That only works where the current user can write next to the installed copy.
/// A machine-wide `C:\Program Files` install or a `.deb` under `/usr` cannot be
/// replaced without elevation, and pretending otherwise would fail silently
/// half-way through. Those copies are offered their own packaging's installer
/// instead, which is the only honest thing to hand them — and, in the `.deb`
/// case, fixes a real bug: a Debian install used to be offered an AppImage it
/// had nowhere to put.
class InstallTarget {
  const InstallTarget({
    required this.assetSuffixes,
    this.swapDirectory,
    this.appImage,
  });

  /// The release asset extensions this copy can update itself from, best
  /// first. `.zip` before `.exe` means a release that still carries only an
  /// installer is not refused.
  final List<String> assetSuffixes;

  /// The `.app` bundle or install directory replaced wholesale by an archive
  /// update, or null when this copy cannot replace itself.
  final String? swapDirectory;

  /// The running `.AppImage`, when Kruftle is one. An AppImage is a single
  /// file rather than a directory, so it is replaced rather than swapped.
  final String? appImage;

  /// True when an update lands without an installer running.
  bool get isSelfReplacing => swapDirectory != null || appImage != null;

  /// The `.app` bundle [executable] is running out of, or null when this build
  /// is not inside one — a `flutter run`, or a bare binary.
  ///
  /// `/Applications/Kruftle.app/Contents/MacOS/Kruftle` is three directories
  /// below the bundle, and that layout is fixed by macOS.
  static String? bundlePath(String executable) {
    final bundle = p.dirname(p.dirname(p.dirname(executable)));
    return p.extension(bundle) == '.app' ? bundle : null;
  }

  /// Works out where this copy lives from the running executable.
  ///
  /// Every input is injectable so the decision can be tested for a platform and
  /// a layout that is not the one the test happens to run on.
  static InstallTarget detect({
    bool? windows,
    bool? macOS,
    String? executable,
    String? appImage,
    bool Function(String directory)? canWrite,
  }) {
    final isWindows = windows ?? Platform.isWindows;
    final isMacOS = macOS ?? Platform.isMacOS;
    final exe = executable ?? Platform.resolvedExecutable;
    final writable = canWrite ?? canWriteInto;

    if (isMacOS) {
      // The disk image already carries the whole bundle, and the swap already
      // replaces it in place without the user dragging anything. A separate
      // archive would be a second way to do a thing that works.
      return InstallTarget(
        assetSuffixes: const ['.dmg'],
        swapDirectory: bundlePath(exe),
      );
    }

    if (!isWindows) {
      final image = appImage ?? Platform.environment['APPIMAGE'];
      if (image != null && image.isNotEmpty) {
        return InstallTarget(
          assetSuffixes: const ['.AppImage'],
          appImage: image,
        );
      }
    }

    // Split with the target platform's own rules rather than the host's. In
    // production the two always agree; asking explicitly is what lets a
    // Windows layout be decided correctly from a test on any machine, and
    // `C:\...\kruftle.exe` has no directory at all under POSIX rules.
    final path = p.Context(style: isWindows ? p.Style.windows : p.Style.posix);

    // The swap creates `<dir>.new` beside the install and renames `<dir>`
    // aside, so it is the *parent* that has to be writable, not the install
    // directory itself.
    final directory = path.dirname(exe);
    if (writable(path.dirname(directory))) {
      return InstallTarget(
        assetSuffixes: isWindows ? const ['.zip', '.exe'] : const ['.tar.gz'],
        swapDirectory: directory,
      );
    }

    return InstallTarget(
      assetSuffixes: isWindows ? const ['.exe'] : const ['.deb'],
    );
  }

  /// Whether this user could create and remove an entry in [directory].
  ///
  /// Asked by writing, not by reading a permission bit: on Windows the bits do
  /// not answer the question, and on every platform the only answer that
  /// matters is what happens when the swap actually tries.
  static bool canWriteInto(String directory) {
    try {
      final probe = File(
        p.join(directory, '.kruftle-update-probe-${pid.toRadixString(36)}'),
      )..writeAsStringSync('');
      probe.deleteSync();
      return true;
    } on Object {
      return false;
    }
  }
}
