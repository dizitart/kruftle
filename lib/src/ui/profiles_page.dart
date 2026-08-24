// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../core/profiles/profile.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'widgets/common.dart';

/// Teaches Kruftle project types it does not know about.
///
/// A profile becomes an ordinary `StackDefinition`, so it is detected,
/// planned and cleaned by exactly the same code as a built-in stack — and is
/// held to exactly the same safety rules. This screen's job is to say that
/// plainly and to refuse anything the rails would refuse later.
class ProfilesPage extends ConsumerWidget {
  const ProfilesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final profiles = ref.watch(profilesProvider).profiles;
    final controller = ref.read(profilesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.profilesTitle),
        titleTextStyle: context.text.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton.icon(
            onPressed: () => _import(context, ref),
            icon: const Icon(Icons.file_download_outlined, size: 16),
            label: Text(l.profilesImport),
          ),
          TextButton.icon(
            onPressed: profiles.isEmpty ? null : () => _export(context, ref),
            icon: const Icon(Icons.file_upload_outlined, size: 16),
            label: Text(l.profilesExport),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: Text(l.profilesNew),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 90),
        children: [
          NoticeBanner(
            message: l.profilesIntro,
            icon: Icons.extension_outlined,
          ),
          const SizedBox(height: 18),
          if (profiles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 70),
              child: Center(
                child: Text(
                  l.profilesNone,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          for (final profile in profiles)
            _ProfileCard(
              profile: profile,
              onEdit: () => _edit(context, ref, profile),
              onToggle: (enabled) =>
                  controller.put(profile.copyWith(enabled: enabled)),
              onDelete: () => _confirmDelete(context, ref, profile),
            ),
        ],
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    CleanupProfile? existing,
  ) async {
    final saved = await showDialog<CleanupProfile>(
      context: context,
      builder: (context) => _ProfileEditor(
        existing: existing,
        otherNames: ref
            .read(profilesProvider)
            .profiles
            .where((p) => p.name != existing?.name)
            .map((p) => p.name)
            .toSet(),
      ),
    );
    if (saved == null) return;

    // A rename is a delete plus an add: the name is the identity.
    if (existing != null && existing.name != saved.name) {
      await ref.read(profilesProvider.notifier).remove(existing.name);
    }
    await ref.read(profilesProvider.notifier).put(saved);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CleanupProfile profile,
  ) async {
    final l = L.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.profilesDeleteConfirm(profile.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(profilesProvider.notifier).remove(profile.name);
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Kruftle profiles', extensions: ['json']),
      ],
    );
    if (file == null) return;

    final parsed = ProfileSet.decode(await file.readAsString());
    if (!context.mounted) return;

    final l = L.of(context);
    if (parsed == null) {
      _toast(context, l.profilesImportFailed);
      return;
    }

    await ref.read(profilesProvider.notifier).import(parsed);
    if (!context.mounted) return;
    _toast(context, l.profilesImported(parsed.profiles.length));
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final location = await getSaveLocation(
      suggestedName: 'kruftle-profiles.json',
    );
    if (location == null) return;

    File(location.path).writeAsStringSync(ref.read(profilesProvider).encode());
  }

