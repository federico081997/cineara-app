import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

/// Root application widget for Cineara.
///
/// This widget owns router composition, localization, and application theme
/// selection. Feature-level navigation and motion remain with the router,
/// application shell, and individual feature surfaces.
final class CinearaApp extends StatelessWidget {
  const CinearaApp({
    required this.router,
    this.appTheme = CinearaAppTheme.system,
    this.locale,
    super.key,
  });

  /// Root application router.
  final GoRouter router;

  /// Current application theme preference.
  final CinearaAppTheme appTheme;

  /// Current application locale.
  ///
  /// When null, Flutter resolves the locale from the device settings.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,

      // Routing
      routerConfig: router,
      restorationScopeId: 'cineara_app',

      // Localization
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // Theme
      theme: CinearaAppThemes.lightTheme(appTheme),
      darkTheme: CinearaAppThemes.darkTheme(appTheme),
      highContrastTheme: CinearaAppThemes.highContrastLightTheme(appTheme),
      highContrastDarkTheme: CinearaAppThemes.highContrastDarkTheme(appTheme),
      themeMode: CinearaAppThemes.themeMode(appTheme),
    );
  }
}
