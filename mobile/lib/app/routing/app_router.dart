import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/discover/discover.dart';
import '../../features/home/home.dart';
import '../../features/library/library.dart';
import '../../features/profile/profile.dart';
import '../shell/app_root_destination.dart';
import '../shell/app_shell.dart';
import 'app_branch_routes.dart';
import 'app_routes.dart';
import 'route_error_page.dart';

/// Creates the root Cineara router.
///
/// Every primary destination owns an independent Navigator through
/// [StatefulShellRoute.indexedStack]. Search and normal media-detail flows stay
/// inside the active branch so Cineara's persistent bottom navigation remains
/// visible and branch history is preserved.
///
/// Routes that must cover the complete application shell belong on the root
/// Navigator instead.
GoRouter createAppRouter({
  AppRootDestination startDestination = AppRootDestination.home,
}) {
  final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );

  final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'home',
  );

  final GlobalKey<NavigatorState> discoverNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'discover');

  final GlobalKey<NavigatorState> libraryNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'library');

  final GlobalKey<NavigatorState> profileNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'profile');

  final String initialLocation = AppRoutes.locationFor(startDestination);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    debugLogDiagnostics: kDebugMode,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => initialLocation,
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CinearaAppShell(
            navigationShell: navigationShell,
            location: state.uri.path,
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: homeNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.homeName,
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
                routes: buildSharedBranchRoutes(
                  destination: AppRootDestination.home,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: discoverNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.discoverName,
                path: AppRoutes.discover,
                builder: (context, state) => const DiscoverPage(),
                routes: buildSharedBranchRoutes(
                  destination: AppRootDestination.discover,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: libraryNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.libraryName,
                path: AppRoutes.library,
                builder: (context, state) => const LibraryPage(),
                routes: buildSharedBranchRoutes(
                  destination: AppRootDestination.library,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: profileNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.profileName,
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
                routes: buildSharedBranchRoutes(
                  destination: AppRootDestination.profile,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      return RouteErrorPage(
        error: state.error,
        onGoHome: () {
          context.goNamed(AppRoutes.homeName);
        },
      );
    },
  );
}