  void _toast(BuildContext context, String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          width: 420,
        ),
      );
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final CleanupProfile profile;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final dirs = [
      ...profile.artifactDirs,
      ...profile.dependencyDirs,
      ...profile.cacheDirs,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        for (final marker in profile.markers.take(3)) ...[
                          Tag(marker),
                          const SizedBox(width: 4),
                        ],
                      ],
                    ),
                    if (profile.command != null &&
                        profile.command!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(profile.command!, style: context.mono(size: 11.5)),
                    ],
                    if (dirs.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        dirs.join(' · '),
                        style: context.mono(
                          size: 11,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (profile.excludeGlobs.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        '${l.profilesExcludes}: '
                        '${profile.excludeGlobs.join(' · ')}',
                        style: context.mono(
                          size: 11,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(value: profile.enabled, onChanged: onToggle),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 17),
                tooltip: l.actionEdit,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 17),
                tooltip: l.actionDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The editor. Validates as the user types, using the same `validate()` the
/// engine uses, so the dialog can never save something a scan would then
/// refuse.
class _ProfileEditor extends StatefulWidget {
  const _ProfileEditor({required this.existing, required this.otherNames});

  final CleanupProfile? existing;
  final Set<String> otherNames;

  @override
  State<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<_ProfileEditor> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _markers = TextEditingController(
    text: widget.existing?.markers.join('\n') ?? '',
  );
  late final _command = TextEditingController(
    text: widget.existing?.command ?? '',
  );
  late final _artifacts = TextEditingController(
    text: widget.existing?.artifactDirs.join('\n') ?? '',
  );
  late final _dependencies = TextEditingController(
    text: widget.existing?.dependencyDirs.join('\n') ?? '',
  );
  late final _caches = TextEditingController(
    text: widget.existing?.cacheDirs.join('\n') ?? '',
  );
  late final _excludes = TextEditingController(
    text: widget.existing?.excludeGlobs.join('\n') ?? '',
  );

  @override
  void dispose() {
    for (final controller in [
      _name,
      _markers,
      _command,
      _artifacts,
      _dependencies,
      _caches,
      _excludes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  static List<String> _lines(TextEditingController controller) => controller
      .text
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  CleanupProfile get _draft => CleanupProfile(
    name: _name.text.trim(),
    markers: _lines(_markers),
    command: _command.text.trim().isEmpty ? null : _command.text.trim(),
    artifactDirs: _lines(_artifacts),
    dependencyDirs: _lines(_dependencies),
    cacheDirs: _lines(_caches),
    excludeGlobs: _lines(_excludes),
    enabled: widget.existing?.enabled ?? true,
  );

  String? _message(L l, ProfileError error) => switch (error.problem) {
    ProfileProblem.noName => l.profilesErrorName,
    ProfileProblem.noMarkers => l.profilesErrorMarkers,
    ProfileProblem.nothingToDo => l.profilesErrorNothingToDo,
    ProfileProblem.absolutePath => l.profilesErrorAbsolutePath(
      error.detail ?? '',
    ),
    ProfileProblem.escapingPath => l.profilesErrorEscapes(error.detail ?? ''),
    ProfileProblem.duplicateName => l.profilesErrorDuplicate(
      error.detail ?? '',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final errors = _draft.validate(existingNames: widget.otherNames);

    return AlertDialog(
      title: Text(widget.existing == null ? l.profilesNew : l.actionEdit),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Field(
                controller: _name,
                label: l.profilesName,
                hint: l.profilesNameHint,
                onChanged: () => setState(() {}),
              ),
              _Field(
                controller: _markers,
                label: l.profilesMarkers,
                hint: l.profilesMarkersHint,
                help: l.profilesMarkersHelp,
                lines: 3,
                mono: true,
                onChanged: () => setState(() {}),
              ),
              _Field(
                controller: _command,
                label: l.profilesCommand,
                hint: l.profilesCommandHint,
                help: l.profilesCommandHelp,
                mono: true,
                onChanged: () => setState(() {}),
              ),
              _Field(
                controller: _artifacts,
                label: l.profilesArtifacts,
                hint: l.profilesArtifactsHint,
                help: l.profilesArtifactsHelp,
                lines: 3,
                mono: true,
                onChanged: () => setState(() {}),
              ),
              _Field(
                controller: _dependencies,
                label: l.reviewRiskDependencies,
                lines: 2,
                mono: true,
                onChanged: () => setState(() {}),
              ),
              _Field(
                controller: _caches,
                label: l.reviewRiskCache,
                lines: 2,
                mono: true,
                onChanged: () => setState(() {}),
              ),
              _Field(
                controller: _excludes,
                label: l.profilesExcludes,
                hint: l.profilesExcludesHint,
                help: l.profilesExcludesHelp,
                lines: 2,
                mono: true,
                onChanged: () => setState(() {}),
              ),

              if (errors.isNotEmpty) ...[
                const SizedBox(height: 6),
                for (final error in errors)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: NoticeBanner(
                      message: _message(l, error) ?? '',
                      icon: Icons.error_outline_rounded,
                      color: context.danger,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          // The dialog cannot save something the engine would reject: it is
          // the same `validate()` on both sides.
          onPressed: errors.isEmpty
              ? () => Navigator.of(context).pop(_draft)
              : null,
          child: Text(l.actionSave),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.hint,
    this.help,
    this.lines = 1,
    this.mono = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? help;
  final int lines;
  final bool mono;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5)),
        if (help != null) ...[
          const SizedBox(height: 3),
          Text(
            help!,
            style: TextStyle(
              fontSize: 11,
              height: 1.35,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          minLines: lines,
          maxLines: lines,
          style: mono ? context.mono(size: 12) : const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
          ),
        ),
      ],
    ),
  );
}
