import 'package:flutter/material.dart';

import '../../../foundations/shapes/cineara_shapes.dart';
import '../../../foundations/tokens/elevation.dart';

/// Visual styling for Cineara's floating bottom navigation.
///
/// The outer navigation surface and active destination use the same navigation
/// corner radius. The indicator is inset without switching to a capsule, so its
/// corners visually match the surrounding pill.
abstract final class CinearaNavigationPillStyle {
  static const double elevation = CinearaElevation.navigation;

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

  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHigh;
  }

  static Color shadowColor(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return colors.shadow.withValues(
      alpha: theme.brightness == Brightness.dark
          ? _shadowDarkOpacity
          : _shadowLightOpacity,
    );
  }

  /// Navigation geometry shared by the outer surface and active indicator.
  static ShapeBorder shape(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);

    return CinearaShapes.navigation(
      side: BorderSide(
        color: highContrast
            ? colors.outline
            : colors.outlineVariant.withValues(alpha: _borderOpacity),
        width: highContrast ? _highContrastBorderWidth : _borderWidth,
      ),
    );
  }

  /// Selection surface using the same navigation radius as [shape].
  static ShapeDecoration indicatorDecoration(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);

    if (highContrast) {
      return ShapeDecoration(
        color: colors.primaryContainer,
        shape: CinearaShapes.navigation(
          side: BorderSide(
            color: colors.primary,
            width: _highContrastBorderWidth,
          ),
        ),
      );
    }

    final double opacity = theme.brightness == Brightness.dark
        ? _indicatorDarkOpacity
        : _indicatorLightOpacity;

    final Color indicatorColor = Color.alphaBlend(
      colors.primary.withValues(alpha: opacity),
      colors.surfaceContainerHighest,
    );

    return ShapeDecoration(
      color: indicatorColor,
      shape: CinearaShapes.navigation(
        side: BorderSide(
          color: colors.primary.withValues(alpha: _indicatorBorderOpacity),
          width: _borderWidth,
        ),
      ),
    );
  }

  static Color iconColor(BuildContext context, {required bool selected}) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return selected ? colors.primary : colors.onSurfaceVariant;
  }

  static WidgetStateProperty<Color?> itemOverlay(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);

    return WidgetStateProperty.resolveWith<Color?>((states) {
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
