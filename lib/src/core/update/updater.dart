// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'install_target.dart';
import 'swap_scripts.dart';
import 'version.dart';

export 'install_target.dart' show InstallTarget;

/// A release newer than what is running, with the asset for this platform.
class AvailableUpdate {
  const AvailableUpdate({
    required this.version,
    required this.assetName,
    required this.downloadUrl,
    required this.sha256,
    required this.notes,
    required this.sizeBytes,
  });

  final Version version;
  final String assetName;
  final String downloadUrl;

  /// From the release's `checksums.txt`. An update that cannot be verified is
  /// never installed.
  final String sha256;

  final String notes;
  final int sizeBytes;

  /// True when applying this lands without an installer running — the archive
  /// is unpacked over the installed copy and the next launch is the new
  /// version.
  bool get isSelfReplacing =>
      !const ['.exe', '.deb'].any(assetName.toLowerCase().endsWith);
}

/// Why an update could not be checked for, downloaded, or applied.
class UpdateFailure implements Exception {
  const UpdateFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Checks GitHub Releases, downloads the right build, verifies it, and replaces
/// the installed Kruftle with it.
///
/// Deliberately not Sparkle/WinSparkle: those need an appcast and, on macOS, a
/// Developer ID signature to work smoothly. This does the same job identically
/// on all three platforms with no extra infrastructure, and — where the
/// installed copy is somewhere this user can write, which is the normal case —
/// with no installer at all. See [InstallTarget].
class Updater {
  Updater({
    required this.currentVersion,
    required this.target,
    http.Client? client,
    this.repository = 'dizitart/kruftle',
    this.includePreReleases = false,
    String? architecture,
  }) : _client = client ?? http.Client(),
       _architecture = architecture ?? currentArchitecture();

  final Version currentVersion;

  /// Where this copy of Kruftle lives, which decides what it can update from.
  final InstallTarget target;

  final String repository;
  final bool includePreReleases;
  final http.Client _client;
  final String _architecture;

  /// The processor this build is running on, as it appears in an asset name:
  /// `arm64` or `x64`.
  ///
  /// From `Abi.current()`, which the VM already knows — no parsing of
  /// `Platform.version`, and no shelling out to `uname`. An unrecognised ABI
  /// reports `x64`, which is the overwhelmingly common case and the one whose
  /// asset is most likely to exist.
  static String currentArchitecture() {
    final abi = Abi.current().toString();
    if (abi.contains('arm64')) return 'arm64';
    if (abi.contains('arm')) return 'arm';
    if (abi.contains('ia32')) return 'ia32';
    if (abi.contains('riscv64')) return 'riscv64';
    return 'x64';
  }

  Uri get _releasesUrl =>
      Uri.https('api.github.com', '/repos/$repository/releases');

  /// The names this architecture answers to in a release asset.
  ///
  /// One processor goes by several names depending on who packaged it —
  /// `x86_64` and `amd64` and `x64` are the same thing, and `aarch64` is
  /// `arm64`. Matching all of them means the release workflow can name assets
  /// whatever its packaging tools naturally produce.
  List<String> get _architectureAliases => switch (_architecture) {
    'arm64' => const ['arm64', 'aarch64'],
    'arm' => const ['armhf', 'armv7', 'arm'],
    'ia32' => const ['i386', 'x86', 'ia32'],
    'riscv64' => const ['riscv64'],
    _ => const ['x64', 'x86_64', 'amd64'],
  };

  /// Picks the asset for this install *and* this processor.
  ///
  /// [InstallTarget.assetSuffixes] is in preference order, so a copy that can
  /// replace itself takes the plain archive and only falls back to an installer
  /// when the release does not carry one — which is what every release before
  /// archives existed looks like.
  Map<String, Object?> selectAsset(List<Map<String, Object?>> assets) {
    for (final suffix in target.assetSuffixes) {
      final chosen = _selectBySuffix(assets, suffix);
      if (chosen.isNotEmpty) return chosen;
    }
    return const {};
  }

