// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'global_caches_page.dart';
import 'settings_page.dart';
import 'state/app_state.dart';
import 'state/update_controller.dart';
import 'theme.dart';
import 'widgets/update_banner.dart';
import 'wizard/wizard_shell.dart';

class KruftleApp extends StatelessWidget {
  const KruftleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Kruftle',
    debugShowCheckedModeBanner: false,
    theme: KruftleTheme.light(),
    darkTheme: KruftleTheme.dark(),
    themeMode: ThemeMode.system,
    home: const _Home(),
  );
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
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        const _TitleBar(),
        const Divider(height: 1),
        const UpdateBanner(),
        const Expanded(child: WizardShell()),
      ],
    ),
  );
}

class _TitleBar extends StatelessWidget {
  const _TitleBar();

  @override
  Widget build(BuildContext context) => Container(
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
        Text(
          'reclaim your disk',
          style: TextStyle(
            fontSize: 12,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const GlobalCachesPage()),
          ),
          icon: const Icon(Icons.public_rounded, size: 18),
          tooltip: 'Global SDK caches',
        ),
        IconButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage())),
          icon: const Icon(Icons.tune_rounded, size: 18),
          tooltip: 'Settings',
        ),
      ],
    ),
  );
}
