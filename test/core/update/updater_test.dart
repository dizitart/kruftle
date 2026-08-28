// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kruftle/src/core/update/updater.dart';
import 'package:kruftle/src/core/update/version.dart';

/// The update a check offered, or null.
///
/// `check()` reports more than that — it also says why nothing was offered —
/// and the tests that care about the difference ask for it directly.
extension on Updater {
  Future<AvailableUpdate?> offered() => check().then((c) => c.update);
}

void main() {
  group('Version', () {
    test('parses the forms a release tag actually takes', () {
      expect(Version.tryParse('1.2.3').toString(), '1.2.3');
      expect(Version.tryParse('v1.2.3').toString(), '1.2.3');
      expect(Version.tryParse('1.2.3+45').toString(), '1.2.3');
      expect(Version.tryParse('1.2.3-beta.1').toString(), '1.2.3-beta.1');
    });

    test('returns null for anything unreadable instead of throwing', () {
      for (final bad in ['', 'latest', '1.2', 'nightly-2026-08-23', 'v1.x']) {
        expect(Version.tryParse(bad), isNull, reason: bad);
      }
    });

    test('orders by major, then minor, then patch', () {
      expect(Version.tryParse('2.0.0')! > Version.tryParse('1.9.9')!, isTrue);
      expect(Version.tryParse('1.10.0')! > Version.tryParse('1.9.0')!, isTrue);
      expect(Version.tryParse('1.0.2')! > Version.tryParse('1.0.1')!, isTrue);
      expect(Version.tryParse('1.0.0')! > Version.tryParse('1.0.0')!, isFalse);
    });

    test('a release-candidate tag sits between two releases', () {
      // How an update is tested without spending a version number on it.
      //
      // A throwaway build tagged v0.2.7-rc.1 is newer than 0.2.6, so an
      // installed 0.2.6 is offered it and the whole path can be watched; it is
      // older than 0.2.7, so whoever took it moves on to the real release when
      // that ships; and it consumes no number, so deleting it afterwards
      // leaves no gap in the history. Publishing the throwaway as 0.2.5 and
      // then releasing the fix as 0.2.6 left exactly such a gap, permanently.
      const chain = [
        '0.2.6',
        '0.2.7-rc.1',
        '0.2.7-rc.2',
        '0.2.7',
        '0.2.8-rc.1',
      ];
      for (var i = 0; i + 1 < chain.length; i++) {
        expect(
          Version.tryParse(chain[i + 1])! > Version.tryParse(chain[i])!,
          isTrue,
          reason: '${chain[i + 1]} must be newer than ${chain[i]}',
        );
      }
    });

    test('a pre-release sorts before its own release', () {
      expect(
        Version.tryParse('1.0.0')! > Version.tryParse('1.0.0-beta.1')!,
        isTrue,
      );
      expect(
        Version.tryParse('1.0.0-beta.2')! > Version.tryParse('1.0.0-beta.1')!,
        isTrue,
      );
    });
  });

  group('Updater.check', () {
    const installer = 'Kruftle-1.4.0-macos.dmg';
    final digest = 'a' * 64;

    String releasesJson({
      String tag = 'v1.4.0',
      bool prerelease = false,
      bool draft = false,
      List<String> assets = const [installer, 'checksums.txt'],
    }) => jsonEncode([
      {
        'tag_name': tag,
        'draft': draft,
        'prerelease': prerelease,
        'body': 'Fixes things.',
        'assets': [
          for (final name in assets)
            {
              'name': name,
              'size': 1024,
              'browser_download_url': 'https://example.test/$name',
            },
        ],
      },
    ]);

    MockClient clientFor(String releases, {String? checksums}) =>
        MockClient((request) async {
          if (request.url.host == 'api.github.com') {
            return http.Response(releases, 200);
          }
          if (request.url.path.endsWith('checksums.txt')) {
            return http.Response(checksums ?? '$digest  $installer\n', 200);
          }
          return http.Response('', 404);
        });

    Updater updaterWith(
      http.Client client, {
      String current = '1.0.0',
      bool preReleases = false,
    }) => Updater(
      currentVersion: Version.tryParse(current)!,
      client: client,
      includePreReleases: preReleases,
      target: const InstallTarget(
        platform: HostPlatform.macOS,
        assetSuffixes: ['.dmg'],
        swapDirectory: '/Applications/Kruftle.app',
      ),
    );

    test('finds a newer release and its verified installer', () async {
      final update = await updaterWith(clientFor(releasesJson())).offered();

      expect(update, isNotNull);
      expect(update!.version.toString(), '1.4.0');
      expect(update.assetName, installer);
      expect(update.sha256, digest);
      expect(update.notes, 'Fixes things.');
    });

    test('reports nothing when already up to date', () async {
      expect(
        await updaterWith(
          clientFor(releasesJson()),
          current: '1.4.0',
        ).offered(),
        isNull,
      );
      expect(
        await updaterWith(
          clientFor(releasesJson()),
          current: '2.0.0',
        ).offered(),
        isNull,
      );
    });

    group('picks the latest release, not the next one up', () {
      /// Several releases at once, in the order GitHub lists them: by
      /// publication date, newest first.
      String manyReleases(List<String> tags) => jsonEncode([
        for (final tag in tags)
          {
            'tag_name': tag,
            'draft': false,
            'prerelease': false,
            'body': '',
            'assets': [
              for (final name in [
                'Kruftle-${tag.substring(1)}-macos.dmg',
                'checksums.txt',
              ])
                {
                  'name': name,
                  'size': 1024,
                  'browser_download_url': 'https://example.test/$name',
                },
            ],
          },
      ]);

      MockClient clientForMany(String releases) => MockClient((request) async {
        if (request.url.host == 'api.github.com') {
          return http.Response(releases, 200);
        }
        // Every asset is listed, so whichever release is chosen verifies.
        return http.Response(
          [
            for (final v in const ['1.1.0', '1.2.0', '1.3.0', '2.0.0'])
              '$digest  Kruftle-$v-macos.dmg',
          ].join('\n'),
          200,
        );
      });

      test('several versions ahead, it offers the newest', () async {
        final update = await updaterWith(
          clientForMany(manyReleases(['v2.0.0', 'v1.3.0', 'v1.2.0', 'v1.1.0'])),
        ).offered();

        expect(update!.version.toString(), '2.0.0');
      });

      test('a patch published after a newer release does not win', () async {
        // The real trap. GitHub lists by publication date, so 1.1.0 cut on an
        // old branch *after* 2.0.0 shipped comes back first. Taking the first
        // newer entry would offer 1.1.0, and an app would climb one stale
        // release at a time instead of arriving at the latest.
        final update = await updaterWith(
          clientForMany(manyReleases(['v1.1.0', 'v2.0.0', 'v1.3.0'])),
        ).offered();

        expect(update!.version.toString(), '2.0.0');
      });

      test('it drops to the next one down when the newest has no asset', () {
        // Not the same thing as preferring an older release: a release this
        // platform cannot install is not an upgrade it can be offered.
        final releases = jsonEncode([
          {
            'tag_name': 'v3.0.0',
            'draft': false,
            'prerelease': false,
            'body': '',
            'assets': const <Map<String, Object?>>[],
          },
          ...(jsonDecode(manyReleases(['v2.0.0'])) as List<dynamic>),
        ]);

        expectLater(
          updaterWith(clientForMany(releases)).offered(),
          completion(
            isA<AvailableUpdate>().having(
              (u) => u.version.toString(),
              'version',
              '2.0.0',
            ),
          ),
        );
      });
    });

    test('ignores drafts', () async {
      final update = await updaterWith(
        clientFor(releasesJson(draft: true)),
      ).offered();
      expect(update, isNull);
    });

    test('ignores pre-releases unless the user opted in', () async {
      final json = releasesJson(tag: 'v1.4.0-beta.1', prerelease: true);
      expect(await updaterWith(clientFor(json)).offered(), isNull);
      expect(
        await updaterWith(clientFor(json), preReleases: true).offered(),
        isNotNull,
      );
    });

    group('nothing offered says which kind of nothing', () {
      // "Up to date" and "there is a newer release and none of it fits this
      // install" are both no-update, and told apart nowhere else. Two reports
      // of "updating does nothing" have turned on exactly this distinction.
      test('being current is up to date', () async {
        final result = await updaterWith(
          clientFor(releasesJson()),
          current: '1.4.0',
        ).check();

        expect(result.isUpToDate, isTrue);
        expect(result.blockedVersion, isNull);
        expect(result.outcome, 'up to date');
      });

      test('a release with no asset for this install is not', () async {
        // A Linux release, asked for by a macOS build.
        final result = await updaterWith(
          clientFor(
            releasesJson(
              assets: const ['Kruftle-1.4.0-x86_64.AppImage', 'checksums.txt'],
            ),
          ),
        ).check();

        expect(result.isUpToDate, isFalse);
        expect(result.update, isNull);
        expect('${result.blockedVersion}', '1.4.0');
        expect(result.reason, contains('.dmg'));
        expect(
          result.reason,
          contains('Kruftle-1.4.0-x86_64.AppImage'),
          reason: 'the log has to say what was on offer instead',
        );
      });

      test('a release with no checksum for our asset is not either', () async {
        final result = await updaterWith(
          clientFor(releasesJson(), checksums: 'nothing  for-us.txt\n'),
        ).check();

        expect(result.isUpToDate, isFalse);
        expect('${result.blockedVersion}', '1.4.0');
        expect(result.reason, contains('checksum'));
      });

      test('the newest unusable release is the one reported', () async {
        // Not the oldest one it walked past on the way down.
        final releases = jsonEncode([
          for (final tag in const ['v3.0.0', 'v2.0.0'])
            {
              'tag_name': tag,
              'draft': false,
              'prerelease': false,
              'body': '',
              'assets': const <Map<String, Object?>>[],
            },
        ]);
        final result = await updaterWith(clientFor(releases)).check();
        expect('${result.blockedVersion}', '3.0.0');
      });
    });

    test('refuses a release with no checksum for our asset', () async {
      final update = await updaterWith(
        clientFor(releasesJson(assets: const [installer])),
      ).offered();

      expect(
        update,
        isNull,
        reason: 'an installer we cannot verify is not an update',
      );
    });

    test('picks the asset matching this platform', () async {
      const assets = [
        'Kruftle-1.4.0-macos.dmg',
        'Kruftle-1.4.0-windows.exe',
        'Kruftle-1.4.0-x86_64.AppImage',
        'checksums.txt',
      ];
      final checksums = assets.map((a) => '$digest  $a').join('\n');

      // The architecture is pinned rather than inherited from whatever
      // machine runs the tests: asset selection is architecture-aware now, and
      // a test whose result depends on the build host is not a test.
      // `test/core/update/architecture_test.dart` covers that dimension.
      Future<String?> assetFor(InstallTarget target) async {
        final update = await Updater(
          currentVersion: Version.tryParse('1.0.0')!,
          client: clientFor(releasesJson(assets: assets), checksums: checksums),
          target: target,
          architecture: 'x64',
        ).offered();
        return update?.assetName;
      }

      expect(
        await assetFor(
          const InstallTarget(
            platform: HostPlatform.macOS,
            assetSuffixes: ['.dmg'],
          ),
        ),
        endsWith('.dmg'),
      );
      expect(
        await assetFor(
          const InstallTarget(
            platform: HostPlatform.windows,
            assetSuffixes: ['.zip', '.exe'],
          ),
        ),
        endsWith('.exe'),
        reason: 'this release carries no archive, so the installer stands in',
      );
      expect(
        await assetFor(
          const InstallTarget(
            platform: HostPlatform.linux,
            assetSuffixes: ['.AppImage'],
          ),
        ),
        endsWith('.AppImage'),
      );
    });

    // A check that could not be made is reported as a failure rather than as
    // "up to date". Whether the user is shown it is the caller's call —
    // `UpdateController` swallows it for the check at launch and surfaces it
    // for the one a person asked for. Saying "up to date" when we never got an
    // answer is the one thing neither caller could recover from.
    test('a network failure is a failure, not an up-to-date answer', () async {
      final client = MockClient(
        (_) async => throw const SocketException('no route'),
      );
      await expectLater(
        updaterWith(client).check(),
        throwsA(isA<UpdateFailure>()),
      );
    });

    test('a rate-limited or broken API is a failure too', () async {
      await expectLater(
        updaterWith(MockClient((_) async => http.Response('{}', 403))).check(),
        throwsA(
          isA<UpdateFailure>().having(
            (e) => e.message,
            'message',
            contains('403'),
          ),
        ),
      );
    });
  });

  group('Updater.download', () {
    late Directory tmp;
    setUp(() => tmp = Directory.systemTemp.createTempSync('kruftle_update'));
    tearDown(() => tmp.deleteSync(recursive: true));

    final payload = utf8.encode('pretend this is an installer');
    final realDigest = sha256.convert(payload).toString();

    AvailableUpdate updateWith(String expectedDigest) => AvailableUpdate(
      version: Version.tryParse('1.4.0')!,
      assetName: 'Kruftle-1.4.0.dmg',
      downloadUrl: 'https://example.test/Kruftle-1.4.0.dmg',
      sha256: expectedDigest,
      notes: '',
      sizeBytes: payload.length,
    );

    Updater downloaderFor(int status) => Updater(
      currentVersion: Version.tryParse('1.0.0')!,
      target: const InstallTarget(
        platform: HostPlatform.macOS,
        assetSuffixes: ['.dmg'],
      ),
      client: MockClient((_) async => http.Response.bytes(payload, status)),
    );

    test('writes the file when the checksum matches', () async {
      final file = await downloaderFor(
        200,
      ).download(updateWith(realDigest), directory: tmp.path);

      expect(file.existsSync(), isTrue);
      expect(file.readAsBytesSync(), payload);
    });

    test(
      'refuses and deletes the file when the checksum does not match',
      () async {
        final updater = downloaderFor(200);

        await expectLater(
          updater.download(updateWith('b' * 64), directory: tmp.path),
          throwsA(
            isA<UpdateFailure>().having(
              (e) => e.message,
              'message',
              contains('Checksum mismatch'),
            ),
          ),
        );

        expect(
          Directory(tmp.path).listSync(),
          isEmpty,
          reason: 'an unverified binary must not be left on disk',
        );
      },
    );

    test('a checksum comparison is case-insensitive', () async {
      final file = await downloaderFor(
        200,
      ).download(updateWith(realDigest.toUpperCase()), directory: tmp.path);
      expect(file.existsSync(), isTrue);
    });

    test('an HTTP error is a clear failure, not a corrupt file', () async {
      await expectLater(
        downloaderFor(
          404,
        ).download(updateWith(realDigest), directory: tmp.path),
        throwsA(isA<UpdateFailure>()),
      );
    });

    test('reports download progress', () async {
      var lastReceived = 0;
      await downloaderFor(200).download(
        updateWith(realDigest),
        directory: tmp.path,
        onProgress: (received, _) => lastReceived = received,
      );
      expect(lastReceived, payload.length);
    });
  });
}
