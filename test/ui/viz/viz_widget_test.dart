// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/disk/native_disk.dart';
import 'package:kruftle/src/core/models/clean.dart';
import 'package:kruftle/src/core/models/project.dart';
import 'package:kruftle/src/core/models/stack.dart';
import 'package:kruftle/src/ui/viz/artifact_treemap.dart';
import 'package:kruftle/src/ui/viz/disk_gauge.dart';

import '../anim_test.dart' show painterOf, pumpAnimated;

DetectedProject project(String name, Map<String, int?> artifacts) =>
    DetectedProject(
      path: '/root/$name',
      depth: 1,
      stacks: [
        StackMatch(
          stackId: StackId.rust,
          displayName: 'Rust',
          command: null,
          toolBinary: null,
          installUrl: null,
          artifacts: [
            for (final entry in artifacts.entries)
              ArtifactHit(
                absolutePath: '/root/$name/${entry.key}',
                relative: entry.key,
                risk: CleanRisk.buildOutput,
                sizeBytes: entry.value,
              ),
          ],
        ),
      ],
    );

void main() {
  group('ArtifactTreemap.blocksFor', () {
    test('one block per measured artifact directory, biggest first', () {
      final blocks = ArtifactTreemap.blocksFor([
        project('small', {'target': 100}),
        project('big', {'target': 900, 'build': 500}),
      ]);

      expect(blocks.map((b) => b.bytes), [900, 500, 100]);
      expect(blocks.first.label, 'big/target');
      expect(blocks.first.path, '/root/big/target');
    });

    test('an unmeasured or empty directory is not drawn', () {
      // A block of no area is not something a user can see or point at, and
      // `null` means "not measured yet", which is not the same as empty.
      final blocks = ArtifactTreemap.blocksFor([
        project('a', {'target': 100, 'build': 0, 'pending': null}),
      ]);

      expect(blocks.map((b) => b.label), ['a/target']);
    });

    test('the tail is gathered into one block rather than dropped', () {
      // Dropping it would make the areas lie: the remaining blocks would each
      // claim a larger share of the total than they really have.
      final blocks = ArtifactTreemap.blocksFor([
        for (var i = 0; i < 30; i++) project('p$i', {'target': 100}),
      ], maxBlocks: 10);

      expect(blocks, hasLength(10));
      expect(blocks.last.label, contains('21'));
      expect(
        blocks.fold<int>(0, (sum, b) => sum + b.bytes),
        30 * 100,
        reason: 'the total must survive the bucketing',
      );
    });

    test('no tail block when everything already fits', () {
      final blocks = ArtifactTreemap.blocksFor([
        for (var i = 0; i < 5; i++) project('p$i', {'target': 100}),
      ], maxBlocks: 10);

      expect(blocks, hasLength(5));
      expect(blocks.every((b) => b.path.isNotEmpty), isTrue);
    });

    test('nothing measured yields nothing to draw', () {
      expect(ArtifactTreemap.blocksFor(const []), isEmpty);
      expect(
        ArtifactTreemap.blocksFor([
          project('a', {'target': null}),
        ]),
        isEmpty,
      );
    });
  });

  group('ArtifactTreemap widget', () {
    testWidgets('draws a hit-test region for every block', (tester) async {
      await pumpAnimated(
        tester,
        SizedBox(
          width: 400,
          child: ArtifactTreemap(
            projects: [
              project('a', {'target': 900}),
              project('b', {'target': 300}),
              project('c', {'target': 100}),
            ],
            root: '/root',
          ),
        ),
      );

      // One tooltip per block: hovering has to report the exact rectangle
      // under the cursor, which is what makes the picture answer "which one
      // is that?".
      expect(find.byType(Tooltip), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders nothing at all when there is nothing measured', (
      tester,
    ) async {
      await pumpAnimated(
        tester,
        SizedBox(
          width: 400,
          child: ArtifactTreemap(
            projects: [
              project('a', {'target': null}),
            ],
            root: '/root',
          ),
        ),
      );

      expect(find.byType(Tooltip), findsNothing);
    });
  });

  group('DiskGauge', () {
    const before = DiskSpace(
      totalBytes: 1000,
      freeBytes: 200,
      availableBytes: 200,
    );
    const after = DiskSpace(
      totalBytes: 1000,
      freeBytes: 500,
      availableBytes: 500,
    );

    testWidgets('travels from the before state to the after state', (
      tester,
    ) async {
      await pumpAnimated(
        tester,
        const SizedBox(
          width: 300,
          child: DiskGauge(
            before: before,
            after: after,
            beforeLabel: 'before',
            afterLabel: 'after',
          ),
        ),
      );

      expect(painterOf<DiskGaugePainter>(tester).currentFraction, 0.8);

      await tester.pump(const Duration(seconds: 2));
      expect(painterOf<DiskGaugePainter>(tester).currentFraction, 0.5);
    });

    testWidgets('reduced motion shows the settled state immediately', (
      tester,
    ) async {
      await pumpAnimated(
        tester,
        const SizedBox(
          width: 300,
          child: DiskGauge(
            before: before,
            after: after,
            beforeLabel: 'before',
            afterLabel: 'after',
          ),
        ),
        reduceMotion: true,
      );
      await tester.pump();

      expect(painterOf<DiskGaugePainter>(tester).currentFraction, 0.5);
    });

    test('a run that freed nothing draws no reclaimed slice', () {
      const painter = DiskGaugePainter(
        usedFractionBefore: 0.8,
        usedFractionAfter: 0.8,
        progress: 1,
        used: Colors.amber,
        freed: Colors.green,
        track: Colors.grey,
      );
      expect(painter.currentFraction, 0.8);
    });
  });

  group('CleanReport.volumeGained', () {
    const before = DiskSpace(
      totalBytes: 1000,
      freeBytes: 200,
      availableBytes: 200,
    );

    test('is null when the platform reports no volume figures', () {
      expect(
        _report(before: null, after: null).volumeGained,
        isNull,
        reason: 'no binding means no claim, not a claim of zero',
      );
      expect(_report(before: before, after: null).volumeGained, isNull);
    });

    test('is the difference in available space', () {
      const after = DiskSpace(
        totalBytes: 1000,
        freeBytes: 650,
        availableBytes: 650,
      );
      expect(_report(before: before, after: after).volumeGained, 450);
    });

    test('never reports a loss', () {
      // Something else on the machine writing during the run is not a loss
      // Kruftle should claim, and a negative "reclaimed" figure is nonsense.
      const after = DiskSpace(
        totalBytes: 1000,
        freeBytes: 100,
        availableBytes: 100,
      );
      expect(_report(before: before, after: after).volumeGained, 0);
    });
  });
}

/// A report carrying nothing but the two volume readings, which is all
/// `volumeGained` looks at.
CleanReport _report({DiskSpace? before, DiskSpace? after}) => CleanReport(
  outcomes: const [],
  bytesFreed: 0,
  estimatedBytes: 0,
  duration: Duration.zero,
  cancelled: false,
  volumeBefore: before,
  volumeAfter: after,
);
