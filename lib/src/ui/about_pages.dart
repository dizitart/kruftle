// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../core/changelog/changelog.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/document.dart';

/// The changelog and the two legal documents ship as assets, so they are the
/// same text in the app as in the repository — one source, not two that drift.
const changelogAsset = 'assets/changelog.json';
const privacyPolicyAsset = 'assets/legal/privacy-policy.md';
const termsAsset = 'assets/legal/terms-of-service.md';

final changelogProvider = FutureProvider<Changelog?>(
  (_) async => Changelog.decode(await rootBundle.loadString(changelogAsset)),
);

/// One legal document, rendered from its Markdown source.
class DocumentPage extends StatelessWidget {
  const DocumentPage({super.key, required this.title, required this.asset});

  final String title;
  final String asset;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      titleTextStyle: context.text.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: context.colors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    body: FutureBuilder<String>(
      future: rootBundle.loadString(asset),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _Unavailable(L.of(context).legalUnavailable);
        }
        final source = snapshot.data;
        if (source == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return MarkdownDocument(source);
      },
    ),
  );
}

class ChangelogPage extends ConsumerWidget {
  const ChangelogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.changelogTitle),
        titleTextStyle: context.text.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ref
          .watch(changelogProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _Unavailable(l.changelogUnavailable),
            data: (changelog) => changelog == null || changelog.entries.isEmpty
                ? _Unavailable(l.changelogUnavailable)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(32, 20, 32, 60),
                    children: [
                      // Same readable measure as the legal documents: a
                      // release note set across a wide window is a wall.
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final entry in changelog.entries)
                                _Release(entry: entry),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
    );
  }
}

class _Release extends StatelessWidget {
  const _Release({required this.entry});

  final ChangelogEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                l.changelogVersionHeading(entry.version),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                entry.date,
                style: context.mono(
                  size: 12,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final (label, lines, colour) in [
            (l.changelogAdded, entry.added, context.freed),
            (l.changelogChanged, entry.changed, context.colors.primary),
            (l.changelogFixed, entry.fixed, context.warn),
          ])
            if (lines.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 6),
                child: Tag(label, color: colour),
              ),
              for (final line in lines) _Item(line),
            ],
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7, right: 11),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Unavailable extends StatelessWidget {
  const _Unavailable(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: NoticeBanner(
        message: message,
        icon: Icons.error_outline_rounded,
        color: context.danger,
      ),
    ),
  );
}

/// Shown once after an update, so the user finds out what changed without
/// having to go looking.
class WhatsNewBanner extends ConsumerWidget {
  const WhatsNewBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final version = ref.watch(appVersionProvider);
    final lastSeen = ref.watch(settingsProvider).lastSeenVersion;

    // Nothing to say on a first run: there is no "since" to report, and the
    // tour is doing the introducing.
    if (version == null || lastSeen == null || lastSeen == version) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      color: context.freed.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, size: 17, color: context.freed),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              l.changelogWhatsNewBanner(version),
              style: TextStyle(fontSize: 12.5, color: context.freed),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).markVersionSeen(version);
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ChangelogPage()),
              );
            },
            child: Text(l.changelogWhatsNewAction),
          ),
          IconButton(
            onPressed: () =>
                ref.read(settingsProvider.notifier).markVersionSeen(version),
            icon: const Icon(Icons.close_rounded, size: 15),
            tooltip: l.actionClose,
          ),
        ],
      ),
    );
  }
}
