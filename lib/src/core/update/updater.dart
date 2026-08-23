// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'version.dart';

/// A release newer than what is running, with the installer for this platform.
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
}

/// Why an update could not be applied.
class UpdateFailure implements Exception {
  const UpdateFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Checks GitHub Releases, downloads the right installer, verifies it, and
/// hands it to the operating system.
///
/// Deliberately not Sparkle/WinSparkle: those need an appcast and, on macOS, a
/// Developer ID signature to work smoothly. This does the same job identically
/// on all three platforms with no extra infrastructure, at the cost of handing
/// off to the platform installer rather than swapping the binary in place.
class Updater {
  Updater({
    required this.currentVersion,
    http.Client? client,
    this.repository = 'dizitart/kruftle',
    this.includePreReleases = false,
    bool? windows,
    bool? macOS,
  }) : _client = client ?? http.Client(),
       _windows = windows ?? Platform.isWindows,
       _macOS = macOS ?? Platform.isMacOS;

  final Version currentVersion;
  final String repository;
  final bool includePreReleases;
  final http.Client _client;
  final bool _windows;
  final bool _macOS;

  Uri get _releasesUrl =>
      Uri.https('api.github.com', '/repos/$repository/releases');

  /// The installer extension this platform can run.
  String get _assetSuffix => _windows
      ? '.exe'
      : _macOS
      ? '.dmg'
      : '.AppImage';

  /// Null when already up to date, or when the check simply could not be made.
  ///
  /// A failed check is not an error the user needs to see: an app that nags
  /// about its own update server being unreachable is worse than one that
  /// quietly tries again tomorrow.
  Future<AvailableUpdate?> check() async {
    final List<dynamic> releases;
    try {
      final response = await _client
          .get(
            _releasesUrl,
            headers: const {'Accept': 'application/vnd.github+json'},
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;
      releases = jsonDecode(response.body) as List<dynamic>;
    } on Object {
      return null;
    }

    for (final entry in releases) {
      final release = entry as Map<String, Object?>;
      if (release['draft'] == true) continue;
      if (release['prerelease'] == true && !includePreReleases) continue;

      final version = Version.tryParse(release['tag_name'] as String? ?? '');
      if (version == null || !(version > currentVersion)) continue;

      final assets = (release['assets'] as List<dynamic>? ?? const [])
          .cast<Map<String, Object?>>();

      final installer = assets.firstWhere(
        (a) => (a['name'] as String? ?? '').endsWith(_assetSuffix),
        orElse: () => const {},
      );
      if (installer.isEmpty) continue;

      final checksums = await _fetchChecksums(assets);
      final name = installer['name']! as String;
      final digest = checksums[name];
      if (digest == null) {
        // A release without a checksum for our asset is not installable. We do
        // not fall back to installing it unverified.
        continue;
      }

      return AvailableUpdate(
        version: version,
        assetName: name,
        downloadUrl: installer['browser_download_url']! as String,
        sha256: digest,
        notes: release['body'] as String? ?? '',
        sizeBytes: (installer['size'] as num?)?.toInt() ?? 0,
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

    Directory(directory).createSync(recursive: true);
    final file = File(p.join(directory, update.assetName));
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

  /// Hands the verified installer to the OS.
  ///
  /// The app is expected to exit immediately afterwards: on every platform the
  /// installer needs to replace files this process is holding open.
  Future<void> install(File installer) async {
    if (_windows) {
      // Inno Setup: run silently, restart the app when finished.
      await Process.start(installer.path, [
        '/SILENT',
        '/CLOSEAPPLICATIONS',
        '/RESTARTAPPLICATIONS',
      ], mode: ProcessStartMode.detached);
    } else if (_macOS) {
      // Mounting the .dmg and showing it is as far as we go: dragging the app
      // to /Applications is the user's decision, and doing it for them means
      // writing into a directory we were never granted.
      await Process.start('open', [
        installer.path,
      ], mode: ProcessStartMode.detached);
    } else {
      // AppImage: make it executable and replace the running one in place.
      await Process.run('chmod', ['+x', installer.path]);
      final current = Platform.environment['APPIMAGE'];
      if (current != null && current.isNotEmpty) {
        await installer.copy(current);
      } else {
        await Process.start('xdg-open', [
          installer.parent.path,
        ], mode: ProcessStartMode.detached);
      }
    }
  }
}
