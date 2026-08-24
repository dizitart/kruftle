// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../core/clean/global_caches.dart';
import '../core/log/activity_log.dart';
import '../core/models/clean.dart';
import '../core/scan/sizer.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'widgets/common.dart';

/// Global SDK caches live in the home directory, are shared by every project
/// on the machine, and cost a re-download for all of them. That is a different
/// decision from cleaning one project's build output, so it gets its own
/// screen, its own survey and its own confirmation.
class GlobalCachesPage extends ConsumerStatefulWidget {
  const GlobalCachesPage({super.key});

  @override
  ConsumerState<GlobalCachesPage> createState() => _GlobalCachesPageState();
}

class _GlobalCachesPageState extends ConsumerState<GlobalCachesPage> {
  final _cleaner = GlobalCacheCleaner();

  List<GlobalCacheTarget> _targets = const [];
  final _selected = <String>{};
  var _loading = true;
  var _running = false;
  List<GlobalCacheOutcome>? _outcomes;

  @override
  void initState() {
    super.initState();
    _survey();
  }

  Future<void> _survey() async {
    setState(() {
      _loading = true;
      _outcomes = null;
    });

    final found = await _cleaner.survey();
    if (!mounted) return;
    setState(() {
      _targets = found;
      _selected.clear();
      _loading = false;
    });

    final measured = await _cleaner.measure(found);
    if (!mounted) return;
    setState(() => _targets = measured);
  }

  int get _selectedBytes => _targets
      .where((t) => _selected.contains(t.cache.displayName))
      .fold(0, (sum, t) => sum + (t.sizeBytes ?? 0));

  Future<void> _clean() async {
    final chosen = _targets
        .where((t) => _selected.contains(t.cache.displayName))
        .toList();
    if (chosen.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _confirmDialog(L.of(context), chosen),
    );
    if (confirmed != true) return;

    setState(() => _running = true);
    final log = ref.read(activityLogProvider);
    log.info('Global cache cleanup started', {
      'caches': chosen.map((t) => t.cache.displayName).toList(),
    });

    final outcomes = await _cleaner.clean(chosen);
    for (final outcome in outcomes) {
      log.log(
        outcome.status == StepStatus.success ? LogLevel.info : LogLevel.error,
        'Global cache ${outcome.status.name}',
        {
          'cache': outcome.cache.displayName,
          'freedBytes': outcome.bytesFreed,
          if (outcome.message != null) 'detail': outcome.message,
        },
      );
    }

    if (!mounted) return;
    setState(() {
      _running = false;
      _outcomes = outcomes;
    });
    await _survey();
  }

  Widget _confirmDialog(L l, List<GlobalCacheTarget> chosen) => AlertDialog(
    icon: Icon(Icons.warning_amber_rounded, size: 30, color: context.warn),
    title: Text(l.cachesConfirmTitle),
    content: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.cachesConfirmBody(formatBytes(_selectedBytes)),
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          for (final target in chosen)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '\u2022  ${target.cache.displayName} '
                '(${formatBytes(target.sizeBytes ?? 0)})',
                style: const TextStyle(fontSize: 13),
              ),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(l.actionCancel),
      ),
      FilledButton(
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(l.cachesConfirmAccept),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final outcomes = _outcomes;
    final freed = outcomes?.fold(0, (int sum, o) => sum + o.bytesFreed) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.cachesTitle),
        titleTextStyle: context.text.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _loading || _running ? null : _survey,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            tooltip: l.cachesRemeasure,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
                    children: [
                      NoticeBanner(
                        message: l.cachesIntro,
                        icon: Icons.public_rounded,
                      ),
                      if (outcomes != null) ...[
                        const SizedBox(height: 12),
                        NoticeBanner(
                          message: l.cachesFreed(
                            formatBytes(freed),
                            outcomes.length,
                          ),
                          icon: Icons.check_circle_outline_rounded,
                          color: context.freed,
                        ),
                      ],
                      const SizedBox(height: 18),
                      if (_targets.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: Text(
                              l.cachesNoneFound,
                              style: TextStyle(
                                fontSize: 13,
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      for (final target in _targets)
                        _CacheRow(
                          target: target,
                          selected: _selected.contains(
                            target.cache.displayName,
                          ),
                          onToggle: () => setState(() {
                            final key = target.cache.displayName;
                            _selected.contains(key)
                                ? _selected.remove(key)
                                : _selected.add(key);
                          }),
                        ),
                    ],
                  ),
                ),
                if (_targets.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(28, 14, 28, 18),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerLowest,
                      border: Border(
                        top: BorderSide(color: context.colors.outlineVariant),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          formatBytes(_selectedBytes),
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: context.colors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l.cachesSelected,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: _selected.isEmpty || _running
                              ? null
                              : _clean,
                          icon: _running
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.8,
                                  ),
                                )
                              : const Icon(
                                  Icons.delete_sweep_outlined,
                                  size: 17,
                                ),
                          label: Text(
                            _running ? l.cachesEmptying : l.cachesEmptySelected,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _CacheRow extends StatelessWidget {
  const _CacheRow({
    required this.target,
    required this.selected,
    required this.onToggle,
  });

  final GlobalCacheTarget target;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Card(
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: selected,
                  onChanged: (_) => onToggle(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          target.cache.displayName,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (target.usesCommand)
                          Tag(
                            '${target.cache.command}',
                            color: context.freed,
                            icon: Icons.terminal_rounded,
                            tooltip: L.of(context).cachesUsesCommand,
                          )
                        else
                          Tag(
                            L.of(context).cachesDeleteTag,
                            icon: Icons.folder_delete_outlined,
                            tooltip: L.of(context).cachesUsesDelete,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      target.cache.description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (final path in target.paths) PathText(path, size: 10.5),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 86,
                child: target.sizeBytes == null
                    ? const Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.6),
                        ),
                      )
                    : Text(
                        formatBytes(target.sizeBytes!),
                        textAlign: TextAlign.right,
                        style: context.mono(
                          size: 12.5,
                          color: context.colors.onSurface,
                          weight: FontWeight.w500,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