  /// A universal or unlabelled asset — which is what the macOS `.dmg` is, since
  /// it carries both architectures in one bundle — is accepted by any
  /// processor. An asset labelled for a different processor is not: offering
  /// an arm64 machine an x64 build is worse than offering it nothing, because
  /// it looks like it worked until it does not run.
  Map<String, Object?> _selectBySuffix(
    List<Map<String, Object?>> assets,
    String suffix,
  ) {
    final wanted = suffix.toLowerCase();
    final candidates = assets
        .where(
          (a) => (a['name'] as String? ?? '').toLowerCase().endsWith(wanted),
        )
        .toList();
    if (candidates.isEmpty) return const {};

    bool mentions(String name, Iterable<String> words) {
      final lower = name.toLowerCase();
      return words.any(lower.contains);
    }

    // Every architecture name any of our assets could carry, so an asset can
    // be told apart from one that simply does not mention a processor.
    const everyAlias = [
      'arm64',
      'aarch64',
      'armhf',
      'armv7',
      'i386',
      'ia32',
      'riscv64',
      'x64',
      'x86_64',
      'amd64',
    ];

    final aliases = _architectureAliases;
    final exact = candidates
        .where((a) => mentions(a['name']! as String, aliases))
        .toList();
    if (exact.isNotEmpty) return exact.first;

    // No asset names this processor. An unlabelled one is universal — take it.
    final unlabelled = candidates
        .where((a) => !mentions(a['name']! as String, everyAlias))
        .toList();
    if (unlabelled.isNotEmpty) return unlabelled.first;

    // Everything on offer with this extension is for some other processor.
    return const {};
  }

  /// Null when already up to date.
  ///
  /// Throws [UpdateFailure] when the check could not be made at all. Whether
  /// that is worth telling the user about depends on who asked: a background
  /// check that nags about its own update server being unreachable is worse
  /// than one that quietly tries again tomorrow, but a person who just pressed
  /// "check for updates" is owed an answer.
  Future<AvailableUpdate?> check() async {
    final List<dynamic> releases;
    try {
      final response = await _client
          .get(
            _releasesUrl,
            headers: const {'Accept': 'application/vnd.github+json'},
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw UpdateFailure(
          'GitHub answered HTTP ${response.statusCode} when asked for the '
          'list of releases.',
        );
      }
      releases = jsonDecode(response.body) as List<dynamic>;
    } on UpdateFailure {
      rethrow;
    } on Object catch (e) {
      throw UpdateFailure('Could not reach the update server: $e');
    }

    for (final entry in releases) {
      final release = entry as Map<String, Object?>;
      if (release['draft'] == true) continue;
      if (release['prerelease'] == true && !includePreReleases) continue;

      final version = Version.tryParse(release['tag_name'] as String? ?? '');
      if (version == null || !(version > currentVersion)) continue;

      final assets = (release['assets'] as List<dynamic>? ?? const [])
          .cast<Map<String, Object?>>();

      final chosen = selectAsset(assets);
      if (chosen.isEmpty) continue;

      final checksums = await _fetchChecksums(assets);
      final name = chosen['name']! as String;
      final digest = checksums[name];
      if (digest == null) {
        // A release without a checksum for our asset is not installable. We do
        // not fall back to installing it unverified.
        continue;
      }

      return AvailableUpdate(
        version: version,
        assetName: name,
        downloadUrl: chosen['browser_download_url']! as String,
        sha256: digest,
        notes: release['body'] as String? ?? '',
        sizeBytes: (chosen['size'] as num?)?.toInt() ?? 0,
      );
    }

    return null;
  }

  /// Parses the release's `checksums.txt`, in `sha256sum` format:
  /// `<hex>  <filename>` per line.
  Future<Map<String, String>> _fetchChecksums(
    List<Map<String, Object?>> assets,
  ) async {
    final asset = assets.firstWhere(
      (a) => a['name'] == 'checksums.txt',
      orElse: () => const {},
    );
    if (asset.isEmpty) return const {};

    try {
      final response = await _client
          .get(Uri.parse(asset['browser_download_url']! as String))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return const {};

      return {
        for (final line in const LineSplitter().convert(response.body))
          if (line.trim().split(RegExp(r'\s+')) case [final hex, final name])
            name.replaceFirst('*', ''): hex.toLowerCase(),
      };
    } on Object {
      return const {};
    }
  }

  /// Downloads [update] into [directory] and verifies its SHA-256.
  ///
  /// Throws [UpdateFailure] on a mismatch and deletes the file. A binary that
  /// does not match its published digest is either corrupt or substituted, and
  /// there is no version of "install it anyway" that is acceptable here.
  ///
  /// [directory] is emptied first. Kruftle is an app about not leaving build
  /// output lying around; leaving a shelf of superseded installers in its own
  /// support directory would be a poor joke.
  Future<File> download(
    AvailableUpdate update, {
    required String directory,
    void Function(int received, int total)? onProgress,
  }) async {
    final request = http.Request('GET', Uri.parse(update.downloadUrl));
    final http.StreamedResponse response;
    try {
      response = await _client.send(request);
    } on Object catch (e) {
      throw UpdateFailure('Could not reach the download server: $e');
    }

    if (response.statusCode != 200) {
      throw UpdateFailure('Download failed with HTTP ${response.statusCode}.');
    }

    final into = Directory(directory);
    if (into.existsSync()) into.deleteSync(recursive: true);
    into.createSync(recursive: true);

    // `basename`, because the name comes off the network: an asset called
    // `../../kruftle.exe` must land in the updates directory like any other.
    final file = File(p.join(directory, p.basename(update.assetName)));
    final sink = file.openWrite();
    final total = response.contentLength ?? update.sizeBytes;
    var received = 0;

    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      }
    } finally {
      await sink.close();
    }

