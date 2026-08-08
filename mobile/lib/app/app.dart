import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

import '../features/theme_preview/theme_preview_screen.dart';

class CinearaApp extends StatelessWidget {
  const CinearaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cineara',
      debugShowCheckedModeBanner: false,
      theme: CinearaLightTheme.theme,
      darkTheme: CinearaDarkTheme.theme,

      // Temporary while designing the dark theme.
      themeMode: ThemeMode.light,

      home: const ThemePreviewScreen(),
    );
  }
}
