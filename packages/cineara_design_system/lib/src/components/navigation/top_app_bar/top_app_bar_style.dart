import 'package:flutter/material.dart';

import 'top_app_bar_metrics.dart';

/// Visual styling for Cineara's top-application-bar controls.
///
/// Colors derive from the active [ColorScheme] so the component automatically
/// follows light, dark, custom and high-contrast Cineara themes.
abstract final class CinearaTopAppBarStyle {
  static const double _disabledForegroundOpacity = 0.38;

  static const double _pressedOverlayOpacity = 0.10;
  static const double _pressedHighContrastOverlayOpacity = 0.18;

  static const double _focusedOverlayOpacity = 0.08;
  static const double _focusedHighContrastOverlayOpacity = 0.14;

  static const double _hoveredOverlayOpacity = 0.055;

  static const double _profilePressedLightOpacity = 0.075;
  static const double _profilePressedDarkOpacity = 0.12;

  /// Returns the shared style for standard top-bar icon actions.
  static ButtonStyle iconAction(BuildContext context, {bool selected = false}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final extent = CinearaTopAppBarMetrics.actionExtentFor(context);

    return IconButton.styleFrom(
      minimumSize: Size.square(extent),
      maximumSize: Size.square(extent),
      padding: EdgeInsets.zero,
      shape: const CircleBorder(),
      backgroundColor: Colors.transparent,
      side: BorderSide.none,
    ).copyWith(
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.onSurface.withValues(alpha: _disabledForegroundOpacity);
        }

        return selected ? colors.primary : colors.onSurface;
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (states) => _iconActionOverlay(context, states),
      ),
    );
  }

  /// Returns the overlay shown inside the profile avatar.
  static Color profileOverlay(
    BuildContext context, {
    required bool pressed,
    required bool hovered,
    required bool focused,
    required bool enabled,
  }) {
    if (!enabled) {
      return Colors.transparent;
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final highContrast = MediaQuery.highContrastOf(context);

    if (pressed) {
      return colors.onSurface.withValues(
        alpha: highContrast
            ? _pressedHighContrastOverlayOpacity
            : theme.brightness == Brightness.dark
            ? _profilePressedDarkOpacity
            : _profilePressedLightOpacity,
      );
    }

    if (focused) {
      return colors.onSurface.withValues(
        alpha: highContrast
            ? _focusedHighContrastOverlayOpacity
            : _focusedOverlayOpacity,
      );
    }

    if (hovered) {
      return colors.onSurface.withValues(alpha: _hoveredOverlayOpacity);
    }

    return Colors.transparent;
  }

  static Color? _iconActionOverlay(
    BuildContext context,
    Set<WidgetState> states,
  ) {
    if (states.contains(WidgetState.disabled)) {
      return null;
    }

    final colors = Theme.of(context).colorScheme;
    final highContrast = MediaQuery.highContrastOf(context);

    if (states.contains(WidgetState.pressed)) {
      return colors.primary.withValues(
        alpha: highContrast
            ? _pressedHighContrastOverlayOpacity
            : _pressedOverlayOpacity,
      );
    }

    if (states.contains(WidgetState.focused)) {
      return colors.primary.withValues(
        alpha: highContrast
            ? _focusedHighContrastOverlayOpacity
            : _focusedOverlayOpacity,
      );
    }

    if (states.contains(WidgetState.hovered)) {
      return colors.primary.withValues(alpha: _hoveredOverlayOpacity);
    }

    return null;
  }
}
