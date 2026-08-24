// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme.dart';
import 'motion.dart';

/// The scanning animation: a rotating sweep over concentric rings, with a blip
/// left behind for each project found.
///
/// Drawn rather than imported. The whole thing is an arc, some circles and a
/// gradient — geometry a `CustomPainter` expresses directly and repaints in
/// well under a millisecond. A vector-animation runtime would be a dependency,
/// an asset pipeline and a licence to audit, in exchange for someone else's
/// arc.
class RadarSweep extends ConsumerStatefulWidget {
  const RadarSweep({
    super.key,
    required this.blipCount,
    this.size = 132,
    this.progress,
  });

  /// How many projects have been found. Each one leaves a mark, up to the
  /// point where more marks stop meaning anything.
  final int blipCount;

  final double size;

  /// 0..1 when the phase is measurable, null while the walk is open-ended.
  final double? progress;

  @override
  ConsumerState<RadarSweep> createState() => _RadarSweepState();
}

class _RadarSweepState extends ConsumerState<RadarSweep>
    with TickerProviderStateMixin, MotionController {
  @override
  Duration get motionPeriod => Motion.sweep;

  @override
  Widget build(BuildContext context) {
    final moving = ref.motionEnabled(context);
    setMotion(enabled: moving);

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: motion,
          builder: (context, _) => CustomPaint(
            painter: RadarPainter(
              // Frozen at a quarter turn when motion is off: the rings and
              // blips still read as "a scan is happening", without anything
              // moving.
              turn: moving ? motion.value : 0.25,
              blips: widget.blipCount,
              progress: widget.progress,
              sweepColor: context.colors.primary,
              ringColor: context.colors.onSurfaceVariant,
              blipColor: context.freed,
              animating: moving,
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints one frame of the radar.
///
/// Kept public and free of widget state so its geometry can be exercised
/// directly in a test.
class RadarPainter extends CustomPainter {
  const RadarPainter({
    required this.turn,
    required this.blips,
    required this.sweepColor,
    required this.ringColor,
    required this.blipColor,
    this.progress,
    this.animating = true,
  });

  /// 0..1, one full rotation.
  final double turn;

  final int blips;
  final double? progress;
  final Color sweepColor;
  final Color ringColor;
  final Color blipColor;
  final bool animating;

  /// Blips beyond this add nothing but clutter and paint cost.
  static const maxBlips = 48;

  int get visibleBlips => blips.clamp(0, maxBlips);

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    _paintRings(canvas, centre, radius);
    _paintBlips(canvas, centre, radius);
    if (animating) _paintSweep(canvas, centre, radius);
    _paintProgressArc(canvas, centre, radius);
  }

  void _paintRings(Canvas canvas, Offset centre, double radius) {
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ringColor.withValues(alpha: 0.18);

    for (var i = 1; i <= 3; i++) {
      canvas.drawCircle(centre, radius * i / 3, ring);
    }

    // Cross-hairs, at a third the weight of the rings.
    final hair = Paint()
      ..strokeWidth = 1
      ..color = ringColor.withValues(alpha: 0.1);
    canvas.drawLine(
      Offset(centre.dx - radius, centre.dy),
      Offset(centre.dx + radius, centre.dy),
      hair,
    );
    canvas.drawLine(
      Offset(centre.dx, centre.dy - radius),
      Offset(centre.dx, centre.dy + radius),
      hair,
    );
  }

  /// The sweeping wedge: a conic gradient that fades from the leading edge
  /// backwards, which is what makes it read as a trailing wake rather than a
  /// spinning pie slice.
  void _paintSweep(Canvas canvas, Offset centre, double radius) {
    final bounds = Rect.fromCircle(center: centre, radius: radius);
    final start = turn * 2 * math.pi;

    final wedge = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi / 2,
        colors: [
          sweepColor.withValues(alpha: 0),
          sweepColor.withValues(alpha: 0.35),
        ],
        transform: GradientRotation(start - math.pi / 2),
      ).createShader(bounds);

    canvas.drawArc(bounds, start - math.pi / 2, math.pi / 2, true, wedge);

    // The leading edge itself, so the sweep has a crisp front.
    final edge = Paint()
      ..strokeWidth = 1.5
      ..color = sweepColor.withValues(alpha: 0.8);
    canvas.drawLine(centre, _pointOn(centre, radius, start), edge);
  }

  /// One mark per project found, laid out on a phyllotaxis spiral.
  ///
  /// Deliberately deterministic: the same count always draws the same picture,
  /// so a rebuild does not make the marks jump. The golden angle spaces them
  /// evenly without any of them landing on top of another, which random
  /// placement cannot promise.
  void _paintBlips(Canvas canvas, Offset centre, double radius) {
    const goldenAngle = 2.39996; // radians
    final dot = Paint()..color = blipColor;

    for (var i = 0; i < visibleBlips; i++) {
      final angle = i * goldenAngle;
      final distance = radius * 0.82 * math.sqrt((i + 0.5) / maxBlips);
      final at = _pointOn(centre, distance, angle);

      // Marks near the sweep's leading edge glow; the rest sit quietly.
      final lit = animating ? _proximityToSweep(angle) : 0.35;
      dot.color = blipColor.withValues(alpha: 0.25 + 0.75 * lit);
      canvas.drawCircle(at, 1.6 + 1.4 * lit, dot);
    }
  }

  /// 0..1, how close [angle] is behind the sweep's leading edge.
  double _proximityToSweep(double angle) {
    final lead = turn * 2 * math.pi;
    var behind = (lead - angle) % (2 * math.pi);
    if (behind < 0) behind += 2 * math.pi;
    // Fades over a quarter turn, which matches the wedge's width.
    const window = math.pi / 2;
    return behind > window ? 0 : 1 - behind / window;
  }

  /// The determinate ring, drawn outside everything else, for the phase where
  /// there is a real percentage to show.
  void _paintProgressArc(Canvas canvas, Offset centre, double radius) {
    final value = progress;
    if (value == null) return;

    final bounds = Rect.fromCircle(center: centre, radius: radius - 1);
    canvas.drawArc(
      bounds,
      -math.pi / 2,
      2 * math.pi * value.clamp(0, 1),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = sweepColor,
    );
  }

  static Offset _pointOn(Offset centre, double distance, double angle) =>
      Offset(
        centre.dx + distance * math.cos(angle),
        centre.dy + distance * math.sin(angle),
      );

  @override
  bool shouldRepaint(RadarPainter old) =>
      old.turn != turn ||
      old.blips != blips ||
      old.progress != progress ||
      old.animating != animating ||
      old.sweepColor != sweepColor;
}
