import 'package:flutter/widgets.dart';

/// Icon sizes used throughout the Cineara design system.
///
/// Sizes should be selected according to the semantic role of the icon rather
/// than by choosing arbitrary values at individual call sites.
///
/// Icons displayed alongside scalable text should generally use
/// `Icon.applyTextScaling`.
///
/// Prominent state and feedback icons should use
/// [CinearaIconSizing.feedback] so they respond to the user's accessibility
/// text scaling without becoming disproportionately large.
abstract final class CinearaIconSizes {
  /// Size for small icons used in compact controls and dense layouts.
  static const double small = 16;

  /// Size for icons displayed alongside text.
  static const double inline = 20;

  /// Default size for standard interface icons.
  static const double standard = 24;

  /// Size for interface icons requiring additional visual emphasis.
  static const double large = 32;

  /// Base size for prominent state and feedback icons.
  static const double feedback = 60;

  /// Maximum size for accessible state and feedback icons.
  static const double feedbackMax = 76;
}

/// Adaptive icon sizing used throughout the Cineara design system.
///
/// These helpers should be used for icon roles that require controlled
/// accessibility scaling.
///
/// Icons directly associated with text should generally rely on
/// `Icon.applyTextScaling` instead.
abstract final class CinearaIconSizing {
  /// Returns the accessible size for a prominent state or feedback icon.
  ///
  /// The icon grows in response to the platform text scaling preference, but
  /// more gradually than the text itself and never beyond
  /// [CinearaIconSizes.feedbackMax].
  static double feedback(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    final scaledSize = textScaler.scale(CinearaIconSizes.feedback);
    final scaledGrowth = scaledSize - CinearaIconSizes.feedback;

    const growthFactor = 0.35;

    return (CinearaIconSizes.feedback + scaledGrowth * growthFactor)
        .clamp(CinearaIconSizes.feedback, CinearaIconSizes.feedbackMax)
        .toDouble();
  }
}
