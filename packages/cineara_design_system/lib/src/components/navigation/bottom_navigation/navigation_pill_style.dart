import 'package:flutter/material.dart';

import '../../../foundations/shapes/cineara_shapes.dart';
import '../../../foundations/tokens/elevation.dart';
import '../../../foundations/tokens/geometry.dart';

/// Visual styling for Cineara's floating bottom navigation.
///
/// The navigation uses two deliberately different geometric layers:
///
/// - the outer surface uses Cineara's signature frame geometry;
/// - the active-destination indicator remains a soft capsule.
///
/// This prevents the component from appearing as two generic nested pills while
/// keeping the selected destination visually familiar and easy to scan.
///
/// Colors derive from the active [ColorScheme] so the component automatically
/// follows Cineara's light, dark, custom, and high-contrast themes.
abstract final class CinearaNavigationPillStyle {
  // ---------------------------------------------------------------------------
  // Elevation
  // ---------------------------------------------------------------------------

  /// Elevation of the floating navigation surface.
  static const double elevation = CinearaElevation.navigation;

  // ---------------------------------------------------------------------------
  // Borders
  // ---------------------------------------------------------------------------

  static const double _borderWidth = 1;
  static const double _highContrastBorderWidth = 2;

  static const double _borderOpacity = 0.40;

  // ---------------------------------------------------------------------------
  // Shadows
  // ---------------------------------------------------------------------------

  static const double _shadowLightOpacity = 0.12;
  static const double _shadowDarkOpacity = 0.28;

  // ---------------------------------------------------------------------------
  // Active indicator
  // ---------------------------------------------------------------------------

  static const double _indicatorLightOpacity = 0.14;
  static const double _indicatorDarkOpacity = 0.22;

  static const double _indicatorBorderOpacity = 0.18;

  // ---------------------------------------------------------------------------
  // Interaction overlays
  // ---------------------------------------------------------------------------

  static const double _pressedOverlayOpacity = 0.07;
  static const double _focusedOverlayOpacity = 0.08;
  static const double _hoveredOverlayOpacity = 0.045;

  // ---------------------------------------------------------------------------
  // Surface
  // ---------------------------------------------------------------------------

  /// Surface color of the floating navigation container.
  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHigh;
  }

  /// Shadow color of the floating navigation container.
  ///
  /// Dark themes use a stronger shadow because separation between neighbouring
  /// dark surfaces otherwise becomes less perceptible.
  static Color shadowColor(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return colors.shadow.withValues(
      alpha: theme.brightness == Brightness.dark
          ? _shadowDarkOpacity
          : _shadowLightOpacity,
    );
  }

  /// Shape and border of the outer navigation surface.
  ///
  /// Unlike the active destination indicator, the surrounding navigation
  /// container uses Cineara's signature chamfered geometry.
  static ShapeBorder shape(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final highContrast = MediaQuery.highContrastOf(context);

    return CinearaShapes.navigation(
      side: BorderSide(
        color: highContrast
            ? colors.outline
            : colors.outlineVariant.withValues(alpha: _borderOpacity),
        width: highContrast ? _highContrastBorderWidth : _borderWidth,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Active destination
  // ---------------------------------------------------------------------------

  /// Decoration of the moving active-destination capsule.
  ///
  /// The indicator intentionally remains fully rounded. The outer navigation
  /// surface carries Cineara's stronger geometric identity, while the capsule
  /// keeps the selected destination visually soft and immediately recognisable.
  static BoxDecoration indicatorDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final highContrast = MediaQuery.highContrastOf(context);

    final borderRadius = BorderRadius.circular(CinearaGeometry.capsuleRadius);

    if (highContrast) {
      return BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: borderRadius,
        border: Border.all(
          color: colors.primary,
          width: _highContrastBorderWidth,
        ),
      );
    }

    final opacity = theme.brightness == Brightness.dark
        ? _indicatorDarkOpacity
        : _indicatorLightOpacity;

    final indicatorColor = Color.alphaBlend(
      colors.primary.withValues(alpha: opacity),
      colors.surfaceContainerHighest,
    );

    return BoxDecoration(
      color: indicatorColor,
      borderRadius: borderRadius,
      border: Border.all(
        color: colors.primary.withValues(alpha: _indicatorBorderOpacity),
        width: _borderWidth,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Destination foreground
  // ---------------------------------------------------------------------------

  /// Foreground color of a navigation icon.
  static Color iconColor(BuildContext context, {required bool selected}) {
    final colors = Theme.of(context).colorScheme;

    return selected ? colors.primary : colors.onSurfaceVariant;
  }

  // ---------------------------------------------------------------------------
  // Interaction
  // ---------------------------------------------------------------------------

  /// Material interaction overlay for one navigation destination.
  ///
  /// Pressed, focused, and hovered states use restrained primary-color
  /// overlays so navigation feedback remains visible without competing with
  /// the moving selected-destination indicator.
  static WidgetStateProperty<Color?> itemOverlay(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final highContrast = MediaQuery.highContrastOf(context);

    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return colors.primary.withValues(
          alpha: highContrast ? _focusedOverlayOpacity : _pressedOverlayOpacity,
        );
      }

      if (states.contains(WidgetState.focused)) {
        return colors.primary.withValues(alpha: _focusedOverlayOpacity);
      }

      if (states.contains(WidgetState.hovered)) {
        return colors.primary.withValues(alpha: _hoveredOverlayOpacity);
      }

      return null;
    });
  }
}
