import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

/// Presentation data for one item in [CinearaNotificationQuickPanel].
@immutable
class CinearaNotificationQuickItem {
  const CinearaNotificationQuickItem({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.onPressed,
    this.body,
    this.icon = Icons.notifications_none_rounded,
    this.isUnread = false,
  });

  final String id;
  final String title;
  final String? body;
  final String timeLabel;
  final IconData icon;
  final bool isUnread;
  final VoidCallback onPressed;
}

/// Localized copy used by [CinearaNotificationQuickPanel].
///
/// Supply these strings from the application's localization layer. The panel
/// deliberately contains no user-visible English fallback copy.
@immutable
class CinearaNotificationQuickPanelLabels {
  const CinearaNotificationQuickPanelLabels({
    required this.title,
    required this.viewAll,
    required this.markAllRead,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.loadingLabel,
    this.unreadCountFormatter,
  });

  final String title;
  final String viewAll;
  final String markAllRead;
  final String emptyTitle;
  final String emptyMessage;
  final String loadingLabel;

  /// Optional formatter for the compact unread-count badge.
  ///
  /// Use this when the locale requires localized digits or a different compact
  /// representation. When null, Cineara uses `1`–`9` and `9+`.
  final String Function(int count)? unreadCountFormatter;
}

/// Accessibility/environment data captured from the invoking subtree.
///
/// Routes opened by Flutter are inserted into the navigator overlay and may not
/// inherit local preview-level [MediaQuery] or [Directionality] overrides.
/// Capturing only accessibility fields avoids freezing keyboard/view-inset data.
@immutable
class _NotificationCallerEnvironment {
  const _NotificationCallerEnvironment({
    required this.mediaQuery,
    required this.textDirection,
  });

  final MediaQueryData mediaQuery;
  final TextDirection textDirection;

  factory _NotificationCallerEnvironment.of(BuildContext context) {
    return _NotificationCallerEnvironment(
      mediaQuery: MediaQuery.of(context),
      textDirection: Directionality.of(context),
    );
  }

  Widget wrap(BuildContext routeContext, Widget child) {
    final MediaQueryData routeMediaQuery = MediaQuery.of(routeContext);

    return Directionality(
      textDirection: textDirection,
      child: MediaQuery(
        data: routeMediaQuery.copyWith(
          textScaler: mediaQuery.textScaler,
          boldText: mediaQuery.boldText,
          highContrast: mediaQuery.highContrast,
          disableAnimations: mediaQuery.disableAnimations,
          accessibleNavigation: mediaQuery.accessibleNavigation,
        ),
        child: child,
      ),
    );
  }
}

