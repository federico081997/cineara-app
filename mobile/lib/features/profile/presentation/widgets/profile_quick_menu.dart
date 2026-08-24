import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

/// Localized labels used by [ProfileQuickMenu].
///
/// The profile identity strings ([ProfileQuickMenu.displayName],
/// [ProfileQuickMenu.subtitle], [ProfileQuickMenu.rankLabel],
/// [ProfileQuickMenu.xpProgressLabel] and
/// [ProfileQuickMenu.xpRemainingLabel]) are supplied separately because they
/// normally contain user/domain data.
@immutable
class ProfileQuickMenuLabels {
  const ProfileQuickMenuLabels({
    required this.viewProfile,
    required this.statistics,
    required this.achievements,
    required this.cinemaPassport,
    required this.settings,
  });

  final String viewProfile;
  final String statistics;
  final String achievements;
  final String cinemaPassport;
  final String settings;
}

/// Opens Cineara's profile quick menu as a modal bottom sheet.
///
/// This helper deliberately uses the active [BottomSheetThemeData], so the
/// presentation follows Cineara's professional light/dark themes without
/// duplicating colour decisions in the profile feature.
///
/// On compact phones the sheet naturally uses the available width. On wider
/// layouts it is capped so it does not become an oversized full-width panel.
///
/// Example:
///
/// ```dart
/// await showProfileQuickMenu(
///   context: context,
///   menu: ProfileQuickMenu(
///     displayName: user.displayName,
///     subtitle: labels.cinearaExplorer,
///     rankLabel: labels.rank(user.rank),
///     progress: user.rankProgress,
///     xpProgressLabel: labels.xpProgress(
///       user.currentXp,
///       user.nextRankXp,
///     ),
///     xpRemainingLabel: labels.xpToNextRank(
///       user.xpRemaining,
///       user.rank + 1,
///     ),
///     imageProvider: user.photoUrl == null
///         ? null
///         : NetworkImage(user.photoUrl!),
///     fallbackInitials: user.initials,
///     labels: ProfileQuickMenuLabels(
///       viewProfile: labels.viewProfile,
///       statistics: labels.statistics,
///       achievements: labels.achievements,
///       cinemaPassport: labels.cinemaPassport,
///       settings: labels.settings,
///     ),
///     onViewProfile: openProfile,
///     onStatistics: openStatistics,
///     onAchievements: openAchievements,
///     onCinemaPassport: openCinemaPassport,
///     onSettings: openSettings,
///   ),
/// );
/// ```
Future<T?> showProfileQuickMenu<T>({
  required BuildContext context,
  required ProfileQuickMenu menu,
}) {
  final ThemeData theme = Theme.of(context);
  final BottomSheetThemeData sheetTheme = theme.bottomSheetTheme;

  final MediaQueryData sourceMediaQuery = MediaQuery.of(context);
  final TextDirection sourceTextDirection = Directionality.of(context);

  final Size screenSize = sourceMediaQuery.size;

  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    enableDrag: true,
    showDragHandle: true,
    backgroundColor:
        sheetTheme.modalBackgroundColor ??
        sheetTheme.backgroundColor ??
        theme.colorScheme.surface,
    elevation: sheetTheme.modalElevation ?? sheetTheme.elevation ?? 8,
    shape:
        sheetTheme.shape ??
        RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(CinearaRadii.xl),
          ),
        ),
    clipBehavior: Clip.antiAlias,
    constraints: BoxConstraints(
      maxWidth: 640,
      maxHeight: screenSize.height * 0.90,
    ),
    builder: (BuildContext sheetContext) {
      final MediaQueryData sheetMediaQuery = MediaQuery.of(sheetContext);

      return Directionality(
        textDirection: sourceTextDirection,
        child: MediaQuery(
          data: sheetMediaQuery.copyWith(
            textScaler: sourceMediaQuery.textScaler,
            boldText: sourceMediaQuery.boldText,
            highContrast: sourceMediaQuery.highContrast,
            disableAnimations: sourceMediaQuery.disableAnimations,
            accessibleNavigation: sourceMediaQuery.accessibleNavigation,
          ),
          child: menu,
        ),
      );
    },
  );
}

