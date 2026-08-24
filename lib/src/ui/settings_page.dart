// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../core/log/activity_log.dart';
import '../core/models/stack.dart';
import '../core/scan/sizer.dart';
import '../core/settings/settings.dart';
import 'about_pages.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'tour_page.dart';
import 'widgets/common.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final log = ref.read(activityLogProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settingsTitle),
        titleTextStyle: context.text.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
        children: [
          _Section(
            title: l.settingsSectionAppearance,
            children: [
              _DropdownRow<AppThemeMode>(
                label: l.settingsTheme,
                value: settings.themeMode,
                items: {
                  AppThemeMode.system: l.settingsThemeSystem,
                  AppThemeMode.light: l.settingsThemeLight,
                  AppThemeMode.dark: l.settingsThemeDark,
                },
                onChanged: (v) =>
                    controller.update((s) => s.copyWith(themeMode: v)),
              ),
              _DropdownRow<String>(
                label: l.settingsLanguage,
                // The empty string stands in for null, because a
                // DropdownButton cannot hold a null value alongside real ones
                // without special-casing every comparison.
                value: settings.localeCode ?? '',
                items: {
                  '': l.settingsLanguageSystem,
                  for (final code in kSupportedLocaleCodes)
                    code: languageName(code),
                },
                onChanged: (v) => controller.update(
                  (s) => v.isEmpty
                      ? s.copyWith(clearLocaleCode: true)
                      : s.copyWith(localeCode: v),
                ),
              ),
              _SwitchRow(
                label: l.settingsReduceMotion,
                help: l.settingsReduceMotionHelp,
                value: settings.reduceMotion,
                onChanged: (v) =>
                    controller.update((s) => s.copyWith(reduceMotion: v)),
              ),
            ],
          ),

          _Section(
            title: l.settingsSectionScanning,
            children: [
              _SliderRow(
                label: l.settingsMaxDepth,
                help: l.settingsMaxDepthHelp,
                value: settings.maxScanDepth.toDouble(),
                min: 2,
                max: 32,
                format: (v) => l.settingsLevels(v.round()),
                onChanged: (v) => controller.update(
                  (s) => s.copyWith(maxScanDepth: v.round()),
                ),
              ),
              _SwitchRow(
                label: l.settingsHiddenDirectories,
                help: l.settingsHiddenDirectoriesHelp,
                value: settings.scanHiddenDirectories,
                onChanged: (v) => controller.update(
                  (s) => s.copyWith(scanHiddenDirectories: v),
                ),
              ),
            ],
          ),

          _Section(
            title: l.settingsSectionSizes,
            children: [
              _DropdownRow<SizeMode>(
                label: l.settingsSizeMode,
                value: settings.sizeMode,
                items: {
                  SizeMode.onDisk: l.settingsSizeModeOnDisk,
                  SizeMode.apparent: l.settingsSizeModeApparent,
                },
                onChanged: (v) =>
                    controller.update((s) => s.copyWith(sizeMode: v)),
              ),
              _HelpText(l.settingsSizeModeHelp),
            ],
          ),

          _Section(
            title: l.settingsSectionCleaning,
            children: [
              _SliderRow(
                label: l.settingsConcurrency,
                help: l.settingsConcurrencyHelp(Platform.numberOfProcessors),
                value: settings.cleanConcurrency.toDouble(),
                min: 1,
                max: 16,
                format: (v) => '${v.round()}',
                onChanged: (v) => controller.update(
                  (s) => s.copyWith(cleanConcurrency: v.round()),
                ),
              ),
              _SliderRow(
                label: l.settingsTimeout,
                help: l.settingsTimeoutHelp,
                value: settings.stepTimeoutSeconds.toDouble(),
                min: 30,
                max: 1800,
                divisions: 59,
                format: (v) => v < 120
                    ? l.settingsSeconds(v.round())
                    : l.settingsMinutes((v / 60).round()),
                onChanged: (v) => controller.update(
                  (s) => s.copyWith(stepTimeoutSeconds: v.round()),
                ),
              ),
              _SwitchRow(
                label: l.settingsConfirmBeforeDelete,
                help: l.settingsConfirmBeforeDeleteHelp,
                value: settings.confirmBeforeDelete,
                onChanged: (v) => controller.update(
                  (s) => s.copyWith(confirmBeforeDelete: v),
                ),
              ),
            ],
          ),

          _Section(
            title: l.settingsSectionPreselect,
            subtitle: l.settingsPreselectHelp,
            children: [
              for (final (risk, label) in [
                (CleanRisk.buildOutput, l.reviewRiskBuildOutput),
                (CleanRisk.dependencies, l.reviewRiskDependencies),
                (CleanRisk.cache, l.reviewRiskCache),
              ])
                _SwitchRow(
                  label: label,
                  value: settings.rememberedRisks.contains(risk),
                  onChanged: (v) => controller.update((s) {
                    final risks = Set<CleanRisk>.of(s.rememberedRisks);
                    v ? risks.add(risk) : risks.remove(risk);
                    return s.copyWith(rememberedRisks: risks);
                  }),
                ),
            ],
          ),

          _Section(
            title: l.settingsSectionLogging,
            children: [
              _DropdownRow<LogLevel>(
                label: l.settingsLogDetail,
                value: settings.logLevel,
                items: {
                  for (final level in LogLevel.values)
                    level: logLevelName(l, level),
                },
                onChanged: (v) {
                  controller.update((s) => s.copyWith(logLevel: v));
                },
              ),
              _SliderRow(
                label: l.settingsLogRetention,
                help: l.settingsLogRetentionHelp,
                value: settings.logRetentionFiles.toDouble(),
                min: 0,
                max: 20,
                format: (v) => v == 0 ? l.settingsNone : '${v.round()}',
                onChanged: (v) => controller.update(
                  (s) => s.copyWith(logRetentionFiles: v.round()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(child: PathText(log.file.path, size: 11)),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () => _revealLog(log),
                      icon: const Icon(Icons.folder_open_rounded, size: 15),
                      label: Text(l.actionShow),
                    ),
                    TextButton(
                      onPressed: log.clear,
                      child: Text(l.actionClear),
                    ),
                  ],
                ),
              ),
            ],
          ),

          _Section(
            title: l.settingsSectionUpdates,
            children: [
              _SwitchRow(
                label: l.settingsCheckUpdates,
                help: l.settingsCheckUpdatesHelp,
                value: settings.checkForUpdates,
                onChanged: (v) =>
                    controller.update((s) => s.copyWith(checkForUpdates: v)),
              ),
            ],
          ),

          _Section(
            title: l.settingsSectionAbout,
            children: [
              _LinkRow(
                label: l.settingsShowTour,
                icon: Icons.slideshow_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const TourScreen()),
                ),
              ),
              _LinkRow(
                label: l.settingsChangelog,
                icon: Icons.auto_awesome_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ChangelogPage(),
                  ),
                ),
              ),
              _LinkRow(
                label: l.settingsPrivacyPolicy,
                icon: Icons.privacy_tip_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DocumentPage(
                      title: l.legalPrivacyTitle,
                      asset: privacyPolicyAsset,
                    ),
                  ),
                ),
              ),
              _LinkRow(
                label: l.settingsTermsOfService,
                icon: Icons.gavel_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DocumentPage(
                      title: l.legalTermsTitle,
                      asset: termsAsset,
                    ),
                  ),
                ),
              ),
              _LinkRow(
                label: l.settingsSourceCode,
                icon: Icons.code_rounded,
                onTap: () => unawaited(
                  launchUrl(
                    Uri.https('github.com', '/dizitart/kruftle'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ),
            ],
          ),

          // Version, licence and provenance sit below the About card rather
          // than inside it. They are not a setting and not something to open —
          // they are the page's colophon, and putting them in the card made
          // the last row look like a dead link.
          _Colophon(version: ref.watch(appVersionProvider)),
        ],
      ),
    );
  }

  void _revealLog(ActivityLog log) {
    final directory = log.file.parent.path;
    final (command, args) = Platform.isMacOS
        ? ('open', [directory])
        : Platform.isWindows
        ? ('explorer', [directory])
        : ('xdg-open', [directory]);
    Process.run(command, args);
  }
}

