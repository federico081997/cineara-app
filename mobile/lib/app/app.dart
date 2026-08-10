import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

import '../features/theme_preview/theme_preview_screen.dart';
import '../l10n/app_localizations.dart';

class CinearaApp extends StatelessWidget {
  const CinearaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cineara',
      debugShowCheckedModeBanner: false,

      // Force Italian while testing localization.
      locale: const Locale('it'),

      // Localization generated from the ARB files in lib/l10n.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      theme: CinearaLightTheme.theme,
      darkTheme: CinearaDarkTheme.theme,

      // Temporary while designing the dark theme.
      themeMode: ThemeMode.dark,

      home: const PosterMediaCardPreviewScreen(),
    );
  }
}
