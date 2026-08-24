import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/discover/presentation/discover_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/library/presentation/library_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../shell/app_root_destination.dart';
import '../shell/app_shell.dart';
import 'app_routes.dart';
import 'route_error_page.dart';

/// Creates the root Cineara router.
///
/// It controls only the normal startup destination. Platform deep links may
/// still provide their own initial location.
///
// TODO: Load [startDestination] from the user's persisted settings.
GoRouter createAppRouter({
  AppRootDestination startDestination = AppRootDestination.home,
}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');

  final discoverNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'discover',
  );

  final libraryNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'library');

  final profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.locationFor(startDestination),
    debugLogDiagnostics: kDebugMode,

    routes: <RouteBase>[
      // Redirect the bare application root to the canonical Home location.
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.home,
      ),

      // Persistent root navigation.
      //
      // Each branch owns an independent navigation stack so switching between
      // Home, Discover, Library and Profile does not discard navigation state
      // within the other branches.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CinearaAppShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: homeNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.homeName,
                path: AppRoutes.home,
                builder: (context, state) {
                  return const HomePage();
                },

                // TODO: Add Home-branch routes that should keep the root navigation shell visible.
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: discoverNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.discoverName,
                path: AppRoutes.discover,
                builder: (context, state) {
                  return const DiscoverPage();
                },

                // TODO: Add Discover-branch routes that should keep the root navigation shell visible.
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: libraryNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.libraryName,
                path: AppRoutes.library,
                builder: (context, state) {
                  return const LibraryPage();
                },

                // TODO: Add Library routes such as Calendar, Lists and History.
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: profileNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.profileName,
                path: AppRoutes.profile,
                builder: (context, state) {
                  return const ProfilePage();
                },

                // TODO: Add Profile sub-routes that should keep the root
                // navigation shell visible.
              ),
            ],
          ),
        ],
      ),

      // Global routes shown above the persistent root shell.
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.searchName,
        path: AppRoutes.search,
        builder: (context, state) {
          // TODO: Replace with the real SearchPage.
          return const _SearchPlaceholderPage();
        },
      ),

      // TODO: Add the Notifications route.
      //
      // TODO: Add the Settings route.
      //
      // TODO: Add movie, series, season, episode and person detail routes.
      // Decide individually whether each route should:
      //
      // - live inside a root branch and keep the bottom navigation visible; or
      // - use [rootNavigatorKey] and appear above the root shell.
    ],

    // TODO: Add authentication and onboarding redirects.
    //
    // TODO: Add app-specific deep-link routing rules.
    //
    // TODO: Add notification-target routing.
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

// TODO: Remove when the real SearchPage is implemented.
final class _SearchPlaceholderPage extends StatelessWidget {
  const _SearchPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Search')));
  }
}
