import 'package:flutter/material.dart';

import '../tokens/colour.dart';
import 'theme_builder.dart';

/// Cool Polar theme for Cineara.
///
/// Uses icy cyan surfaces, cool blue accents, and subtle violet details while
/// keeping the interface clean and allowing media artwork to remain visually
/// dominant.
///
/// Polar is intentionally a light theme.
abstract final class CinearaPolarTheme {
  /// Standard Polar theme.
  static ThemeData get theme {
    return CinearaThemeBuilder.build(colorScheme: _colorScheme);
  }

  /// High-contrast Polar theme.
  static ThemeData get highContrastTheme {
    return CinearaThemeBuilder.build(
      colorScheme: _highContrastColorScheme,
      highContrast: true,
    );
  }

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,

    // Primary — muted polar cyan
    primary: CinearaColours.cyan500,
    onPrimary: CinearaColours.neutral900,
    primaryContainer: CinearaColours.cyan100,
    onPrimaryContainer: CinearaColours.neutral900,

    // Secondary — cool blue
    secondary: CinearaColours.blue500,
    onSecondary: CinearaColours.neutral900,
    secondaryContainer: CinearaColours.blue100,
    onSecondaryContainer: CinearaColours.blue700,

    // Tertiary — subtle violet
    tertiary: CinearaColours.brand600,
    onTertiary: CinearaColours.neutral0,
    tertiaryContainer: CinearaColours.brand100,
    onTertiaryContainer: CinearaColours.brand800,

    // Error
    error: CinearaColours.red500,
    onError: CinearaColours.neutral900,
    errorContainer: CinearaColours.red100,
    onErrorContainer: CinearaColours.red700,

    // Surfaces
    surface: CinearaColours.neutral0,
    onSurface: CinearaColours.neutral900,
    onSurfaceVariant: CinearaColours.neutral600,

    surfaceDim: CinearaColours.cyan100,
    surfaceBright: CinearaColours.neutral0,

    surfaceContainerLowest: CinearaColours.neutral0,
    surfaceContainerLow: CinearaColours.cyan50,
    surfaceContainer: CinearaColours.neutral50,
    surfaceContainerHigh: CinearaColours.cyan100,
    surfaceContainerHighest: CinearaColours.neutral200,

    // Borders
    outline: CinearaColours.neutral500,
    outlineVariant: CinearaColours.neutral200,

    // Inverse
    inverseSurface: CinearaColours.neutral900,
    onInverseSurface: CinearaColours.neutral50,
    inversePrimary: CinearaColours.cyan300,

    // Miscellaneous
    shadow: CinearaColours.neutral950,
    scrim: CinearaColours.neutral950,
    surfaceTint: Colors.transparent,
  );

  static const ColorScheme _highContrastColorScheme = ColorScheme(
    brightness: Brightness.light,

    // Primary
    primary: CinearaColours.cyan700,
    onPrimary: CinearaColours.neutral0,
    primaryContainer: CinearaColours.cyan100,
    onPrimaryContainer: CinearaColours.neutral950,

    // Secondary
    secondary: CinearaColours.blue700,
    onSecondary: CinearaColours.neutral0,
    secondaryContainer: CinearaColours.blue100,
    onSecondaryContainer: CinearaColours.neutral950,

    // Tertiary
    tertiary: CinearaColours.brand700,
    onTertiary: CinearaColours.neutral0,
    tertiaryContainer: CinearaColours.brand100,
    onTertiaryContainer: CinearaColours.neutral950,

    // Error
    error: CinearaColours.red700,
    onError: CinearaColours.neutral0,
    errorContainer: CinearaColours.red100,
    onErrorContainer: CinearaColours.neutral950,

    // Surfaces
    surface: CinearaColours.neutral0,
    onSurface: CinearaColours.neutral950,
    onSurfaceVariant: CinearaColours.neutral700,

    surfaceDim: CinearaColours.cyan100,
    surfaceBright: CinearaColours.neutral0,

    surfaceContainerLowest: CinearaColours.neutral0,
    surfaceContainerLow: CinearaColours.cyan50,
    surfaceContainer: CinearaColours.neutral50,
    surfaceContainerHigh: CinearaColours.cyan100,
    surfaceContainerHighest: CinearaColours.neutral300,

    // Borders
    outline: CinearaColours.neutral700,
    outlineVariant: CinearaColours.neutral500,

    // Inverse
    inverseSurface: CinearaColours.neutral950,
    onInverseSurface: CinearaColours.neutral0,
    inversePrimary: CinearaColours.cyan300,

    // Miscellaneous
    shadow: CinearaColours.neutral950,
    scrim: CinearaColours.neutral950,
    surfaceTint: Colors.transparent,
  );
}
