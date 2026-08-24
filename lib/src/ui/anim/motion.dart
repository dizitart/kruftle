// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_state.dart';

/// Whether this build should animate.
///
/// Two sources, and both are honoured: the operating system's own
/// reduced-motion accessibility setting, and Kruftle's own switch. Either one
/// being on is enough. A user who has asked their desktop for less motion
/// should not have to find the setting again in every app they install.
extension MotionQuery on WidgetRef {
  bool motionEnabled(BuildContext context) =>
      !MediaQuery.disableAnimationsOf(context) &&
      !read(settingsProvider).reduceMotion;
}

/// A [Ticker]-backed animation that stops when motion is off.
///
/// The point is not only that the pixels stop moving — a controller left
/// repeating schedules a frame forever, which on a laptop is a battery cost
/// with nothing on screen to show for it.
mixin MotionController<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late final AnimationController motion = AnimationController(
    vsync: this,
    duration: motionPeriod,
  );

  /// How long one cycle of this animation takes.
  Duration get motionPeriod;

  /// Called every build to start or stop the loop.
  void setMotion({required bool enabled}) {
    if (enabled && !motion.isAnimating) {
      motion.repeat();
    } else if (!enabled && motion.isAnimating) {
      motion.stop();
      motion.value = 0;
    }
  }

  @override
  void dispose() {
    motion.dispose();
    super.dispose();
  }
}

/// Kruftle's motion vocabulary, in one place so the app moves as one thing.
///
/// The durations are deliberately unglamorous. This is a tool that runs beside
/// a terminal: motion here exists to say "something is happening" and "this
/// number changed", not to perform.
abstract final class Motion {
  /// A state change the user caused — a step advancing, a panel swapping.
  static const quick = Duration(milliseconds: 220);

  /// A number settling to a new value.
  static const settle = Duration(milliseconds: 650);

  /// One turn of a continuous loop: the radar sweep, the cleaning band.
  static const sweep = Duration(milliseconds: 2400);

  /// A slow pulse, for something that is waiting rather than working.
  static const pulse = Duration(milliseconds: 1600);

  /// Decelerating: things arriving on screen.
  static const enter = Curves.easeOutCubic;

  /// Symmetric: things changing in place.
  static const change = Curves.easeInOutCubic;

  /// A little overshoot, used once — on the reclaimed figure at the end.
  static const celebrate = Curves.easeOutBack;
}