/// Cineara's compact profile navigation surface.
///
/// This widget is intentionally a quick menu rather than a second Profile page.
/// It contains:
///
/// - a concise identity/rank summary;
/// - progress toward the next rank;
/// - exactly five high-value shortcuts:
///   View Profile, Statistics, Achievements, Cinema Passport and Settings.
///
/// It deliberately excludes Library, Discover, Watchlist, Calendar, Picker and
/// similar destinations that already have stronger primary navigation paths.
///
/// The component is fully theme-driven:
///
/// - sheet/header surfaces come from [ColorScheme];
/// - primary violet is reserved for rank progress and interaction feedback;
/// - text follows Cineara's semantic typography;
/// - no light/dark branches or hard-coded theme colours are required.
///
/// The content is wrapped in [SingleChildScrollView] so large accessibility text
/// settings and small displays cannot cause vertical overflow.
class ProfileQuickMenu extends StatelessWidget {
  const ProfileQuickMenu({
    required this.displayName,
    required this.rankLabel,
    required this.progress,
    required this.xpProgressLabel,
    required this.labels,
    required this.onViewProfile,
    required this.onStatistics,
    required this.onAchievements,
    required this.onCinemaPassport,
    required this.onSettings,
    super.key,
    this.subtitle,
    this.xpRemainingLabel,
    this.imageProvider,
    this.fallbackInitials,
    this.dismissOnAction = true,
  }) : assert(progress >= 0 && progress <= 1);

  /// User-facing profile name.
  final String displayName;

  /// Optional Cineara identity/title, e.g. `Cineara Explorer`.
  final String? subtitle;

  /// Already-localized rank text, e.g. `Rank 27`.
  final String rankLabel;

  /// Rank progress in the inclusive range 0–1.
  final double progress;

  /// Already-localized XP progress, e.g. `3,420 / 4,000 XP`.
  final String xpProgressLabel;

  /// Optional already-localized next-rank copy,
  /// e.g. `580 XP to Rank 28`.
  ///
  /// This may be null at the maximum rank or when the product does not want to
  /// expose an explicit remaining-XP value.
  final String? xpRemainingLabel;

  /// Optional profile image.
  ///
  /// If loading fails, [fallbackInitials] or a generic person glyph is used.
  final ImageProvider<Object>? imageProvider;

  /// Optional fallback initials such as `FM`.
  final String? fallbackInitials;

  /// Localized shortcut labels.
  final ProfileQuickMenuLabels labels;

  final VoidCallback onViewProfile;
  final VoidCallback onStatistics;
  final VoidCallback onAchievements;
  final VoidCallback onCinemaPassport;
  final VoidCallback onSettings;

  /// Whether selecting an action first closes the containing route/sheet.
  ///
  /// Keep this true in production. Set it to false in embedded component
  /// previews where the menu is not actually hosted in a modal route.
  final bool dismissOnAction;

  bool get _hasSubtitle => subtitle != null && subtitle!.trim().isNotEmpty;

  bool get _hasXpRemaining =>
      xpRemainingLabel != null && xpRemainingLabel!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.fromSTEB(
          CinearaSpacing.md,
          CinearaSpacing.xxs,
          CinearaSpacing.md,
          CinearaSpacing.lg + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ProfileQuickMenuHeader(
              displayName: displayName,
              subtitle: _hasSubtitle ? subtitle!.trim() : null,
              rankLabel: rankLabel,
              progress: progress,
              xpProgressLabel: xpProgressLabel,
              xpRemainingLabel: _hasXpRemaining
                  ? xpRemainingLabel!.trim()
                  : null,
              imageProvider: imageProvider,
              fallbackInitials: fallbackInitials,
            ),
            const SizedBox(height: CinearaSpacing.md),

            Divider(
              color: colors.outlineVariant.withValues(alpha: 0.82),
              height: 1,
              thickness: 1,
            ),

            const SizedBox(height: CinearaSpacing.sm),

            _ProfileQuickMenuActionTile(
              icon: Icons.person_outline_rounded,
              label: labels.viewProfile,
              onPressed: () => _runAction(context, onViewProfile),
            ),
            _ProfileQuickMenuActionTile(
              icon: Icons.query_stats_rounded,
              label: labels.statistics,
              onPressed: () => _runAction(context, onStatistics),
            ),
            _ProfileQuickMenuActionTile(
              icon: Icons.emoji_events_outlined,
              label: labels.achievements,
              onPressed: () => _runAction(context, onAchievements),
            ),
            _ProfileQuickMenuActionTile(
              icon: Icons.public_rounded,
              label: labels.cinemaPassport,
              onPressed: () => _runAction(context, onCinemaPassport),
            ),
            _ProfileQuickMenuActionTile(
              icon: Icons.settings_outlined,
              label: labels.settings,
              onPressed: () => _runAction(context, onSettings),
            ),
          ],
        ),
      ),
    );
  }

  void _runAction(BuildContext context, VoidCallback callback) {
    if (!dismissOnAction) {
      callback();
      return;
    }

    Navigator.of(context).pop();

    // Let the modal route begin dismissing before a destination transition is
    // requested. The supplied callback should use its owning page/shell context,
    // not the bottom-sheet context.
    Future<void>.microtask(callback);
  }
}

/// Identity + rank summary at the top of [ProfileQuickMenu].
///
/// The panel has only a faint branded tint. It is intentionally not a bright
/// purple card: the profile sheet should remain refined and content-first.
class _ProfileQuickMenuHeader extends StatelessWidget {
  const _ProfileQuickMenuHeader({
    required this.displayName,
    required this.subtitle,
    required this.rankLabel,
    required this.progress,
    required this.xpProgressLabel,
    required this.xpRemainingLabel,
    required this.imageProvider,
    required this.fallbackInitials,
  });

