import 'package:flutter/material.dart';

import 'top_app_bar_metrics.dart';
import 'top_app_bar_style.dart';

/// Standard icon action used in Cineara's top application bar.
///
/// Suitable for global actions such as search, cast, help, sync, or other
/// simple icon-based controls.
///
/// Use a specialized component when an action requires additional
/// presentation, such as a notification badge or profile avatar.
final class CinearaTopAppBarIconAction extends StatelessWidget {
  const CinearaTopAppBarIconAction({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.selectedIcon,
    this.isSelected = false,
    super.key,
  });

  /// Default action icon.
  final IconData icon;

  /// Optional icon displayed when [isSelected] is true.
  final IconData? selectedIcon;

  /// Localized tooltip and accessibility label.
  final String semanticLabel;

  /// Whether the action is currently selected.
  final bool isSelected;

  /// Called when the action is activated.
  ///
  /// When null, the action is disabled.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: semanticLabel,
      onPressed: onPressed,
      iconSize: CinearaTopAppBarMetrics.actionIconSizeFor(context),
      style: CinearaTopAppBarStyle.iconAction(context, selected: isSelected),
      icon: Icon(isSelected ? selectedIcon ?? icon : icon),
    );
  }
}
