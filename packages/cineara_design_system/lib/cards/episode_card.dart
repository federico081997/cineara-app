import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Controls how an [EpisodeCard] is composed.
///
/// The same episode component is reused throughout Cineara. The surrounding
/// feature decides why an episode is being surfaced; the card only adapts its
/// information density and emphasis.
enum EpisodeCardLayout {
  /// Landscape card used in horizontally scrolling Home sections such as
  /// Continue Watching, New Episodes and Upcoming Episodes.
  home,

  /// Compact full-width row used for episodes inside a Season page.
  seasonList,

  /// Emphasized compact row used for the next episode on a Series detail page.
  upNext,

  /// Compact schedule row used by Calendar / Upcoming pages.
  ///
  /// The surrounding page owns the day/date grouping. The card therefore
  /// prioritizes the series, episode identity and air time instead of repeating
  /// the calendar date inside every row.
  calendar,
}

/// Localized strings required by [EpisodeCard].
///
/// The design system deliberately does not depend on the application's
/// generated localization class. The application should construct this object
/// from its own localization layer.
///
/// [poster] is passed directly to the internal [PosterMediaCard], allowing the
/// episode still to reuse Cineara's existing image loading, fallback and NEW
/// treatment.
@immutable
class EpisodeCardLabels {
  const EpisodeCardLabels({
    required this.poster,
    required this.episode,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.newEpisode,
    required this.watched,
    required this.markWatched,
    required this.markUnwatched,
    required this.updating,
    required this.notYetAvailable,
    required this.progress,
  });

  /// Existing localized labels used by [PosterMediaCard].
  final PosterMediaCardLabels poster;

  /// Semantic media-type label for a single episode.
  final String episode;

  /// Builds the localized episode-number label.
  ///
  /// Examples:
  /// - `Episode 4`
  /// - `Episodio 4`
  final String Function(int number) episodeNumber;

  /// Builds the localized season-number label.
  ///
  /// Examples:
  /// - `Season 2`
  /// - `Stagione 2`
  final String Function(int number) seasonNumber;

  /// Accessibility description for a newly available episode.
  final String newEpisode;

  /// Localized state label for an episode already marked as watched.
  final String watched;

  /// Localized action label for marking an episode as watched.
  final String markWatched;

  /// Localized action label for reverting a watched episode.
  final String markUnwatched;

  /// Localized label used while watched state is being persisted.
  final String updating;

  /// Localized label for an episode that is not yet available.
  final String notYetAvailable;

  /// Builds a localized playback-progress description.
  ///
  /// The callback remains part of the public labels API for compatibility with
  /// the wider progress system. [EpisodeCard] itself intentionally does not
  /// display streaming-style playback progress.
  final String Function(int percentage) progress;
}

/// Optional context-specific trailing action for [EpisodeCard].
///
/// Calendar and Home Upcoming are the primary use cases: before release this
/// can represent a reminder/notification action, while released episodes can
/// omit it and fall back to the normal watched check.
///
/// The card deliberately receives icons and already-localized semantic labels
/// instead of knowing what a reminder means.
@immutable
class EpisodeCardQuickAction {
  const EpisodeCardQuickAction({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onPressed,
    required this.semanticLabel,
    required this.activeSemanticLabel,
    this.isUpdating = false,
  });

  /// Icon used while the action is inactive.
  final IconData icon;

  /// Icon used while the action is active.
  final IconData activeIcon;

  /// Whether the action's state is currently active.
  final bool isActive;

  /// Whether the action is currently being persisted.
  final bool isUpdating;

  /// Called when the action is activated.
  final VoidCallback onPressed;

  /// Localized accessibility/tooltip label for the inactive action.
  final String semanticLabel;

  /// Localized accessibility/tooltip label for the active action.
  final String activeSemanticLabel;

  /// Semantic label matching the current state.
  String get resolvedSemanticLabel =>
      isActive ? activeSemanticLabel : semanticLabel;
}

/// Reusable episode card used throughout Cineara.
///
/// The card is intentionally presentation-only. It does not decide:
///
/// - which episode is next;
/// - whether an episode belongs in Continue Watching or New Episodes;
/// - whether earlier episodes should also be marked watched;
/// - how watched state is persisted;
/// - how Season or Series progress is recalculated.
///
/// Those rules belong to the application's progress/domain layer.
///
/// Interaction principles:
///
/// - the complete physical card opens episode details when [onTap] is supplied;
/// - the complete card uses the same Cineara press language as
///   [PosterMediaCard]: short compression, restrained outer glow and an inner
///   brand-colour highlight;
/// - watched state is changed through a compact circular check control rather
///   than a text-heavy button;
/// - successfully marking watched triggers a short whole-card colour sweep,
///   while the check control performs its own confirmation pop/ring;
/// - Season-list watched rows receive a subtle theme-derived surface tint and
///   state rail so a completed run of episodes is obvious at a glance;
/// - NEW episodes use a different accent treatment from watched episodes;
/// - Home and Calendar can expose the series title as a small secondary
///   navigation target. Tapping the series link opens the series while tapping
///   the rest of the card still opens the episode;
/// - Home Upcoming can reuse [quickAction] for reminder/notification actions;
/// - Calendar rows put the air time directly on the artwork, keep the text area
///   to two lines and deliberately suppress the redundant NEW visual treatment.
///
/// The episode still is rendered through [PosterMediaCard] in artwork-only
/// 16:9 mode, keeping image loading, fallback artwork, clipping and NEW
/// treatment consistent with the rest of Cineara.
class EpisodeCard extends StatefulWidget {
  const EpisodeCard({
    required this.episodeNumber,
    required this.title,
    required this.labels,
    super.key,
    this.layout = EpisodeCardLayout.seasonList,
    this.imageUrl,
    this.seriesTitle,
    this.seasonNumber,
    this.episodeLabel,
    this.airDateLabel,
    this.airTimeLabel,
    this.runtimeLabel,
    this.progress,
    this.isNew = false,
    this.isWatched = false,
    this.isAvailable = true,
    this.isWatchedUpdating = false,
    this.showWatchedAction = true,
    this.quickAction,
    this.onTap,
    this.onSeriesTap,
    this.onLongPress,
    this.onMarkWatched,
    this.onMarkUnwatched,
    this.semanticLabel,
    this.seriesSemanticLabel,
    this.progressSemanticLabel,
    this.heroTag,
    this.enableHaptics = true,
  }) : assert(episodeNumber >= 0),
       assert(seasonNumber == null || seasonNumber >= 0),
       assert(progress == null || (progress >= 0 && progress <= 1));

  /// Episode number inside its season.
  ///
  /// Zero is supported because some catalogues use Episode 0 for specials.
  final int episodeNumber;

  /// Episode title.
  final String title;

  /// Localized strings supplied by the application.
  final EpisodeCardLabels labels;

  /// Physical composition of the card.
  final EpisodeCardLayout layout;

  /// Episode still/backdrop URL.
  final String? imageUrl;

