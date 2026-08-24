import 'package:flutter/material.dart';

import '../tokens/colour.dart';
import 'theme_builder.dart';

/// Dark Aurora theme for Cineara.
///
/// Uses deep midnight surfaces with cool cyan, violet, and rose accents,
/// inspired by the colours of the aurora while keeping media artwork visually
/// dominant.
///
/// Aurora is intentionally a dark theme.
abstract final class CinearaAuroraTheme {
  /// Standard Aurora theme.
  static ThemeData get theme {
    return CinearaThemeBuilder.build(colorScheme: _colorScheme);
  }

  /// High-contrast Aurora theme.
  static ThemeData get highContrastTheme {
    return CinearaThemeBuilder.build(
      colorScheme: _highContrastColorScheme,
      highContrast: true,
    );
  }

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.dark,

    // Primary — icy aurora cyan
    primary: CinearaColours.cyan300,
    onPrimary: CinearaColours.neutral900,
    primaryContainer: CinearaColours.cyan700,
    onPrimaryContainer: CinearaColours.cyan100,

    // Secondary — Cineara violet
    secondary: CinearaColours.brand300,
    onSecondary: CinearaColours.brand950,
    secondaryContainer: CinearaColours.brand800,
    onSecondaryContainer: CinearaColours.brand100,

    // Tertiary — aurora rose
    tertiary: CinearaColours.pink300,
    onTertiary: CinearaColours.neutral900,
    tertiaryContainer: CinearaColours.pink700,
    onTertiaryContainer: CinearaColours.pink100,

    // Error
    error: CinearaColours.red300,
    onError: CinearaColours.neutral900,
    errorContainer: CinearaColours.red700,
    onErrorContainer: CinearaColours.red100,

    // Surfaces
    surface: CinearaColours.neutral925,
    onSurface: CinearaColours.neutral50,
    onSurfaceVariant: CinearaColours.neutral300,

    surfaceDim: CinearaColours.neutral950,
    surfaceBright: CinearaColours.neutral800,

    surfaceContainerLowest: CinearaColours.neutral950,
    surfaceContainerLow: CinearaColours.neutral925,
    surfaceContainer: CinearaColours.neutral900,
    surfaceContainerHigh: CinearaColours.neutral850,
    surfaceContainerHighest: CinearaColours.neutral800,

    // Borders
    outline: CinearaColours.neutral500,
    outlineVariant: CinearaColours.neutral700,

    // Inverse
    inverseSurface: CinearaColours.neutral50,
    onInverseSurface: CinearaColours.neutral900,
    inversePrimary: CinearaColours.cyan700,

    // Miscellaneous
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Colors.transparent,
  );

  static const ColorScheme _highContrastColorScheme = ColorScheme(
    brightness: Brightness.dark,

    // Primary
    primary: CinearaColours.cyan100,
    onPrimary: CinearaColours.neutral950,
    primaryContainer: CinearaColours.cyan700,
    onPrimaryContainer: CinearaColours.neutral0,

    // Secondary
    secondary: CinearaColours.brand200,
    onSecondary: CinearaColours.brand950,
    secondaryContainer: CinearaColours.brand800,
    onSecondaryContainer: CinearaColours.neutral0,

    // Tertiary
    tertiary: CinearaColours.pink300,
    onTertiary: CinearaColours.neutral950,
    tertiaryContainer: CinearaColours.pink700,
    onTertiaryContainer: CinearaColours.neutral0,

    // Error
    error: CinearaColours.red300,
    onError: CinearaColours.neutral950,
    errorContainer: CinearaColours.red700,
    onErrorContainer: CinearaColours.neutral0,

    // Surfaces
    surface: CinearaColours.neutral950,
    onSurface: CinearaColours.neutral0,
    onSurfaceVariant: CinearaColours.neutral300,

    surfaceDim: CinearaColours.neutral950,
    surfaceBright: CinearaColours.neutral700,

    surfaceContainerLowest: CinearaColours.neutral950,
    surfaceContainerLow: CinearaColours.neutral925,
    surfaceContainer: CinearaColours.neutral900,
    surfaceContainerHigh: CinearaColours.neutral800,
    surfaceContainerHighest: CinearaColours.neutral700,

    // Borders
    outline: CinearaColours.neutral400,
    outlineVariant: CinearaColours.neutral500,

    // Inverse
    inverseSurface: CinearaColours.neutral0,
    onInverseSurface: CinearaColours.neutral950,
    inversePrimary: CinearaColours.cyan700,

    // Miscellaneous
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Colors.transparent,
  );
}
