// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/scan/sizer.dart';
import 'motion.dart';

/// A byte figure that counts up to its new value instead of jumping.
///
/// Sizes arrive in a stream of several hundred measurements, so this number
/// changes constantly during a scan. Jumping makes it look like a glitch;
/// counting makes it look like a measurement, which is what it is.
///
/// The tween is over the *bytes*, not the formatted string, so the units climb
/// through KiB and MiB on the way up rather than the text being interpolated
/// character by character.
class AnimatedBytes extends ConsumerWidget {
  const AnimatedBytes(
    this.bytes, {
    super.key,
    this.style,
    this.duration = Motion.settle,
    this.curve = Motion.change,
  });

  final int bytes;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moving = ref.motionEnabled(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: bytes.toDouble()),
      duration: moving ? duration : Duration.zero,
      curve: curve,
      builder: (context, value, _) => Text(
        formatBytes(value.round()),
        style: style,
        // A figure that changes width every frame drags the layout around
        // with it. Tabular figures keep every digit the same width, so the
        // number changes without the row twitching.
        textAlign: TextAlign.right,
      ),
    );
  }
}

/// A plain integer that counts, for step and project tallies.
class AnimatedCount extends ConsumerWidget {
  const AnimatedCount(this.value, {super.key, this.style});

  final int value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moving = ref.motionEnabled(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: moving ? Motion.quick : Duration.zero,
      curve: Motion.enter,
      builder: (context, v, _) => Text('${v.round()}', style: style),
    );
  }
}

/// A placeholder that breathes while a size is still being measured.
///
/// The alternative is showing `0 B`, which is a lie, or a spinner per row,
/// which on a table of two hundred projects is two hundred tickers.
class MeasuringShimmer extends ConsumerStatefulWidget {
  const MeasuringShimmer({super.key, this.width = 52, this.height = 10});

  final double width;
  final double height;

  @override
  ConsumerState<MeasuringShimmer> createState() => _MeasuringShimmerState();
}

class _MeasuringShimmerState extends ConsumerState<MeasuringShimmer>
    with TickerProviderStateMixin, MotionController {
  @override
  Duration get motionPeriod => Motion.pulse;

  @override
  Widget build(BuildContext context) {
    final moving = ref.motionEnabled(context);
    setMotion(enabled: moving);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: motion,
        builder: (context, _) {
          // A triangle wave, so the fade in and out are symmetric and the loop
          // has no visible seam where it restarts.
          final t = moving ? 1 - (motion.value * 2 - 1).abs() : 0.5;
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.1 + 0.14 * t),
              borderRadius: BorderRadius.circular(widget.height / 2),
            ),
          );
        },
      ),
    );
  }
}
