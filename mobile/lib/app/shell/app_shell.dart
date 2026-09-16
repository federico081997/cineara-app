import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../routing/app_routes.dart';
import 'app_root_destination.dart';

/// Persistent application shell for Cineara's primary navigation branches.
///
/// The shell owns application-level chrome shared by Home, Discover, Library,
/// and Profile:
///
/// - the root Cineara top app bar;
/// - the persistent floating bottom navigation.
///
/// Root destinations display the Cineara wordmark:
///
/// ```text
/// /home
/// /discover
/// /library
/// /profile
/// ```
///
/// Nested routes deliberately do not receive the root app bar:
///
/// ```text
/// /discover/search
/// /discover/media/tv/123
/// /discover/media/tv/123/season/1
/// /discover/media/tv/123/season/1/episode/4
/// ```
///
/// Those pages provide their own contextual navigation treatment. Search
/// provides a conventional back control and title, while cinematic detail pages
/// may place controls directly over their artwork.
///
/// The bottom navigation remains visible for normal nested application flows.
final class CinearaAppShell extends StatelessWidget {
  const CinearaAppShell({
    required this.navigationShell,
    required this.location,
    super.key,
  });

  /// Stateful shell containing Cineara's independent root navigation branches.
  final StatefulNavigationShell navigationShell;

  /// Current router path.
  ///
  /// The shell uses this to distinguish an exact root destination from a
  /// deeper route within the active branch.
  final String location;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final currentDestination =
        AppRootDestination.values[navigationShell.currentIndex];

    final destinations = [
      for (final destination in AppRootDestination.values)
        destination.navigationDestination(l10n),
    ];

    final isRootLocation = AppRoutes.isRootLocation(location);

    return Scaffold(
      // Allows page artwork and other cinematic surfaces to continue beneath
      // the floating bottom navigation. Reusable page layouts are responsible
      // for reserving sufficient interactive-content clearance.
      extendBody: true,

      // Only exact root destinations receive Cineara's application-level top
      // bar. Nested routes provide their own contextual navigation UI.
      appBar: isRootLocation
          ? _buildRootTopAppBar(context, l10n, currentDestination)
          : null,

      body: navigationShell,

      bottomNavigationBar: CinearaNavigationPill(
        destinations: destinations,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _selectDestination,
      ),
    );
  }

  /// Builds the common top app bar used by all four root destinations.
  ///
  /// Home, Discover, Library, and Profile intentionally share the same Cineara
  /// branding rather than displaying their destination names in the app bar.
  PreferredSizeWidget _buildRootTopAppBar(
    BuildContext context,
    AppLocalizations l10n,
    AppRootDestination currentDestination,
  ) {
    return CinearaTopAppBar(
      showBrand: true,
      actions: [
        CinearaTopAppBarIconAction(
          icon: Icons.search_rounded,
          semanticLabel: l10n.topBarSearch,
          onPressed: () {
            context.push(AppRoutes.searchFor(currentDestination));
          },
        ),
        CinearaNotificationAppBarAction(
          semanticLabel: l10n.topBarNotifications,
          onPressed: () {
            // TODO: Open notifications.
          },
        ),
        CinearaProfileAppBarAction(
          semanticLabel: l10n.topBarOpenProfileMenu,
          onPressed: () {
            // TODO: Open the profile quick-action menu.
          },

          // TODO: Supply the authenticated user's profile image and initials.
          imageProvider: null,
          fallbackInitials: null,
        ),
      ],
    );
  }

  /// Selects one of Cineara's persistent root navigation branches.
  ///
  /// Selecting another branch restores that branch's existing navigator stack.
  /// Selecting the already-active destination returns that branch to its root.
  void _selectDestination(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
