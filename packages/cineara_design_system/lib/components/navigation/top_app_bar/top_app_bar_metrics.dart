import 'package:flutter/material.dart';

import '../../../tokens/accessibility.dart';
import '../../../tokens/breakpoints.dart';
import '../../../tokens/icon_sizes.dart';
import '../../../tokens/spacing.dart';
import '../../../tokens/typography.dart';

/// Layout metrics used by Cineara's top application bar.
///
/// General-purpose values reuse Cineara design-system tokens. Values defined
/// directly here belong specifically to the top-app-bar component family.
///
/// The top-app-bar surface may span the full available width, while its inner
/// content can be constrained on wider layouts to preserve comfortable visual
/// spacing and alignment.
abstract final class CinearaTopAppBarMetrics {
  // Toolbar

  /// Minimum supported toolbar height.
  static const double minimumToolbarHeight = 56;

  /// Default toolbar height.
  static const double toolbarHeight = 64;

  // Responsive horizontal layout

  /// Horizontal content padding on compact layouts.
  static const double compactHorizontalPadding = CinearaSpacing.md;

  /// Horizontal content padding on medium layouts.
  static const double mediumHorizontalPadding = CinearaSpacing.lg;

  /// Horizontal content padding on expanded layouts.
  static const double expandedHorizontalPadding = CinearaSpacing.xl;

  /// Horizontal content padding on large layouts.
  static const double largeHorizontalPadding = CinearaSpacing.xl;

  /// Maximum inner content width on medium layout.
  static const double mediumContentMaxWidth = 720;

  /// Maximum inner content width on expanded layouts.
  static const double expandedContentMaxWidth = 960;

  /// Maximum inner content width on large layouts.
  static const double largeContentMaxWidth = 1180;

  // Actions

  /// Base extent of a top-bar action's interactive hit target.
  static const double actionExtent = 48;

  /// Base size of standard top-bar action icons.
  static const double actionIconSize = CinearaIconSizes.standard;

  // Profile

  /// Base visual size of the profile avatar.
  static const double avatarExtent = 36;

  /// Base size of the fallback profile icon.
  static const double avatarFallbackIconSize = CinearaIconSizes.inline;

  /// Base font size used for profile initials.
  static const double avatarInitialsFontSize = CinearaFontSizes.labelSmall;

  // Notification badge

  /// Base top offset of the notification badge within its action.
  static const double notificationBadgeTop = CinearaSpacing.xxs / 2;

  /// Base directional-end offset of the notification badge within its action.
  static const double notificationBadgeEnd = 0;

  // Responsive helpers

  /// Returns the current Cineara responsive window size.
  static CinearaWindowSize windowSize(BuildContext context) {
    return CinearaBreakpoints.fromWidth(MediaQuery.sizeOf(context).width);
  }

  /// Returns the root-page title font size for the current layout.
  static double titleFontSizeFor(BuildContext context) {
    return switch (windowSize(context)) {
      CinearaWindowSize.compact => CinearaFontSizes.titleSmall,
      CinearaWindowSize.medium => 20,
      CinearaWindowSize.expanded ||
      CinearaWindowSize.large => CinearaFontSizes.titleMedium,
    };
  }

  /// Returns the horizontal content padding for the current layout.
  static double horizontalPaddingFor(BuildContext context) {
    return switch (windowSize(context)) {
      CinearaWindowSize.compact => compactHorizontalPadding,
      CinearaWindowSize.medium => mediumHorizontalPadding,
      CinearaWindowSize.expanded => expandedHorizontalPadding,
      CinearaWindowSize.large => largeHorizontalPadding,
    };
  }

  /// Returns the maximum width of the top-app-bar inner content.
  ///
  /// Compact layouts use the full available width. Wider layouts constrain
  /// the content so the brand and actions do not become excessively separated.
  static double contentMaxWidthFor(BuildContext context) {
    return switch (windowSize(context)) {
      CinearaWindowSize.compact => double.infinity,
      CinearaWindowSize.medium => mediumContentMaxWidth,
      CinearaWindowSize.expanded => expandedContentMaxWidth,
      CinearaWindowSize.large => largeContentMaxWidth,
    };
  }

  // Accessibility-aware metrics

  /// Returns the accessibility-aware top offset of the notification badge.
  static double notificationBadgeTopFor(BuildContext context) {
    return notificationBadgeTop *
        CinearaAccessibility.compactControlScale(context);
  }

  /// Returns the accessibility-aware directional-end offset of the notification
  /// badge.
  static double notificationBadgeEndFor(BuildContext context) {
    return notificationBadgeEnd *
        CinearaAccessibility.compactControlScale(context);
  }

  /// Returns the accessibility-aware action hit-target extent.
  static double actionExtentFor(BuildContext context) {
    return actionExtent * CinearaAccessibility.compactControlScale(context);
  }

  /// Returns the accessibility-aware top-bar icon size.
  static double actionIconSizeFor(BuildContext context) {
    return actionIconSize * CinearaAccessibility.controlScale(context);
  }

  /// Returns the accessibility-aware profile-avatar extent.
  static double avatarExtentFor(BuildContext context) {
    return avatarExtent * CinearaAccessibility.controlScale(context);
  }

  /// Returns the accessibility-aware fallback profile-icon size.
  static double avatarFallbackIconSizeFor(BuildContext context) {
    return avatarFallbackIconSize * CinearaAccessibility.controlScale(context);
  }

  /// Returns the restrained scale used by compact badge content.
  static double badgeScale(BuildContext context) {
    return CinearaAccessibility.compactControlScale(context);
  }

  /// Returns the restrained scale used by profile initials.
  static double initialsScale(BuildContext context) {
    return CinearaAccessibility.compactControlScale(context);
  }
}
