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
/// The router uses a [StatefulShellRoute] so every primary destination owns an
/// independent navigation stack.
///
/// Normal application routes such as:
///
/// ```text
/// Search
/// Media details
/// Season details
/// Episode details
/// ```
///
/// live inside the active root branch rather than above the shell. This keeps
/// Cineara's bottom navigation visible and preserves each branch's navigation
/// state while moving between Home, Discover, Library, and Profile.
///
/// The root navigator is reserved for routes that genuinely need to appear
/// above the complete application shell, such as future immersive or
/// application-level flows.
///
/// [startDestination] controls Cineara's normal startup destination. Platform
/// deep links may still provide their own initial location.
///
/// TODO: Load [startDestination] from the user's persisted settings.
GoRouter createAppRouter({
  AppRootDestination startDestination = AppRootDestination.home,
}) {
  // ---------------------------------------------------------------------------
  // Navigator keys
  // ---------------------------------------------------------------------------

  /// Navigator above the complete persistent application shell.
  ///
  /// Do not place normal Search or media-detail flows on this navigator.
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Independent navigator for the Home branch.
  final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');

  /// Independent navigator for the Discover branch.
  final discoverNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'discover',
  );

  /// Independent navigator for the Library branch.
  final libraryNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'library');

  /// Independent navigator for the Profile branch.
  final profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

  final initialLocation = AppRoutes.locationFor(startDestination);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    debugLogDiagnostics: kDebugMode,

    routes: <RouteBase>[
      // -----------------------------------------------------------------------
      // Bare application root
      // -----------------------------------------------------------------------

      /// Redirect `/` to the configured startup destination.
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) {
          return initialLocation;
        },
      ),

      // -----------------------------------------------------------------------
      // Persistent root shell
      // -----------------------------------------------------------------------

      /// Persistent root navigation.
      ///
      /// Each branch owns a separate navigator. Navigating deeper inside one
      /// branch therefore does not destroy the route stack of another branch.
      ///
      /// Example:
      ///
      /// ```text
      /// Home:
      /// /home
      /// /home/media/movie/550
      ///
      /// Discover:
      /// /discover
      /// /discover/search
      /// /discover/media/tv/1399/season/2
      ///
      /// Library:
      /// /library
      ///
      /// Profile:
      /// /profile
      /// ```
      ///
      /// Switching tabs preserves those branch stacks.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CinearaAppShell(
            navigationShell: navigationShell,

            // The shell needs the active location so it can distinguish a root
            // destination from a nested route and adjust shell-level chrome
            // accordingly.
            location: state.uri.path,
          );
        },
        branches: <StatefulShellBranch>[
          // -------------------------------------------------------------------
          // Home
          // -------------------------------------------------------------------
          StatefulShellBranch(
            navigatorKey: homeNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.homeName,
                path: AppRoutes.home,
                builder: (context, state) {
                  return const HomePage();
                },
                routes: buildSharedBranchRoutes(
                  destination: AppRootDestination.home,
                ),
              ),
            ],
          ),

          // -------------------------------------------------------------------
          // Discover
          // -------------------------------------------------------------------
          StatefulShellBranch(
            navigatorKey: discoverNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.discoverName,
                path: AppRoutes.discover,
                builder: (context, state) {
                  return const DiscoverPage();
                },
                routes: buildSharedBranchRoutes(
                  destination: AppRootDestination.discover,
                ),
              ),
            ],
          ),

          // -------------------------------------------------------------------
          // Library
          // -------------------------------------------------------------------
          StatefulShellBranch(
            navigatorKey: libraryNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.libraryName,
                path: AppRoutes.library,
                builder: (context, state) {
                  return const LibraryPage();
                },
                routes: buildSharedBranchRoutes(
                  destination: AppRootDestination.library,
                ),
              ),
            ],
          ),

          // -------------------------------------------------------------------
          // Profile
          // -------------------------------------------------------------------
          StatefulShellBranch(
            navigatorKey: profileNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                name: AppRoutes.profileName,
                path: AppRoutes.profile,
                builder: (context, state) {
                  return const ProfilePage();
                },
                routes: buildSharedBranchRoutes(
                  destination: AppRootDestination.profile,
                ),
              ),
            ],
          ),
        ],
      ),

      // -----------------------------------------------------------------------
      // Routes above the application shell
      // -----------------------------------------------------------------------
      //
      // Only genuinely shell-independent or immersive flows should be added
      // here using:
      //
      // parentNavigatorKey: rootNavigatorKey
      //
      // Search, media details, seasons, and episodes intentionally do NOT live
      // here because they should retain Cineara's persistent root navigation.
      //
      // TODO: Add application-level routes here only when their UX requires
      // covering the complete root shell.
      //
      // Examples that may eventually qualify:
      //
      // - authentication;
      // - onboarding;
      // - full-screen media viewer;
      // - full-screen local media player.
    ],

    // -------------------------------------------------------------------------
    // Future router policies
    // -------------------------------------------------------------------------
    //
    // TODO: Add authentication and onboarding redirects.
    //
    // TODO: Add application-specific deep-link routing rules.
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
