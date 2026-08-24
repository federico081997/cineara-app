import 'package:flutter/material.dart';

import '../../../tokens/radius.dart';

/// Visual styling for Cineara's bottom-navigation pill.
///
/// Colors derive from the active [ColorScheme] so the component automatically
/// follows Cineara's light, dark, custom, and high-contrast themes.
abstract final class CinearaNavigationPillStyle {
  /// Elevation of the floating navigation surface.
  static const double elevation = 6;

  static const double _borderWidth = 1;
  static const double _highContrastBorderWidth = 2;

  static const double _borderOpacity = 0.40;

  static const double _shadowLightOpacity = 0.12;
  static const double _shadowDarkOpacity = 0.28;

  static const double _indicatorLightOpacity = 0.14;
  static const double _indicatorDarkOpacity = 0.22;

  static const double _indicatorBorderOpacity = 0.18;

  static const double _pressedOverlayOpacity = 0.07;
  static const double _focusedOverlayOpacity = 0.08;
  static const double _hoveredOverlayOpacity = 0.045;

  /// Surface color of the floating navigation pill.
  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHigh;
  }

  /// Shadow color of the floating navigation pill.
  static Color shadowColor(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return colors.shadow.withValues(
      alpha: theme.brightness == Brightness.dark
          ? _shadowDarkOpacity
          : _shadowLightOpacity,
    );
  }

  /// Shape and border of the outer navigation pill.
  static ShapeBorder shape(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final highContrast = MediaQuery.highContrastOf(context);

    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(CinearaRadii.pill),
      side: BorderSide(
        color: highContrast
            ? colors.outline
            : colors.outlineVariant.withValues(alpha: _borderOpacity),
        width: highContrast ? _highContrastBorderWidth : _borderWidth,
      ),
    );
  }

  /// Decoration of the moving active-destination capsule.
  static BoxDecoration indicatorDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final highContrast = MediaQuery.highContrastOf(context);

    if (highContrast) {
      return BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(CinearaRadii.pill),
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
      borderRadius: BorderRadius.circular(CinearaRadii.pill),
      border: Border.all(
        color: colors.primary.withValues(alpha: _indicatorBorderOpacity),
      ),
    );
  }

  /// Foreground color of a navigation icon.
  static Color iconColor(BuildContext context, {required bool selected}) {
    final colors = Theme.of(context).colorScheme;

    return selected ? colors.primary : colors.onSurfaceVariant;
  }

  /// Material interaction overlay for one navigation destination.
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
