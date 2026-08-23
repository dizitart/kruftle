// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/disk/native_disk.dart';

/// These tests check the FFI bindings against the operating system's own
/// tools. They are the only way to know the struct offsets are right: a wrong
/// offset does not crash, it silently returns a plausible-looking number.
void main() {
  final disk = NativeDisk();

  group('volume space', () {
    test('reports a plausible total, free and available for a real path', () {
      final space = disk.spaceFor(Directory.current.path);
      if (space == null) {
        expect(
          disk.supportsVolumeSpace,
          isFalse,
          reason: 'a null result must mean the platform is unsupported',
        );
        return;
      }

      expect(space.totalBytes, greaterThan(0));
      expect(space.freeBytes, greaterThanOrEqualTo(0));
      expect(space.freeBytes, lessThanOrEqualTo(space.totalBytes));
      expect(space.availableBytes, lessThanOrEqualTo(space.freeBytes));
      expect(space.usedBytes, space.totalBytes - space.freeBytes);
      expect(space.usedFraction, inInclusiveRange(0, 1));
    });

    test('agrees with df to within a percent', () {
      if (!disk.supportsVolumeSpace || Platform.isWindows) return;

      final space = disk.spaceFor(Directory.current.path)!;
      // -k forces 1024-byte blocks, so the arithmetic is the same everywhere.
      final df = Process.runSync('df', ['-k', Directory.current.path]);
      final line = const LineSplitter()
          .convert(df.stdout as String)
          .where((l) => l.trim().isNotEmpty)
          .last;
      final fields = line.split(RegExp(r'\s+'));
      final totalKb = int.parse(fields[1]);
      final availableKb = int.parse(fields[3]);

      expect(
        space.totalBytes / 1024,
        closeTo(totalKb, totalKb * 0.01),
        reason: 'total from statfs should match df',
      );
      // Free space genuinely moves between the two calls, so this is a
      // loose bound — it is here to catch a wrong offset, not to audit df.
      expect(
        space.availableBytes / 1024,
        closeTo(availableKb, totalKb * 0.01 + 1024 * 1024),
        reason: 'available from statfs should match df',
      );
    });

    test(
      'returns null rather than throwing for a path that does not exist',
      () {
        expect(disk.spaceFor('/definitely/not/a/real/path/kruftle'), isNull);
      },
    );
  });

  group('allocated size', () {
    late Directory fixture;

    setUp(() {
      fixture = Directory.systemTemp.createTempSync('kruftle_alloc');
      // A file whose apparent size is deliberately not a block multiple.
      File('${fixture.path}/small.bin').writeAsBytesSync(List.filled(10, 7));
      File(
        '${fixture.path}/big.bin',
      ).writeAsBytesSync(List.filled(300 * 1024, 7));
    });

    tearDown(() => fixture.deleteSync(recursive: true));

    test('a 10-byte file occupies at least one block on disk', () {
      final allocated = disk.allocatedSize('${fixture.path}/small.bin');
      if (allocated == null) {
        expect(disk.supportsAllocatedSize, isFalse);
        return;
      }
      expect(
        allocated,
        greaterThanOrEqualTo(512),
        reason: 'ten bytes still costs a whole block',
      );
      expect(allocated % 512, 0, reason: 'st_blocks is counted in 512s');
    });

    test('agrees with du for a whole tree', () {
      if (!disk.supportsAllocatedSize || Platform.isWindows) return;

      var total = 0;
      for (final entity in fixture.listSync(recursive: true)) {
        total += disk.allocatedSize(entity.path) ?? 0;
      }
      total += disk.allocatedSize(fixture.path) ?? 0;

      final du = Process.runSync('du', ['-sk', fixture.path]);
      final duKb = int.parse(
        (du.stdout as String).trim().split(RegExp(r'\s+')).first,
      );

      expect(
        total,
        duKb * 1024,
        reason: 'our st_blocks sum must equal du to the byte',
      );
    });

    test('returns null for a path that does not exist', () {
      expect(disk.allocatedSize('${fixture.path}/nope'), isNull);
    });

    test('does not follow a symlink to its target', () {
      if (!disk.supportsAllocatedSize || Platform.isWindows) return;

      final link = Link('${fixture.path}/link')..createSync('big.bin');
      final linkSize = disk.allocatedSize(link.path)!;
      final targetSize = disk.allocatedSize('${fixture.path}/big.bin')!;

      expect(
        linkSize,
        lessThan(targetSize),
        reason: 'lstat, not stat — rail 3 depends on it',
      );
    });
  });

  test('self-check refuses to trust bindings whose offsets do not agree', () {
    // The guard that makes the rest of this safe: if the struct layout were
    // wrong, `st_size` would not match what Dart already knows the file size
    // to be, and the probe disables itself instead of reporting nonsense.
    expect(
      disk.supportsAllocatedSize,
      Platform.isMacOS || Platform.isLinux,
      reason: 'POSIX platforms should pass their own self-check',
    );
  });
}
