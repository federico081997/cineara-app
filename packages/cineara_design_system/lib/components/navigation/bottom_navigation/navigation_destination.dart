import 'package:flutter/widgets.dart';

/// Presentation data for one Cineara bottom-navigation destination.
///
/// Labels and semantic labels must already be localized by the application.
///
/// Routing information deliberately does not belong in this model.
final class CinearaNavigationDestination {
  const CinearaNavigationDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.semanticLabel,
  });

  /// Localized destination label.
  ///
  /// The bottom navigation is visually icon-only, but this label remains
  /// available to accessibility services and tooltips.
  final String label;

  /// Icon displayed while the destination is inactive.
  final IconData icon;

  /// Optional icon displayed while the destination is active.
  ///
  /// When null, [icon] is used in both states.
  final IconData? selectedIcon;

  /// Optional localized accessibility label.
  ///
  /// When null or empty, [label] is used.
  final String? semanticLabel;

  /// Icon displayed while the destination is active.
  IconData get effectiveSelectedIcon => selectedIcon ?? icon;

  /// Accessibility label exposed by the navigation item.
  String get effectiveSemanticLabel {
    final normalized = semanticLabel?.trim();

    if (normalized == null || normalized.isEmpty) {
      return label;
    }

    return normalized;
  }
}
