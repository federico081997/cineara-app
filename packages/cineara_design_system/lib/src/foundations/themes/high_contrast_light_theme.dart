import 'package:flutter/material.dart';

import '../tokens/colour.dart';
import 'theme_builder.dart';

/// High-contrast light theme for Cineara.
///
/// Preserves Cineara's soft visual identity while increasing separation
/// between text, controls, borders, and surfaces for improved accessibility.
abstract final class CinearaHighContrastLightTheme {
  static ThemeData get theme {
    return CinearaThemeBuilder.build(
      colorScheme: _colorScheme,
      highContrast: true,
    );
  }

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,

    // Primary
    primary: CinearaColours.brand800,
    onPrimary: CinearaColours.neutral0,
    primaryContainer: CinearaColours.brand100,
    onPrimaryContainer: CinearaColours.brand900,

    // Secondary
    secondary: CinearaColours.blue700,
    onSecondary: CinearaColours.neutral0,
    secondaryContainer: CinearaColours.blue100,
    onSecondaryContainer: CinearaColours.blue700,

    // Tertiary
    tertiary: CinearaColours.pink700,
    onTertiary: CinearaColours.neutral0,
    tertiaryContainer: CinearaColours.pink100,
    onTertiaryContainer: CinearaColours.pink700,

    // Error
    error: CinearaColours.red700,
    onError: CinearaColours.neutral0,
    errorContainer: CinearaColours.red100,
    onErrorContainer: CinearaColours.red700,

    // Surfaces
    surface: CinearaColours.neutral0,
    onSurface: CinearaColours.neutral950,
    onSurfaceVariant: CinearaColours.neutral700,

    surfaceDim: CinearaColours.neutral200,
    surfaceBright: CinearaColours.neutral0,

    surfaceContainerLowest: CinearaColours.neutral0,
    surfaceContainerLow: CinearaColours.neutral50,
    surfaceContainer: CinearaColours.neutral100,
    surfaceContainerHigh: CinearaColours.neutral200,
    surfaceContainerHighest: CinearaColours.neutral300,

    // Borders
    outline: CinearaColours.neutral700,
    outlineVariant: CinearaColours.neutral500,

    // Inverse
    inverseSurface: CinearaColours.neutral950,
    onInverseSurface: CinearaColours.neutral0,
    inversePrimary: CinearaColours.brand200,

    // Miscellaneous
    shadow: CinearaColours.neutral950,
    scrim: CinearaColours.neutral950,
    surfaceTint: Colors.transparent,
  );
}