/// Opens Cineara's notifications quick panel.
///
/// Compact layouts use the same modal-bottom-sheet language as the profile
/// quick menu. Wider layouts use a restrained floating surface aligned to the
/// logical trailing edge near the root app bar.
///
/// The caller's text scale, accessibility flags and text direction are
/// preserved so the panel behaves correctly in RTL and manual stress previews.
Future<T?> showCinearaNotificationQuickPanel<T>({
  required BuildContext context,
  required CinearaNotificationQuickPanel panel,
}) {
  final ThemeData theme = Theme.of(context);
  final ColorScheme colors = theme.colorScheme;
  final MediaQueryData mediaQuery = MediaQuery.of(context);
  final Size screenSize = mediaQuery.size;
  final bool compact = screenSize.width < 600;
  final _NotificationCallerEnvironment environment =
      _NotificationCallerEnvironment.of(context);

  final double textScale = (mediaQuery.textScaler.scale(16) / 16)
      .clamp(1.0, 3.0)
      .toDouble();

  if (compact) {
    final BottomSheetThemeData sheetTheme = theme.bottomSheetTheme;

    return showModalBottomSheet<T>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor:
          sheetTheme.modalBackgroundColor ??
          sheetTheme.backgroundColor ??
          colors.surface,
      elevation: sheetTheme.modalElevation ?? sheetTheme.elevation ?? 8,
      shape:
          sheetTheme.shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(CinearaRadii.xl),
            ),
          ),
      clipBehavior: Clip.antiAlias,
      constraints: BoxConstraints(
        maxWidth: 640,
        maxHeight: screenSize.height * (textScale >= 1.5 ? 0.92 : 0.86),
      ),
      builder: (BuildContext sheetContext) {
        return environment.wrap(sheetContext, panel);
      },
    );
  }

  final double horizontalMargin = CinearaSpacing.md * 2;
  final double availableWidth = screenSize.width - horizontalMargin;
  final double preferredWidth = textScale >= 1.5 ? 480 : 400;
  final double panelWidth = preferredWidth
      .clamp(360.0, availableWidth)
      .toDouble();

  return showDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierColor: colors.scrim.withValues(alpha: 0.18),
    builder: (BuildContext dialogContext) {
      return environment.wrap(
        dialogContext,
        SafeArea(
          child: Align(
            alignment: AlignmentDirectional.topEnd,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 58,
                end: CinearaSpacing.md,
                start: CinearaSpacing.md,
                bottom: CinearaSpacing.md,
              ),
              child: Material(
                color: colors.surface,
                elevation: 8,
                shadowColor: colors.shadow.withValues(alpha: 0.28),
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CinearaRadii.lg),
                  side: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.78),
                    width: 0.8,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: panelWidth,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight:
                          screenSize.height * (textScale >= 1.5 ? 0.82 : 0.72),
                    ),
                    child: panel,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Quick notifications surface shown from Cineara's root app bar.
///
/// The panel provides a lightweight summary of recent notifications rather than
/// replacing the full Notifications page. It is intended for quick inspection
/// and common actions directly from the global navigation shell.
///
/// Unread notifications receive a restrained branded treatment and a compact
/// unread indicator, while read notifications remain visually neutral.
///
/// The component is designed to remain usable across different screen sizes,
/// locales and accessibility settings:
///
/// - long localized header actions may move onto a second row;
/// - notification text receives additional lines at larger text scales;
/// - notification content scrolls when the available height is constrained;
/// - directional spacing and alignment are used throughout for RTL support;
/// - directional Material icons mirror automatically with [Directionality].
///
/// The widget owns presentation only. Notification loading, persistence,
/// read-state changes and navigation are supplied by the application through
/// the provided data and callbacks.
class CinearaNotificationQuickPanel extends StatelessWidget {
  const CinearaNotificationQuickPanel({
    required this.labels,
    required this.items,
    required this.onViewAll,
    super.key,
    this.onMarkAllRead,
    this.isLoading = false,
    this.maxVisibleItems = 5,
    this.dismissOnItemPressed = true,
    this.dismissOnViewAll = true,
  }) : assert(maxVisibleItems > 0);

  /// Localized user-facing labels used throughout the panel.
  ///
  /// This includes the panel title, empty/loading copy and action labels.
  final CinearaNotificationQuickPanelLabels labels;

  /// Notifications available to the quick panel.
  ///
  /// Only the first [maxVisibleItems] entries are displayed, so callers should
  /// normally provide these in descending relevance or recency order.
  final List<CinearaNotificationQuickItem> items;

  /// Called when the user chooses to open the full Notifications page.
  final VoidCallback onViewAll;

  /// Called when the user requests that all unread notifications be marked read.
  ///
  /// When null, or when there are no unread items, the "mark all read" action
  /// is not shown.
  final VoidCallback? onMarkAllRead;

  /// Whether the panel should display its loading state instead of notifications.
  ///
  /// Defaults to false.
  final bool isLoading;

  /// Maximum number of notifications displayed in the quick panel.
  ///
  /// Additional items remain available through [onViewAll].
  ///
  /// Defaults to 5 and must be greater than zero.
  final int maxVisibleItems;

  /// Whether selecting a notification should dismiss the containing route or
  /// bottom sheet before invoking that notification's callback.
  ///
  /// Defaults to true. Set this to false for embedded previews or other cases
  /// where the panel is not presented inside a dismissible modal surface.
  final bool dismissOnItemPressed;

  /// Whether selecting the "view all" action should dismiss the containing
  /// route or bottom sheet before invoking [onViewAll].
  ///
  /// Defaults to true.
  final bool dismissOnViewAll;

  int get _unreadCount =>
      items.where((CinearaNotificationQuickItem item) => item.isUnread).length;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List<CinearaNotificationQuickItem> visibleItems = items
        .take(maxVisibleItems)
        .toList(growable: false);

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _NotificationPanelHeader(
            title: labels.title,
            unreadCount: _unreadCount,
            unreadCountFormatter: labels.unreadCountFormatter,
            markAllReadLabel: labels.markAllRead,
            onMarkAllRead: _unreadCount > 0 ? onMarkAllRead : null,
          ),
          Divider(
            height: 1,
            thickness: 0.75,
            color: colors.outlineVariant.withValues(alpha: 0.72),
          ),
          Flexible(
            child: isLoading
                ? _NotificationLoadingState(label: labels.loadingLabel)
                : visibleItems.isEmpty
                ? _NotificationEmptyState(
                    title: labels.emptyTitle,
                    message: labels.emptyMessage,
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      CinearaSpacing.xs,
                      CinearaSpacing.xs,
                      CinearaSpacing.xs,
                      CinearaSpacing.xs,
                    ),
                    itemCount: visibleItems.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 2),
                    itemBuilder: (BuildContext context, int index) {
                      final CinearaNotificationQuickItem item =
                          visibleItems[index];

                      return _NotificationItemTile(
                        item: item,
                        onPressed: () {
                          _runAction(
                            context,
                            item.onPressed,
                            dismiss: dismissOnItemPressed,
                          );
                        },
                      );
                    },
                  ),
          ),
          Divider(
            height: 1,
            thickness: 0.75,
            color: colors.outlineVariant.withValues(alpha: 0.72),
          ),
          _NotificationViewAllButton(
            label: labels.viewAll,
            onPressed: () {
              _runAction(context, onViewAll, dismiss: dismissOnViewAll);
            },
          ),
        ],
      ),
    );
  }

  void _runAction(
    BuildContext context,
    VoidCallback callback, {
    required bool dismiss,
  }) {
    if (!dismiss) {
      callback();
      return;
    }

    Navigator.of(context).pop();
    Future<void>.microtask(callback);
  }
}

