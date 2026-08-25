// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/single_instance.dart';
import 'package:path/path.dart' as p;

/// The lock excludes other *processes* — POSIX file locks are per-process, so
/// asserting it from a second `tryAcquire` in this one would prove nothing.
/// A real child Dart process is the only honest test.
void main() {
  late Directory temp;

  setUp(() => temp = Directory.systemTemp.createTempSync('kruftle-lock'));
  tearDown(() => temp.deleteSync(recursive: true));

  /// Runs `InstanceLock.tryAcquire` in another process, and reports whether it
  /// was granted the lock.
  bool acquiredElsewhere(String directory) {
    final script = File(p.join(temp.path, 'child.dart'))
      ..writeAsStringSync('''
import 'package:kruftle/src/core/single_instance.dart';
void main() {
  print(InstanceLock.tryAcquire(r'$directory') == null ? 'refused' : 'granted');
}
''');

    // `Platform.resolvedExecutable` under `flutter test` is flutter_tester,
    // which cannot run a script; the Dart that ships with the SDK can.
    final root = Platform.environment['FLUTTER_ROOT'];
    final dart = root == null
        ? 'dart'
        : p.join(root, 'bin', Platform.isWindows ? 'dart.bat' : 'dart');

    final result = Process.runSync(dart, [
      'run',
      '--packages=${p.join(Directory.current.path, '.dart_tool/package_config.json')}',
      script.path,
    ]);

    expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
    return (result.stdout as String).contains('granted');
  }

  test(
    'a second Kruftle is refused while the first holds the lock',
    () {
      final lock = InstanceLock.tryAcquire(temp.path);
      expect(lock, isNotNull);

      expect(acquiredElsewhere(temp.path), isFalse);

      // And the moment the first one goes away, the next one may start.
      lock!.release();
      expect(acquiredElsewhere(temp.path), isTrue);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
