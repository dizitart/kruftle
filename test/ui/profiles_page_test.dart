// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/l10n/app_localizations.dart';
import 'package:kruftle/src/core/profiles/profile.dart';
import 'package:kruftle/src/ui/profiles_page.dart';
import 'package:kruftle/src/ui/state/app_state.dart';
import 'package:kruftle/src/ui/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> pumpProfiles(
  WidgetTester tester, {
  ProfileSet seed = ProfileSet.empty,
}) async {
  SharedPreferences.setMockInitialValues({
    if (seed.profiles.isNotEmpty) 'kruftle.profiles.v1': seed.encode(),
  });
  final preferences = await SharedPreferences.getInstance();

  tester.view.physicalSize = const Size(1100, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      appSupportDirectoryProvider.overrideWithValue('/tmp/kruftle-test'),
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
        home: const ProfilesPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

const _unreal = CleanupProfile(
  name: 'Unreal Engine',
  markers: ['*.uproject'],
  command: 'make clean',
  artifactDirs: ['Binaries'],
);

void main() {
  testWidgets('an empty list says so rather than showing nothing', (
    tester,
  ) async {
    await pumpProfiles(tester);
    final l = L.of(tester.element(find.byType(ProfilesPage)));

    expect(find.text(l.profilesNone), findsOneWidget);
    expect(find.text(l.profilesIntro), findsOneWidget);
  });

  testWidgets('a saved profile is listed with what it will do', (tester) async {
    await pumpProfiles(tester, seed: const ProfileSet([_unreal]));

    expect(find.text('Unreal Engine'), findsOneWidget);
    expect(find.text('*.uproject'), findsOneWidget);
    expect(find.text('make clean'), findsOneWidget);
    expect(find.text('Binaries'), findsOneWidget);
  });

  testWidgets('disabling a profile persists and takes it out of the registry', (
    tester,
  ) async {
    final container = await pumpProfiles(
      tester,
      seed: const ProfileSet([_unreal]),
    );

    expect(container.read(registryProvider).stacks.length, greaterThan(42));

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(container.read(profilesProvider).profiles.single.enabled, isFalse);
    expect(
      container
          .read(registryProvider)
          .stacks
          .any((s) => s.displayName == 'Unreal Engine'),
      isFalse,
      reason: 'a disabled profile must take no part in the next scan',
    );
  });

  testWidgets('the editor refuses to save an invalid profile', (tester) async {
    await pumpProfiles(tester);
    final l = L.of(tester.element(find.byType(ProfilesPage)));

    await tester.tap(find.text(l.profilesNew));
    await tester.pumpAndSettle();

    // Nothing filled in: the save button is dead, and the reason is on screen.
    final save = find.widgetWithText(FilledButton, l.actionSave);
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    expect(find.text(l.profilesErrorName), findsOneWidget);
    expect(find.text(l.profilesErrorMarkers), findsOneWidget);
  });

  testWidgets('the editor refuses a directory that escapes the project', (
    tester,
  ) async {
    // The important one. The dialog runs the same `validate()` the engine
    // does, so it cannot save something a scan would then refuse — and the
    // user is told which value is the problem.
    await pumpProfiles(tester);
    final l = L.of(tester.element(find.byType(ProfilesPage)));

    await tester.tap(find.text(l.profilesNew));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, l.profilesNameHint),
      'Escaper',
    );
    await tester.enterText(
      find.widgetWithText(TextField, l.profilesMarkersHint),
      'marker.txt',
    );
    await tester.enterText(
      find.widgetWithText(TextField, l.profilesArtifactsHint),
      '../../etc',
    );
    await tester.pumpAndSettle();

    expect(find.text(l.profilesErrorEscapes('../../etc')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, l.actionSave))
          .onPressed,
      isNull,
    );
  });

  testWidgets('a valid profile saves and appears in the list', (tester) async {
    final container = await pumpProfiles(tester);
    final l = L.of(tester.element(find.byType(ProfilesPage)));

    await tester.tap(find.text(l.profilesNew));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, l.profilesNameHint),
      'Godot',
    );
    await tester.enterText(
      find.widgetWithText(TextField, l.profilesMarkersHint),
      'project.godot',
    );
    await tester.enterText(
      find.widgetWithText(TextField, l.profilesArtifactsHint),
      '.import',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, l.actionSave));
    await tester.pumpAndSettle();

    expect(container.read(profilesProvider).profiles.single.name, 'Godot');
    expect(find.text('Godot'), findsOneWidget);
    expect(
      container
          .read(registryProvider)
          .stacks
          .any((s) => s.displayName == 'Godot'),
      isTrue,
      reason: 'a saved profile is in effect on the very next scan',
    );
  });

  testWidgets('a duplicate name is refused', (tester) async {
    await pumpProfiles(tester, seed: const ProfileSet([_unreal]));
    final l = L.of(tester.element(find.byType(ProfilesPage)));

    await tester.tap(find.text(l.profilesNew));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, l.profilesNameHint),
      'Unreal Engine',
    );
    await tester.enterText(
      find.widgetWithText(TextField, l.profilesMarkersHint),
      'x.txt',
    );
    await tester.enterText(
      find.widgetWithText(TextField, l.profilesArtifactsHint),
      'out',
    );
    await tester.pumpAndSettle();

    expect(
      find.text(l.profilesErrorDuplicate('Unreal Engine')),
      findsOneWidget,
    );
  });

  testWidgets('editing a profile does not report it as its own duplicate', (
    tester,
  ) async {
    await pumpProfiles(tester, seed: const ProfileSet([_unreal]));
    final l = L.of(tester.element(find.byType(ProfilesPage)));

    await tester.tap(find.byTooltip(l.actionEdit));
    await tester.pumpAndSettle();

    expect(find.text(l.profilesErrorDuplicate('Unreal Engine')), findsNothing);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, l.actionSave))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('deleting asks first, then removes', (tester) async {
    final container = await pumpProfiles(
      tester,
      seed: const ProfileSet([_unreal]),
    );
    final l = L.of(tester.element(find.byType(ProfilesPage)));

    await tester.tap(find.byTooltip(l.actionDelete));
    await tester.pumpAndSettle();
    expect(find.text(l.profilesDeleteConfirm('Unreal Engine')), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, l.actionCancel));
    await tester.pumpAndSettle();
    expect(container.read(profilesProvider).profiles, hasLength(1));

    await tester.tap(find.byTooltip(l.actionDelete));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, l.actionDelete));
    await tester.pumpAndSettle();

    expect(container.read(profilesProvider).profiles, isEmpty);
  });
}