    final actual = sha256.convert(await file.readAsBytes()).toString();
    if (actual != update.sha256.toLowerCase()) {
      await file.delete();
      throw UpdateFailure(
        'Checksum mismatch: the download does not match the published '
        'SHA-256. The update was discarded.',
      );
    }

    return file;
  }

  /// Applies the verified download.
  ///
  /// Returns true when Kruftle has to quit for it to finish, which it does for
  /// every in-place swap: the helper is waiting for this process to exit before
  /// it can replace the files we are running out of. It relaunches us when it
  /// is done.
  ///
  /// Dispatches on the asset's own extension rather than on the platform, so
  /// what runs is decided by what was actually downloaded.
  Future<bool> install(File asset) async {
    final path = asset.path;
    final name = path.toLowerCase();

    if (name.endsWith('.dmg')) return _applyMacImage(path);
    if (name.endsWith('.zip')) return _applyWindowsArchive(path);
    if (name.endsWith('.tar.gz')) return _applyLinuxArchive(path);
    if (name.endsWith('.appimage')) return _applyAppImage(path);

    if (name.endsWith('.exe')) {
      // Inno Setup. `/NORESTART` because an app update is never a reason to
      // reboot somebody's machine.
      await Process.start(path, [
        '/SILENT',
        '/NORESTART',
        '/CLOSEAPPLICATIONS',
        '/RESTARTAPPLICATIONS',
      ], mode: ProcessStartMode.detached);
      return false;
    }

    // A .deb, which needs a package manager and root. Hand it to the desktop's
    // own installer rather than asking for a password behind a progress bar.
    await Process.start('xdg-open', [path], mode: ProcessStartMode.detached);
    return false;
  }

  Future<bool> _applyMacImage(String image) async {
    final bundle = target.swapDirectory;
    if (bundle == null) {
      // Not running out of a bundle we could replace. Show the disk image and
      // let the drag be done by hand.
      await Process.start('open', [image], mode: ProcessStartMode.detached);
      return false;
    }
    await Process.start('/bin/sh', [
      '-c',
      macSwapScript,
      'kruftle-update',
      image,
      bundle,
      '$pid',
    ], mode: ProcessStartMode.detached);
    return true;
  }

  Future<bool> _applyLinuxArchive(String archive) async {
    final directory = target.swapDirectory;
    if (directory == null) return _reveal(archive);
    await Process.start('/bin/sh', [
      '-c',
      linuxSwapScript,
      'kruftle-update',
      archive,
      directory,
      '$pid',
      Platform.resolvedExecutable,
    ], mode: ProcessStartMode.detached);
    return true;
  }

  Future<bool> _applyAppImage(String image) async {
    final current = target.appImage;
    if (current == null) return _reveal(image);
    await Process.start('/bin/sh', [
      '-c',
      appImageSwapScript,
      'kruftle-update',
      image,
      current,
      '$pid',
    ], mode: ProcessStartMode.detached);
    return true;
  }

  Future<bool> _applyWindowsArchive(String archive) async {
    final directory = target.swapDirectory;
    if (directory == null) return _reveal(archive);

    // Written out rather than passed inline: `powershell -File` takes named
    // arguments, which keeps every path out of the script text.
    final script = File(p.join(p.dirname(archive), 'apply-update.ps1'))
      ..writeAsStringSync(windowsSwapScript);

    await Process.start('powershell', [
      '-NoProfile',
      '-NonInteractive',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      script.path,
      '-Archive',
      archive,
      '-Dir',
      directory,
      '-Owner',
      '$pid',
      '-Exe',
      Platform.resolvedExecutable,
    ], mode: ProcessStartMode.detached);
    return true;
  }

  /// The last resort: show the user what was downloaded. Reached only when the
  /// install shape changed underneath us between the check and the install.
  Future<bool> _reveal(String path) async {
    await Process.start(Platform.isWindows ? 'explorer' : 'xdg-open', [
      p.dirname(path),
    ], mode: ProcessStartMode.detached);
    return false;
  }
}
