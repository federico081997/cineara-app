import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Primary root destinations of the Cineara application.
///
/// Enum order defines the branch order used by the root router and bottom
/// navigation.
///
/// Root destinations share the same application-level visual identity:
/// Cineara branding remains in the top app bar while the destination itself is
/// communicated by the selected navigation item and the page content.
///
/// Contextual titles belong to secondary routes such as Search, Settings,
/// media details, seasons, and episodes rather than these root destinations.
enum AppRootDestination { home, discover, library, profile }

/// Presentation metadata for Cineara root destinations.
extension AppRootDestinationPresentation on AppRootDestination {
  /// Whether this destination displays Cineara branding in the root app bar.
  ///
  /// All primary root destinations retain the Cineara wordmark. This keeps the
  /// top app bar visually stable while switching between navigation branches.
  ///
  /// Secondary and cinematic routes decide their own app-bar treatment and do
  /// not derive that behaviour from this enum.
  bool get showBrand => true;

  /// Localized destination label.
  ///
  /// Although root pages display Cineara branding rather than this label in
  /// the app bar, the label remains important for navigation semantics,
  /// tooltips, and other contextual UI.
  String label(AppLocalizations l10n) {
    return switch (this) {
      AppRootDestination.home => l10n.navigationHome,
      AppRootDestination.discover => l10n.navigationDiscover,
      AppRootDestination.library => l10n.navigationLibrary,
      AppRootDestination.profile => l10n.navigationProfile,
    };
  }

  /// Icon displayed while this destination is inactive.
  IconData get icon {
    return switch (this) {
      AppRootDestination.home => Icons.home_outlined,
      AppRootDestination.discover => Icons.explore_outlined,
      AppRootDestination.library => Icons.video_library_outlined,
      AppRootDestination.profile => Icons.person_outline_rounded,
    };
  }

  /// Icon displayed while this destination is active.
  IconData get selectedIcon {
    return switch (this) {
      AppRootDestination.home => Icons.home_rounded,
      AppRootDestination.discover => Icons.explore_rounded,
      AppRootDestination.library => Icons.video_library_rounded,
      AppRootDestination.profile => Icons.person_rounded,
    };
  }

  /// Creates the design-system representation of this root destination.
  CinearaNavigationDestination navigationDestination(AppLocalizations l10n) {
    return CinearaNavigationDestination(
      label: label(l10n),
      icon: icon,
      selectedIcon: selectedIcon,
    );
  }
}
