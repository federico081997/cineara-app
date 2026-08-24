import 'package:flutter/material.dart';

import 'aurora_theme.dart';
import 'dark_theme.dart';
import 'high_contrast_dark_theme.dart';
import 'high_contrast_light_theme.dart';
import 'light_theme.dart';
import 'polar_theme.dart';
import 'sunrise_theme.dart';

enum CinearaAppTheme { system, light, dark, sunrise, polar, aurora }

abstract final class CinearaAppThemes {
  static ThemeMode themeMode(CinearaAppTheme theme) {
    return switch (theme) {
      CinearaAppTheme.system => ThemeMode.system,
      CinearaAppTheme.light => ThemeMode.light,
      CinearaAppTheme.dark => ThemeMode.dark,

      CinearaAppTheme.sunrise => ThemeMode.light,
      CinearaAppTheme.polar => ThemeMode.light,
      CinearaAppTheme.aurora => ThemeMode.light,
    };
  }

  static ThemeData lightTheme(CinearaAppTheme theme) {
    return switch (theme) {
      CinearaAppTheme.system ||
      CinearaAppTheme.light ||
      CinearaAppTheme.dark => CinearaLightTheme.theme,

      CinearaAppTheme.sunrise => CinearaSunriseTheme.theme,
      CinearaAppTheme.polar => CinearaPolarTheme.theme,
      CinearaAppTheme.aurora => CinearaAuroraTheme.theme,
    };
  }

  static ThemeData darkTheme(CinearaAppTheme theme) {
    return switch (theme) {
      CinearaAppTheme.system ||
      CinearaAppTheme.light ||
      CinearaAppTheme.dark => CinearaDarkTheme.theme,

      CinearaAppTheme.sunrise => CinearaSunriseTheme.theme,
      CinearaAppTheme.polar => CinearaPolarTheme.theme,
      CinearaAppTheme.aurora => CinearaAuroraTheme.theme,
    };
  }

  static ThemeData highContrastLightTheme(CinearaAppTheme theme) {
    return switch (theme) {
      CinearaAppTheme.system ||
      CinearaAppTheme.light ||
      CinearaAppTheme.dark => CinearaHighContrastLightTheme.theme,

      CinearaAppTheme.sunrise => CinearaSunriseTheme.highContrastTheme,
      CinearaAppTheme.polar => CinearaPolarTheme.highContrastTheme,
      CinearaAppTheme.aurora => CinearaAuroraTheme.highContrastTheme,
    };
  }

  static ThemeData highContrastDarkTheme(CinearaAppTheme theme) {
    return switch (theme) {
      CinearaAppTheme.system ||
      CinearaAppTheme.light ||
      CinearaAppTheme.dark => CinearaHighContrastDarkTheme.theme,

      CinearaAppTheme.sunrise => CinearaSunriseTheme.highContrastTheme,
      CinearaAppTheme.polar => CinearaPolarTheme.highContrastTheme,
      CinearaAppTheme.aurora => CinearaAuroraTheme.highContrastTheme,
    };
  }
}
