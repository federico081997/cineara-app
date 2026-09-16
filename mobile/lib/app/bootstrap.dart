import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'routing/app_router.dart';
import 'shell/app_root_destination.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Validate build and runtime configuration.
  AppConfig.fromEnvironment();

  // TODO: Initialize logging.
  //
  // TODO: Initialize crash reporting.
  //
  // TODO: Initialize local storage.
  //
  // TODO: Create API clients and repositories from AppConfig.
  //
  // TODO: Load persisted user settings before creating the router.

  // Temporary defaults until persisted user settings are implemented.
  const startDestination = AppRootDestination.home;
  const appTheme = CinearaAppTheme.system;
  const Locale? locale = null;

  final router = createAppRouter(startDestination: startDestination);

  runApp(CinearaApp(router: router, appTheme: appTheme, locale: locale));
}
