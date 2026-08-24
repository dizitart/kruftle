// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kruftle/src/core/update/updater.dart';
import 'package:kruftle/src/core/update/version.dart';

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
      windows: false,
      macOS: true,
    );

    test('finds a newer release and its verified installer', () async {
      final update = await updaterWith(clientFor(releasesJson())).check();

      expect(update, isNotNull);
      expect(update!.version.toString(), '1.4.0');
      expect(update.assetName, installer);
      expect(update.sha256, digest);
      expect(update.notes, 'Fixes things.');
    });

    test('reports nothing when already up to date', () async {
      expect(
        await updaterWith(clientFor(releasesJson()), current: '1.4.0').check(),
        isNull,
      );
      expect(
        await updaterWith(clientFor(releasesJson()), current: '2.0.0').check(),
        isNull,
      );
    });

    test('ignores drafts', () async {
      final update = await updaterWith(
        clientFor(releasesJson(draft: true)),
      ).check();
      expect(update, isNull);
    });

    test('ignores pre-releases unless the user opted in', () async {
      final json = releasesJson(tag: 'v1.4.0-beta.1', prerelease: true);
      expect(await updaterWith(clientFor(json)).check(), isNull);
      expect(
        await updaterWith(clientFor(json), preReleases: true).check(),
        isNotNull,
      );
    });

    test('refuses a release with no checksum for our asset', () async {
      final update = await updaterWith(
        clientFor(releasesJson(assets: const [installer])),
      ).check();

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
      Future<String?> assetFor({
        required bool windows,
        required bool mac,
      }) async {
        final update = await Updater(
          currentVersion: Version.tryParse('1.0.0')!,
          client: clientFor(releasesJson(assets: assets), checksums: checksums),
          windows: windows,
          macOS: mac,
          architecture: 'x64',
        ).check();
        return update?.assetName;
      }

      expect(await assetFor(windows: false, mac: true), endsWith('.dmg'));
      expect(await assetFor(windows: true, mac: false), endsWith('.exe'));
      expect(await assetFor(windows: false, mac: false), endsWith('.AppImage'));
    });

    test(
      'a network failure is silent, not an error the user must dismiss',
      () async {
        final client = MockClient(
          (_) async => throw const SocketException('no route'),
        );
        expect(await updaterWith(client).check(), isNull);
      },
    );

    test('a rate-limited or broken API is silent too', () async {
      expect(
        await updaterWith(
          MockClient((_) async => http.Response('{}', 403)),
        ).check(),
        isNull,
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
