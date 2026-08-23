// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/log/activity_log.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tmp;
  late ActivityLog log;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('kruftle_log');
    log = ActivityLog(directory: tmp.path, minimumLevel: LogLevel.debug);
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  test('writes entries that read back identically', () {
    log.info('cleaned', {'project': '/work/app', 'bytes': 4096});
    log.error('failed', {'exitCode': 101});

    final read = log.readAll();
    expect(read, hasLength(2));
    expect(read.first.message, 'cleaned');
    expect(read.first.data['bytes'], 4096);
    expect(read.last.level, LogLevel.error);
  });

  test('respects the minimum level', () {
    ActivityLog(directory: tmp.path, minimumLevel: LogLevel.warning)
      ..debug('noise')
      ..info('noise')
      ..warning('kept')
      ..error('kept');

    final read = ActivityLog(directory: tmp.path).readAll();
    expect(read.map((e) => e.message), ['kept', 'kept']);
  });

  test('survives a truncated final line', () {
    log.info('good');
    log.file.writeAsStringSync('{"time": "not final', mode: FileMode.append);

    expect(
      log.readAll(),
      hasLength(1),
      reason: 'a crash mid-write must not make the whole log unreadable',
    );
  });

  test('rotates once the file passes its size limit', () {
    final small = ActivityLog(
      directory: tmp.path,
      minimumLevel: LogLevel.debug,
      maxBytes: 512,
      keepRotations: 2,
    );
    for (var i = 0; i < 60; i++) {
      small.info('entry $i', {'padding': 'x' * 40});
    }

    expect(File('${small.file.path}.1').existsSync(), isTrue);
    expect(
      File('${small.file.path}.3').existsSync(),
      isFalse,
      reason: 'only keepRotations files are retained',
    );
  });

  test('exports a readable plain-text copy', () {
    log.info('cleaned', {'project': '/work/app'});
    final out = log.export(p.join(tmp.path, 'export', 'kruftle.log'));

    final text = out.readAsStringSync();
    expect(text, contains('INFO'));
    expect(text, contains('cleaned'));
    expect(text, contains('project=/work/app'));
  });

  test('an unwritable directory does not throw', () {
    // Logging failures must never take down the run they are recording.
    final broken = ActivityLog(directory: '/proc/kruftle-cannot-write-here');
    expect(() => broken.info('still fine'), returnsNormally);
  });

  test('keeps this session in memory for the in-app view', () {
    log.info('one');
    log.info('two');
    expect(log.entries, hasLength(2));
  });

  test('clear removes both the file and the session buffer', () {
    log.info('one');
    log.clear();
    expect(log.entries, isEmpty);
    expect(log.readAll(), isEmpty);
  });
}
