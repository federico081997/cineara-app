import 'package:flutter/animation.dart';

/// Motion speeds used throughout the Cineara design system.
enum CinearaMotionSpeed { press, fast, standard, slow }

/// Centralised motion values used throughout Cineara.
///
/// Components should build their motion from these durations, curves, and
/// interaction scales so navigation, selection, and content transitions feel
/// related without sharing component-specific implementation details.
abstract final class CinearaMotion {
  /// Immediate interaction feedback.
  static const Duration press = Duration(milliseconds: 100);

  /// Short fades, icon changes, and compact state changes.
  static const Duration fast = Duration(milliseconds: 180);

  /// Default interface transition duration.
  static const Duration standard = Duration(milliseconds: 280);

  /// Search uses a slightly longer geometry transition because one compact
  /// top-bar action grows into a full interactive field.
  static const Duration searchTransition = Duration(milliseconds: 360);

  /// Large or prominent transitions.
  static const Duration slow = Duration(milliseconds: 420);

  /// Deliberately slow motion reserved for exceptional presentation states.
  static const Duration verySlow = Duration(milliseconds: 840);

  /// Default delay between related staged entrances.
  static const Duration stagger = Duration(milliseconds: 45);

  /// Scale applied to standard interactive surfaces while pressed.
  static const double pressedScale = 0.985;

  /// Small lift used while a shared bubble is travelling.
  static const double bubbleLiftScale = 1.018;

  /// Initial scale for bubble-like entrances.
  static const double bubbleEnterScale = 0.94;

  /// Terminal scale for bubble-like exits.
  static const double bubbleExitScale = 0.96;

  /// Curve used for immediate press feedback.
  static const Curve pressCurve = Curves.easeOut;

  /// General-purpose interface movement.
  static const Curve standardCurve = Cubic(0.20, 0.80, 0.20, 1.00);

  /// Incoming content that should settle quickly and softly.
  static const Curve enterCurve = Cubic(0.16, 1.00, 0.30, 1.00);

  /// Outgoing content that should leave without overshoot.
  static const Curve exitCurve = Cubic(0.40, 0.00, 1.00, 1.00);

  /// Shared bubble geometry such as Search and segmented selection surfaces.
  static const Curve bubbleCurve = Cubic(0.16, 0.90, 0.24, 1.00);

  /// Layout reflow and size interpolation.
  static const Curve layoutCurve = Cubic(0.20, 0.75, 0.20, 1.00);

  /// Opacity-only interpolation.
  static const Curve fadeCurve = Curves.easeInOut;

  /// Shared selection movement such as Grid/List and bottom navigation.
  static const Duration selectionTransition = standard;

  /// General reusable bubble expansion/collapse duration.
  static const Duration bubbleTransition = standard;

  /// Content replacement inside an already established surface.
  static const Duration contentTransition = fast;

  /// Navigation selection movement.
  static const Duration navigationTransition = standard;

  /// Shared-element transitions between substantial surfaces.
  static const Duration sharedTransition = slow;

  /// Returns the duration associated with [speed].
  static Duration duration(CinearaMotionSpeed speed) {
    return switch (speed) {
      CinearaMotionSpeed.press => press,
      CinearaMotionSpeed.fast => fast,
      CinearaMotionSpeed.standard => standard,
      CinearaMotionSpeed.slow => slow,
    };
  }

  /// Resolves a motion speed against the active reduced-motion preference.
  static Duration resolvedDuration(
    CinearaMotionSpeed speed, {
    required bool reduceMotion,
  }) {
    return reduceMotion ? Duration.zero : duration(speed);
  }

  /// Resolves an arbitrary Cineara duration against reduced motion.
  static Duration resolve(Duration value, {required bool reduceMotion}) {
    return reduceMotion ? Duration.zero : value;
  }
}
