import 'package:flutter/animation.dart';

/// Motion speeds used throughout the Cineara design system.
enum CinearaMotionSpeed { press, fast, standard, slow }

/// Centralised motion values used by the Cineara design system.
///
/// Motion durations:
/// - Press:    100 ms
/// - Fast:     180 ms
/// - Standard: 280 ms
/// - Slow:     420 ms
///
/// Interactive surfaces use subtle movement to provide clear feedback without
/// making the interface feel excessively animated.
abstract final class CinearaMotion {
  /// Duration for immediate interaction feedback such as pressed states.
  static const Duration press = Duration(milliseconds: 100);

  /// Duration for quick transitions such as fades and icon changes.
  static const Duration fast = Duration(milliseconds: 180);

  /// Default duration for interface transitions and navigation movement.
  static const Duration standard = Duration(milliseconds: 280);

  /// Duration for larger or more prominent transitions.
  static const Duration slow = Duration(milliseconds: 420);

  /// Duration for slower transitions as required.
  static const Duration verySlow = Duration(milliseconds: 840);

  /// Scale applied to standard interactive surfaces while pressed.
  static const double pressedScale = 0.985;

  /// Curve used for immediate press feedback.
  static const Curve pressCurve = Curves.easeOut;

  /// Curve used for standard interface movement and transitions.
  static const Curve standardCurve = Curves.easeOutCubic;

  /// Returns the duration associated with [speed].
  static Duration duration(CinearaMotionSpeed speed) {
    return switch (speed) {
      CinearaMotionSpeed.press => press,
      CinearaMotionSpeed.fast => fast,
      CinearaMotionSpeed.standard => standard,
      CinearaMotionSpeed.slow => slow,
    };
  }
}
