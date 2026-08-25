// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/l10n/app_localizations.dart';
import 'package:kruftle/src/core/changelog/changelog.dart';
import 'package:kruftle/src/core/settings/settings.dart';
import 'package:kruftle/src/ui/about_pages.dart';
import 'package:kruftle/src/ui/consent_page.dart';
import 'package:kruftle/src/ui/state/app_state.dart';
import 'package:kruftle/src/ui/theme.dart';
import 'package:kruftle/src/ui/tour_page.dart';
import 'package:kruftle/src/ui/widgets/document.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

Future<ProviderContainer> pumpAbout(
  WidgetTester tester,
  Widget child, {
  Settings settings = const Settings(),
  String? version,
}) async {
  SharedPreferences.setMockInitialValues({
    'kruftle.settings.v1': settings.encode(),
  });
  final preferences = await SharedPreferences.getInstance();

  tester.view.physicalSize = const Size(1000, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      appSupportDirectoryProvider.overrideWithValue('/tmp/kruftle-test'),
      appVersionProvider.overrideWithValue(version),
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
        home: child,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
  return container;
}

void main() {
  group('the shipped documents', () {
    test('the changelog asset parses and is newest first', () {
      final changelog = Changelog.decode(
        File('assets/changelog.json').readAsStringSync(),
      );

      expect(changelog, isNotNull);
      expect(changelog!.entries, isNotEmpty);
      for (final entry in changelog.entries) {
        expect(entry.version, isNotEmpty);
        expect(entry.date, isNotEmpty);
        expect(
          entry.isEmpty,
          isFalse,
          reason: '${entry.version} lists no changes at all',
        );
      }

      final versions = changelog.entries.map((e) => e.version).toList();
      expect(
        versions,
        [...versions]..sort((a, b) => _compare(b, a)),
        reason: 'the newest release has to be the one at the top',
      );
    });

    test('the top changelog entry matches the version being built', () {
      // The check that stops a release shipping with last version's notes.
      final pubspec =
          loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
      final version = (pubspec['version'] as String).split('+').first;

      final changelog = Changelog.decode(
        File('assets/changelog.json').readAsStringSync(),
      )!;

      expect(
        changelog.latest!.version,
        version,
        reason:
            'pubspec says $version; the changelog leads with '
            '${changelog.latest!.version}',
      );
    });

    test('both legal documents ship and say what they are', () {
      for (final (path, heading) in [
        ('assets/legal/privacy-policy.md', '# Privacy Policy'),
        ('assets/legal/terms-of-service.md', '# Terms of Service'),
      ]) {
        final source = File(path).readAsStringSync();
        expect(source.trim(), startsWith(heading));
        expect(source.length, greaterThan(2000));
        expect(source, contains('Last updated'));
        expect(source, contains('support@dizitart.com'));
      }
    });

    test('the privacy policy names every host the app actually contacts', () {
      // The claim that is easiest to make and easiest to get wrong. If code
      // ever starts talking to something else, this fails.
      final policy = File('assets/legal/privacy-policy.md').readAsStringSync();

      final contacted = <String>{};
      for (final file
          in Directory('lib')
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))) {
        final source = file.readAsStringSync();
        for (final match in RegExp(
          r"Uri\.https\(\s*'([^']+)'",
        ).allMatches(source)) {
          contacted.add(match.group(1)!);
        }
      }

      expect(contacted, isNotEmpty, reason: 'the scan found nothing to check');
      for (final host in contacted) {
        expect(
          policy.contains(host) || host == 'github.com',
          isTrue,
          reason:
              'the app contacts $host but the Privacy Policy does not '
              'mention it',
        );
      }
      expect(contacted, contains('api.github.com'));
    });

    test('the changelog refuses a file that is not one', () {
      expect(Changelog.decode('{"versions": []}'), isNull);
      expect(Changelog.decode('nonsense'), isNull);
      expect(Changelog.decode(null), isNull);
    });

    test('"since" reports only what is newer', () {
      const changelog = Changelog([
        ChangelogEntry(version: '0.3.0', date: 'c', added: ['c']),
        ChangelogEntry(version: '0.2.0', date: 'b', added: ['b']),
        ChangelogEntry(version: '0.1.0', date: 'a', added: ['a']),
      ]);

      expect(changelog.since('0.2.0').map((e) => e.version), ['0.3.0']);
      expect(changelog.since('0.1.0').map((e) => e.version), [
        '0.3.0',
        '0.2.0',
      ]);
      expect(changelog.since('0.3.0'), isEmpty);
      expect(
        changelog.since('9.9.9').map((e) => e.version),
        ['0.3.0', '0.2.0', '0.1.0'],
        reason: 'an unknown version means we cannot tell, so show everything',
      );
      expect(changelog.since(null), hasLength(3));
    });
  });

  group('the consent gate', () {
    testWidgets('offers both documents and records acceptance', (tester) async {
      // Reading an asset here leaves it cached as a buffer the next test
      // cannot read again, which fails whichever legal test runs after this
      // one. Dropping the cache on the way out keeps them independent.
      addTearDown(rootBundle.clear);

      final container = await pumpAbout(tester, const ConsentScreen());
      final l = L.of(tester.element(find.byType(ConsentScreen)));

      expect(find.text(l.consentTitle), findsOneWidget);
      expect(container.read(settingsProvider).hasAcceptedLegal, isFalse);

      // Each document opens from the gate itself, so nobody has to accept
      // terms they were never shown.
      for (final title in [l.legalTermsTitle, l.legalPrivacyTitle]) {
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        expect(find.byType(DocumentPage), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text(l.consentAccept));
      await tester.pump();

      expect(container.read(settingsProvider).hasAcceptedLegal, isTrue);
    });
  });

  group('the tour', () {
    testWidgets('shows on a first run and sets the flag when finished', (
      tester,
    ) async {
      final container = await pumpAbout(tester, const TourScreen());
      final l = L.of(tester.element(find.byType(TourScreen)));

      expect(find.text(l.tourWelcomeTitle), findsOneWidget);
      expect(container.read(settingsProvider).hasSeenTour, isFalse);

      await tester.tap(find.text(l.tourWelcomeSkip));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(container.read(settingsProvider).hasSeenTour, isTrue);
    });

    testWidgets('every page is reachable and skip is always offered', (
      tester,
    ) async {
      await pumpAbout(tester, const TourScreen());
      final l = L.of(tester.element(find.byType(TourScreen)));

      final titles = [
        l.tourWelcomeTitle,
        l.tourScanTitle,
        l.tourReviewTitle,
        l.tourSafetyTitle,
        l.tourCachesTitle,
        l.tourScheduleTitle,
        l.tourFinishTitle,
      ];

      for (var i = 0; i < titles.length; i++) {
        expect(find.text(titles[i]), findsOneWidget, reason: 'page $i');
        expect(
          find.byType(TextButton),
          findsWidgets,
          reason: 'skip must be offered on page $i, not only the first',
        );
        if (i == titles.length - 1) break;
        await tester.tap(find.byType(FilledButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
      }

      expect(find.text(l.tourFinishAction), findsOneWidget);
    });

    testWidgets('the last page finishes rather than paging further', (
      tester,
    ) async {
      final container = await pumpAbout(tester, const TourScreen());
      final l = L.of(tester.element(find.byType(TourScreen)));

      for (var i = 0; i < 6; i++) {
        await tester.tap(find.byType(FilledButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
      }
      expect(find.text(l.tourFinishTitle), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(container.read(settingsProvider).hasSeenTour, isTrue);
    });
  });

  group('the changelog screen', () {
    testWidgets('lists every release with its changes', (tester) async {
      await pumpAbout(tester, const ChangelogPage());
      // The asset load is a future; give it a few frames to resolve.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.textContaining('0.2.0'), findsWidgets);

      // The list is lazy, so the older release is not in the tree until it is
      // scrolled to. Scrolling to it is also the check that it is reachable.
      await tester.scrollUntilVisible(
        find.textContaining('0.1.0'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('0.1.0'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('the legal screens', () {
    testWidgets('the privacy policy renders its headings and body', (
      tester,
    ) async {
      await pumpAbout(
        tester,
        const DocumentPage(title: 'Privacy Policy', asset: privacyPolicyAsset),
      );

      expect(find.byType(MarkdownDocument), findsOneWidget);
      expect(find.textContaining('Privacy Policy'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the terms render too', (tester) async {
      await pumpAbout(
        tester,
        const DocumentPage(title: 'Terms of Service', asset: termsAsset),
      );

      expect(find.byType(MarkdownDocument), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a missing document says so instead of hanging', (
      tester,
    ) async {
      await pumpAbout(
        tester,
        const DocumentPage(title: 'Nope', asset: 'assets/legal/nothing.md'),
      );

      expect(find.byType(MarkdownDocument), findsNothing);
      expect(
        find.text(L.of(tester.element(find.byType(Scaffold))).legalUnavailable),
        findsOneWidget,
      );
    });
  });

  group("the what's-new banner", () {
    testWidgets('stays hidden on a first run', (tester) async {
      // Nothing to say "what changed" about, and the tour has just introduced
      // the app.
      await pumpAbout(tester, const WhatsNewBanner(), version: '0.2.0');
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('stays hidden when the version has not moved', (tester) async {
      await pumpAbout(
        tester,
        const WhatsNewBanner(),
        settings: const Settings(lastSeenVersion: '0.2.0'),
        version: '0.2.0',
      );
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('appears after an update, and only until dismissed', (
      tester,
    ) async {
      final container = await pumpAbout(
        tester,
        const WhatsNewBanner(),
        settings: const Settings(lastSeenVersion: '0.1.0'),
        version: '0.2.0',
      );
      final l = L.of(tester.element(find.byType(WhatsNewBanner)));

      expect(find.text(l.changelogWhatsNewBanner('0.2.0')), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(container.read(settingsProvider).lastSeenVersion, '0.2.0');
      expect(find.text(l.changelogWhatsNewBanner('0.2.0')), findsNothing);
    });
  });
}

/// Compares dotted version strings numerically.
int _compare(String a, String b) {
  final left = a.split('.').map(int.tryParse).toList();
  final right = b.split('.').map(int.tryParse).toList();
  for (var i = 0; i < left.length && i < right.length; i++) {
    final order = (left[i] ?? 0).compareTo(right[i] ?? 0);
    if (order != 0) return order;
  }
  return left.length.compareTo(right.length);
}
