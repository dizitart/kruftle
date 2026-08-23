// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/models/project.dart';
import '../../core/models/stack.dart';
import '../../core/scan/sizer.dart';
import '../../core/scan/toolchain.dart';
import '../state/app_state.dart';
import '../state/wizard_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Step 3 — choose what to clean, and what Kruftle is allowed to delete.
class StepReview extends ConsumerStatefulWidget {
  const StepReview({super.key});

  @override
  ConsumerState<StepReview> createState() => _StepReviewState();
}

class _StepReviewState extends ConsumerState<StepReview> {
  final _filter = TextEditingController();
  final _filterFocus = FocusNode();
  var _query = '';
  var _sortBySize = true;

  @override
  void dispose() {
    _filter.dispose();
    _filterFocus.dispose();
    super.dispose();
  }

  List<DetectedProject> _visible(WizardState state) {
    final query = _query.trim().toLowerCase();
    final matching = state.projects.where((project) {
      if (query.isEmpty) return true;
      return project.name.toLowerCase().contains(query) ||
          project.path.toLowerCase().contains(query) ||
          project.stacks.any(
            (s) => s.displayName.toLowerCase().contains(query),
          );
    }).toList();

    // Sorting by a size that is still being measured makes rows jump around
    // under the cursor. While measurement is in flight the order stays fixed,
    // and settles into size order once every figure is known.
    final sizesSettled = state.sizingProgress == null;
    matching.sort(
      _sortBySize && sizesSettled
          ? (a, b) => b.estimatedBytes.compareTo(a.estimatedBytes)
          : (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()),
    );
    return matching;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wizardProvider);
    final controller = ref.read(wizardProvider.notifier);
    final visible = _visible(state);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyA, control: true):
            controller.selectAll,
        const SingleActivator(LogicalKeyboardKey.keyA, meta: true):
            controller.selectAll,
        const SingleActivator(LogicalKeyboardKey.slash):
            _filterFocus.requestFocus,
      },
      child: Focus(
        autofocus: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(state, controller),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _table(state, visible, controller)),
                  const SizedBox(width: 22),
                  SizedBox(width: 320, child: _sidebar(state, controller)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Says which folder these results came from, and offers the way back out.
  /// Without this the review screen is a dead end: the step rail is a progress
  /// indicator, not navigation.
  Widget _header(WizardState state, WizardController controller) => Row(
    children: [
      Icon(
        Icons.folder_rounded,
        size: 16,
        color: context.colors.onSurfaceVariant,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.basename(state.root ?? ''),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 1),
            PathText(state.root ?? '', size: 11),
          ],
        ),
      ),
      Text(
        '${state.projects.length} '
        '${state.projects.length == 1 ? 'project' : 'projects'}',
        style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant),
      ),
      const SizedBox(width: 12),
      IconButton(
        onPressed: () => controller.startScan(state.root!),
        icon: const Icon(Icons.refresh_rounded, size: 17),
        tooltip: 'Scan again',
      ),
      TextButton.icon(
        onPressed: controller.restart,
        icon: const Icon(Icons.arrow_back_rounded, size: 15),
        label: const Text('Change folder'),
      ),
    ],
  );

  // ------------------------------------------------------------------- table

  Widget _table(
    WizardState state,
    List<DetectedProject> visible,
    WizardController controller,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _filter,
              focusNode: _filterFocus,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Filter by name, path or stack   ( / )',
                prefixIcon: const Icon(Icons.search_rounded, size: 17),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 38,
                  minHeight: 34,
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 15),
                        onPressed: () {
                          _filter.clear();
                          setState(() => _query = '');
                        },
                      ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: _query.isEmpty
                ? controller.selectAll
                : () => controller.selectOnly(
                    visible.map((project) => project.path),
                  ),
            child: Text(_query.isEmpty ? 'All' : 'All matching'),
          ),
          TextButton(
            onPressed: controller.selectNone,
            child: const Text('None'),
          ),
          IconButton(
            onPressed: () => setState(() => _sortBySize = !_sortBySize),
            icon: Icon(
              _sortBySize
                  ? Icons.data_usage_rounded
                  : Icons.sort_by_alpha_rounded,
              size: 17,
            ),
            tooltip: _sortBySize ? 'Sorted by size' : 'Sorted by path',
          ),
        ],
      ),
      const SizedBox(height: 14),
      Expanded(
        child: visible.isEmpty
            ? Center(
                child: Text(
                  state.projects.isEmpty
                      ? 'No projects with build output under this folder.'
                      : 'Nothing matches "$_query".',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              )
            : Card(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => _ProjectRow(
                    project: visible[index],
                    root: state.root!,
                    tools: state.tools,
                    selected: state.selected.contains(visible[index].path),
                    onToggle: () => controller.toggle(visible[index].path),
                  ),
                ),
              ),
      ),
    ],
  );

  // ----------------------------------------------------------------- sidebar

  Widget _sidebar(WizardState state, WizardController controller) {
    final plan = state.plan;

    // The options list is taller than the panel on a small window, so it
    // scrolls while the two actions stay pinned where the user expects them.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatTile(
                          value: formatBytes(
                            plan?.estimatedBytes ?? state.selectedBytes,
                          ),
                          label: plan == null
                              ? 'in ${state.selected.length} selected '
                                    '${state.selected.length == 1 ? 'project' : 'projects'}'
                              : 'measured by the dry run',
                          emphasis: true,
                          color: context.colors.primary,
                        ),
                        if (state.sizingProgress != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                width: 11,
                                height: 11,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.6,
                                  value: state.sizingProgress,
                                  color: context.colors.primary,
                                ),
                              ),
                              const SizedBox(width: 9),
                              Text(
                                'still measuring — '
                                '${((state.sizingProgress ?? 0) * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 14),
                        Text(
                          plan == null
                              ? '${formatBytes(state.totalBytes)} found in total across '
                                    '${state.projects.length} projects.'
                              : '${plan.steps.length} steps across '
                                    '${plan.projectPaths.length} projects.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                const PanelLabel('Also delete outright'),
                const SizedBox(height: 4),
                Text(
                  'Kruftle prefers each toolchain’s own clean command. These '
                  'categories are removed by deleting the directory, so they are off '
                  'unless you say otherwise.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.45,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),

                RiskToggle(
                  risk: CleanRisk.buildOutput,
                  value: state.risks.contains(CleanRisk.buildOutput),
                  onChanged: (v) =>
                      controller.setRisk(CleanRisk.buildOutput, v),
                  title: 'Build output when the SDK is missing',
                  subtitle:
                      'For projects whose toolchain is not installed, delete the '
                      'known output directory instead. Rebuilding restores it.',
                ),
                RiskToggle(
                  risk: CleanRisk.dependencies,
                  value: state.risks.contains(CleanRisk.dependencies),
                  onChanged: (v) =>
                      controller.setRisk(CleanRisk.dependencies, v),
                  title: 'Downloaded dependencies',
                  subtitle:
                      'node_modules, .venv, deps. Restored from the lockfile, '
                      'but that costs a download.',
                ),
                RiskToggle(
                  risk: CleanRisk.cache,
                  value: state.risks.contains(CleanRisk.cache),
                  onChanged: (v) => controller.setRisk(CleanRisk.cache, v),
                  title: 'Tool caches',
                  subtitle:
                      '.gradle, .turbo, .mypy_cache and friends. Only cost is a '
                      'slower next build.',
                ),

                if (state.hasMissingToolchains &&
                    !state.risks.contains(CleanRisk.buildOutput)) ...[
                  const SizedBox(height: 12),
                  const NoticeBanner(
                    message:
                        'Some selected projects have no SDK installed. Without '
                        'the first option above, they will be skipped.',
                    icon: Icons.info_outline_rounded,
                    color: KruftleTheme.warn,
                  ),
                ],

                if (plan != null && plan.gitTracked.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  NoticeBanner(
                    message:
                        '${plan.gitTracked.length} artifact '
                        '${plan.gitTracked.length == 1 ? 'directory is' : 'directories are'} '
                        'tracked by git and will be left alone. Deleting committed '
                        'content is not something a rebuild can undo.',
                    icon: Icons.shield_outlined,
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: state.selected.isEmpty
                ? null
                : () => controller.dryRun(),
            icon: const Icon(Icons.calculate_outlined, size: 17),
            label: Text(plan == null ? 'Dry run' : 'Re-measure'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: state.selected.isEmpty
                ? null
                : () => _confirmAndRun(state, controller),
            icon: const Icon(Icons.cleaning_services_rounded, size: 17),
            label: const Text('Clean now'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A dry run changes nothing. You can skip it.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// The last gate before anything is destroyed (safety rail 7).
  Future<void> _confirmAndRun(
    WizardState state,
    WizardController controller,
  ) async {
    final settings = ref.read(settingsProvider);
    final needsConfirm = state.risks.isNotEmpty && settings.confirmBeforeDelete;

    if (needsConfirm) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => _ConfirmDialog(state: state),
      );
      if (confirmed != true) return;
    }

    await controller.execute();
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({required this.state});

  final WizardState state;

  @override
  Widget build(BuildContext context) {
    final categories = {
      CleanRisk.buildOutput:
          'build output directories where the SDK is missing',
      CleanRisk.dependencies: 'downloaded dependency directories',
      CleanRisk.cache: 'tool cache directories',
    };

    return AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        size: 30,
        color: KruftleTheme.warn,
      ),
      title: const Text('Delete these directories?'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alongside running each toolchain’s clean command, Kruftle '
              'will delete:',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final risk in state.risks)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(
                      child: Text(
                        categories[risk]!,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'Across ${state.selected.length} selected projects under '
              '${p.basename(state.root ?? '')}. Everything here is '
              'regenerable, and anything git tracks is skipped.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete and clean'),
        ),
      ],
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({
    required this.project,
    required this.root,
    required this.tools,
    required this.selected,
    required this.onToggle,
  });

  final DetectedProject project;
  final String root;
  final Map<StackId, ToolStatus> tools;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    // Basenames repeat constantly in a real tree (five folders called `rust`),
    // so the row is identified by its path relative to the scan root.
    final relative = p.relative(project.path, from: root);
    final parent = p.dirname(relative);

    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
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
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (parent != '.') ...[
                    const SizedBox(height: 1),
                    PathText(parent, size: 10.5),
                  ],
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Wrap(
                spacing: 5,
                runSpacing: 4,
                children: [
                  for (final stack in project.stacks)
                    ToolBadge(
                      status: tools[stack.stackId] ?? ToolStatus.notApplicable,
                      binary: stack.toolBinary,
                      stackName: stack.displayName,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Tooltip(
              message: project.allArtifacts.map((a) => a.relative).join('\n'),
              child: SizedBox(
                width: 84,
                child: Text(
                  formatBytes(project.estimatedBytes),
                  textAlign: TextAlign.right,
                  style: context.mono(
                    size: 12,
                    color: context.colors.onSurface,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
