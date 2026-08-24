import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

final class CinearaApp extends StatelessWidget {
  const CinearaApp({
    required this.router,
    this.appTheme = CinearaAppTheme.system,
    this.locale,
    super.key,
  });

  /// Root application router.
  final GoRouter router;

  /// Current user-selected application theme.
  ///
  /// Defaults to following the operating system light or dark preference.
  final CinearaAppTheme appTheme;

  /// Current user-selected locale.
  ///
  /// When null, Flutter uses the device locale.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
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
