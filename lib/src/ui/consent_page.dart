// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'about_pages.dart';
import 'state/app_state.dart';
import 'theme.dart';

/// First-run gate: the terms and the privacy policy, before anything else.
///
/// The documents are the ones already shipping as assets and already reachable
/// from Settings — the same text, opened through the same [DocumentPage], so
/// there is nothing here to keep in step with them. Declining quits, because
/// there is no version of this app that runs without the terms.
class ConsentScreen extends ConsumerWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.gavel_rounded,
                    size: 56,
                    color: context.colors.primary,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    l.consentTitle,
                    textAlign: TextAlign.center,
                    style: context.text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l.consentBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.6,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _DocumentLink(
                        label: l.legalTermsTitle,
                        icon: Icons.description_outlined,
                        asset: termsAsset,
                      ),
                      _DocumentLink(
                        label: l.legalPrivacyTitle,
                        icon: Icons.privacy_tip_outlined,
                        asset: privacyPolicyAsset,
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => exit(0),
                        child: Text(l.consentDecline),
                      ),
                      FilledButton(
                        onPressed: () => ref
                            .read(settingsProvider.notifier)
                            .update((s) => s.copyWith(hasAcceptedLegal: true)),
                        child: Text(l.consentAccept),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentLink extends StatelessWidget {
  const _DocumentLink({
    required this.label,
    required this.icon,
    required this.asset,
  });

  final String label;
  final IconData icon;
  final String asset;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DocumentPage(title: label, asset: asset),
      ),
    ),
    icon: Icon(icon, size: 16),
    label: Text(label),
  );
}
