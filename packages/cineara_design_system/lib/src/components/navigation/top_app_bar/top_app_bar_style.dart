import 'package:flutter/material.dart';

import 'top_app_bar_metrics.dart';

/// Visual styling for Cineara's top-application-bar controls.
///
/// Every icon action uses the same circular interaction surface so Search,
/// Notifications, and other global actions share identical press feedback.
abstract final class CinearaTopAppBarStyle {
  static const double _disabledForegroundOpacity = 0.38;

  static const double _pressedOverlayOpacity = 0.10;
  static const double _pressedHighContrastOverlayOpacity = 0.18;

  static const double _focusedOverlayOpacity = 0.08;
  static const double _focusedHighContrastOverlayOpacity = 0.14;

  static const double _hoveredOverlayOpacity = 0.055;

  static const double _profilePressedLightOpacity = 0.075;
  static const double _profilePressedDarkOpacity = 0.12;

  /// Shared top-bar icon style.
  ///
  /// A selected action keeps the same surface that appears during press
  /// feedback. This lets an activation transition begin from the exact visual
  /// state the user just touched.
  static ButtonStyle iconAction(BuildContext context, {bool selected = false}) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final double extent = CinearaTopAppBarMetrics.actionExtentFor(context);

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
      backgroundColor: WidgetStatePropertyAll<Color>(
        selected ? _actionHighlightColor(context) : Colors.transparent,
      ),
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

    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);

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

  static Color _actionHighlightColor(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);

    return colors.primary.withValues(
      alpha: highContrast
          ? _pressedHighContrastOverlayOpacity
          : _pressedOverlayOpacity,
    );
  }

  static Color? _iconActionOverlay(
    BuildContext context,
    Set<WidgetState> states,
  ) {
    if (states.contains(WidgetState.disabled)) {
      return null;
    }

    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);

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