  /// Series title.
  ///
  /// Primarily useful on Home and Calendar, where the surrounding page does
  /// not already establish which series owns the episode.
  ///
  /// When [onSeriesTap] is supplied in those layouts, the title becomes a
  /// compact secondary navigation link with a trailing chevron.
  final String? seriesTitle;

  /// Season containing the episode.
  ///
  /// Home and Up Next may show this in compact metadata. Season-list cards do
  /// not repeat it because the surrounding page already establishes the season.
  final int? seasonNumber;

  /// Optional already-localized override for the episode-number label.
  ///
  /// Useful for `Special`, `OVA`, `Prologue`, etc.
  final String? episodeLabel;

  /// Already-formatted localized air-date text.
  final String? airDateLabel;

  /// Already-formatted localized local air-time text.
  ///
  /// Calendar rows render this directly over the artwork so the central text
  /// column does not need another line.
  ///
  /// Examples:
  /// - `15:00`
  /// - `11:55`
  /// - `TBA`
  final String? airTimeLabel;

  /// Already-formatted localized runtime text.
  final String? runtimeLabel;

  /// Retained for API compatibility with the broader progress model.
  ///
  /// Cineara is a tracker rather than the streaming provider, so this card
  /// intentionally does not draw a playback-position bar.
  final double? progress;

  /// Whether the episode is newly available.
  final bool isNew;

  /// Whether the episode is marked as watched.
  ///
  /// This is presentation state only. In particular, Calendar parents should
  /// normally keep a watched episode in its date group and update its styling
  /// rather than removing the row immediately. Visibility/filtering belongs to
  /// the parent feature.
  final bool isWatched;

  /// Whether this episode is currently available.
  ///
  /// Upcoming episodes remain tappable for details, but their watched control
  /// is replaced by a passive schedule indicator.
  final bool isAvailable;

  /// Whether a watched-state mutation is currently being persisted.
  ///
  /// Repeated taps on the watched control are ignored while this is true.
  final bool isWatchedUpdating;

  /// Whether the episode-level watched control should be shown.
  ///
  /// For example, a New Episodes Home section may hide it to keep NEW as the
  /// primary signal.
  final bool showWatchedAction;

  /// Optional context-specific trailing action.
  ///
  /// Calendar and Home Upcoming commonly use this for reminders before release.
  /// A supplied quick action takes precedence over the normal watched/availability
  /// control for that card.
  final EpisodeCardQuickAction? quickAction;

  /// Opens episode details.
  ///
  /// When supplied, the entire physical card is interactive.
  final VoidCallback? onTap;

  /// Opens the owning series.
  ///
  /// This is surfaced only by Home and Calendar layouts because Season List
  /// and Up Next already live inside a series-oriented navigation context.
  ///
  /// The series link is an independent nested interaction. Tapping it must not
  /// invoke [onTap].
  final VoidCallback? onSeriesTap;

  /// Optional state-aware episode action sheet.
  final VoidCallback? onLongPress;

  /// Requests that this episode be marked watched.
  ///
  /// The parent owns any "mark previous episodes watched" convenience flow.
  final VoidCallback? onMarkWatched;

  /// Requests that this episode be marked unwatched.
  ///
  /// Cineara should not automatically mark later episodes unwatched; users may
  /// intentionally keep non-contiguous watch history.
  final VoidCallback? onMarkUnwatched;

  /// Optional fully localized accessibility description for the complete card.
  final String? semanticLabel;

  /// Optional localized accessibility label for the series-navigation link.
  ///
  /// When omitted, [seriesTitle] is used.
  final String? seriesSemanticLabel;

  /// Retained for callers that keep progress semantics alongside progress.
  ///
  /// [EpisodeCard] does not currently expose playback-position UI.
  final String? progressSemanticLabel;

  /// Optional Hero tag for seamless artwork transitions.
  ///
  /// The caller is responsible for keeping Hero tags unique on a route.
  final Object? heroTag;

  /// Whether supported episode actions emit lightweight haptics.
  final bool enableHaptics;

  @override
  State<EpisodeCard> createState() => _EpisodeCardState();
}

