// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'src/background_run.dart';
import 'src/core/schedule/background_service.dart';
import 'src/core/single_instance.dart';
import 'src/ui/already_running_page.dart';
import 'src/ui/app.dart';
import 'src/ui/state/app_state.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Started by the operating system's scheduler rather than by a person: do
  // the cleanup and quit, without a window manager, a locale, a version, or a
  // widget tree. Both signals are checked because only one of them survives
  // the trip on any given platform — see `BackgroundService`.
  if (BackgroundService.isBackgroundRun ||
      args.contains(BackgroundService.flag)) {
    await runBackgroundCleanup();
    exit(0);
  }

  await windowManager.ensureInitialized();

  // `DateFormat` refuses any locale but the system's until the symbols are
  // loaded, and the language picker can choose any of the ten.
  await initializeDateFormatting();

  // One Kruftle at a time. Two windows cleaning the same tree would have two
  // build tools writing one directory, which is how a half-deleted `target/`
  // happens. Held for the life of the process; the operating system drops it
  // when we exit, however we exit.
  final supportDirectory = await getApplicationSupportDirectory();
  if (InstanceLock.tryAcquire(supportDirectory.path) == null) {
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        // Small, but not so small that a long translation of the notice runs
        // out of room — `already_running_test.dart` holds the minimum to it.
        size: Size(560, 340),
        minimumSize: Size(480, 300),
        center: true,
        title: 'Kruftle',
        titleBarStyle: TitleBarStyle.normal,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
    runApp(const AlreadyRunningApp());
    return;
  }

  // A results table is unreadable below this width, so the window refuses to
  // go there rather than reflowing into something cramped.
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: Size(1160, 780),
      minimumSize: Size(940, 620),
      center: true,
      title: 'Kruftle',
      titleBarStyle: TitleBarStyle.normal,
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );

  // Only available asynchronously, and every provider wants it synchronously,
  // so it is resolved once here and injected.
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        appSupportDirectoryProvider.overrideWithValue(supportDirectory.path),
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const KruftleApp(),
    ),
  );
}
