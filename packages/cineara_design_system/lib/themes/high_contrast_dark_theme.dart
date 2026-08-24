import 'package:flutter/material.dart';

import '../tokens/colour.dart';
import 'theme_builder.dart';

/// High-contrast dark theme for Cineara.
///
/// Uses deep neutral surfaces, bright foreground content, and restrained
/// high-contrast accents while preserving Cineara's cinematic appearance.
abstract final class CinearaHighContrastDarkTheme {
  static ThemeData get theme {
    return CinearaThemeBuilder.build(
      colorScheme: _colorScheme,
      highContrast: true,
    );
  }

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.dark,

    // Primary
    primary: CinearaColours.brand200,
    onPrimary: CinearaColours.brand950,
    primaryContainer: CinearaColours.brand800,
    onPrimaryContainer: CinearaColours.brand100,

    // Secondary
    secondary: CinearaColours.blue300,
    onSecondary: CinearaColours.neutral950,
    secondaryContainer: CinearaColours.blue700,
    onSecondaryContainer: CinearaColours.blue100,

    // Tertiary
    tertiary: CinearaColours.pink300,
    onTertiary: CinearaColours.neutral950,
    tertiaryContainer: CinearaColours.pink700,
    onTertiaryContainer: CinearaColours.pink100,

    // Error
    error: CinearaColours.red300,
    onError: CinearaColours.neutral950,
    errorContainer: CinearaColours.red700,
    onErrorContainer: CinearaColours.red100,

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
    inversePrimary: CinearaColours.brand800,

    // Miscellaneous
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Colors.transparent,
  );
}
