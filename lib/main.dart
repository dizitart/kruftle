// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'src/ui/app.dart';
import 'src/ui/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // `DateFormat` refuses any locale but the system's until the symbols are
  // loaded, and the language picker can choose any of the ten.
  await initializeDateFormatting();

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

  // Both of these are only available asynchronously, and every provider wants
  // them synchronously, so they are resolved once here and injected.
  final supportDirectory = await getApplicationSupportDirectory();
  final preferences = await SharedPreferences.getInstance();
  final packageInfo = await PackageInfo.fromPlatform();

  runApp(
    ProviderScope(
      overrides: [
        appSupportDirectoryProvider.overrideWithValue(supportDirectory.path),
        sharedPreferencesProvider.overrideWithValue(preferences),
        appVersionProvider.overrideWithValue(packageInfo.version),
      ],
      child: const KruftleApp(),
    ),
  );
}
