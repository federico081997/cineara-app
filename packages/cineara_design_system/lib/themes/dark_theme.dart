import 'package:flutter/material.dart';

import '../tokens/colour.dart';
import 'theme_builder.dart';

/// Standard dark theme for Cineara.
///
/// Uses soft midnight-charcoal surfaces rather than pure black, with restrained
/// colour accents reserved for interaction and semantic meaning.
abstract final class CinearaDarkTheme {
  static ThemeData get theme {
    return CinearaThemeBuilder.build(colorScheme: _colorScheme);
  }

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.dark,

    // Primary
    primary: CinearaColours.brand300,
    onPrimary: CinearaColours.brand950,
    primaryContainer: CinearaColours.brand800,
    onPrimaryContainer: CinearaColours.brand100,

    // Secondary
    secondary: CinearaColours.blue300,
    onSecondary: CinearaColours.neutral900,
    secondaryContainer: CinearaColours.blue700,
    onSecondaryContainer: CinearaColours.blue100,

    // Tertiary
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
    inversePrimary: CinearaColours.brand700,

    // Miscellaneous
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Colors.transparent,
  );
}
