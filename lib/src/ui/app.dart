// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../core/settings/settings.dart';
import 'about_pages.dart';
import 'consent_page.dart';
import 'global_caches_page.dart';
import 'profiles_page.dart';
import 'schedule_page.dart';
import 'settings_page.dart';
import 'state/app_state.dart';
import 'state/schedule_controller.dart';
import 'state/update_controller.dart';
import 'state/wizard_controller.dart';
import 'theme.dart';
import 'tour_page.dart';
import 'widgets/update_banner.dart';
import 'wizard/wizard_shell.dart';

class KruftleApp extends ConsumerWidget {
  const KruftleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Kruftle',
      debugShowCheckedModeBanner: false,
      theme: KruftleTheme.light(),
      darkTheme: KruftleTheme.dark(),
      themeMode: switch (settings.themeMode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      // Null means "follow the operating system", which is what Flutter does
      // when `locale` is unset.
      locale: settings.localeCode == null ? null : Locale(settings.localeCode!),
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      home: const _Root(),
    );
  }
}

/// The legal documents on the very first run, then the tour, then the app.
///
/// A gate rather than a route pushed after the fact: pushing would mean the
/// wizard building, checking for updates and starting a schedule timer behind
/// a screen the user has not got past yet.
class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    if (!settings.hasAcceptedLegal) return const ConsentScreen();
    return settings.hasSeenTour ? const _Home() : const TourScreen();
  }
}

class _Home extends ConsumerStatefulWidget {
  const _Home();

  @override
  ConsumerState<_Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<_Home> {
  @override
  void initState() {
    super.initState();
    // Deferred to the first frame so a slow or unreachable network never
    // delays the window appearing.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(settingsProvider).checkForUpdates) {
        ref.read(updateProvider.notifier).check();
      }
      // Realises the controller, which is what raises a reminder that came due
      // while Kruftle was closed.
      ref.read(scheduleProvider);

      // A fresh install has no version recorded, and there is nothing to say
      // "what's new" about — the tour has just done the introducing. Record it
      // silently so the banner only ever appears after a real update.
      final version = ref.read(appVersionProvider);
      if (version != null &&
          ref.read(settingsProvider).lastSeenVersion == null) {
        ref.read(settingsProvider.notifier).markVersionSeen(version);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        const _TitleBar(),
        const Divider(height: 1),
        const UpdateBanner(),
        const WhatsNewBanner(),
        // The reminder. It sits above the wizard rather than inside a step,
        // because it is true whichever step the user happens to be on.
        ScheduleDueBanner(
          onScan: (root) => ref.read(wizardProvider.notifier).startScan(root),
        ),
        const Expanded(child: WizardShell()),
      ],
    ),
  );
}

class _TitleBar extends StatelessWidget {
  const _TitleBar();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      color: context.colors.surfaceContainerLowest,
      child: Row(
        children: [
          Image.asset(
            'assets/icon/kruftle-512.png',
            width: 20,
            height: 20,
            filterQuality: FilterQuality.medium,
          ),
          const SizedBox(width: 10),
          const Text(
            'Kruftle',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 10),
          // Expanded rather than Flexible with a Spacer after it: both take a
          // flex of 1, so the pair split the free space between them and the
          // buttons ended up in the middle of the bar. One flexible child, and
          // the buttons sit against the right edge where they belong.
          Expanded(
            child: Text(
              l.appTagline,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SchedulePage()),
            ),
            icon: const Icon(Icons.schedule_rounded, size: 18),
            tooltip: l.titleBarSchedule,
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfilesPage()),
            ),
            icon: const Icon(Icons.extension_outlined, size: 18),
            tooltip: l.titleBarProfiles,
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const GlobalCachesPage()),
            ),
            icon: const Icon(Icons.public_rounded, size: 18),
            tooltip: l.titleBarGlobalCaches,
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
            ),
            icon: const Icon(Icons.tune_rounded, size: 18),
            tooltip: l.titleBarSettings,
          ),
        ],
      ),
    );
  }
}
