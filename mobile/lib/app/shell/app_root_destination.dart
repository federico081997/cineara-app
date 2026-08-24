import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Primary root destinations of the Cineara application.
///
/// Enum order defines the branch order used by the root router and bottom
/// navigation.
enum AppRootDestination { home, discover, library, profile }

/// Presentation metadata for Cineara root destinations.
extension AppRootDestinationPresentation on AppRootDestination {
  /// Whether this destination displays Cineara branding instead of a title.
  bool get showBrand => this == AppRootDestination.home;

  /// Localized destination label.
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

  /// Creates the design-system representation of this destination.
  CinearaNavigationDestination navigationDestination(AppLocalizations l10n) {
    return CinearaNavigationDestination(
      label: label(l10n),
      icon: icon,
      selectedIcon: selectedIcon,
    );
  }
}
