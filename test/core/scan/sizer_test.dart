// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/scan/sizer.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('kruftle_size'));
  tearDown(() => tmp.deleteSync(recursive: true));

  String write(String relative, int bytes) {
    final f = File(p.join(tmp.path, relative));
    f.parent.createSync(recursive: true);
    f.writeAsBytesSync(List.filled(bytes, 0));
    return f.path;
  }

  group('directorySizeSync', () {
    test('sums files across nested directories', () {
      write('a/one.bin', 1000);
      write('a/b/two.bin', 2000);
      write('a/b/c/three.bin', 3000);

      expect(directorySizeSync(p.join(tmp.path, 'a')), 6000);
    });

    test('reports zero for a directory that does not exist', () {
      expect(directorySizeSync(p.join(tmp.path, 'ghost')), 0);
    });

    test('reports zero for an empty directory', () {
      Directory(p.join(tmp.path, 'empty')).createSync();
      expect(directorySizeSync(p.join(tmp.path, 'empty')), 0);
    });

    test('does not follow symlinks or count what they point at', () {
      write('real/big.bin', 5000);
      Directory(p.join(tmp.path, 'measured')).createSync();
      write('measured/small.bin', 100);
      Link(p.join(tmp.path, 'measured', 'link'))
          .createSync(p.join(tmp.path, 'real'));

      expect(
        directorySizeSync(p.join(tmp.path, 'measured')),
        100,
        reason: 'the 5000 bytes behind the link belong to another tree',
      );
    });
  });

  group('Sizer', () {
    test('measures every path it is given', () async {
      write('one/f.bin', 1024);
      write('two/f.bin', 2048);
      write('three/f.bin', 4096);

      final paths = [
        for (final n in ['one', 'two', 'three']) p.join(tmp.path, n),
      ];
      final sizes = await Sizer().measureAll(paths);

      expect(sizes.keys.toSet(), paths.toSet());
      expect(sizes.values.reduce((a, b) => a + b), 7168);
    });

    test('the total does not depend on how many workers run', () async {
      for (var i = 0; i < 12; i++) {
        write('d$i/f.bin', 500);
      }
      final paths = [for (var i = 0; i < 12; i++) p.join(tmp.path, 'd$i')];

      final serial = await Sizer(concurrency: 1).measureAll(paths);
      final parallel = await Sizer(concurrency: 8).measureAll(paths);

      expect(serial, parallel);
      expect(parallel.values.reduce((a, b) => a + b), 6000);
    });

    test('reports progress as each path completes', () async {
      write('a/f.bin', 10);
      write('b/f.bin', 20);
      final paths = [p.join(tmp.path, 'a'), p.join(tmp.path, 'b')];

      final seen = <String, int>{};
      await Sizer().measureAll(paths, onMeasured: (path, b) => seen[path] = b);

      expect(seen, hasLength(2));
    });

    test('measures when the progress callback closes over unsendable state',
        () async {
      // Regression. The isolate computation used to be created inside the
      // worker loop, so it captured that whole scope — including onMeasured
      // and, transitively, whatever the caller's callback referenced. Dart
      // refuses to send a Completer or a StreamSubscription across a port, so
      // in the real app every measurement threw into an unawaited future and
      // the scan sat at 0% forever with no visible error.
      //
      // The callback here deliberately closes over exactly the kind of object
      // that cannot cross an isolate boundary.
      write('a/f.bin', 64);
      write('b/f.bin', 64);
      final paths = [p.join(tmp.path, 'a'), p.join(tmp.path, 'b')];

      final unsendable = Completer<void>();
      final seen = <String>[];

      await Sizer().measureAll(
        paths,
        onMeasured: (path, _) {
          seen.add(path);
          if (seen.length == paths.length && !unsendable.isCompleted) {
            unsendable.complete();
          }
        },
      );

      await unsendable.future;
      expect(seen, hasLength(2));
    });

    test('handles an empty batch', () async {
      expect(await Sizer().measureAll([]), isEmpty);
    });

    test('an unreadable path is zero, not a thrown batch', () async {
      final sizes = await Sizer().measureAll([p.join(tmp.path, 'missing')]);
      expect(sizes.values.single, 0);
    });
  });

  group('formatBytes', () {
    test('formats each magnitude the way a developer expects', () {
      expect(formatBytes(0), '0 B');
      expect(formatBytes(512), '512 B');
      expect(formatBytes(1024), '1.0 KiB');
      expect(formatBytes(1536), '1.5 KiB');
      expect(formatBytes(1024 * 1024), '1.0 MiB');
      expect(formatBytes(1024 * 1024 * 1024 * 3), '3.0 GiB');
    });

    test('drops the decimal once three digits are shown', () {
      expect(formatBytes(1024 * 512), '512 KiB');
    });
  });
}
