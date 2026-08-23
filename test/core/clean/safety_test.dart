// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/clean/safety.dart';
import 'package:path/path.dart' as p;

void main() {
  group('rail 2 — forbidden scan roots', () {
    bool alwaysExists(String _) => true;

    test('refuses the filesystem root', () {
      expect(
        checkScanRoot(
          '/',
          home: '/Users/dev',
          windows: false,
          directoryExists: alwaysExists,
        ),
        SafetyViolation.forbiddenRoot,
      );
    });

    test('refuses the user home directory', () {
      expect(
        checkScanRoot(
          '/Users/dev',
          home: '/Users/dev',
          windows: false,
          directoryExists: alwaysExists,
        ),
        SafetyViolation.forbiddenRoot,
      );
    });

    test('refuses a home path written with a trailing separator', () {
      expect(
        checkScanRoot(
          '/Users/dev/',
          home: '/Users/dev',
          windows: false,
          directoryExists: alwaysExists,
        ),
        SafetyViolation.forbiddenRoot,
      );
    });

    test('refuses system directories', () {
      for (final dir in ['/usr', '/etc', '/System', '/var', '/Applications']) {
        expect(
          checkScanRoot(
            dir,
            home: '/Users/dev',
            windows: false,
            directoryExists: alwaysExists,
          ),
          SafetyViolation.forbiddenRoot,
          reason: dir,
        );
      }
    });

    test('refuses Windows system directories', () {
      for (final dir in [
        r'C:\',
        r'C:\Windows',
        r'C:\Users',
        r'C:\Program Files',
      ]) {
        expect(
          checkScanRoot(
            dir,
            home: r'C:\Users\dev',
            windows: true,
            directoryExists: alwaysExists,
          ),
          SafetyViolation.forbiddenRoot,
          reason: dir,
        );
      }
    });

    test('is case-insensitive on Windows', () {
      expect(
        checkScanRoot(
          r'c:\windows',
          home: r'C:\Users\dev',
          windows: true,
          directoryExists: alwaysExists,
        ),
        SafetyViolation.forbiddenRoot,
      );
    });

    test('refuses a path only one level deep', () {
      expect(
        checkScanRoot(
          '/scratch',
          home: '/Users/dev',
          windows: false,
          directoryExists: alwaysExists,
        ),
        SafetyViolation.tooShallow,
      );
    });

    test('refuses a directory that does not exist', () {
      expect(
        checkScanRoot(
          '/Users/dev/nope/gone',
          home: '/Users/dev',
          windows: false,
          directoryExists: (_) => false,
        ),
        SafetyViolation.notADirectory,
      );
    });

    test('accepts an ordinary project tree', () {
      expect(
        checkScanRoot(
          '/Volumes/External/codebase',
          home: '/Users/dev',
          windows: false,
          directoryExists: alwaysExists,
        ),
        isNull,
      );
      expect(
        checkScanRoot(
          r'D:\work\projects',
          home: r'C:\Users\dev',
          windows: true,
          directoryExists: alwaysExists,
        ),
        isNull,
      );
    });
  });

  group('rails 1, 3, 4, 5 — delete targets', () {
    const root = '/work';
    const project = '/work/app';

    SafetyViolation? check(
      String target, {
      Set<String> allowed = const {'target'},
      String Function(String)? resolve,
      bool Function(String)? isLink,
      bool Function(String)? exists,
    }) => checkDeleteTarget(
      scanRoot: root,
      projectRoot: project,
      target: target,
      allowedRelatives: allowed,
      windows: false,
      resolve: resolve ?? (q) => q,
      isLink: isLink ?? (_) => false,
      directoryExists: exists ?? (_) => true,
    );

    test('accepts an allow-listed artifact directory', () {
      expect(check('/work/app/target'), isNull);
    });

    test('rail 4 — refuses a directory no stack declared', () {
      expect(check('/work/app/src'), SafetyViolation.notAllowListed);
      expect(check('/work/app/.git'), SafetyViolation.notAllowListed);
    });

    test('rail 4 — refuses a glob, never expands one', () {
      expect(check('/work/app/*'), SafetyViolation.notAllowListed);
    });

    test('rail 5 — refuses an allow-listed name outside the project root', () {
      // `target` is legal inside /work/app, not two levels up.
      expect(check('/work/other/target'), SafetyViolation.notAllowListed);
    });

    test('rail 3 — refuses a symlink outright', () {
      expect(
        check('/work/app/target', isLink: (_) => true),
        SafetyViolation.symlink,
      );
    });

    test('rail 1 — refuses when resolution escapes the scan root', () {
      // A link planted mid-path: the name is legal, the destination is not.
      expect(
        check(
          '/work/app/target',
          resolve: (q) => q == '/work/app/target' ? '/Users/dev/Documents' : q,
        ),
        SafetyViolation.outsideRoot,
      );
    });

    test('rail 1 — refuses a target that resolves to the scan root itself', () {
      expect(
        check('/work/app/target', resolve: (q) => '/work'),
        SafetyViolation.outsideRoot,
      );
    });

    test('refuses a target that no longer exists', () {
      expect(
        check('/work/app/target', exists: (_) => false),
        SafetyViolation.notADirectory,
      );
    });

    test('accepts a nested allow-listed path such as .next/cache', () {
      expect(check('/work/app/.next/cache', allowed: {'.next/cache'}), isNull);
      // ...but not the parent it lives in.
      expect(
        check('/work/app/.next', allowed: {'.next/cache'}),
        SafetyViolation.notAllowListed,
      );
    });

    test('every violation explains itself to the user', () {
      for (final violation in SafetyViolation.values) {
        expect(violation.message, isNotEmpty);
      }
    });
  });

  group('against a real filesystem', () {
    late Directory tmp;

    setUp(() => tmp = Directory.systemTemp.createTempSync('kruftle_safety'));
    tearDown(() => tmp.deleteSync(recursive: true));

    test('a real symlink pointing outside the root is refused', () {
      final scanRoot = Directory(p.join(tmp.path, 'root'))..createSync();
      final project = Directory(p.join(scanRoot.path, 'app'))..createSync();
      final outside = Directory(p.join(tmp.path, 'precious'))..createSync();
      Link(p.join(project.path, 'target')).createSync(outside.path);

      expect(
        checkDeleteTarget(
          scanRoot: scanRoot.path,
          projectRoot: project.path,
          target: p.join(project.path, 'target'),
          allowedRelatives: const {'target'},
        ),
        SafetyViolation.symlink,
      );
    });

    test('a genuine artifact directory inside the root is accepted', () {
      final scanRoot = Directory(p.join(tmp.path, 'root'))..createSync();
      final project = Directory(p.join(scanRoot.path, 'app'))..createSync();
      Directory(p.join(project.path, 'target')).createSync();

      expect(
        checkDeleteTarget(
          scanRoot: scanRoot.path,
          projectRoot: project.path,
          target: p.join(project.path, 'target'),
          allowedRelatives: const {'target'},
        ),
        isNull,
      );
    });
  });
}