class _NotificationPanelHeader extends StatelessWidget {
  const _NotificationPanelHeader({
    required this.title,
    required this.unreadCount,
    required this.unreadCountFormatter,
    required this.markAllReadLabel,
    required this.onMarkAllRead,
  });

  final String title;
  final int unreadCount;
  final String Function(int count)? unreadCountFormatter;
  final String markAllReadLabel;
  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final double textScale = (scaler.scale(16) / 16).clamp(1.0, 3.0).toDouble();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stackAction =
            textScale >= 1.35 || constraints.maxWidth < 380;

        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            CinearaSpacing.md,
            CinearaSpacing.sm,
            CinearaSpacing.sm,
            CinearaSpacing.sm,
          ),
          child: stackAction
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _NotificationHeaderIdentity(
                      title: title,
                      unreadCount: unreadCount,
                      unreadCountFormatter: unreadCountFormatter,
                      allowTwoTitleLines: true,
                    ),
                    if (onMarkAllRead != null) ...<Widget>[
                      const SizedBox(height: CinearaSpacing.xxs),
                      _MarkAllReadButton(
                        label: markAllReadLabel,
                        onPressed: onMarkAllRead!,
                        alignToStart: true,
                      ),
                    ],
                  ],
                )
              : Row(
                  children: <Widget>[
                    Expanded(
                      child: _NotificationHeaderIdentity(
                        title: title,
                        unreadCount: unreadCount,
                        unreadCountFormatter: unreadCountFormatter,
                        allowTwoTitleLines: false,
                      ),
                    ),
                    if (onMarkAllRead != null) ...<Widget>[
                      const SizedBox(width: CinearaSpacing.xs),
                      Flexible(
                        child: _MarkAllReadButton(
                          label: markAllReadLabel,
                          onPressed: onMarkAllRead!,
                          alignToStart: false,
                        ),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class _NotificationHeaderIdentity extends StatelessWidget {
  const _NotificationHeaderIdentity({
    required this.title,
    required this.unreadCount,
    required this.unreadCountFormatter,
    required this.allowTwoTitleLines,
  });

  final String title;
  final int unreadCount;
  final String Function(int count)? unreadCountFormatter;
  final bool allowTwoTitleLines;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Text(
            title,
            maxLines: allowTwoTitleLines ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (unreadCount > 0) ...<Widget>[
          const SizedBox(width: CinearaSpacing.xs),
          _UnreadCountBadge(
            count: unreadCount,
            formatter: unreadCountFormatter,
          ),
        ],
      ],
    );
  }
}

class _MarkAllReadButton extends StatelessWidget {
  const _MarkAllReadButton({
    required this.label,
    required this.onPressed,
    required this.alignToStart,
  });

  final String label;
  final VoidCallback onPressed;
  final bool alignToStart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final Widget button = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.xs,
          vertical: CinearaSpacing.xs,
        ),
        minimumSize: const Size(0, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    if (!alignToStart) {
      return button;
    }

    return Align(alignment: AlignmentDirectional.centerStart, child: button);
  }
}

class _UnreadCountBadge extends StatelessWidget {
  const _UnreadCountBadge({required this.count, required this.formatter});

  final int count;
  final String Function(int count)? formatter;

  String get _defaultLabel => count > 9 ? '9+' : '$count';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final TextScaler scaler = MediaQuery.textScalerOf(context);

    final double scale = (1 + (((scaler.scale(14) / 14) - 1) * 0.18))
        .clamp(1.0, 1.18)
        .toDouble();

    final String label = formatter?.call(count) ?? _defaultLabel;

    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Container(
          constraints: BoxConstraints(
            minWidth: 20 * scale,
            minHeight: 20 * scale,
          ),
          padding: EdgeInsets.symmetric(horizontal: 6 * scale),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(CinearaRadii.pill),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              textScaler: TextScaler.noScaling,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onPrimaryContainer,
                fontSize: 10 * scale,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationItemTile extends StatelessWidget {
  const _NotificationItemTile({required this.item, required this.onPressed});

  final CinearaNotificationQuickItem item;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final TextScaler scaler = MediaQuery.textScalerOf(context);

    final double textScale = (scaler.scale(16) / 16).clamp(1.0, 3.0).toDouble();

    final int titleLines = textScale >= 1.5 ? 3 : 2;
    final int bodyLines = textScale >= 1.5 ? 3 : 2;
    final int timeLines = textScale >= 1.8 ? 2 : 1;

    final double iconScale = (1 + ((textScale - 1) * 0.18))
        .clamp(1.0, 1.16)
        .toDouble();

    final Color background = item.isUnread
        ? Color.alphaBlend(
            colors.primaryContainer.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.13 : 0.20,
            ),
            colors.surface,
          )
        : Colors.transparent;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(CinearaRadii.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(CinearaRadii.md),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed)) {
            return colors.primary.withValues(alpha: 0.075);
          }

          if (states.contains(WidgetState.hovered)) {
            return colors.primary.withValues(alpha: 0.04);
          }

          if (states.contains(WidgetState.focused)) {
            return colors.primary.withValues(alpha: 0.055);
          }

          return null;
        }),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            CinearaSpacing.sm,
            CinearaSpacing.sm,
            CinearaSpacing.sm,
            CinearaSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  item.icon,
                  size: 21 * iconScale,
                  color: item.isUnread
                      ? colors.primary
                      : colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: CinearaSpacing.sm),
              Expanded(
                child: _NotificationItemText(
                  item: item,
                  titleLines: titleLines,
                  bodyLines: bodyLines,
                  timeLines: timeLines,
                ),
              ),
              const SizedBox(width: CinearaSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: item.isUnread
                    ? Container(
                        width: 7 * iconScale,
                        height: 7 * iconScale,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      )
                    : SizedBox(width: 7 * iconScale, height: 7 * iconScale),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationItemText extends StatelessWidget {
  const _NotificationItemText({
    required this.item,
    required this.titleLines,
    required this.bodyLines,
    required this.timeLines,
  });

  final CinearaNotificationQuickItem item;
  final int titleLines;
  final int bodyLines;
  final int timeLines;

  bool get _hasBody => item.body != null && item.body!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          item.title,
          maxLines: titleLines,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: item.isUnread ? FontWeight.w700 : FontWeight.w600,
            height: 1.25,
          ),
        ),
        if (_hasBody) ...<Widget>[
          const SizedBox(height: 3),
          Text(
            item.body!.trim(),
            maxLines: bodyLines,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.30,
            ),
          ),
        ],
        const SizedBox(height: 5),
        Text(
          item.timeLabel,
          maxLines: timeLines,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: theme.textTheme.labelSmall?.copyWith(
            color: item.isUnread
                ? colors.primary.withValues(alpha: 0.92)
                : colors.onSurfaceVariant.withValues(alpha: 0.78),
            fontWeight: item.isUnread ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _NotificationViewAllButton extends StatelessWidget {
  const _NotificationViewAllButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final TextScaler scaler = MediaQuery.textScalerOf(context);

    final double iconScale = (1 + (((scaler.scale(16) / 16) - 1) * 0.18))
        .clamp(1.0, 1.16)
        .toDouble();

    return Padding(
      padding: const EdgeInsets.all(CinearaSpacing.xs),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(CinearaRadii.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.pressed)) {
              return colors.primary.withValues(alpha: 0.075);
            }

            if (states.contains(WidgetState.hovered)) {
              return colors.primary.withValues(alpha: 0.04);
            }

            if (states.contains(WidgetState.focused)) {
              return colors.primary.withValues(alpha: 0.055);
            }

            return null;
          }),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: CinearaSpacing.sm,
                vertical: CinearaSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: CinearaSpacing.xxs),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 19 * iconScale,
                    color: colors.primary,

                    // This Material icon supports matchTextDirection, so the
                    // same icon correctly points to the logical trailing edge.
                    textDirection: Directionality.of(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationEmptyState extends StatelessWidget {
  const _NotificationEmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(CinearaSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.notifications_none_rounded,
            size: 32,
            color: colors.onSurfaceVariant.withValues(alpha: 0.72),
          ),
          const SizedBox(height: CinearaSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: CinearaSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationLoadingState extends StatelessWidget {
  const _NotificationLoadingState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(CinearaSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: CinearaSpacing.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
