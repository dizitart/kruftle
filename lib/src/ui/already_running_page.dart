// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'theme.dart';

/// The whole app, when the app is already open.
///
/// A window rather than a silent `exit(0)`: someone who double-clicks the icon
/// and sees nothing happen tries again, and then goes looking for a bug.
class AlreadyRunningApp extends StatelessWidget {
  const AlreadyRunningApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Kruftle',
    debugShowCheckedModeBanner: false,
    theme: KruftleTheme.light(),
    darkTheme: KruftleTheme.dark(),
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    home: const _AlreadyRunning(),
  );
}

class _AlreadyRunning extends StatelessWidget {
  const _AlreadyRunning();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.alreadyRunningTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l.alreadyRunningBody,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton(
                onPressed: () => exit(0),
                child: Text(l.actionClose),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
