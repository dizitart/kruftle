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

export 'install_target.dart' show HostPlatform, InstallTarget;

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

/// What a check found, including when what it found was nothing.
///
/// "Up to date" and "there is a newer release, and nothing in it this copy can
/// install" look identical from outside — both are simply no update — and the
/// difference between them is the difference between a shrug and a bug report.
/// Telling them apart is the whole reason this is not just a nullable
/// [AvailableUpdate].
class UpdateCheck {
  const UpdateCheck({this.update, this.blockedVersion, this.reason});

  final AvailableUpdate? update;

  /// The newest release this copy could *not* use, when there was one.
  final Version? blockedVersion;

  /// Why it could not, in the log's words rather than the user's.
  final String? reason;

  bool get isUpToDate => update == null && blockedVersion == null;

  /// For the activity log.
  String get outcome => switch (this) {
    _ when update != null =>
      'offering ${update!.version} (${update!.assetName})',
    _ when blockedVersion != null => '$blockedVersion unusable: $reason',
    _ => 'up to date',
  };
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

  /// `per_page`, because the default is thirty and the answer has to contain
  /// the newest release however many have been cut since.
  Uri get _releasesUrl => Uri.https(
    'api.github.com',
    '/repos/$repository/releases',
    const {'per_page': '100'},
  );

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
    bool mentions(String name, Iterable<String> words) {
      final lower = name.toLowerCase();
      return words.any(lower.contains);
    }

    // Another platform's asset is never a candidate, whatever its extension.
    // macOS and Windows both publish a `.zip` now, and the macOS one carries no
    // processor in its name — it is universal — so without this a Windows build
    // whose own archive was missing would happily take it.
    final foreign = [
      for (final other in HostPlatform.values)
        if (other != target.platform) other.token,
    ];

    final wanted = suffix.toLowerCase();
    final candidates = assets
        .map((a) => (a, (a['name'] as String? ?? '').toLowerCase()))
        .where((e) => e.$2.endsWith(wanted) && !mentions(e.$2, foreign))
        .map((e) => e.$1)
        .toList();
    if (candidates.isEmpty) return const {};

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

