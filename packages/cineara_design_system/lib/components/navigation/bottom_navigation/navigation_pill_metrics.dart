import 'package:flutter/widgets.dart';

import '../../../tokens/accessibility.dart';
import '../../../tokens/breakpoints.dart';
import '../../../tokens/icon_sizes.dart';
import '../../../tokens/spacing.dart';

/// Responsive layout metrics for Cineara's bottom-navigation pill.
///
/// The navigation uses an icon-only visual treatment. Localized destination
/// labels remain available to accessibility services and tooltips.
///
/// General-purpose values reuse Cineara design-system tokens. Values defined
/// directly here belong specifically to this component family.
abstract final class CinearaNavigationPillMetrics {
  // Maximum widths

  /// Maximum pill width on compact layouts.
  static const double compactMaxWidth = 320;

  /// Maximum pill width on medium layouts.
  static const double mediumMaxWidth = 360;

  /// Maximum pill width on expanded and large layouts.
  static const double expandedMaxWidth = 400;

  // Surface heights

  /// Pill height on compact layouts.
  static const double compactHeight = 64;

  /// Pill height on medium layouts.
  static const double mediumHeight = 68;

  /// Pill height on expanded and large layouts.
  static const double expandedHeight = 72;

  // Icons

  /// Inactive icon size on compact layouts.
  static const double compactIconSize = CinearaIconSizes.standard;

  /// Inactive icon size on medium layouts.
  static const double mediumIconSize = 25;

  /// Inactive icon size on expanded and large layouts.
  static const double expandedIconSize = 26;

  /// Active icon emphasis on compact layouts.
  static const double compactSelectedIconScale = 1.06;

  /// Active icon emphasis on medium layouts.
  static const double mediumSelectedIconScale = 1.05;

  /// Active icon emphasis on expanded and large layouts.
  static const double expandedSelectedIconScale = 1.04;

  // Moving selection capsule

  static const double compactIndicatorWidth = 64;
  static const double mediumIndicatorWidth = 70;
  static const double expandedIndicatorWidth = 76;

  static const double compactIndicatorHeight = 48;
  static const double mediumIndicatorHeight = 50;
  static const double expandedIndicatorHeight = 52;

  // External positioning

  /// Horizontal screen margin around the floating navigation pill.
  static const double horizontalMargin = CinearaSpacing.md;

  /// Additional visual separation above the system safe area.
  static const double bottomMargin = CinearaSpacing.lg;

  /// Returns the current Cineara responsive window size.
  static CinearaWindowSize windowSize(BuildContext context) {
    return CinearaBreakpoints.fromWidth(MediaQuery.sizeOf(context).width);
  }

  /// Returns the maximum pill width for the current layout.
  static double maxWidthFor(BuildContext context) {
    return switch (windowSize(context)) {
      CinearaWindowSize.compact => compactMaxWidth,
      CinearaWindowSize.medium => mediumMaxWidth,
      CinearaWindowSize.expanded || CinearaWindowSize.large => expandedMaxWidth,
    };
  }

  /// Returns the accessibility-aware pill height.
  static double heightFor(BuildContext context) {
    final base = switch (windowSize(context)) {
      CinearaWindowSize.compact => compactHeight,
      CinearaWindowSize.medium => mediumHeight,
      CinearaWindowSize.expanded || CinearaWindowSize.large => expandedHeight,
    };

    return base * CinearaAccessibility.controlScale(context);
  }

  /// Returns the accessibility-aware inactive icon size.
  static double iconSizeFor(BuildContext context) {
    final base = switch (windowSize(context)) {
      CinearaWindowSize.compact => compactIconSize,
      CinearaWindowSize.medium => mediumIconSize,
      CinearaWindowSize.expanded || CinearaWindowSize.large => expandedIconSize,
    };

    return base * CinearaAccessibility.compactControlScale(context);
  }

  /// Returns the scale applied to the active icon.
  static double selectedIconScaleFor(BuildContext context) {
    return switch (windowSize(context)) {
      CinearaWindowSize.compact => compactSelectedIconScale,
      CinearaWindowSize.medium => mediumSelectedIconScale,
      CinearaWindowSize.expanded ||
      CinearaWindowSize.large => expandedSelectedIconScale,
    };
  }

  /// Returns the accessibility-aware selection-capsule width.
  static double indicatorWidthFor(BuildContext context) {
    final base = switch (windowSize(context)) {
      CinearaWindowSize.compact => compactIndicatorWidth,
      CinearaWindowSize.medium => mediumIndicatorWidth,
      CinearaWindowSize.expanded ||
      CinearaWindowSize.large => expandedIndicatorWidth,
    };

    return base * CinearaAccessibility.compactControlScale(context);
  }

  /// Returns the accessibility-aware selection-capsule height.
  static double indicatorHeightFor(BuildContext context) {
    final base = switch (windowSize(context)) {
      CinearaWindowSize.compact => compactIndicatorHeight,
      CinearaWindowSize.medium => mediumIndicatorHeight,
      CinearaWindowSize.expanded ||
      CinearaWindowSize.large => expandedIndicatorHeight,
    };

    return base * CinearaAccessibility.compactControlScale(context);
  }
}
