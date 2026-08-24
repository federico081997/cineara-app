import '../shell/app_root_destination.dart';

/// Route locations and names used by Cineara.
abstract final class AppRoutes {
  // Root locations

  static const String root = '/';

  static const String home = '/home';
  static const String discover = '/discover';
  static const String library = '/library';
  static const String profile = '/profile';

  // Root route names

  static const String homeName = 'home';
  static const String discoverName = 'discover';
  static const String libraryName = 'library';
  static const String profileName = 'profile';

  // Global routes

  static const String search = '/search';
  static const String searchName = 'search';

  static String locationFor(AppRootDestination destination) {
    return switch (destination) {
      AppRootDestination.home => home,
      AppRootDestination.discover => discover,
      AppRootDestination.library => library,
      AppRootDestination.profile => profile,
    };
  }

  static String nameFor(AppRootDestination destination) {
    return switch (destination) {
      AppRootDestination.home => homeName,
      AppRootDestination.discover => discoverName,
      AppRootDestination.library => libraryName,
      AppRootDestination.profile => profileName,
    };
  }
}