  /// Throws [UpdateFailure] when the check could not be made at all. Whether
  /// that is worth telling the user about depends on who asked: a background
  /// check that nags about its own update server being unreachable is worse
  /// than one that quietly tries again tomorrow, but a person who just pressed
  /// "check for updates" is owed an answer.
  Future<UpdateCheck> check() async {
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

    // Highest version first, not the order GitHub happened to list them in.
    //
    // That order is by publication date, and the two come apart: a patch cut on
    // an older line after a newer release — 0.2.9 published after 0.3.0 — sorts
    // first there, and an app on 0.2.8 would be offered 0.2.9 and stay a whole
    // minor version behind, one release at a time. Sorting by what the tag
    // actually means costs nothing and cannot drift from the API's ordering.
    final newer =
        releases
            .cast<Map<String, Object?>>()
            .where((r) => r['draft'] != true)
            .where((r) => r['prerelease'] != true || includePreReleases)
            .map((r) => (Version.tryParse(r['tag_name'] as String? ?? ''), r))
            .where((e) => e.$1 != null && e.$1! > currentVersion)
            .map((e) => (e.$1!, e.$2))
            .toList()
          ..sort((a, b) => b.$1.compareTo(a.$1));

    // Why the newest unusable release was unusable, kept for the log and for
    // the person who pressed the button. Only the first is recorded: it is the
    // newest, and the rest are the same story further down.
    Version? blocked;
    String? reason;

    for (final (version, release) in newer) {
      final assets = (release['assets'] as List<dynamic>? ?? const [])
          .cast<Map<String, Object?>>();

      final chosen = selectAsset(assets);
      if (chosen.isEmpty) {
        blocked ??= version;
        reason ??=
            'no ${target.assetSuffixes.join(' or ')} for $_architecture among '
            '${assets.map((a) => a['name']).join(', ')}';
        continue;
      }

      final checksums = await _fetchChecksums(assets);
      final name = chosen['name']! as String;
      final digest = checksums[name];
      if (digest == null) {
        // A release without a checksum for our asset is not installable. We do
        // not fall back to installing it unverified, and we do not stop
        // looking: the next one down is still an upgrade.
        blocked ??= version;
        reason ??= 'no published checksum for $name';
        continue;
      }

      return UpdateCheck(
        update: AvailableUpdate(
          version: version,
          assetName: name,
          downloadUrl: chosen['browser_download_url']! as String,
          sha256: digest,
          notes: release['body'] as String? ?? '',
          sizeBytes: (chosen['size'] as num?)?.toInt() ?? 0,
        ),
      );
    }

    return UpdateCheck(blockedVersion: blocked, reason: reason);
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
  /// An installer is recognised by its own extension, since each belongs to
  /// exactly one platform. An *archive* is not: macOS and Windows both publish
  /// a `.zip`, unpacked by different helpers, so what applies one is decided by
  /// where this copy lives rather than by what it is called.
  Future<bool> install(File asset) async {
    final path = asset.path;
    final name = path.toLowerCase();

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

    if (name.endsWith('.deb')) return _applyDebianPackage(path);

    if (name.endsWith('.dmg')) return _applyMacImage(path);
    if (name.endsWith('.appimage')) return _applyAppImage(path);

    return switch (target.platform) {
      HostPlatform.macOS => _applyMacArchive(path),
      HostPlatform.windows => _applyWindowsArchive(path),
      HostPlatform.linux => _applyLinuxArchive(path),
    };
  }

  /// Installs a `.deb` over the running copy, asking for a password properly.
  ///
  /// This used to hand the file to `xdg-open`, on the reasoning that a system
  /// package is the desktop's business and not ours. In practice that opens
  /// GNOME Software, and GNOME Software will not upgrade a package it already
  /// considers installed — it shows the new version, greys the button out, and
  /// does nothing. The update looked applied and was not.
  ///
  /// `pkexec` is how a desktop application asks for root: polkit shows its own
  /// password dialog, and a refusal is a clean no rather than a half-done
  /// update. There is no version of "replace a package under /usr" that does
  /// not need this, so the honest thing is to ask for it plainly.
  ///
  /// `dpkg` replaces the files of a running program quite happily on Linux, so
  /// the install finishes while Kruftle is still up — but the Kruftle that is
  /// up is still the old one, and it cannot start its own replacement while it
  /// holds the single-instance lock. The relaunch waits for it to go.
  Future<bool> _applyDebianPackage(String package) async {
    bool installed;
    try {
      // ponytail: `dpkg -i`, not `apt-get install`. It is the right tool for
      // replacing a package whose dependencies have not changed, which is what
      // an update of our own .deb is. If Kruftle ever gains a new runtime
      // dependency, dpkg will refuse the unmet one and this falls through to
      // showing the file — swap in `apt-get install -y <path>` then, which
      // resolves them.
      final result = await Process.run('pkexec', [
        'dpkg',
        '--install',
        package,
      ]);
      installed = result.exitCode == 0;
    } on Object {
      installed = false; // No pkexec, or no polkit agent to answer it.
    }

    if (!installed) {
      // Cancelled, or nothing to ask with. Show the file rather than pretend.
      await Process.start('xdg-open', [
        package,
      ], mode: ProcessStartMode.detached);
      return false;
    }

    await Process.start('/bin/sh', [
      '-c',
      relaunchScript,
      'kruftle-update',
      Platform.resolvedExecutable,
      '$pid',
    ], mode: ProcessStartMode.detached);
    return true;
  }

  Future<bool> _applyMacArchive(String archive) async {
    final bundle = target.swapDirectory;
    if (bundle == null) return _reveal(archive);
    await Process.start('/bin/sh', [
      '-c',
      macArchiveSwapScript,
      'kruftle-update',
      archive,
      bundle,
      '$pid',
    ], mode: ProcessStartMode.detached);
    return true;
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
