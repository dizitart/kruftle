// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../../core/models/project.dart';
import '../../core/scan/sizer.dart';
import '../theme.dart';
import 'treemap.dart';

/// What one rectangle stands for.
class ArtifactBlock {
  const ArtifactBlock({
    required this.label,
    required this.path,
    required this.bytes,
  });

  final String label;
  final String path;
  final int bytes;
}

/// Where the space actually is, drawn as a treemap of the biggest artifact
/// directories under the scanned root.
///
/// A sorted table already tells the user which project is biggest. What it
/// cannot do is show *how much* bigger — that one `target/` is not merely
/// first but is most of the total. Area says that in one glance, which is the
/// only reason this view exists.
class ArtifactTreemap extends StatefulWidget {
  const ArtifactTreemap({
    super.key,
    required this.projects,
    required this.root,
    this.maxBlocks = 24,
    this.height = 190,
  });

  final List<DetectedProject> projects;
  final String root;

  /// Beyond this the rectangles are too small to read or hover, and the tail
  /// is collapsed into one "everything else" block.
  final int maxBlocks;

  final double height;

  /// The blocks a set of projects reduces to, largest first, with the tail
  /// gathered up.
  ///
  /// Static and pure so the bucketing can be tested without a widget tree.
  static List<ArtifactBlock> blocksFor(
    List<DetectedProject> projects, {
    int maxBlocks = 24,
    String otherLabel = 'other',
  }) {
    final all = <ArtifactBlock>[
      for (final project in projects)
        for (final artifact in project.allArtifacts)
          if ((artifact.sizeBytes ?? 0) > 0)
            ArtifactBlock(
              label: '${project.name}/${artifact.relative}',
              path: artifact.absolutePath,
              bytes: artifact.sizeBytes!,
            ),
    ]..sort((a, b) => b.bytes.compareTo(a.bytes));

    if (all.length <= maxBlocks) return all;

    final head = all.take(maxBlocks - 1).toList();
    final tail = all.skip(maxBlocks - 1);
    final tailBytes = tail.fold<int>(0, (sum, b) => sum + b.bytes);

    return [
      ...head,
      ArtifactBlock(
        label: '$otherLabel (${tail.length})',
        path: '',
        bytes: tailBytes,
      ),
    ];
  }

  @override
  State<ArtifactTreemap> createState() => _ArtifactTreemapState();
}

class _ArtifactTreemapState extends State<ArtifactTreemap> {
  ArtifactBlock? _hovered;

  @override
  Widget build(BuildContext context) {
    final blocks = ArtifactTreemap.blocksFor(
      widget.projects,
      maxBlocks: widget.maxBlocks,
    );
    if (blocks.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tiles = squarify([
            for (final block in blocks)
              TreemapItem(value: block.bytes, data: block),
          ], Offset.zero & constraints.biggest);

          return MouseRegion(
            onExit: (_) => setState(() => _hovered = null),
            child: Stack(
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    size: constraints.biggest,
                    painter: _TreemapPainter(
                      tiles: tiles,
                      hovered: _hovered,
                      base: context.colors.primary,
                      border: context.colors.surface,
                      text: context.colors.onSurface,
                      fontFamily: context.text.bodySmall?.fontFamily,
                    ),
                  ),
                ),
                // One hit-test region per tile, so hovering reports the exact
                // rectangle under the cursor rather than the painter having to
                // do its own hit testing.
                for (final tile in tiles)
                  Positioned.fromRect(
                    rect: tile.rect,
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hovered = tile.item.data),
                      child: Tooltip(
                        message: tile.item.data.path.isEmpty
                            ? '${tile.item.data.label} · '
                                  '${formatBytes(tile.item.data.bytes)}'
                            : '${tile.item.data.path}\n'
                                  '${formatBytes(tile.item.data.bytes)}',
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TreemapPainter extends CustomPainter {
  const _TreemapPainter({
    required this.tiles,
    required this.hovered,
    required this.base,
    required this.border,
    required this.text,
    required this.fontFamily,
  });

  final List<TreemapTile<ArtifactBlock>> tiles;
  final ArtifactBlock? hovered;
  final Color base;
  final Color border;
  final Color text;

  /// The face the rest of the app is set in. The labels are painted straight
  /// onto a canvas rather than built as widgets, so nothing hands them a
  /// theme — without this they fall through to whatever the engine happens to
  /// default to, which is not the font every other string here uses.
  final String? fontFamily;

  /// A rectangle needs to be at least this big before a label fits in it.
  static const _labelMinWidth = 62.0;
  static const _labelMinHeight = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (tiles.isEmpty) return;
    final largest = tiles.first.item.value;

    for (final tile in tiles) {
      // Shade by relative size, so the picture still ranks the blocks when
      // two of them happen to be laid out the same width.
      final weight = largest == 0 ? 0.0 : tile.item.value / largest;
      final isHovered = identical(tile.item.data, hovered);

      final rect = tile.rect.deflate(1);
      if (rect.width <= 0 || rect.height <= 0) continue;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()
          ..color = base.withValues(
            alpha: (isHovered ? 0.85 : 0.28 + 0.42 * weight).clamp(0.0, 1.0),
          ),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = border.withValues(alpha: 0.6),
      );

      if (rect.width >= _labelMinWidth && rect.height >= _labelMinHeight) {
        _paintLabel(canvas, rect, tile.item.data);
      }
    }
  }

  void _paintLabel(Canvas canvas, Rect rect, ArtifactBlock block) {
    final painter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${block.label}\n',
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 10,
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
          TextSpan(
            text: formatBytes(block.bytes),
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 9.5,
              height: 1.25,
              color: text.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: rect.width - 10);

    painter.paint(canvas, rect.topLeft + const Offset(5, 4));
  }

  @override
  bool shouldRepaint(_TreemapPainter old) =>
      old.tiles != tiles ||
      old.hovered != hovered ||
      old.base != base ||
      old.fontFamily != fontFamily;
}
