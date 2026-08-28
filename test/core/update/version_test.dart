// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/update/version.dart';

void main() {
  test('kAppVersion is the version pubspec.yaml declares', () {
    // The updater compares itself against release tags using this constant, so
    // if it drifted from the version the release is built under, the app would
    // either never see a new release or offer itself the one it is already
    // running. The release workflow makes the same check against the tag.
    final pubspec = File('pubspec.yaml').readAsLinesSync();
    final declared = pubspec
        .firstWhere((line) => line.startsWith('version:'))
        .split(':')
        .last
        .trim()
        .split('+')
        .first;

    expect(kAppVersion, declared);
  });

  test('kAppVersion is a version the updater can parse', () {
    // `Version.tryParse` returning null is how the update check used to give
    // up in silence.
    expect(Version.tryParse(kAppVersion), isNotNull);
  });
}
