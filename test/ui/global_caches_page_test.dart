// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/clean/global_caches.dart';
import 'package:kruftle/src/core/models/stack.dart';
import 'package:kruftle/src/ui/global_caches_page.dart';

/// The global cache screen's ordering.
///
/// The list exists to answer "what is worth emptying", and the survey returns
/// caches in registry order, which says nothing about size. The ordering is
/// therefore the value of the screen, and it is a pure function so it can be
/// asserted here — the screen itself surveys the real home directory, which is
/// not something a unit test should be driving.
void main() {
  GlobalCacheTarget target(String name, int? bytes) => GlobalCacheTarget(
    cache: GlobalCache(
      id: StackId.custom,
      displayName: name,
      description: 'test cache',
      relativePaths: const ['x'],
    ),
    paths: const ['/home/dev/x'],
    toolAvailable: false,
    sizeBytes: bytes,
  );

  group('ordering', () {
    final unsorted = [
      target('small', 10),
      target('huge', 9000),
      target('middling', 500),
    ];

    List<String> names(List<GlobalCacheTarget> ordered) =>
        ordered.map((t) => t.cache.displayName).toList();

    test('largest first is the default the screen opens on', () {
      expect(names(orderCaches(unsorted, CacheOrder.largestFirst)), [
        'huge',
        'middling',
        'small',
      ]);
    });

    test('smallest first reverses it', () {
      expect(names(orderCaches(unsorted, CacheOrder.smallestFirst)), [
        'small',
        'middling',
        'huge',
      ]);
    });

    test('a cache still being measured waits at the bottom', () {
      // Not sorted as zero: it would sit at the top under "smallest first" and
      // then jump the moment its real size arrived, moving the row out from
      // under a cursor that was about to tick it.
      final pending = [target('unmeasured', null), ...unsorted];
      for (final order in CacheOrder.values) {
        expect(names(orderCaches(pending, order)).last, 'unmeasured');
      }
    });

    test('equal sizes keep a stable order rather than shuffling', () {
      final tied = [target('a', 100), target('b', 100), target('c', 100)];
      expect(names(orderCaches(tied, CacheOrder.largestFirst)), [
        'a',
        'b',
        'c',
      ]);
    });

    test('an empty survey is not a special case', () {
      expect(orderCaches(const [], CacheOrder.largestFirst), isEmpty);
    });
  });
}
