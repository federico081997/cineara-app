import 'package:flutter/material.dart';

import '../tokens/colour.dart';
import 'theme_builder.dart';

/// Standard light theme for Cineara.
///
/// Uses soft neutral surfaces and restrained colour accents so media artwork
/// remains visually dominant.
abstract final class CinearaLightTheme {
  static ThemeData get theme {
    return CinearaThemeBuilder.build(colorScheme: _colorScheme);
  }

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,

    // Primary
    primary: CinearaColours.brand600,
    onPrimary: CinearaColours.neutral0,
    primaryContainer: CinearaColours.brand100,
    onPrimaryContainer: CinearaColours.brand900,

    // Secondary
    secondary: CinearaColours.blue500,
    onSecondary: CinearaColours.neutral900,
    secondaryContainer: CinearaColours.blue100,
    onSecondaryContainer: CinearaColours.blue700,

    // Tertiary
    tertiary: CinearaColours.pink500,
    onTertiary: CinearaColours.neutral900,
    tertiaryContainer: CinearaColours.pink100,
    onTertiaryContainer: CinearaColours.pink700,

    // Error
    error: CinearaColours.red500,
    onError: CinearaColours.neutral900,
    errorContainer: CinearaColours.red100,
    onErrorContainer: CinearaColours.red700,

    // Surfaces
    surface: CinearaColours.neutral0,
    onSurface: CinearaColours.neutral900,
    onSurfaceVariant: CinearaColours.neutral600,

    surfaceDim: CinearaColours.neutral200,
    surfaceBright: CinearaColours.neutral0,

    surfaceContainerLowest: CinearaColours.neutral0,
    surfaceContainerLow: CinearaColours.neutral50,
    surfaceContainer: CinearaColours.neutral100,
    surfaceContainerHigh: CinearaColours.neutral200,
    surfaceContainerHighest: CinearaColours.neutral300,

    // Borders
    outline: CinearaColours.neutral500,
    outlineVariant: CinearaColours.neutral200,

    // Inverse
    inverseSurface: CinearaColours.neutral900,
    onInverseSurface: CinearaColours.neutral50,
    inversePrimary: CinearaColours.brand300,

    // Miscellaneous
    shadow: CinearaColours.neutral950,
    scrim: CinearaColours.neutral950,
    surfaceTint: Colors.transparent,
  );
}
