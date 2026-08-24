// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/disk/native_disk.dart';
import '../../core/scan/sizer.dart';
import '../anim/motion.dart';
import '../theme.dart';

/// How full the volume was before a run and how full it is after, drawn as one
/// bar with the reclaimed slice picked out between the two marks.
///
/// The freed-bytes figure says what Kruftle removed. This says what the
/// machine now has, which is the thing the user actually opened the app to
/// change — and it comes from the same call `df` and Finder make, so it will
/// agree with what they go and check afterwards.
class DiskGauge extends ConsumerWidget {
  const DiskGauge({
    super.key,
    required this.before,
    required this.after,
    required this.beforeLabel,
    required this.afterLabel,
    this.height = 26,
  });

  final DiskSpace before;
  final DiskSpace after;
  final String beforeLabel;
  final String afterLabel;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moving = ref.motionEnabled(context);

    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        // Animates from the "before" state to the "after" state, so the slice
        // that was freed is seen being freed rather than simply being there.
        tween: Tween(begin: 0, end: 1),
        duration: moving ? const Duration(milliseconds: 1100) : Duration.zero,
        curve: Motion.change,
        builder: (context, t, _) => SizedBox(
          height: height,
          child: CustomPaint(
            size: Size.infinite,
            painter: DiskGaugePainter(
              usedFractionBefore: before.usedFraction,
              usedFractionAfter: after.usedFraction,
              progress: t,
              used: context.colors.primary,
              freed: context.freed,
              track: context.colors.surfaceContainerHighest,
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints one frame of the gauge.
class DiskGaugePainter extends CustomPainter {
  const DiskGaugePainter({
    required this.usedFractionBefore,
    required this.usedFractionAfter,
    required this.progress,
    required this.used,
    required this.freed,
    required this.track,
  });

  /// 0..1 of the volume in use, either side of the run.
  final double usedFractionBefore;
  final double usedFractionAfter;

  /// 0..1 through the transition between the two.
  final double progress;

  final Color used;
  final Color freed;
  final Color track;

  /// Where the filled portion currently ends.
  double get currentFraction =>
      usedFractionBefore +
      (usedFractionAfter - usedFractionBefore) * progress.clamp(0, 1);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final full = RRect.fromRectAndRadius(Offset.zero & size, radius);

    canvas.drawRRect(full, Paint()..color = track);
    canvas.save();
    canvas.clipRRect(full);

    // The slice between the two marks: space that was in use and is not any
    // more. Drawn first, so the shrinking "used" bar reveals it.
    final reclaimedFrom = size.width * usedFractionAfter;
    final reclaimedTo = size.width * usedFractionBefore;
    if (reclaimedTo > reclaimedFrom) {
      canvas.drawRect(
        Rect.fromLTRB(reclaimedFrom, 0, reclaimedTo, size.height),
        Paint()..color = freed.withValues(alpha: 0.45),
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * currentFraction, size.height),
      Paint()..color = used,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(DiskGaugePainter old) =>
      old.progress != progress ||
      old.usedFractionBefore != usedFractionBefore ||
      old.usedFractionAfter != usedFractionAfter ||
      old.used != used;
}

/// The gauge plus the figures that explain it.
class DiskGaugeCard extends StatelessWidget {
  const DiskGaugeCard({
    super.key,
    required this.before,
    required this.after,
    required this.heading,
    required this.beforeLabel,
    required this.afterLabel,
  });

  final DiskSpace before;
  final DiskSpace after;
  final String heading;
  final String beforeLabel;
  final String afterLabel;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        heading,
        style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant),
      ),
      const SizedBox(height: 8),
      DiskGauge(
        before: before,
        after: after,
        beforeLabel: beforeLabel,
        afterLabel: afterLabel,
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          _Marker(
            colour: context.colors.primary,
            label: beforeLabel,
            value: formatBytes(before.availableBytes),
          ),
          const SizedBox(width: 22),
          _Marker(
            colour: context.freed,
            label: afterLabel,
            value: formatBytes(after.availableBytes),
          ),
        ],
      ),
    ],
  );
}

class _Marker extends StatelessWidget {
  const _Marker({
    required this.colour,
    required this.label,
    required this.value,
  });

  final Color colour;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: colour, shape: BoxShape.circle),
      ),
      const SizedBox(width: 7),
      Text(
        '$label  ',
        style: TextStyle(
          fontSize: 11.5,
          color: context.colors.onSurfaceVariant,
        ),
      ),
      Text(value, style: context.mono(size: 11.5, weight: FontWeight.w600)),
    ],
  );
}