/// The endonym for each supported language — what its own speakers call it.
///
/// A language picker that lists "Japanese" to someone who cannot read English
/// is not a language picker. These are deliberately not translated.
String languageName(String code) => switch (code) {
  'en' => 'English',
  'ar' => 'العربية',
  'de' => 'Deutsch',
  'es' => 'Español',
  'fr' => 'Français',
  'hi' => 'हिन्दी',
  'ja' => '日本語',
  'pt' => 'Português',
  'ru' => 'Русский',
  'zh' => '中文',
  _ => code,
};

/// The label for a log level, so the picker reads as prose rather than as the
/// enum constant it happens to be stored as.
String logLevelName(L l, LogLevel level) => switch (level) {
  LogLevel.debug => l.settingsLogDebug,
  LogLevel.info => l.settingsLogInfo,
  LogLevel.warning => l.settingsLogWarning,
  LogLevel.error => l.settingsLogError,
};

/// Version, licence and where it came from. Below the last card, centred.
class _Colophon extends StatelessWidget {
  const _Colophon({required this.version});

  final String? version;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final quiet = TextStyle(
      fontSize: 11.5,
      height: 1.5,
      color: context.colors.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Column(
        children: [
          if (version case final version?)
            Text(
              l.settingsVersion(version),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5),
            ),
          const SizedBox(height: 4),
          Text(l.settingsLicence, textAlign: TextAlign.center, style: quiet),
          const SizedBox(height: 10),
          Text(
            l.settingsMadeWith,
            textAlign: TextAlign.center,
            style: quiet.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// A settings row that opens something.
class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.colors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: context.colors.onSurfaceVariant,
          ),
        ],
      ),
    ),
  );
}

/// Explanatory paragraph under a control that is too long for a `help:` line.
class _HelpText extends StatelessWidget {
  const _HelpText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11.5,
        height: 1.4,
        color: context.colors.onSurfaceVariant,
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children, this.subtitle});

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PanelLabel(title),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(children: children),
          ),
        ),
      ],
    ),
  );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.help,
  });

  final String label;
  final String? help;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              if (help != null) ...[
                const SizedBox(height: 3),
                Text(
                  help!,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 20),
        Switch(value: value, onChanged: onChanged),
      ],
    ),
  );
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.format,
    required this.onChanged,
    this.help,
    this.divisions,
  });

  final String label;
  final String? help;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
            Text(
              format(value),
              style: context.mono(size: 12, color: context.colors.primary),
            ),
          ],
        ),
        if (help != null) ...[
          const SizedBox(height: 3),
          Text(
            help!,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions ?? (max - min).round(),
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

class _DropdownRow<T> extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        const SizedBox(width: 16),
        KruftleDropdown<T>(value: value, items: items, onChanged: onChanged),
      ],
    ),
  );
}