class _EpisodeCardState extends State<EpisodeCard>
    with SingleTickerProviderStateMixin {
  static const Duration _minimumPressDuration = Duration(milliseconds: 90);

  bool _isPressed = false;
  bool _nestedInteractionActive = false;
  DateTime? _pressStartedAt;

  late final AnimationController _watchedConfirmationController;
  late final Animation<double> _confirmationOpacity;
  late final Animation<double> _confirmationSweep;
  late final Animation<double> _confirmationBorderOpacity;

  bool get _isCardInteractive =>
      widget.onTap != null || widget.onLongPress != null;

  bool get _hasSeriesTitle =>
      widget.seriesTitle != null && widget.seriesTitle!.trim().isNotEmpty;

  bool get _hasAirDate =>
      widget.airDateLabel != null && widget.airDateLabel!.trim().isNotEmpty;

  bool get _hasAirTime =>
      widget.airTimeLabel != null && widget.airTimeLabel!.trim().isNotEmpty;

  bool get _hasRuntime =>
      widget.runtimeLabel != null && widget.runtimeLabel!.trim().isNotEmpty;

  bool get _showWatchedControl =>
      widget.showWatchedAction &&
      (widget.onMarkWatched != null ||
          widget.onMarkUnwatched != null ||
          widget.isWatchedUpdating);

  bool get _showNewTreatment =>
      widget.layout != EpisodeCardLayout.calendar &&
      widget.isNew &&
      widget.isAvailable &&
      !widget.isWatched;

  bool get _showSeriesLink =>
      _hasSeriesTitle &&
      widget.onSeriesTap != null &&
      (widget.layout == EpisodeCardLayout.home ||
          widget.layout == EpisodeCardLayout.calendar);

  String get _resolvedEpisodeLabel {
    final String? override = widget.episodeLabel;

    if (override != null && override.trim().isNotEmpty) {
      return override;
    }

    return widget.labels.episodeNumber(widget.episodeNumber);
  }

  String get _resolvedSemanticLabel {
    if (widget.semanticLabel case final String label
        when label.trim().isNotEmpty) {
      return label;
    }

    final List<String> parts = <String>[];

    if (_hasSeriesTitle) {
      parts.add(widget.seriesTitle!);
    }

    if (widget.layout != EpisodeCardLayout.seasonList &&
        widget.seasonNumber != null) {
      parts.add(widget.labels.seasonNumber(widget.seasonNumber!));
    }

    parts.add(_resolvedEpisodeLabel);
    parts.add(widget.title);

    if (_hasAirDate) {
      parts.add(widget.airDateLabel!);
    }

    if (_hasAirTime) {
      parts.add(widget.airTimeLabel!);
    }

    if (_hasRuntime) {
      parts.add(widget.runtimeLabel!);
    }

    if (_showNewTreatment) {
      parts.add(widget.labels.newEpisode);
    }

    if (!widget.isAvailable) {
      parts.add(widget.labels.notYetAvailable);
    } else if (widget.isWatched) {
      parts.add(widget.labels.watched);
    }

    return parts.join(', ');
  }

  @override
  void initState() {
    super.initState();

    _watchedConfirmationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _confirmationOpacity = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 20,
      ),
      TweenSequenceItem<double>(tween: ConstantTween<double>(1), weight: 30),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 50,
      ),
    ]).animate(_watchedConfirmationController);

    _confirmationSweep = CurvedAnimation(
      parent: _watchedConfirmationController,
      curve: Curves.easeOutCubic,
    );

    _confirmationBorderOpacity =
        TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(
              begin: 0,
              end: 0.82,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
            weight: 28,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(
              begin: 0.82,
              end: 0,
            ).chain(CurveTween(curve: Curves.easeInCubic)),
            weight: 72,
          ),
        ]).animate(_watchedConfirmationController);
  }

  @override
  void didUpdateWidget(covariant EpisodeCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Celebrate only after the parent has actually committed watched state.
    if (!oldWidget.isWatched && widget.isWatched) {
      _watchedConfirmationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _watchedConfirmationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (_isPressed || _nestedInteractionActive) {
      return;
    }

    _pressStartedAt = DateTime.now();

    setState(() {
      _isPressed = true;
    });
  }

  void _handleNestedInteractionChanged(bool active) {
    _nestedInteractionActive = active;

    // A nested series/action target owns its own feedback. If the outer
    // InkWell already started its press state before the gesture arena resolved,
    // remove that state immediately so the user never sees two simultaneous
    // highlights.
    if (active && _isPressed) {
      _releasePressedState();
    }
  }

  void _handleTap() {
    final VoidCallback? callback = widget.onTap;

    if (callback == null) {
      return;
    }

    _scheduleRelease();
    callback();
  }

  void _handleTapCancel() {
    _scheduleRelease();
  }

  void _scheduleRelease() {
    if (!_isPressed) {
      return;
    }

    final DateTime startedAt = _pressStartedAt ?? DateTime.now();
    final Duration elapsed = DateTime.now().difference(startedAt);

    final Duration remaining = elapsed >= _minimumPressDuration
        ? Duration.zero
        : _minimumPressDuration - elapsed;

    if (remaining == Duration.zero) {
      _releasePressedState();
      return;
    }

    Future<void>.delayed(remaining, () {
      if (!mounted) {
        return;
      }

      _releasePressedState();
    });
  }

  void _releasePressedState() {
    if (!_isPressed) {
      return;
    }

    setState(() {
      _isPressed = false;
    });

    _pressStartedAt = null;
  }

  void _handleLongPress() {
    final VoidCallback? callback = widget.onLongPress;

    if (callback == null) {
      return;
    }

    if (widget.enableHaptics) {
      HapticFeedback.mediumImpact();
    }

    callback();
  }

  void _handleWatchedAction() {
    if (widget.isWatchedUpdating || !widget.isAvailable) {
      return;
    }

    if (widget.isWatched) {
      final VoidCallback? callback = widget.onMarkUnwatched;

      if (callback == null) {
        return;
      }

      if (widget.enableHaptics) {
        HapticFeedback.selectionClick();
      }

      callback();
      return;
    }

    final VoidCallback? callback = widget.onMarkWatched;

    if (callback == null) {
      return;
    }

    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    callback();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final Duration interactionDuration = reduceMotion
        ? Duration.zero
        : CinearaMotion.fast;

    final Duration scaleDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 90);

    final BorderRadius borderRadius = BorderRadius.circular(
      widget.layout == EpisodeCardLayout.home
          ? CinearaRadii.lg
          : CinearaRadii.md,
    );

    final _EpisodeSurfacePalette palette = _resolveSurfacePalette(
      colors: colors,
      layout: widget.layout,
      isNew: _showNewTreatment,
      isWatched: widget.isWatched,
      isAvailable: widget.isAvailable,
    );

    final Widget body = switch (widget.layout) {
      EpisodeCardLayout.home => _buildHome(context),
      EpisodeCardLayout.seasonList => _buildSeasonList(context),
      EpisodeCardLayout.upNext => _buildUpNext(context),
      EpisodeCardLayout.calendar => _buildCalendar(context),
    };

    final Widget interactiveSurface = AnimatedScale(
      scale: _isPressed && !reduceMotion ? 0.985 : 1,
      duration: scaleDuration,
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: scaleDuration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: borderRadius,

          // Match PosterMediaCard's short Cineara-coloured press glow.
          // Physical elevation and Cineara press glow.
          boxShadow: _isPressed && !reduceMotion
              ? <BoxShadow>[
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.14),
                    blurRadius: 7,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: colors.secondary.withValues(alpha: 0.04),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ]
              : widget.layout == EpisodeCardLayout.home
              ? <BoxShadow>[
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.045),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : widget.layout == EpisodeCardLayout.upNext
              ? <BoxShadow>[
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.055),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              duration: interactionDuration,
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: palette.background,
                gradient: palette.gradient,
                borderRadius: borderRadius,
                border: Border.all(
                  color: _isPressed && !reduceMotion
                      ? colors.primary.withValues(alpha: 0.52)
                      : palette.border,
                  width: widget.layout == EpisodeCardLayout.upNext ? 1.2 : 1,
                ),
              ),
              child: InkWell(
                excludeFromSemantics: true,
                onTap: widget.onTap == null ? null : _handleTap,
                onTapDown: _isCardInteractive ? _handleTapDown : null,
                onTapCancel: _isCardInteractive ? _handleTapCancel : null,
                onLongPress: widget.onLongPress == null
                    ? null
                    : _handleLongPress,
                splashFactory: NoSplash.splashFactory,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    body,

                    // State rail is intentionally confined to row-style cards.
                    if (widget.layout != EpisodeCardLayout.home &&
                        (widget.isWatched ||
                            _showNewTreatment ||
                            widget.layout == EpisodeCardLayout.upNext))
                      PositionedDirectional(
                        start: 0,
                        top: CinearaSpacing.xs,
                        bottom: CinearaSpacing.xs,
                        child: _EpisodeStateRail(
                          isWatched: widget.isWatched,
                          isNew: _showNewTreatment,
                        ),
                      ),

                    // The inner colour wash mirrors PosterMediaCard. The
                    // border itself is NOT drawn here: the animated surface
                    // above owns the single physical border, preventing the
                    // doubled outline that can appear when two borders overlap.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: _isPressed && !reduceMotion ? 1 : 0,
                          duration: scaleDuration,
                          curve: Curves.easeOutCubic,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: borderRadius,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  colors.tertiary.withValues(alpha: 0.10),
                                  colors.primary.withValues(alpha: 0.055),
                                  Colors.transparent,
                                  colors.secondary.withValues(alpha: 0.09),
                                ],
                                stops: const <double>[0, 0.30, 0.60, 1],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      button: widget.onTap != null,
      label: _resolvedSemanticLabel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          interactiveSurface,

          // The watched confirmation is a colour sweep only. There is no large
          // overlaid check, preventing the confirmation from obscuring content.
          if (!reduceMotion)
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: _WatchedConfirmationOverlay(
                    animation: _watchedConfirmationController,
                    opacity: _confirmationOpacity,
                    sweep: _confirmationSweep,
                    borderOpacity: _confirmationBorderOpacity,
                    borderRadius: borderRadius,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final TextStyle titleStyle =
        theme.textTheme.titleSmall?.copyWith(
          color: widget.isWatched
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          height: 1.16,
          letterSpacing: -0.1,
        ) ??
        const TextStyle();

    final double titleLineHeight =
        (titleStyle.fontSize ?? CinearaFontSizes.bodyLarge) *
        (titleStyle.height ?? 1.16);

    return Padding(
      padding: const EdgeInsets.all(CinearaSpacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildArtwork(),
          const SizedBox(height: CinearaSpacing.sm),

          if (_hasSeriesTitle) ...<Widget>[
            _buildSeriesIdentity(
              context,
              style: theme.textTheme.labelLarge?.copyWith(
                color: widget.isWatched
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
            const SizedBox(height: CinearaSpacing.xxs),
          ],

          SizedBox(
            height: titleLineHeight * 2,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
            ),
          ),

          const SizedBox(height: CinearaSpacing.xs),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: _EpisodeMetadataLine(
                  items: _homeMetadata,
                  muted: widget.isWatched,
                ),
              ),

              if (widget.quickAction != null ||
                  _showWatchedControl ||
                  !widget.isAvailable) ...<Widget>[
                const SizedBox(width: CinearaSpacing.xs),
                _buildTrailingAction(density: _EpisodeActionDensity.normal),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonList(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 370;
        final double artworkWidth = compact ? 108 : 124;

        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            widget.isWatched || _showNewTreatment
                ? CinearaSpacing.sm
                : CinearaSpacing.xs,
            CinearaSpacing.xs,
            CinearaSpacing.xs,
            CinearaSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: artworkWidth,
                child: _buildArtwork(
                  showEpisodeNumberBadge: widget.episodeLabel == null,
                ),
              ),

              const SizedBox(width: CinearaSpacing.sm),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: widget.isWatched
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: widget.isWatched
                            ? FontWeight.w600
                            : FontWeight.w700,
                        height: 1.15,
                        letterSpacing: -0.1,
                      ),
                    ),

                    if (_seasonMetadata.isNotEmpty) ...<Widget>[
                      const SizedBox(height: CinearaSpacing.xs),
                      _EpisodeMetadataLine(
                        items: _seasonMetadata,
                        muted: widget.isWatched,
                      ),
                    ],
                  ],
                ),
              ),

              if (_showWatchedControl || !widget.isAvailable) ...<Widget>[
                const SizedBox(width: CinearaSpacing.xs),
                _buildWatchedOrAvailabilityAction(
                  density: _EpisodeActionDensity.compact,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpNext(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 370;
        final double artworkWidth = compact ? 104 : 118;

        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            CinearaSpacing.sm,
            CinearaSpacing.xs,
            CinearaSpacing.xs,
            CinearaSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: artworkWidth,
                child: _buildArtwork(
                  showEpisodeNumberBadge: widget.episodeLabel == null,
                ),
              ),

              const SizedBox(width: CinearaSpacing.sm),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: widget.isWatched
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        letterSpacing: -0.1,
                      ),
                    ),

                    if (_upNextMetadata.isNotEmpty) ...<Widget>[
                      const SizedBox(height: CinearaSpacing.xs),
                      _EpisodeMetadataLine(
                        items: _upNextMetadata,
                        muted: widget.isWatched,
                      ),
                    ],
                  ],
                ),
              ),

              if (_showWatchedControl || !widget.isAvailable) ...<Widget>[
                const SizedBox(width: CinearaSpacing.xs),
                _buildWatchedOrAvailabilityAction(
                  density: _EpisodeActionDensity.compact,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 370;
        final double artworkWidth = compact ? 108 : 122;

        final String primaryTitle = _hasSeriesTitle
            ? widget.seriesTitle!
            : widget.title;

        final String secondaryText = _hasSeriesTitle
            ? '$_resolvedEpisodeLabel  •  ${widget.title}'
            : _resolvedEpisodeLabel;

        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            widget.isWatched || _showNewTreatment
                ? CinearaSpacing.sm
                : CinearaSpacing.xs,
            CinearaSpacing.xs,
            CinearaSpacing.xs,
            CinearaSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: artworkWidth,
                child: _buildArtwork(showAirTimeBadge: _hasAirTime),
              ),

              const SizedBox(width: CinearaSpacing.sm),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (_hasSeriesTitle)
                      _buildSeriesIdentity(
                        context,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: widget.isWatched
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          height: 1.12,
                          letterSpacing: -0.1,
                        ),
                      )
                    else
                      Text(
                        primaryTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: widget.isWatched
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          height: 1.12,
                          letterSpacing: -0.1,
                        ),
                      ),

                    const SizedBox(height: CinearaSpacing.xs),

                    Text(
                      secondaryText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: widget.isWatched ? 0.70 : 0.90,
                        ),
                        fontSize: 11.5,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              if (widget.quickAction != null ||
                  _showWatchedControl ||
                  !widget.isAvailable) ...<Widget>[
                const SizedBox(width: CinearaSpacing.xs),
                _buildTrailingAction(density: _EpisodeActionDensity.compact),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrailingAction({required _EpisodeActionDensity density}) {
    if (widget.quickAction case final EpisodeCardQuickAction action) {
      return _EpisodeQuickActionButton(
        action: action,
        density: density,
        enableHaptics: widget.enableHaptics,
      );
    }

    return _buildWatchedOrAvailabilityAction(density: density);
  }

  Widget _buildSeriesIdentity(
    BuildContext context, {
    required TextStyle? style,
  }) {
    final String title = widget.seriesTitle!;

    if (!_showSeriesLink) {
      return Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    return _EpisodeSeriesLink(
      title: title,
      semanticLabel: widget.seriesSemanticLabel ?? title,
      style: style,
      onTap: widget.onSeriesTap!,
      onPressChanged: _handleNestedInteractionChanged,
    );
  }

  Widget _buildArtwork({
    bool showEpisodeNumberBadge = false,
    bool showAirTimeBadge = false,
  }) {
    Widget artwork = _EpisodeArtwork(
      title: widget.title,
      imageUrl: widget.imageUrl,
      labels: widget.labels,
      isNew: _showNewTreatment,
      isWatched: widget.isWatched,
      isAvailable: widget.isAvailable,
      episodeNumber: showEpisodeNumberBadge ? widget.episodeNumber : null,
      airTimeLabel: showAirTimeBadge ? widget.airTimeLabel : null,
    );

    if (widget.heroTag != null) {
      artwork = Hero(
        tag: widget.heroTag!,
        transitionOnUserGestures: true,
        child: artwork,
      );
    }

    return artwork;
  }

  Widget _buildWatchedOrAvailabilityAction({
    required _EpisodeActionDensity density,
  }) {
    if (!widget.isAvailable) {
      return _EpisodeAvailabilityAction(
        label: widget.labels.notYetAvailable,
        density: density,
      );
    }

    if (!_showWatchedControl) {
      return const SizedBox.shrink();
    }

    return _EpisodeWatchedAction(
      isWatched: widget.isWatched,
      isUpdating: widget.isWatchedUpdating,
      labels: widget.labels,
      density: density,
      enabled: widget.isWatched
          ? widget.onMarkUnwatched != null
          : widget.onMarkWatched != null,
      onPressed: _handleWatchedAction,
    );
  }

  /// Home metadata is intentionally context-sensitive and short.
  ///
  /// Continue Watching:
  /// `Season 2 • Episode 4`
  ///
  /// New Episodes:
  /// `Episode 6 • Today`
  ///
  /// Runtime is deliberately omitted on Home because it is lower-priority and
  /// was the first value to become truncated on compact cards.
  List<String> get _homeMetadata {
    final List<String> items = <String>[];

    // Upcoming Episodes on Home: episode identity + the next useful temporal
    // cue. This keeps the line short enough for the horizontal card.
    if (!widget.isAvailable) {
      items.add(_resolvedEpisodeLabel);

      if (_hasAirDate) {
        items.add(widget.airDateLabel!);
      } else if (_hasAirTime) {
        items.add(widget.airTimeLabel!);
      }

      return items;
    }

    if (_showNewTreatment) {
      items.add(_resolvedEpisodeLabel);

      if (_hasAirDate) {
        items.add(widget.airDateLabel!);
      }

      return items;
    }

    if (widget.seasonNumber case final int season) {
      items.add(widget.labels.seasonNumber(season));
    }

    items.add(_resolvedEpisodeLabel);

    return items;
  }

  /// A Season page already communicates the season and the episode number is
  /// shown on the still, so only genuinely useful secondary information remains
  /// beside the title.
  List<String> get _seasonMetadata {
    final List<String> items = <String>[];

    // Specials do not get a numeric artwork badge, so keep their localized
    // episode label in metadata.
    if (widget.episodeLabel != null && widget.episodeLabel!.trim().isNotEmpty) {
      items.add(_resolvedEpisodeLabel);
    }

    if (_hasAirDate) {
      items.add(widget.airDateLabel!);
    }

    if (_hasRuntime) {
      items.add(widget.runtimeLabel!);
    }

    return items;
  }

  /// Up Next is a decision card, not a complete episode-information panel.
  /// Season + episode identity is enough; date/runtime stay on the destination
  /// episode page.
  List<String> get _upNextMetadata {
    final List<String> items = <String>[];

    if (widget.seasonNumber case final int season) {
      items.add(widget.labels.seasonNumber(season));
    }

    items.add(_resolvedEpisodeLabel);

    return items;
  }
}

/// 16:9 episode still implemented through [PosterMediaCard].
///
/// Episode cards intentionally disable poster-specific ratings, world identity,
/// status docks and playback progress. Only relevant artwork behaviour is
/// reused:
///
/// - image loading and fade-in;
/// - fallback artwork;
/// - rounded clipping;
/// - NEW marker.
class _EpisodeArtwork extends StatelessWidget {
  const _EpisodeArtwork({
    required this.title,
    required this.imageUrl,
    required this.labels,
    required this.isNew,
    required this.isWatched,
    required this.isAvailable,
    this.episodeNumber,
    this.airTimeLabel,
  });

  final String title;
  final String? imageUrl;
  final EpisodeCardLabels labels;
  final bool isNew;
  final bool isWatched;
  final bool isAvailable;

  /// Optional already-formatted air-time label used by Calendar rows.
  final String? airTimeLabel;

  /// Optional compact numeric episode marker used by Season-list rows.
  ///
  /// Full localized episode wording remains in semantics, so the artwork can
  /// use the much denser number-only treatment without losing accessibility.
  final int? episodeNumber;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Widget poster = ExcludeSemantics(
      child: PosterMediaCard(
        title: title,
        mediaTypeLabel: labels.episode,
        labels: labels.poster,
        imageUrl: imageUrl,
        viewingStatus: isWatched
            ? PosterViewingStatus.completed
            : PosterViewingStatus.notStarted,
        newContent: isNew
            ? const PosterNewContent(type: PosterNewContentType.release)
            : null,
        aspectRatio: 16 / 9,
        layout: PosterMediaCardLayout.artworkOnly,
        showWorldIdentity: false,
        showExternalRating: false,
        showUserRating: false,
        showStatusDock: false,
        showNewContent: isNew,
        enableHaptics: false,
      ),
    );

    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        poster,

        // Watched artwork is softened slightly instead of receiving another
        // check badge. The trailing circular action is the single check source
        // of truth, avoiding duplicated/overlapping icons.
        if (isWatched)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(CinearaRadii.lg),
                ),
              ),
            ),
          ),

        if (!isAvailable)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.scrim.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(CinearaRadii.lg),
                ),
              ),
            ),
          ),

        if (airTimeLabel case final String airTime
            when airTime.trim().isNotEmpty)
          PositionedDirectional(
            start: CinearaSpacing.xs,
            bottom: CinearaSpacing.xs,
            child: _EpisodeAirTimeBadge(label: airTime),
          ),

        if (episodeNumber case final int number)
          PositionedDirectional(
            start: CinearaSpacing.xs,
            bottom: CinearaSpacing.xs,
            child: _EpisodeNumberBadge(number: number),
          ),
      ],
    );
  }
}

