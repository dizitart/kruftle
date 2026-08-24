// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme.dart';
import 'motion.dart';

/// The cleaning animation: a progress bar with a band of light travelling
/// along the filled portion, and motes being swept ahead of it.
///
/// Replaces a bare `LinearProgressIndicator` during a run. A clean can take
/// minutes and spends most of it inside somebody else's build tool, where the
/// only honest thing to report is "still going" — which is exactly the thing a
/// static bar is worst at saying.
class CleaningSweep extends ConsumerStatefulWidget {
  const CleaningSweep({super.key, required this.value, this.height = 8});

  /// 0..1. The bar is determinate; the sweep on top of it is not.
  final double value;

  final double height;

  @override
  ConsumerState<CleaningSweep> createState() => _CleaningSweepState();
}

class _CleaningSweepState extends ConsumerState<CleaningSweep>
    with TickerProviderStateMixin, MotionController {
  @override
  Duration get motionPeriod => Motion.sweep;

  @override
  Widget build(BuildContext context) {
    final moving = ref.motionEnabled(context);
    setMotion(enabled: moving);

    // The bar's own fill is animated by value, separately from the sweep, so
    // that progress arriving in a jump still reads as movement.
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: widget.value.clamp(0, 1)),
        duration: moving ? Motion.settle : Duration.zero,
        curve: Motion.change,
        builder: (context, filled, _) => SizedBox(
          height: widget.height,
          child: AnimatedBuilder(
            animation: motion,
            builder: (context, _) => CustomPaint(
              size: Size.infinite,
              painter: CleaningPainter(
                value: filled,
                phase: moving ? motion.value : 0,
                animating: moving,
                fill: context.colors.primary,
                track: context.colors.surfaceContainerHighest,
                spark: context.freed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints one frame of the cleaning bar.
class CleaningPainter extends CustomPainter {
  const CleaningPainter({
    required this.value,
    required this.phase,
    required this.fill,
    required this.track,
    required this.spark,
    this.animating = true,
  });

  /// 0..1 filled.
  final double value;

  /// 0..1, position of the travelling band.
  final double phase;

  final Color fill;
  final Color track;
  final Color spark;
  final bool animating;

  /// Motes swept ahead of the band. Enough to read as debris, few enough that
  /// the whole frame is still a handful of draw calls.
  static const moteCount = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final full = RRect.fromRectAndRadius(Offset.zero & size, radius);

    canvas.drawRRect(full, Paint()..color = track);

    final filledWidth = size.width * value.clamp(0, 1);
    if (filledWidth <= 0) return;

    canvas.save();
    canvas.clipRRect(full);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, filledWidth, size.height),
        radius,
      ),
      Paint()..color = fill,
    );

    if (animating) {
      _paintBand(canvas, size, filledWidth);
      _paintMotes(canvas, size, filledWidth);
    }

    canvas.restore();
  }

  /// A soft band of light travelling left to right along the filled portion.
  void _paintBand(Canvas canvas, Size size, double filledWidth) {
    const bandWidth = 0.28; // fraction of the filled portion
    final centre = filledWidth * (phase * (1 + bandWidth) - bandWidth / 2);
    final band = Rect.fromCenter(
      center: Offset(centre, size.height / 2),
      width: filledWidth * bandWidth,
      height: size.height,
    );
    if (band.width <= 0) return;

    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          colors: [
            fill.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.32),
            fill.withValues(alpha: 0),
          ],
        ).createShader(band),
    );
  }

  /// Motes ahead of the band, drifting toward the leading edge and fading as
  /// they arrive — the visual claim being "this is being swept away".
  void _paintMotes(Canvas canvas, Size size, double filledWidth) {
    final paint = Paint();

    for (var i = 0; i < moteCount; i++) {
      // Each mote runs on its own offset phase, so they do not pulse in
      // lockstep. Deterministic, so a rebuild does not scatter them.
      final own = (phase + i / moteCount) % 1.0;
      final x = filledWidth * own;
      // Sits off the centre line by a fixed amount per mote.
      final y = size.height * (0.3 + 0.4 * ((i * 7) % 5) / 4);
      final fade = math.sin(own * math.pi); // fades in and out at the ends

      paint.color = spark.withValues(alpha: 0.55 * fade);
      canvas.drawCircle(Offset(x, y), size.height * 0.12, paint);
    }
  }

  @override
  bool shouldRepaint(CleaningPainter old) =>
      old.value != value ||
      old.phase != phase ||
      old.animating != animating ||
      old.fill != fill;
}
