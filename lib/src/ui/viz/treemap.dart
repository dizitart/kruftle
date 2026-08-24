// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

/// One thing to be drawn as a rectangle, and how big it is.
class TreemapItem<T> {
  const TreemapItem({required this.value, required this.data});

  /// Bytes. Must not be negative; zero-valued items are dropped by the layout
  /// because a rectangle of no area is not a thing anyone can point at.
  final int value;

  final T data;
}

/// An item and the rectangle it was given.
class TreemapTile<T> {
  const TreemapTile({required this.item, required this.rect});

  final TreemapItem<T> item;
  final Rect rect;
}

/// Lays items out as a squarified treemap: rectangles whose *areas* are
/// proportional to their values, packed to be as close to square as possible.
///
/// Squarified rather than the far simpler slice-and-dice, which alternates
/// horizontal and vertical cuts. Slice-and-dice is a dozen lines, but on real
/// data — where one Rust `target/` is a hundred times the next item — it
/// produces slivers a pixel wide that carry no information and cannot be
/// hovered. The whole point of this view is that the user can see and click
/// the big one, so the packing has to be the kind that keeps rectangles
/// clickable.
///
/// Bruls, Huizing and van Wijk, *Squarified Treemaps* (2000). Pure geometry
/// with no widget involved, so it is tested directly.
List<TreemapTile<T>> squarify<T>(List<TreemapItem<T>> items, Rect bounds) {
  final significant = items.where((i) => i.value > 0).toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  if (significant.isEmpty || bounds.width <= 0 || bounds.height <= 0) {
    return const [];
  }

  final total = significant.fold<int>(0, (sum, i) => sum + i.value);
  // Values are scaled into area units up front, so every later comparison is
  // in pixels² and the arithmetic never has to know about bytes.
  final areaPerUnit = bounds.width * bounds.height / total;

  final tiles = <TreemapTile<T>>[];
  var remaining = bounds;
  var index = 0;

  while (index < significant.length) {
    final row = <TreemapItem<T>>[];
    var rowArea = 0.0;
    // The short side is what a row's aspect ratios are measured against.
    final side = remaining.shortestSide;

    // Grow the row while doing so makes its worst rectangle *less* elongated.
    while (index < significant.length) {
      final candidate = significant[index];
      final candidateArea = candidate.value * areaPerUnit;

      final before = _worstRatio(row.map((i) => i.value * areaPerUnit), side);
      final after = _worstRatio([
        ...row.map((i) => i.value * areaPerUnit),
        candidateArea,
      ], side);

      if (row.isNotEmpty && after > before) break;

      row.add(candidate);
      rowArea += candidateArea;
      index++;
    }

    remaining = _placeRow(tiles, row, rowArea, remaining, areaPerUnit);
    if (remaining.width <= 0 || remaining.height <= 0) break;
  }

  return tiles;
}

/// Places one row along the shorter edge of [remaining] and returns what is
/// left for the next row.
Rect _placeRow<T>(
  List<TreemapTile<T>> tiles,
  List<TreemapItem<T>> row,
  double rowArea,
  Rect remaining,
  double areaPerUnit,
) {
  if (row.isEmpty) return Rect.zero;

  final horizontal = remaining.width >= remaining.height;
  // Thickness of the band this row occupies, chosen so the band's area is
  // exactly the sum of its items'.
  final thickness = horizontal
      ? rowArea / remaining.height
      : rowArea / remaining.width;

  var offset = horizontal ? remaining.top : remaining.left;

  for (final item in row) {
    final itemArea = item.value * areaPerUnit;
    final extent = itemArea / thickness;

    tiles.add(
      TreemapTile(
        item: item,
        rect: horizontal
            ? Rect.fromLTWH(remaining.left, offset, thickness, extent)
            : Rect.fromLTWH(offset, remaining.top, extent, thickness),
      ),
    );
    offset += extent;
  }

  return horizontal
      ? Rect.fromLTRB(
          remaining.left + thickness,
          remaining.top,
          remaining.right,
          remaining.bottom,
        )
      : Rect.fromLTRB(
          remaining.left,
          remaining.top + thickness,
          remaining.right,
          remaining.bottom,
        );
}

/// The worst aspect ratio in a row laid along an edge of length [side].
///
/// Infinity for an empty row, so the first item is always accepted.
double _worstRatio(Iterable<double> areas, double side) {
  if (areas.isEmpty) return double.infinity;

  var sum = 0.0;
  var min = double.infinity;
  var max = 0.0;
  for (final area in areas) {
    sum += area;
    if (area < min) min = area;
    if (area > max) max = area;
  }
  if (sum <= 0 || side <= 0) return double.infinity;

  final sideSquared = side * side;
  final sumSquared = sum * sum;
  return _max(sideSquared * max / sumSquared, sumSquared / (sideSquared * min));
}

double _max(double a, double b) => a > b ? a : b;
