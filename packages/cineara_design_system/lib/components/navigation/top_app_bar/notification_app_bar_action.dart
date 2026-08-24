import 'package:flutter/material.dart';

import '../../feedback/count_badge.dart';
import 'top_app_bar_icon_action.dart';
import 'top_app_bar_metrics.dart';

/// Notification action used in Cineara's top application bar.
///
/// The visible badge is presentation-only. The application remains
/// responsible for deriving and localizing unread-count meaning.
///
/// Include the badge meaning in [semanticLabel], for example:
///
/// ```dart
/// semanticLabel: l10n.notificationsWithUnread(3),
/// badgeLabel: '3',
/// ```
final class CinearaNotificationAppBarAction extends StatelessWidget {
  const CinearaNotificationAppBarAction({
    required this.semanticLabel,
    required this.onPressed,
    this.icon = Icons.notifications_none_rounded,
    this.badgeLabel,
    super.key,
  });

  /// Notification icon.
  final IconData icon;

  /// Localized tooltip and accessibility label.
  ///
  /// Include unread-count meaning when [badgeLabel] is displayed.
  final String semanticLabel;

  /// Optional compact visible unread label such as `3` or `9+`.
  final String? badgeLabel;

  /// Opens notifications.
  ///
  /// When null, the action is disabled.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final normalizedBadge = badgeLabel?.trim();

    final hasBadge = normalizedBadge != null && normalizedBadge.isNotEmpty;

    final extent = CinearaTopAppBarMetrics.actionExtentFor(context);

    return SizedBox.square(
      dimension: extent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CinearaTopAppBarIconAction(
              icon: icon,
              semanticLabel: semanticLabel,
              onPressed: onPressed,
            ),
          ),
          if (hasBadge)
            PositionedDirectional(
              top: CinearaTopAppBarMetrics.notificationBadgeTopFor(context),
              end: CinearaTopAppBarMetrics.notificationBadgeEndFor(context),
              child: IgnorePointer(
                child: CinearaCountBadge(
                  label: normalizedBadge,
                  scale: CinearaTopAppBarMetrics.badgeScale(context),
                  outlineColor:
                      Theme.of(context).appBarTheme.backgroundColor ??
                      Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
