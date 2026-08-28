// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kruftle/l10n/app_localizations.dart';
import 'package:kruftle/src/core/update/updater.dart';
import 'package:kruftle/src/core/update/version.dart';
import 'package:kruftle/src/ui/state/app_state.dart';
import 'package:kruftle/src/ui/state/update_controller.dart';
import 'package:kruftle/src/ui/theme.dart';
import 'package:kruftle/src/ui/widgets/update_banner.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

/// The banner is the whole of what a user sees of updating, so this walks it
/// through every state the controller can put it in, against a real `Updater`
/// with a stubbed network.
void main() {
  late Directory support;

  setUp(() {
    support = Directory.systemTemp.createTempSync('kruftle-update-ui');
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() => support.deleteSync(recursive: true));

  final payload = utf8.encode('a whole new Kruftle');
  final digest = sha256.convert(payload).toString();

  /// A release one version above whatever [kAppVersion] says.
  String releases({String asset = 'Kruftle-99.0.0-linux-x86_64.tar.gz'}) =>
      jsonEncode([
        {
          'tag_name': 'v99.0.0',
          'draft': false,
          'prerelease': false,
          'body': 'Everything is better.',
          'assets': [
            for (final name in [asset, 'checksums.txt'])
              {
                'name': name,
                'size': payload.length,
                'browser_download_url': 'https://example.test/$name',
              },
          ],
        },
      ]);

  MockClient client(String? body, {int status = 200, String? sums}) =>
      MockClient((request) async {
        if (request.url.host == 'api.github.com') {
          return http.Response(body ?? '[]', status);
        }
        if (request.url.path.endsWith('checksums.txt')) {
          return http.Response(sums ?? '', 200);
        }
        return http.Response.bytes(payload, 200);
      });

  Future<ProviderContainer> pump(
    WidgetTester tester,
    http.Client stub, {
    InstallTarget target = const InstallTarget(
      assetSuffixes: ['.tar.gz'],
      swapDirectory: '/home/me/kruftle',
    ),
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appSupportDirectoryProvider.overrideWithValue(support.path),
        installTargetProvider.overrideWithValue(target),
        updaterProvider.overrideWith(
          (ref) => Updater(
            currentVersion: Version.tryParse(kAppVersion)!,
            target: target,
            client: stub,
            architecture: 'x64',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: KruftleTheme.dark(),
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          home: const Scaffold(body: UpdateBanner()),
        ),
      ),
    );
    return container;
  }

  testWidgets('nothing is shown until there is something to say', (
    tester,
  ) async {
    await pump(tester, client(releases()));
    expect(find.byType(UpdateBanner), findsOneWidget);
    expect(find.byType(Row), findsNothing, reason: 'the banner is collapsed');
  });

  testWidgets('a new release is offered, with its size, and can be dismissed', (
    tester,
  ) async {
    final container = await pump(
      tester,
      client(releases(), sums: '$digest  Kruftle-99.0.0-linux-x86_64.tar.gz\n'),
    );

    await container.read(updateProvider.notifier).check();
    await tester.pump();

    expect(find.textContaining('99.0.0'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(find.textContaining('99.0.0'), findsNothing);
  });

  testWidgets('the download is verified and then waits to be applied', (
    tester,
  ) async {
    final container = await pump(
      tester,
      client(releases(), sums: '$digest  Kruftle-99.0.0-linux-x86_64.tar.gz\n'),
    );

    // `runAsync`: the download writes a real file, and real I/O does not
    // complete under the fake clock a widget test runs on.
    await tester.runAsync(() async {
      await container.read(updateProvider.notifier).check();
      await container.read(updateProvider.notifier).download();
    });
    await tester.pump();

    final state = container.read(updateProvider);
    expect(state.phase, UpdatePhase.ready);
    expect(state.installer!.readAsBytesSync(), payload);

    // Nothing was replaced. The swap happens on a restart the user asks for,
    // which is the whole difference from an installer running behind a
    // progress bar.
    expect(find.text('Restart now'), findsOneWidget);
  });

  testWidgets('a download that does not match its checksum is discarded', (
    tester,
  ) async {
    final container = await pump(
      tester,
      client(
        releases(),
        sums: '${'b' * 64}  Kruftle-99.0.0-linux-x86_64.tar.gz\n',
      ),
    );

    // `runAsync`: the download writes a real file, and real I/O does not
    // complete under the fake clock a widget test runs on.
    await tester.runAsync(() async {
      await container.read(updateProvider.notifier).check();
      await container.read(updateProvider.notifier).download();
    });
    await tester.pump();

    expect(container.read(updateProvider).phase, UpdatePhase.failed);
    expect(find.textContaining('Checksum mismatch'), findsOneWidget);
    final updates = Directory(p.join(support.path, 'updates'));
    expect(
      updates.existsSync() ? updates.listSync() : const <FileSystemEntity>[],
      isEmpty,
      reason: 'a download that could not be verified is not kept',
    );
  });

  testWidgets('an installer-only copy is told to install, not to restart', (
    tester,
  ) async {
    // A .deb under /usr cannot be swapped in place, so "restart to finish"
    // would be a lie.
    final container = await pump(
      tester,
      client(
        releases(asset: 'Kruftle-99.0.0-amd64.deb'),
        sums: '$digest  Kruftle-99.0.0-amd64.deb\n',
      ),
      target: const InstallTarget(assetSuffixes: ['.deb']),
    );

    // `runAsync`: the download writes a real file, and real I/O does not
    // complete under the fake clock a widget test runs on.
    await tester.runAsync(() async {
      await container.read(updateProvider.notifier).check();
      await container.read(updateProvider.notifier).download();
    });
    await tester.pump();

    expect(find.text('Restart now'), findsNothing);
    expect(find.text('Update'), findsOneWidget);
  });

  group('the check at launch and the one a person asks for', () {
    testWidgets('an unreachable server says nothing in the background', (
      tester,
    ) async {
      final container = await pump(tester, client(null, status: 503));
      await container.read(updateProvider.notifier).check();
      await tester.pump();

      expect(container.read(updateProvider).phase, UpdatePhase.idle);
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('and says so when the button was pressed', (tester) async {
      // The silence is right for a check nobody asked for and useless for
      // somebody wondering why they are never offered anything.
      final container = await pump(tester, client(null, status: 503));
      await container.read(updateProvider.notifier).check(byHand: true);
      await tester.pump();

      expect(container.read(updateProvider).phase, UpdatePhase.failed);
      expect(find.textContaining('503'), findsOneWidget);
    });

    testWidgets('being up to date is worth saying, once asked', (tester) async {
      final container = await pump(tester, client('[]'));

      await container.read(updateProvider.notifier).check();
      await tester.pump();
      expect(find.byType(Row), findsNothing);

      await container.read(updateProvider.notifier).check(byHand: true);
      await tester.pump();
      expect(find.text('Kruftle is up to date.'), findsOneWidget);
    });
  });
}
