import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../routing/app_routes.dart';
import 'app_root_destination.dart';

/// Persistent application shell for Cineara's primary destinations.
///
/// The shell owns global navigation chrome. Feature pages provide only their
/// page-specific content.
final class CinearaAppShell extends StatelessWidget {
  const CinearaAppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final currentDestination =
        AppRootDestination.values[navigationShell.currentIndex];

    final destinations = [
      for (final destination in AppRootDestination.values)
        destination.navigationDestination(l10n),
    ];

    return Scaffold(
      appBar: _buildTopAppBar(context, l10n, currentDestination),
      body: navigationShell,
      bottomNavigationBar: CinearaNavigationPill(
        destinations: destinations,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          _selectDestination(index);
        },
      ),
    );
  }

  PreferredSizeWidget _buildTopAppBar(
    BuildContext context,
    AppLocalizations l10n,
    AppRootDestination destination,
  ) {
    final actions = <Widget>[
      CinearaTopAppBarIconAction(
        icon: Icons.search_rounded,
        semanticLabel: l10n.topBarSearch,
        onPressed: () {
          context.pushNamed(AppRoutes.searchName);
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
    ];

    if (destination.showBrand) {
      return CinearaTopAppBar(showBrand: true, actions: actions);
    }

    return CinearaTopAppBar(title: destination.label(l10n), actions: actions);
  }

  void _selectDestination(int index) {
    navigationShell.goBranch(
      index,

      // Tapping the active item again returns that branch to its root page.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
