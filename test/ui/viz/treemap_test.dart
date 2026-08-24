// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/ui/viz/treemap.dart';

TreemapItem<String> item(String name, int value) =>
    TreemapItem(value: value, data: name);

void main() {
  const bounds = Rect.fromLTWH(0, 0, 400, 300);
  const area = 400 * 300;

  test('a single item fills the whole space', () {
    final tiles = squarify([item('only', 100)], bounds);

    expect(tiles, hasLength(1));
    expect(tiles.single.rect.width, closeTo(bounds.width, 0.01));
    expect(tiles.single.rect.height, closeTo(bounds.height, 0.01));
  });

  test('area is proportional to value', () {
    // The whole claim of a treemap. If this does not hold the picture is a
    // decoration rather than a measurement.
    final tiles = squarify([
      item('big', 600),
      item('medium', 300),
      item('small', 100),
    ], bounds);

    final byName = {for (final t in tiles) t.item.data: t.rect};

    expect(
      byName['big']!.width * byName['big']!.height,
      closeTo(area * 0.6, 1),
    );
    expect(
      byName['medium']!.width * byName['medium']!.height,
      closeTo(area * 0.3, 1),
    );
    expect(
      byName['small']!.width * byName['small']!.height,
      closeTo(area * 0.1, 1),
    );
  });

  test('the tiles exactly fill the bounds, with no gap and no overlap', () {
    final tiles = squarify([
      for (var i = 1; i <= 12; i++) item('i$i', i * 40),
    ], bounds);

    final covered = tiles.fold<double>(
      0,
      (sum, t) => sum + t.rect.width * t.rect.height,
    );
    expect(covered, closeTo(area, 1));

    for (final tile in tiles) {
      expect(bounds.contains(tile.rect.topLeft), isTrue);
      // A hair of tolerance: the right and bottom edges land exactly on the
      // boundary, which `contains` treats as outside.
      expect(tile.rect.right, lessThanOrEqualTo(bounds.right + 0.01));
      expect(tile.rect.bottom, lessThanOrEqualTo(bounds.bottom + 0.01));
    }

    for (var i = 0; i < tiles.length; i++) {
      for (var j = i + 1; j < tiles.length; j++) {
        final overlap = tiles[i].rect.intersect(tiles[j].rect);
        expect(
          overlap.width > 0.01 && overlap.height > 0.01,
          isFalse,
          reason: '${tiles[i].item.data} overlaps ${tiles[j].item.data}',
        );
      }
    }
  });

  test('rectangles stay close to square rather than becoming slivers', () {
    // The reason this is squarified and not slice-and-dice. On real data one
    // artifact directory dwarfs the rest; naive packing turns the rest into
    // one-pixel strips nobody can see or click.
    final tiles = squarify([
      item('huge', 10000),
      for (var i = 0; i < 8; i++) item('rest$i', 200),
    ], bounds);

    for (final tile in tiles) {
      final ratio = tile.rect.width > tile.rect.height
          ? tile.rect.width / tile.rect.height
          : tile.rect.height / tile.rect.width;
      expect(
        ratio,
        lessThan(12),
        reason:
            '${tile.item.data} is a sliver at ${ratio.toStringAsFixed(1)}:1',
      );
    }
  });

  test('the biggest item comes first and gets the biggest rectangle', () {
    final tiles = squarify([
      item('small', 10),
      item('big', 900),
      item('medium', 90),
    ], bounds);

    expect(tiles.first.item.data, 'big');

    final areas = tiles.map((t) => t.rect.width * t.rect.height).toList();
    expect(areas.first, greaterThan(areas[1]));
    expect(areas[1], greaterThan(areas[2]));
  });

  test('zero-sized items are dropped rather than drawn as nothing', () {
    final tiles = squarify([
      item('real', 100),
      item('empty', 0),
      item('unmeasured', 0),
    ], bounds);

    expect(tiles.map((t) => t.item.data), ['real']);
  });

  test(
    'an empty or degenerate input produces no tiles rather than throwing',
    () {
      expect(squarify<String>([], bounds), isEmpty);
      expect(squarify([item('a', 100)], Rect.zero), isEmpty);
      expect(squarify([item('a', 0)], bounds), isEmpty);
      expect(
        squarify([item('a', 100)], const Rect.fromLTWH(0, 0, 100, 0)),
        isEmpty,
      );
    },
  );

  test('a tall space is packed as happily as a wide one', () {
    const tall = Rect.fromLTWH(0, 0, 120, 600);
    final tiles = squarify([
      for (var i = 1; i <= 6; i++) item('i$i', i * 100),
    ], tall);

    final covered = tiles.fold<double>(
      0,
      (sum, t) => sum + t.rect.width * t.rect.height,
    );
    expect(covered, closeTo(tall.width * tall.height, 1));
  });

  test('items of identical value get identical areas', () {
    final tiles = squarify([
      for (var i = 0; i < 4; i++) item('same$i', 250),
    ], const Rect.fromLTWH(0, 0, 200, 200));

    final areas = tiles.map((t) => t.rect.width * t.rect.height).toList();
    for (final a in areas) {
      expect(a, closeTo(areas.first, 0.01));
    }
  });
}
