import 'package:flutter/widgets.dart';

import 'typography.dart';

/// Accessibility policies used throughout the Cineara design system.
///
/// Normal text continues to use Flutter's platform-provided text scaling.
///
/// These helpers are intended for constrained non-text interface elements such
/// as toolbar icons, avatars, navigation icons, indicators, and touch targets.
abstract final class CinearaAccessibility {
  /// Fraction of platform text-scale growth applied to constrained controls.
  static const double _controlGrowthFactor = 0.22;

  /// Maximum scale applied to visual controls.
  static const double _maximumControlScale = 1.18;

  /// Maximum scale applied to compact controls and indicators.
  static const double _maximumCompactControlScale = 1.08;

  /// Returns a restrained accessibility scale for constrained controls.
  static double controlScale(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    const referenceSize = CinearaFontSizes.bodyMedium;

    final textScale = textScaler.scale(referenceSize) / referenceSize;

    final restrainedScale = 1 + ((textScale - 1) * _controlGrowthFactor);

    return restrainedScale.clamp(1.0, _maximumControlScale).toDouble();
  }

  /// Returns a more strongly constrained scale for compact controls.
  static double compactControlScale(BuildContext context) {
    return controlScale(
      context,
    ).clamp(1.0, _maximumCompactControlScale).toDouble();
  }

  /// Whether non-essential interface animation should be reduced.
  static bool reduceMotion(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;
  }

  /// Returns [duration], or zero when reduced motion is requested.
  static Duration adaptiveDuration(BuildContext context, Duration duration) {
    return reduceMotion(context) ? Duration.zero : duration;
  }
}
