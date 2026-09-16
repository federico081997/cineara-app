import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

import '../app/routing/route_error_page.dart';
import '../l10n/app_localizations.dart';

void main() {
  runApp(const RouteErrorPreviewApp());
}

final class RouteErrorPreviewApp extends StatelessWidget {
  const RouteErrorPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appTheme = CinearaAppTheme.system;

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Localization
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // Theme
      theme: CinearaAppThemes.lightTheme(appTheme),
      darkTheme: CinearaAppThemes.darkTheme(appTheme),
      highContrastTheme: CinearaAppThemes.highContrastLightTheme(appTheme),
      highContrastDarkTheme: CinearaAppThemes.highContrastDarkTheme(appTheme),
      themeMode: CinearaAppThemes.themeMode(appTheme),

      // Preview
      home: RouteErrorPage(
        error: Exception(
          'Preview routing error: /movie/123 could not be resolved.',
        ),
        onGoHome: _handleGoHome,
      ),
    );
  }

  static void _handleGoHome() {
    debugPrint('Go home pressed');
  }
}
