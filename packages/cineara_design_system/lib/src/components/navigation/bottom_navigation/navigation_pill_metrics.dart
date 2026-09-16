import 'package:flutter/widgets.dart';

import '../../../foundations/tokens/accessibility.dart';
import '../../../foundations/tokens/breakpoints.dart';
import '../../../foundations/tokens/icon_sizes.dart';
import '../../../foundations/tokens/spacing.dart';

/// Responsive layout metrics for Cineara's floating bottom navigation.
///
/// The navigation uses an icon-only visual treatment. Localized destination
/// labels remain available through tooltips and accessibility semantics.
///
/// General-purpose values reuse Cineara design-system tokens. Values defined
/// directly here belong specifically to this component family.
///
/// The moving active-destination capsule is inset uniformly from its
/// destination cell. Using one shared inset rather than independent width and
/// height values keeps the visual distance between the inner and outer
/// navigation surfaces consistent on every side.
///
/// Page layouts should use [contentClearanceFor] rather than duplicating bottom
/// padding calculations. This ensures scrollable content remains accessible
/// behind the persistent floating navigation surface.
abstract final class CinearaNavigationPillMetrics {
  // ---------------------------------------------------------------------------
  // Maximum widths
  // ---------------------------------------------------------------------------

  /// Maximum navigation width on compact layouts.
  static const double compactMaxWidth = 320;

  /// Maximum navigation width on medium layouts.
  static const double mediumMaxWidth = 360;

  /// Maximum navigation width on expanded and large layouts.
  static const double expandedMaxWidth = 400;

  // ---------------------------------------------------------------------------
  // Surface heights
  // ---------------------------------------------------------------------------

  /// Navigation height on compact layouts.
  static const double compactHeight = 64;

  /// Navigation height on medium layouts.
  static const double mediumHeight = 68;

  /// Navigation height on expanded and large layouts.
  static const double expandedHeight = 72;

  // ---------------------------------------------------------------------------
  // Icons
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Moving selection capsule
  // ---------------------------------------------------------------------------

  /// Uniform gap between the active-destination capsule and the bounds of its
  /// navigation destination cell.
  ///
  /// The same inset is applied horizontally and vertically so the capsule
  /// remains visually balanced inside the outer navigation surface.
  ///
  /// With the standard compact navigation:
  ///
  /// ```text
  /// navigation height: 64
  /// inset:              4
  /// indicator height:  56
  /// ```
  ///
  /// For a four-destination navigation at 320 logical pixels:
  ///
  /// ```text
  /// destination width: 80
  /// inset:              4
  /// indicator width:   72
  /// ```
  ///
  /// This produces the same four-logical-pixel gap on all sides.
  static const double indicatorInset = CinearaSpacing.xxs;

  // ---------------------------------------------------------------------------
  // External positioning
  // ---------------------------------------------------------------------------

  /// Minimum horizontal screen margin around the floating navigation surface.
  ///
  /// The maximum navigation width still constrains the component on wider
  /// layouts.
  static const double horizontalMargin = CinearaSpacing.md;

  /// Visual separation between the floating navigation surface and the
  /// device's bottom safe area.
  static const double bottomMargin = CinearaSpacing.lg;

  /// Additional space maintained between scrollable page content and the
  /// floating navigation surface.
  ///
  /// This prevents the final row, card, or control on a page from sitting
  /// directly underneath the navigation.
  static const double contentGap = CinearaSpacing.md;

  // ---------------------------------------------------------------------------
  // Responsive classification
  // ---------------------------------------------------------------------------

  /// Returns the current Cineara responsive window size.
  static CinearaWindowSize windowSize(BuildContext context) {
    return CinearaBreakpoints.fromWidth(MediaQuery.sizeOf(context).width);
  }

  // ---------------------------------------------------------------------------
  // Navigation surface
  // ---------------------------------------------------------------------------

  /// Returns the maximum navigation width for the current layout.
  static double maxWidthFor(BuildContext context) {
    return switch (windowSize(context)) {
      CinearaWindowSize.compact => compactMaxWidth,
      CinearaWindowSize.medium => mediumMaxWidth,
      CinearaWindowSize.expanded || CinearaWindowSize.large => expandedMaxWidth,
    };
  }

  /// Returns the accessibility-aware navigation height.
  ///
  /// The complete navigation surface scales with the user's accessibility
  /// control-size preference so its interactive regions remain comfortable.
  static double heightFor(BuildContext context) {
    final base = switch (windowSize(context)) {
      CinearaWindowSize.compact => compactHeight,
      CinearaWindowSize.medium => mediumHeight,
      CinearaWindowSize.expanded || CinearaWindowSize.large => expandedHeight,
    };

    return base * CinearaAccessibility.controlScale(context);
  }

  // ---------------------------------------------------------------------------
  // Icons
  // ---------------------------------------------------------------------------

  /// Returns the accessibility-aware inactive icon size.
  ///
  /// Compact-control scaling is used because icon emphasis should grow more
  /// conservatively than the complete navigation surface.
  static double iconSizeFor(BuildContext context) {
    final base = switch (windowSize(context)) {
      CinearaWindowSize.compact => compactIconSize,
      CinearaWindowSize.medium => mediumIconSize,
      CinearaWindowSize.expanded || CinearaWindowSize.large => expandedIconSize,
    };

    return base * CinearaAccessibility.compactControlScale(context);
  }

  /// Returns the scale applied to the active icon.
  ///
  /// Larger layouts require slightly less relative emphasis because the base
  /// icon itself is already larger.
  static double selectedIconScaleFor(BuildContext context) {
    return switch (windowSize(context)) {
      CinearaWindowSize.compact => compactSelectedIconScale,
      CinearaWindowSize.medium => mediumSelectedIconScale,
      CinearaWindowSize.expanded ||
      CinearaWindowSize.large => expandedSelectedIconScale,
    };
  }

  // ---------------------------------------------------------------------------
  // Page integration
  // ---------------------------------------------------------------------------

  /// Returns the bottom inset required by scrollable page content when the
  /// persistent floating navigation is visible.
  ///
  /// The clearance accounts for:
  ///
  /// ```text
  /// navigation height
  /// + navigation bottom margin
  /// + operating-system safe area
  /// + content breathing room
  /// ```
  ///
  /// Page-layout primitives such as `CinearaContentPage` and
  /// `CinearaCinematicPage` should use this value instead of reproducing the
  /// calculation independently.
  static double contentClearanceFor(BuildContext context) {
    final systemBottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return heightFor(context) + bottomMargin + systemBottomInset + contentGap;
  }
}
