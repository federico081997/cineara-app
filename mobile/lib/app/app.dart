import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

/// Defines main application widget.
final class CinearaApp extends StatelessWidget {
  /// Creates the Cineara root application widget.
  ///
  /// **Parameters:**
  /// - [router] — Router used for application navigation.
  /// - [appTheme] — Theme preference for the application. Defaults to
  ///   [CinearaAppTheme.system].
  /// - [locale] — Locale used by the application. If `null`, the system
  ///   locale is used.
  /// - [key] — Optional widget key used by Flutter to identify this widget.
  const CinearaApp({
    required this.router,
    this.appTheme = CinearaAppTheme.system,
    this.locale,
    super.key,
  });

  // === Instance fields ===

  final GoRouter router;
  final CinearaAppTheme appTheme;
  final Locale? locale;

  // Overrides

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // App title
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
