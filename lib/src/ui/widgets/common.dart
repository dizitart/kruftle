// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/models/stack.dart';
import '../../core/scan/toolchain.dart';
import '../theme.dart';

/// A small, quiet label. Used for stack names and statuses, where a full
/// Material chip would dominate a dense table row.
class Tag extends StatelessWidget {
  const Tag(this.label, {super.key, this.color, this.icon, this.tooltip});

  final String label;
  final Color? color;
  final IconData? icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.colors.onSurfaceVariant;
    final tag = Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: tint.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: tint),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              height: 1.2,
              color: tint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    return tooltip == null ? tag : Tooltip(message: tooltip!, child: tag);
  }
}

/// Says at a glance whether a project will get a proper clean.
class ToolBadge extends StatelessWidget {
  const ToolBadge({
    super.key,
    required this.status,
    required this.binary,
    required this.stackName,
  });

  final ToolStatus status;
  final String? binary;
  final String stackName;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return switch (status) {
      ToolStatus.available => Tag(
        stackName,
        color: context.freed,
        icon: Icons.check_rounded,
        tooltip: l.toolAvailable(binary ?? '', stackName),
      ),
      ToolStatus.missing => Tag(
        stackName,
        color: context.warn,
        icon: Icons.priority_high_rounded,
        tooltip: l.toolMissing(binary ?? ''),
      ),
      ToolStatus.notApplicable => Tag(
        stackName,
        tooltip: l.toolNotApplicable(stackName),
      ),
    };
  }
}

/// Section heading inside a panel.
class PanelLabel extends StatelessWidget {
  const PanelLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      fontSize: 10.5,
      letterSpacing: 1.1,
      fontWeight: FontWeight.w700,
      color: context.colors.onSurfaceVariant,
    ),
  );
}

/// A single headline figure with its caption.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.color,
    this.emphasis = false,
  });

  final String value;
  final String label;
  final Color? color;
  final bool emphasis;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: emphasis ? 34 : 20,
          height: 1.1,
          fontWeight: FontWeight.w700,
          color: color ?? context.colors.onSurface,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          color: context.colors.onSurfaceVariant,
        ),
      ),
    ],
  );
}

/// A path, shown the way a terminal would, ellipsised from the left so the
/// meaningful end of it stays visible.
class PathText extends StatelessWidget {
  const PathText(this.path, {super.key, this.size = 12, this.color});

  final String path;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    path,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: context.mono(
      size: size,
      color: color ?? context.colors.onSurfaceVariant,
    ),
  );
}

/// Explains a risk category and lets the user opt in for this run.
class RiskToggle extends StatelessWidget {
  const RiskToggle({
    super.key,
    required this.risk,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
  });

  final CleanRisk risk;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => onChanged(!value),
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Inline notice — used for scan failures and safety explanations.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.color,
    this.action,
  });

  final String message;
  final IconData icon;
  final Color? color;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.colors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tint.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: tint),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.5, height: 1.4, color: tint),
            ),
          ),
          if (action != null) ...[const SizedBox(width: 12), action!],
        ],
      ),
    );
  }
}

/// A dropdown that looks like the rest of the app.
///
/// The Material default is a bare label with an underline and a menu whose
/// corners are rounded by two pixels, so the hover highlight runs flush into a
/// nearly square edge and the whole control reads as unstyled next to the
/// app's rounded cards. This gives it a padded, bordered resting state and a
/// menu with the same radius as everything else.
///
/// One widget rather than the same eight lines of styling at each of the five
/// call sites, because the five have to agree with each other.
class KruftleDropdown<T> extends StatelessWidget {
  const KruftleDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;

  /// Value to label, in the order they should be offered.
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: context.colors.outlineVariant),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isDense: true,
        // Matches the cards and the buttons. The default of 2 is what made the
        // highlighted row look like it was overflowing the menu.
        borderRadius: BorderRadius.circular(10),
        dropdownColor: context.colors.surfaceContainerHigh,
        focusColor: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        icon: Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Icon(
            Icons.expand_more_rounded,
            size: 18,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        // Derived from the theme rather than built from scratch, because the
        // menu items are wrapped in this style and inherit nothing else. A
        // bare TextStyle would leave them on the platform's default family
        // while every label beside them followed the theme.
        style: context.text.bodyMedium?.copyWith(
          fontSize: 13,
          color: context.colors.onSurface,
        ),
        items: [
          for (final entry in items.entries)
            DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (v) => v == null ? null : onChanged(v),
      ),
    ),
  );
}
