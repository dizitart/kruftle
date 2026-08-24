// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../l10n/app_localizations.dart';
import '../../core/models/project.dart';
import '../../core/models/stack.dart';
import '../../core/scan/sizer.dart';
import '../../core/scan/toolchain.dart';
import '../anim/animated_bytes.dart';
import '../state/app_state.dart';
import '../state/wizard_controller.dart';
import '../theme.dart';
import '../viz/artifact_treemap.dart';
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
    final l = L.of(context);

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
            _header(l, state, controller),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _table(l, state, visible, controller)),
                  const SizedBox(width: 22),
                  SizedBox(width: 320, child: _sidebar(l, state, controller)),
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
  Widget _header(L l, WizardState state, WizardController controller) => Row(
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
        l.reviewProjectCount(state.projects.length),
        style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant),
      ),
      const SizedBox(width: 12),
      IconButton(
        onPressed: () => controller.startScan(state.root!),
        icon: const Icon(Icons.refresh_rounded, size: 17),
        tooltip: l.reviewScanAgain,
      ),
      TextButton.icon(
        onPressed: controller.restart,
        icon: const Icon(Icons.arrow_back_rounded, size: 15),
        label: Text(l.reviewChangeFolder),
      ),
    ],
  );

  // ------------------------------------------------------------------- table

  Widget _table(
    L l,
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
                hintText: l.reviewFilterHint,
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
            child: Text(_query.isEmpty ? l.actionAll : l.actionAllMatching),
          ),
          TextButton(
            onPressed: controller.selectNone,
            child: Text(l.actionNone),
          ),
          IconButton(
            onPressed: () => setState(() => _sortBySize = !_sortBySize),
            icon: Icon(
              _sortBySize
                  ? Icons.data_usage_rounded
                  : Icons.sort_by_alpha_rounded,
              size: 17,
            ),
            tooltip: _sortBySize ? l.reviewSortedBySize : l.reviewSortedByPath,
          ),
        ],
      ),
      const SizedBox(height: 14),
      Expanded(
        child: visible.isEmpty
            ? Center(
                child: Text(
                  state.projects.isEmpty
                      ? l.reviewNoProjects
                      : l.reviewNoMatches(_query),
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

  Widget _sidebar(L l, WizardState state, WizardController controller) {
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
                        // Sizes arrive in a stream of several hundred
                        // measurements, so this figure changes constantly.
                        // Counting reads as measurement; jumping reads as a
                        // glitch.
                        AnimatedBytes(
                          plan?.estimatedBytes ?? state.selectedBytes,
                          style: TextStyle(
                            fontSize: 34,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                            color: context.colors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          plan == null
                              ? l.reviewInSelected(state.selected.length)
                              : l.reviewMeasuredByDryRun,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: context.colors.onSurfaceVariant,
                          ),
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
                                l.reviewStillMeasuring(
                                  ((state.sizingProgress ?? 0) * 100).round(),
                                ),
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
                              ? l.reviewFoundInTotal(
                                  formatBytes(state.totalBytes),
                                  state.projects.length,
                                )
                              : l.reviewPlanSummary(
                                  plan.steps.length,
                                  plan.projectPaths.length,
                                ),
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

                // Where the space is, before deciding what to do about it. A
                // sorted table says which project is biggest; only area says
                // that one of them is most of the total.
                if (state.sizingProgress == null &&
                    state.selectedBytes > 0) ...[
                  const SizedBox(height: 20),
                  PanelLabel(l.reviewLargestDirectories),
                  const SizedBox(height: 4),
                  Text(
                    l.reviewLargestDirectoriesHelp,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.45,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ArtifactTreemap(
                    projects: state.selectedProjects,
                    root: state.root ?? '',
                  ),
                ],

                const SizedBox(height: 18),
                PanelLabel(l.reviewAlsoDelete),
                const SizedBox(height: 4),
                Text(
                  l.reviewAlsoDeleteHelp,
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
                  title: l.reviewRiskBuildOutput,
                  subtitle: l.reviewRiskBuildOutputHelp,
                ),
                RiskToggle(
                  risk: CleanRisk.dependencies,
                  value: state.risks.contains(CleanRisk.dependencies),
                  onChanged: (v) =>
                      controller.setRisk(CleanRisk.dependencies, v),
                  title: l.reviewRiskDependencies,
                  subtitle: l.reviewRiskDependenciesHelp,
                ),
                RiskToggle(
                  risk: CleanRisk.cache,
                  value: state.risks.contains(CleanRisk.cache),
                  onChanged: (v) => controller.setRisk(CleanRisk.cache, v),
                  title: l.reviewRiskCache,
                  subtitle: l.reviewRiskCacheHelp,
                ),

                if (state.hasMissingToolchains &&
                    !state.risks.contains(CleanRisk.buildOutput)) ...[
                  const SizedBox(height: 12),
                  NoticeBanner(
                    message: l.reviewMissingToolchains,
                    icon: Icons.info_outline_rounded,
                    color: context.warn,
                  ),
                ],

                if (plan != null && plan.gitTracked.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  NoticeBanner(
                    message: l.reviewGitTracked(plan.gitTracked.length),
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
            label: Text(plan == null ? l.reviewDryRun : l.reviewRemeasure),
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
            label: Text(l.reviewCleanNow),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l.reviewDryRunNote,
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
    final l = L.of(context);
    final categories = {
      CleanRisk.buildOutput: l.confirmCategoryBuildOutput,
      CleanRisk.dependencies: l.confirmCategoryDependencies,
      CleanRisk.cache: l.confirmCategoryCache,
    };

    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, size: 30, color: context.warn),
      title: Text(l.confirmDeleteTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.confirmDeleteIntro,
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
              l.confirmDeleteScope(
                state.selected.length,
                p.basename(state.root ?? ''),
              ),
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
          child: Text(l.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l.confirmDeleteAccept),
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
  final Map<String, ToolStatus> tools;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    // Basenames repeat constantly in a real tree (five folders called `rust`),
    // so the row is identified by its path relative to the scan root.
    final relative = p.relative(project.path, from: root);
    final parent = p.dirname(relative);
    // "Measured" means every artifact directory has a byte count, not that the
    // total is non-zero: an empty `target/` legitimately measures zero.
    final measured = project.allArtifacts.every((a) => a.sizeBytes != null);

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
                      status:
                          tools[stack.toolBinary] ?? ToolStatus.notApplicable,
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
                child: measured
                    ? Text(
                        formatBytes(project.estimatedBytes),
                        textAlign: TextAlign.right,
                        style: context.mono(
                          size: 12,
                          color: context.colors.onSurface,
                          weight: FontWeight.w500,
                        ),
                      )
                    // Not measured yet. Showing `0 B` here would be a lie the
                    // user might act on, and a spinner per row on a table of
                    // two hundred projects is two hundred tickers.
                    : const Align(
                        alignment: Alignment.centerRight,
                        child: MeasuringShimmer(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