  final String displayName;
  final String? subtitle;
  final String rankLabel;
  final double progress;
  final String xpProgressLabel;
  final String? xpRemainingLabel;
  final ImageProvider<Object>? imageProvider;
  final String? fallbackInitials;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);

    final Color background = Color.alphaBlend(
      colors.primaryContainer.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.14 : 0.22,
      ),
      colors.surfaceContainerLow,
    );

    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(CinearaRadii.lg),
          border: Border.all(
            color: colors.outlineVariant.withValues(
              alpha: highContrast ? 1 : 0.72,
            ),
            width: highContrast ? 1.5 : 0.75,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(CinearaSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _ProfileQuickMenuAvatar(
                    imageProvider: imageProvider,
                    fallbackInitials: fallbackInitials,
                  ),
                  const SizedBox(width: CinearaSpacing.sm),
                  Expanded(
                    child: _ProfileQuickMenuIdentity(
                      displayName: displayName,
                      subtitle: subtitle,
                      rankLabel: rankLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: CinearaSpacing.md),
              _ProfileQuickMenuProgress(
                progress: progress,
                xpProgressLabel: xpProgressLabel,
                xpRemainingLabel: xpRemainingLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileQuickMenuIdentity extends StatelessWidget {
  const _ProfileQuickMenuIdentity({
    required this.displayName,
    required this.subtitle,
    required this.rankLabel,
  });

  final String displayName;
  final String? subtitle;
  final String rankLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          rankLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Profile avatar used by the quick menu.
///
/// Normal mode has no decorative ring. High-contrast mode adds an outline to
/// preserve edge definition.
class _ProfileQuickMenuAvatar extends StatelessWidget {
  const _ProfileQuickMenuAvatar({
    required this.imageProvider,
    required this.fallbackInitials,
  });

  final ImageProvider<Object>? imageProvider;
  final String? fallbackInitials;

  bool get _hasInitials =>
      fallbackInitials != null && fallbackInitials!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);
    const double extent = 52;

    final Widget fallback = Center(
      child: _hasInitials
          ? Padding(
              padding: const EdgeInsets.all(9),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  fallbackInitials!.trim(),
                  maxLines: 1,
                  softWrap: false,
                  textScaler: TextScaler.noScaling,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            )
          : Icon(
              Icons.person_rounded,
              size: 27,
              color: colors.onPrimaryContainer,
            ),
    );

    final Widget content = imageProvider == null
        ? fallback
        : Image(
            image: imageProvider!,
            width: extent,
            height: extent,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
                  return fallback;
                },
          );

    return SizedBox.square(
      dimension: extent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primaryContainer,
          border: highContrast
              ? Border.all(color: colors.primary, width: 2)
              : null,
        ),
        child: ClipOval(child: content),
      ),
    );
  }
}

/// Rank progress block.
///
/// The progress bar is intentionally slim so rank remains supporting context
/// rather than becoming the visual focus of the sheet.
class _ProfileQuickMenuProgress extends StatelessWidget {
  const _ProfileQuickMenuProgress({
    required this.progress,
    required this.xpProgressLabel,
    required this.xpRemainingLabel,
  });

  final double progress;
  final String xpProgressLabel;
  final String? xpRemainingLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final double resolvedProgress = progress.clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          label: xpProgressLabel,
          value: '${(resolvedProgress * 100).round()}%',
          child: ExcludeSemantics(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CinearaRadii.pill),
              child: SizedBox(
                height: 6,
                child: LinearProgressIndicator(
                  value: resolvedProgress,
                  backgroundColor: colors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: CinearaSpacing.xs),
        Text(
          xpProgressLabel,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (xpRemainingLabel != null) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            xpRemainingLabel!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// One of the five profile quick-menu destinations.
///
/// The icon itself has no circle or decorative container. Interaction feedback
/// belongs to the complete row, producing a quieter and more professional menu.
class _ProfileQuickMenuActionTile extends StatelessWidget {
  const _ProfileQuickMenuActionTile({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final TextDirection direction = Directionality.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
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
              return colors.primary.withValues(alpha: 0.085);
            }

            if (states.contains(WidgetState.hovered)) {
              return colors.primary.withValues(alpha: 0.045);
            }

            if (states.contains(WidgetState.focused)) {
              return colors.primary.withValues(alpha: 0.065);
            }

            return null;
          }),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 54),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: CinearaSpacing.sm,
                vertical: CinearaSpacing.xs,
              ),
              child: Row(
                children: <Widget>[
                  Icon(icon, size: 21, color: colors.onSurfaceVariant),
                  const SizedBox(width: CinearaSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: CinearaSpacing.xs),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.78),
                    textDirection: direction,
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