/// Compact local air time shown directly on Calendar artwork.
///
/// The calendar page already groups cards under a date heading, so placing the
/// time on the still keeps the text area to two lines without losing the most
/// important schedule information.
class _EpisodeAirTimeBadge extends StatelessWidget {
  const _EpisodeAirTimeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ExcludeSemantics(
      child: Container(
        constraints: const BoxConstraints(minHeight: 24),
        padding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.xs,
          vertical: 4,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.inverseSurface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(CinearaRadii.pill),
          border: Border.all(
            color: theme.colorScheme.onInverseSurface.withValues(alpha: 0.18),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.16),
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onInverseSurface,
            fontWeight: FontWeight.w800,
            height: 1,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// Compact episode number shown directly on Season-list artwork.
///
/// This removes an entire metadata item from the narrow text column while
/// keeping the episode order immediately scannable.
class _EpisodeNumberBadge extends StatelessWidget {
  const _EpisodeNumberBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ExcludeSemantics(
      child: Container(
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        padding: const EdgeInsets.symmetric(horizontal: 7),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.scrim.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(CinearaRadii.pill),
          border: Border.all(
            color: theme.colorScheme.surface.withValues(alpha: 0.22),
          ),
        ),
        child: Text(
          '$number',
          maxLines: 1,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.surface,
            fontWeight: FontWeight.w800,
            height: 1,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// Compact secondary navigation target for the owning series.
///
/// This link is deliberately quieter than the whole-card interaction:
///
/// - the card keeps the stronger PosterMediaCard-style compression/glow;
/// - the series link receives only a small local highlight and a tiny scale;
/// - a trailing chevron makes the separate destination discoverable.
///
/// Because this is a nested interactive child, its [InkWell] wins the tap
/// gesture over the outer episode-card [InkWell]. The series callback therefore
/// does not also open the episode.
class _EpisodeSeriesLink extends StatefulWidget {
  const _EpisodeSeriesLink({
    required this.title,
    required this.semanticLabel,
    required this.style,
    required this.onTap,
    required this.onPressChanged,
  });

  final String title;
  final String semanticLabel;
  final TextStyle? style;
  final VoidCallback onTap;
  final ValueChanged<bool> onPressChanged;

  @override
  State<_EpisodeSeriesLink> createState() => _EpisodeSeriesLinkState();
}

class _EpisodeSeriesLinkState extends State<_EpisodeSeriesLink>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confirmationController;

  late final Animation<double> _highlightOpacity;
  late final Animation<double> _chevronOffset;
  late final Animation<double> _chevronScale;

  @override
  void initState() {
    super.initState();

    _confirmationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _highlightOpacity = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 28,
      ),
      TweenSequenceItem<double>(tween: ConstantTween<double>(1), weight: 18),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 54,
      ),
    ]).animate(_confirmationController);

    _chevronOffset = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0,
          end: 3,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 42,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 3,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 58,
      ),
    ]).animate(_confirmationController);

    _chevronScale = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1,
          end: 1.12,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 42,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.12,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 58,
      ),
    ]).animate(_confirmationController);
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _handleHighlightChanged(bool highlighted) {
    // This remains important even though it produces no visible feedback.
    //
    // It tells the outer EpisodeCard that this nested target owns the gesture,
    // preventing the whole card from showing its PosterMediaCard-style press
    // effect at the same time.
    widget.onPressChanged(highlighted);
  }

  void _handleTap() {
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (reduceMotion) {
      widget.onTap();
      return;
    }

    // The visual confirmation begins only once the gesture has been recognised
    // as a tap. Nothing changes merely because the user's finger is down.
    _confirmationController.forward(from: 0);

    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(CinearaRadii.sm),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _handleTap,
              onHighlightChanged: _handleHighlightChanged,

              // No normal Material press/splash feedback. The custom
              // confirmation animation below is shown after the click.
              splashFactory: NoSplash.splashFactory,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,

              borderRadius: BorderRadius.circular(CinearaRadii.sm),

              child: AnimatedBuilder(
                animation: _confirmationController,
                builder: (BuildContext context, Widget? child) {
                  final double confirmation = _highlightOpacity.value;

                  return Container(
                    constraints: const BoxConstraints(minHeight: 32),
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      CinearaSpacing.xxs,
                      3,
                      CinearaSpacing.xs,
                      3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(CinearaRadii.sm),

                      // Local Cineara highlight. It briefly blooms after the
                      // click and then disappears.
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.centerStart,
                        end: AlignmentDirectional.centerEnd,
                        colors: <Color>[
                          colors.primary.withValues(alpha: 0.14 * confirmation),
                          colors.secondary.withValues(
                            alpha: 0.07 * confirmation,
                          ),
                          Colors.transparent,
                        ],
                        stops: const <double>[0, 0.68, 1],
                      ),

                      // Very restrained local glow.
                      boxShadow: confirmation <= 0
                          ? const <BoxShadow>[]
                          : <BoxShadow>[
                              BoxShadow(
                                color: colors.primary.withValues(
                                  alpha: 0.10 * confirmation,
                                ),
                                blurRadius: 8,
                                spreadRadius: 0.5,
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: widget.style,
                          ),
                        ),

                        const SizedBox(width: 2),

                        Transform.translate(
                          offset: Offset(_chevronOffset.value, 0),
                          child: Transform.scale(
                            scale: _chevronScale.value,
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 17,
                              color: Color.lerp(
                                widget.style?.color ??
                                    colors.primary.withValues(alpha: 0.90),
                                colors.primary,
                                confirmation,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Single-line metadata that never grows the episode row vertically.
///
/// Values are already localized by the application. A non-linguistic bullet
/// keeps the line compact, and the entire sequence ellipsizes as one unit.
class _EpisodeMetadataLine extends StatelessWidget {
  const _EpisodeMetadataLine({required this.items, required this.muted});

  final List<String> items;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final List<String> visibleItems = items
        .where((String item) => item.trim().isNotEmpty)
        .toList(growable: false);

    if (visibleItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final Color textColor = theme.colorScheme.onSurfaceVariant.withValues(
      alpha: muted ? 0.70 : 0.90,
    );

    return Text(
      visibleItems.join('  •  '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: theme.textTheme.bodySmall?.copyWith(
        color: textColor,
        fontSize: 11.5,
        height: 1.1,
      ),
    );
  }
}

enum _EpisodeActionDensity { compact, normal }

/// Compact circular watched control.
///
/// The visible control stays small, while its surrounding square preserves a
/// comfortable touch target. State is expressed by the check itself and by the
/// fill treatment rather than by a separate `Watched` text label.
class _EpisodeWatchedAction extends StatefulWidget {
  const _EpisodeWatchedAction({
    required this.isWatched,
    required this.isUpdating,
    required this.labels,
    required this.density,
    required this.enabled,
    required this.onPressed,
  });

  final bool isWatched;
  final bool isUpdating;
  final EpisodeCardLabels labels;
  final _EpisodeActionDensity density;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<_EpisodeWatchedAction> createState() => _EpisodeWatchedActionState();
}

class _EpisodeWatchedActionState extends State<_EpisodeWatchedAction>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  late final AnimationController _confirmationController;
  late final Animation<double> _popScale;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  String get _semanticLabel {
    if (widget.isUpdating) {
      return widget.labels.updating;
    }

    return widget.isWatched
        ? widget.labels.markUnwatched
        : widget.labels.markWatched;
  }

  @override
  void initState() {
    super.initState();

    _confirmationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _popScale = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1,
          end: 1.10,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.10,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
    ]).animate(_confirmationController);

    _ringScale = Tween<double>(begin: 0.84, end: 1.70).animate(
      CurvedAnimation(
        parent: _confirmationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _ringOpacity = Tween<double>(begin: 0.46, end: 0).animate(
      CurvedAnimation(parent: _confirmationController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant _EpisodeWatchedAction oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isWatched && widget.isWatched) {
      _confirmationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _handleHighlightChanged(bool highlighted) {
    if (_isPressed == highlighted) {
      return;
    }

    setState(() {
      _isPressed = highlighted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final Duration animationDuration = reduceMotion
        ? Duration.zero
        : CinearaMotion.fast;

    final double hitSize = widget.density == _EpisodeActionDensity.compact
        ? 42
        : 44;

    final double visualSize = widget.density == _EpisodeActionDensity.compact
        ? 34
        : 36;

    final double iconSize = widget.density == _EpisodeActionDensity.compact
        ? 19
        : 20;

    final Color background = widget.isWatched
        ? colors.primary
        : colors.surfaceContainerHighest;

    final Color foreground = widget.isWatched
        ? colors.onPrimary
        : colors.onSurfaceVariant.withValues(alpha: 0.68);

    return Tooltip(
      message: _semanticLabel,
      child: Semantics(
        button: true,
        enabled: widget.enabled && !widget.isUpdating,
        toggled: widget.isWatched,
        label: _semanticLabel,
        child: ExcludeSemantics(
          child: SizedBox.square(
            dimension: hitSize,
            child: InkResponse(
              onTap: widget.enabled && !widget.isUpdating
                  ? widget.onPressed
                  : null,
              onHighlightChanged: _handleHighlightChanged,
              radius: hitSize / 2,
              containedInkWell: false,
              highlightShape: BoxShape.circle,
              child: Center(
                child: AnimatedBuilder(
                  animation: _confirmationController,
                  builder: (BuildContext context, Widget? child) {
                    final double popScale = reduceMotion ? 1 : _popScale.value;

                    return Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        if (!reduceMotion &&
                            _confirmationController.isAnimating)
                          IgnorePointer(
                            child: Opacity(
                              opacity: _ringOpacity.value,
                              child: Transform.scale(
                                scale: _ringScale.value,
                                child: Container(
                                  width: visualSize,
                                  height: visualSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        AnimatedScale(
                          scale: _isPressed && !reduceMotion ? 0.86 : popScale,
                          duration: _isPressed
                              ? const Duration(milliseconds: 80)
                              : const Duration(milliseconds: 120),
                          curve: _isPressed
                              ? Curves.easeOutCubic
                              : Curves.easeOutBack,
                          child: AnimatedContainer(
                            duration: animationDuration,
                            curve: Curves.easeOutCubic,
                            width: visualSize,
                            height: visualSize,
                            decoration: BoxDecoration(
                              color: background,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.isWatched
                                    ? colors.primary
                                    : colors.outlineVariant.withValues(
                                        alpha: 0.82,
                                      ),
                                width: 1,
                              ),
                              boxShadow: widget.isWatched
                                  ? <BoxShadow>[
                                      BoxShadow(
                                        color: colors.primary.withValues(
                                          alpha: 0.22,
                                        ),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : const <BoxShadow>[],
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: animationDuration,
                                switchInCurve: Curves.easeOutBack,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder:
                                    (
                                      Widget child,
                                      Animation<double> animation,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: Tween<double>(
                                            begin: 0.70,
                                            end: 1,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                child: widget.isUpdating
                                    ? SizedBox(
                                        key: const ValueKey<String>('saving'),
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: foreground,
                                        ),
                                      )
                                    : Icon(
                                        Icons.check_rounded,
                                        key: ValueKey<bool>(widget.isWatched),
                                        size: iconSize,
                                        color: foreground,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Generic compact trailing action used by Calendar and Home Upcoming rows.
///
/// It follows the same interaction family as the watched control:
///
/// - physical compression while pressed;
/// - active-state fill;
/// - a short confirmation pop/ring when the action becomes active;
/// - optional haptic feedback;
/// - a stable touch target larger than the visible circle.
class _EpisodeQuickActionButton extends StatefulWidget {
  const _EpisodeQuickActionButton({
    required this.action,
    required this.density,
    required this.enableHaptics,
  });

  final EpisodeCardQuickAction action;
  final _EpisodeActionDensity density;
  final bool enableHaptics;

  @override
  State<_EpisodeQuickActionButton> createState() =>
      _EpisodeQuickActionButtonState();
}

class _EpisodeQuickActionButtonState extends State<_EpisodeQuickActionButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  late final AnimationController _confirmationController;
  late final Animation<double> _popScale;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  EpisodeCardQuickAction get action => widget.action;

  @override
  void initState() {
    super.initState();

    _confirmationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _popScale = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1,
          end: 1.10,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.10,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
    ]).animate(_confirmationController);

    _ringScale = Tween<double>(begin: 0.84, end: 1.70).animate(
      CurvedAnimation(
        parent: _confirmationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _ringOpacity = Tween<double>(begin: 0.46, end: 0).animate(
      CurvedAnimation(parent: _confirmationController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant _EpisodeQuickActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.action.isActive && action.isActive) {
      _confirmationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _handleHighlightChanged(bool highlighted) {
    if (_isPressed == highlighted) {
      return;
    }

    setState(() {
      _isPressed = highlighted;
    });
  }

  void _handleTap() {
    if (action.isUpdating) {
      return;
    }

    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    action.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final Duration animationDuration = reduceMotion
        ? Duration.zero
        : CinearaMotion.fast;

    final double hitSize = widget.density == _EpisodeActionDensity.compact
        ? 42
        : 44;

    final double visualSize = widget.density == _EpisodeActionDensity.compact
        ? 34
        : 36;

    final double iconSize = widget.density == _EpisodeActionDensity.compact
        ? 19
        : 20;

    final Color background = action.isActive
        ? colors.primary
        : colors.surfaceContainerHighest;

    final Color foreground = action.isActive
        ? colors.onPrimary
        : colors.onSurfaceVariant;

    return Tooltip(
      message: action.resolvedSemanticLabel,
      child: Semantics(
        button: true,
        enabled: !action.isUpdating,
        toggled: action.isActive,
        label: action.resolvedSemanticLabel,
        child: ExcludeSemantics(
          child: SizedBox.square(
            dimension: hitSize,
            child: InkResponse(
              onTap: action.isUpdating ? null : _handleTap,
              onHighlightChanged: _handleHighlightChanged,
              radius: hitSize / 2,
              containedInkWell: false,
              highlightShape: BoxShape.circle,
              child: Center(
                child: AnimatedBuilder(
                  animation: _confirmationController,
                  builder: (BuildContext context, Widget? child) {
                    final double popScale = reduceMotion ? 1 : _popScale.value;

                    return Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        if (!reduceMotion &&
                            _confirmationController.isAnimating)
                          IgnorePointer(
                            child: Opacity(
                              opacity: _ringOpacity.value,
                              child: Transform.scale(
                                scale: _ringScale.value,
                                child: Container(
                                  width: visualSize,
                                  height: visualSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        AnimatedScale(
                          scale: _isPressed && !reduceMotion ? 0.86 : popScale,
                          duration: _isPressed
                              ? const Duration(milliseconds: 80)
                              : const Duration(milliseconds: 120),
                          curve: _isPressed
                              ? Curves.easeOutCubic
                              : Curves.easeOutBack,
                          child: AnimatedContainer(
                            duration: animationDuration,
                            curve: Curves.easeOutCubic,
                            width: visualSize,
                            height: visualSize,
                            decoration: BoxDecoration(
                              color: background,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: action.isActive
                                    ? colors.primary
                                    : colors.outlineVariant.withValues(
                                        alpha: 0.82,
                                      ),
                              ),
                              boxShadow: action.isActive
                                  ? <BoxShadow>[
                                      BoxShadow(
                                        color: colors.primary.withValues(
                                          alpha: 0.20,
                                        ),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : const <BoxShadow>[],
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: animationDuration,
                                switchInCurve: Curves.easeOutBack,
                                switchOutCurve: Curves.easeInCubic,
                                child: action.isUpdating
                                    ? SizedBox(
                                        key: const ValueKey<String>(
                                          'quick-action-updating',
                                        ),
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: foreground,
                                        ),
                                      )
                                    : Icon(
                                        action.isActive
                                            ? action.activeIcon
                                            : action.icon,
                                        key: ValueKey<bool>(action.isActive),
                                        size: iconSize,
                                        color: foreground,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Passive upcoming-episode indicator occupying the same trailing geometry as
/// the watched control so rows stay aligned.
class _EpisodeAvailabilityAction extends StatelessWidget {
  const _EpisodeAvailabilityAction({
    required this.label,
    required this.density,
  });

  final String label;
  final _EpisodeActionDensity density;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final double hitSize = density == _EpisodeActionDensity.compact ? 42 : 44;
    final double visualSize = density == _EpisodeActionDensity.compact
        ? 34
        : 36;

    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        child: ExcludeSemantics(
          child: SizedBox.square(
            dimension: hitSize,
            child: Center(
              child: Container(
                width: visualSize,
                height: visualSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.76),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.72),
                  ),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Theme-derived surface treatment for one episode-card state.
@immutable
class _EpisodeSurfacePalette {
  const _EpisodeSurfacePalette({
    required this.background,
    required this.border,
    this.gradient,
  });

  final Color background;
  final Color border;
  final Gradient? gradient;
}

/// Resolves the visual surface treatment for an episode card based on its
/// current state and layout. Unavailable, watched, new, Up Next, calendar and
/// default cards receive distinct but restrained backgrounds, borders and
/// optional gradients using semantic theme colours so the styling remains
/// consistent across all Cineara themes.
_EpisodeSurfacePalette _resolveSurfacePalette({
  required ColorScheme colors,
  required EpisodeCardLayout layout,
  required bool isNew,
  required bool isWatched,
  required bool isAvailable,
}) {
  if (!isAvailable) {
    return _EpisodeSurfacePalette(
      background: colors.surfaceContainerLow,
      border: colors.outlineVariant.withValues(alpha: 0.46),
    );
  }

  // Watched rows should be immediately distinguishable without becoming
  // visually loud. Alpha blending produces a light/dark-theme-safe tint.
  if (isWatched) {
    final Color watchedBackground = Color.alphaBlend(
      colors.primaryContainer.withValues(
        alpha: layout == EpisodeCardLayout.seasonList ? 0.34 : 0.22,
      ),
      colors.surfaceContainerLow,
    );

    return _EpisodeSurfacePalette(
      background: watchedBackground,
      border: colors.primary.withValues(
        alpha: layout == EpisodeCardLayout.seasonList ? 0.34 : 0.24,
      ),
      gradient: layout == EpisodeCardLayout.seasonList
          ? LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: <Color>[
                colors.primaryContainer.withValues(alpha: 0.20),
                Colors.transparent,
              ],
            )
          : null,
    );
  }

  if (isNew) {
    return _EpisodeSurfacePalette(
      background: colors.surfaceContainerLow,
      border: colors.tertiary.withValues(alpha: 0.38),
      gradient: LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: <Color>[
          colors.tertiaryContainer.withValues(alpha: 0.14),
          colors.primaryContainer.withValues(alpha: 0.06),
          colors.surfaceContainerLow,
        ],
      ),
    );
  }

  if (layout == EpisodeCardLayout.upNext) {
    return _EpisodeSurfacePalette(
      background: colors.surfaceContainerLow,
      border: colors.primary.withValues(alpha: 0.28),
      gradient: LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: <Color>[
          colors.primaryContainer.withValues(alpha: 0.10),
          colors.surfaceContainerLow,
        ],
      ),
    );
  }

  // Calendar intentionally does not receive NEW tinting. The surrounding
  // date/time grouping already communicates temporal recency.
  if (layout == EpisodeCardLayout.calendar) {
    return _EpisodeSurfacePalette(
      background: colors.surfaceContainerLow,
      border: colors.outlineVariant.withValues(alpha: 0.48),
    );
  }

  return _EpisodeSurfacePalette(
    background: colors.surface,
    border: colors.outlineVariant.withValues(alpha: 0.72),
  );
}

/// Thin visual state rail for compact row layouts.
///
/// Watched episodes use a stable primary rail. NEW/Up Next rows use Cineara's
/// tertiary → primary → secondary journey gradient.
class _EpisodeStateRail extends StatelessWidget {
  const _EpisodeStateRail({required this.isWatched, required this.isNew});

  final bool isWatched;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Gradient gradient = isWatched
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[colors.primary, colors.primary],
          )
        : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              isNew ? colors.tertiary : colors.primary,
              colors.primary,
              colors.secondary,
            ],
          );

    return Container(
      width: isWatched ? 3 : 3.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CinearaRadii.pill),
        gradient: gradient,
      ),
    );
  }
}

/// Short whole-card confirmation after watched state becomes true.
///
/// The effect is deliberately restrained and never covers content with a large
/// check icon:
///
/// - a temporary primary border;
/// - a low-opacity tertiary → primary → secondary sweep;
/// - no particles, blur filters or continuously running animations.
class _WatchedConfirmationOverlay extends StatelessWidget {
  const _WatchedConfirmationOverlay({
    required this.animation,
    required this.opacity,
    required this.sweep,
    required this.borderOpacity,
    required this.borderRadius,
  });

  final Animation<double> animation;
  final Animation<double> opacity;
  final Animation<double> sweep;
  final Animation<double> borderOpacity;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        if (!animation.isAnimating &&
            (animation.value == 0 || animation.value == 1)) {
          return const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 320;

            final double sweepWidth = width * 0.66;
            final double travel = width + sweepWidth;
            final double x = -sweepWidth + (travel * sweep.value);

            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: borderOpacity.value,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.78),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: opacity.value * 0.22,
                  child: Transform.translate(
                    offset: Offset(x, 0),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: SizedBox(
                        width: sweepWidth,
                        height: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: AlignmentDirectional.centerStart,
                              end: AlignmentDirectional.centerEnd,
                              colors: <Color>[
                                Colors.transparent,
                                colors.tertiary,
                                colors.primary,
                                colors.secondary,
                                Colors.transparent,
                              ],
                              stops: const <double>[0, 0.18, 0.48, 0.78, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
