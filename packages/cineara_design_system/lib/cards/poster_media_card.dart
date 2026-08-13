import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/theme_extensions.dart';

/// Controls how a poster media card is displayed.
enum PosterMediaCardLayout {
  /// Displays only the poster artwork.
  artworkOnly,

  /// Displays the artwork with title and supporting information below.
  artworkWithInformation,
}

/// Current viewing state of the media.
///
/// This is presentation state only. Cineara's progress/domain layer should
/// calculate this before providing it to [PosterMediaCard].
enum PosterViewingStatus {
  /// The user has not started this media.
  notStarted,

  /// The user is currently watching this media.
  watching,

  /// Every currently available episode has been watched, but the series may
  /// still be airing.
  caughtUp,

  /// The media has been completely watched.
  completed,

  /// The user is currently rewatching previously completed media.
  rewatching,

  /// The user has temporarily paused watching.
  onHold,

  /// The user has stopped watching the media.
  dropped,
}

/// Type of shortcut exposed by the poster's quick-action button.
///
/// Only one quick action is shown at a time to keep the artwork uncluttered.
enum PosterQuickActionType {
  /// Add or remove the media from the watchlist.
  watchlist,

  /// Add or remove the media from favourites.
  favourite,

  /// Mark or unmark the media as watched.
  watched,
}

/// Status information already communicated by the surrounding UI.
///
/// The poster card can suppress this information to avoid redundant icons.
enum PosterStatusContext {
  /// No status is already communicated by the surrounding UI.
  none,

  /// The current viewing status is already clear from the surrounding UI.
  viewingStatus,

  /// The surrounding UI already indicates that the media is a favourite.
  favourite,

  /// The surrounding UI already indicates that the media is in the watchlist.
  watchlist,

  /// The surrounding UI already indicates that the media is in a collection.
  collection,
}

/// Type of newly available content associated with the media.
enum PosterNewContentType {
  /// A newly released movie, series, season, or other media item.
  release,

  /// One or more newly available episodes of an episodic title.
  episodes,
}

/// Newly available content associated with a poster media card.
@immutable
class PosterNewContent {
  const PosterNewContent({required this.type, this.count})
    : assert(
        (type == PosterNewContentType.release && count == null) ||
            (type == PosterNewContentType.episodes &&
                count != null &&
                count > 0),
      );

  /// Type of newly available content.
  final PosterNewContentType type;

  /// Number of new episodes when [type] is [PosterNewContentType.episodes].
  final int? count;
}

/// World-cinema identity displayed by Cineara's Compass.
///
/// This is intentionally presentation-only. The application's catalogue
/// layer should determine the actual cultural/origin classification.
@immutable
class PosterWorldIdentity {
  /// Creates world-cinema identity information.
  const PosterWorldIdentity({
    required this.label,
    required this.compactLabel,
    required this.semanticLabel,
  });

  /// Full label for normal-width cards.
  ///
  /// Examples:
  /// - `JP · Anime`
  /// - `KR · K-Drama`
  /// - `HK · Film`
  /// - `IN · Malayalam`
  final String label;

  /// Compact label used when the poster becomes narrow.
  ///
  /// Examples:
  /// - `JP`
  /// - `KR`
  /// - `HK`
  /// - `IN`
  final String compactLabel;

  /// Full accessibility description.
  ///
  /// Examples:
  /// - `Japan, Anime`
  /// - `South Korea, K-Drama`
  /// - `Hong Kong, Cantonese cinema`
  final String semanticLabel;
}

/// External/community rating for the media.
@immutable
class PosterExternalRating {
  /// Creates an external rating.
  const PosterExternalRating({
    required this.sourceLabel,
    required this.value,
    this.semanticLabel,
  });

  /// Rating provider.
  ///
  /// Examples:
  /// - `IMDb`
  /// - `TMDb`
  /// - `RT`
  final String sourceLabel;

  /// Already formatted rating value.
  ///
  /// Examples:
  /// - `8.7`
  /// - `92%`
  final String value;

  /// Optional accessibility description.
  final String? semanticLabel;
}

/// A single interactive shortcut displayed over the poster.
@immutable
class PosterQuickAction {
  /// Creates a quick action.
  const PosterQuickAction({
    required this.type,
    required this.isActive,
    required this.onPressed,
    this.semanticLabel,
  });

  /// Type of action.
  final PosterQuickActionType type;

  /// Whether the corresponding state is currently active.
  final bool isActive;

  /// Called when the action is activated.
  final VoidCallback onPressed;

  /// Optional custom accessibility description.
  final String? semanticLabel;
}

@immutable
class PosterMediaCardLabels {
  const PosterMediaCardLabels({
    required this.notStarted,
    required this.watching,
    required this.caughtUp,
    required this.completed,
    required this.rewatching,
    required this.onHold,
    required this.dropped,
    required this.favourite,
    required this.watchlist,
    required this.userRating,
    required this.collectionCount,
    required this.progress,
    required this.newContent,
    required this.newContentBadge,
    required this.newContentDescription,
    required this.quickAction,
  });

  /// Label for media that has not been started.
  final String notStarted;

  /// Label for media currently being watched.
  final String watching;

  /// Label for media with all available episodes watched.
  final String caughtUp;

  /// Label for fully completed media.
  final String completed;

  /// Label for media currently being rewatched.
  final String rewatching;

  /// Label for media temporarily put on hold.
  final String onHold;

  /// Label for media the user has stopped watching.
  final String dropped;

  /// Label indicating that the media is a favourite.
  final String favourite;

  /// Label indicating that the media is in the watchlist.
  final String watchlist;

  /// Builds the localized label for the user's rating.
  final String Function(String rating) userRating;

  /// Builds the localized collection-membership label.
  final String Function(int count) collectionCount;

  /// Builds the localized viewing-progress label.
  final String Function(int percentage) progress;

  /// Legacy short label for newly available content.
  ///
  /// The poster artwork no longer renders a translated NEW word. This field is
  /// retained so existing localization/controller code does not need to change
  /// immediately; the complete spoken meaning comes from
  /// [newContentDescription].
  final String newContent;

  /// Legacy short NEW-content label builder.
  ///
  /// Cineara represents every kind of new content with the same compact,
  /// theme-adaptive corner signature rather than artwork text or a numeric
  /// badge. Keeping this builder preserves source compatibility with existing
  /// ARB and controller code.
  final String Function(PosterNewContentType type, int? count) newContentBadge;

  /// Builds the localized description for newly available content.
  final String Function(PosterNewContentType type, int? count)
  newContentDescription;

  /// Builds the localized semantic label for a quick action.
  final String Function(
    PosterQuickActionType type,
    bool isActive,
    String mediaTitle,
  )
  quickAction;
}

/// Reusable poster-style media card used throughout Cineara.
///
/// The component deliberately separates:
///
/// - Cineara world/cultural identity;
/// - external ratings;
/// - the user's personal rating;
/// - viewing status;
/// - favourite and collection relationships;
/// - newly available content;
/// - quick actions;
/// - progress.
///
/// This prevents the artwork from becoming a collection of unrelated badges.
///
/// The component also progressively reduces overlay density when its available
/// width decreases.
///
/// Example:
///
/// ```dart
/// PosterMediaCard(
///   title: 'Frieren: Beyond Journey\'s End',
///   mediaTypeLabel: 'TV Series',
///   labels: posterLabels,
///   subtitle: 'S2 E7 · Japan',
///   imageUrl: posterUrl,
///   worldIdentity: const PosterWorldIdentity(
///     label: 'JP · Anime',
///     compactLabel: 'JP',
///     semanticLabel: 'Japan, Anime',
///   ),
///   externalRating: const PosterExternalRating(
///     sourceLabel: 'IMDb',
///     value: '8.9',
///   ),
///   userRating: '9.5',
///   viewingStatus: PosterViewingStatus.watching,
///   progress: 0.62,
///   newContent: const PosterNewContent(
///     type: PosterNewContentType.episodes,
///     count: 2,
///   ),
///   isFavourite: true,
///   collectionCount: 2,
///   quickAction: PosterQuickAction(
///     type: PosterQuickActionType.watchlist,
///     isActive: true,
///     onPressed: () {},
///   ),
///   onTap: () {},
///   onLongPress: () {},
/// )
/// ```
class PosterMediaCard extends StatefulWidget {
  /// Creates a Cineara poster media card.
  const PosterMediaCard({
    required this.title,
    required this.mediaTypeLabel,
    required this.labels,
    super.key,
    this.imageUrl,
    this.subtitle,
    this.secondarySubtitle,
    this.worldIdentity,
    this.externalRating,
    this.userRating,
    this.statusContext = PosterStatusContext.none,
    this.viewingStatus = PosterViewingStatus.notStarted,
    this.isFavourite = false,
    this.isInWatchlist = false,
    this.collectionCount = 0,
    this.quickAction,
    this.progress,
    this.newContent,
    this.newContentSemanticLabel,
    this.collectionSemanticLabel,
    this.progressSemanticLabel,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.aspectRatio = 2 / 3,
    this.maxTitleLines = 2,
    this.layout = PosterMediaCardLayout.artworkWithInformation,
    this.showWorldIdentity = true,
    this.showExternalRating = true,
    this.showUserRating = true,
    this.showStatusDock = true,
    this.showNewContent = true,
    this.enableHaptics = true,
  }) : assert(aspectRatio > 0),
       assert(maxTitleLines > 0),
       assert(collectionCount >= 0);

  /// Primary media title.
  final String title;

  /// Semantic/basic media type.
  ///
  /// Examples:
  /// - `Movie`
  /// - `TV Series`
  /// - `Anime Movie`
  /// - `OVA`
  ///
  /// This remains available for accessibility even when not shown visually.
  final String mediaTypeLabel;

  /// Optional poster artwork URL.
  final String? imageUrl;

  /// Context-sensitive supporting text below the title.
  ///
  /// Examples:
  /// - `Japan · Japanese`
  /// - `Hong Kong · Cantonese`
  /// - `S2 E7 · 42%`
  /// - `Caught up`
  final String? subtitle;

  /// Optional second supporting metadata line.
  ///
  /// This should contain lower-priority contextual information than [subtitle].
  ///
  /// Examples:
  /// - `South Korea · Thriller`
  /// - `Today · 21:00`
  /// - `2023 · Japan`
  final String? secondarySubtitle;

  /// Optional Cineara world-cinema identity.
  final PosterWorldIdentity? worldIdentity;

  /// Optional IMDb, TMDb, Rotten Tomatoes, etc. rating.
  final PosterExternalRating? externalRating;

  /// Rating personally assigned by the current user.
  final String? userRating;

  /// Status information already communicated by the surrounding UI.
  final PosterStatusContext statusContext;

  /// Current viewing status.
  final PosterViewingStatus viewingStatus;

  /// Whether the title is a favourite.
  final bool isFavourite;

  /// Whether the title is in the watchlist.
  final bool isInWatchlist;

  /// Number of user collections containing this media.
  final int collectionCount;

  /// Optional single quick action.
  final PosterQuickAction? quickAction;

  /// Viewing progress between `0.0` and `1.0`.
  final double? progress;

  /// Newly available content associated with the media.
  final PosterNewContent? newContent;

  /// Localized labels used by the card.
  final PosterMediaCardLabels labels;

  /// Optional accessibility description for newly available content.
  final String? newContentSemanticLabel;

  /// Optional accessibility description for collection membership.
  final String? collectionSemanticLabel;

  /// Optional accessibility description for the progress bar.
  final String? progressSemanticLabel;

  /// Opens the media detail screen.
  final VoidCallback? onTap;

  /// Opens the complete state-aware action sheet.
  final VoidCallback? onLongPress;

  /// Optional accessibility description for the complete card.
  final String? semanticLabel;

  /// Aspect ratio of the artwork.
  final double aspectRatio;

  /// Maximum number of lines used by the title.
  final int maxTitleLines;

  /// Layout variant.
  final PosterMediaCardLayout layout;

  /// Whether world identity is shown.
  final bool showWorldIdentity;

  /// Whether the external rating is shown.
  final bool showExternalRating;

  /// Whether the user's personal rating is shown.
  final bool showUserRating;

  /// Whether the passive personal-state dock is shown.
  final bool showStatusDock;

  /// Whether the single theme-adaptive new-content corner signature is shown.
  final bool showNewContent;

  /// Whether interaction haptics are enabled.
  final bool enableHaptics;

  @override
  State<PosterMediaCard> createState() => _PosterMediaCardState();
}

class _PosterMediaCardState extends State<PosterMediaCard> {
  static const Duration _minimumPressDuration = Duration(milliseconds: 90);

  bool _isPressed = false;

  DateTime? _pressStartedAt;

  bool get _isTappable => widget.onTap != null;

  bool get _supportsLongPress => widget.onLongPress != null;

  bool get _isInteractive => _isTappable || _supportsLongPress;

  bool get _hasNewContent {
    final PosterNewContent? newContent = widget.newContent;

    if (!widget.showNewContent || newContent == null) {
      return false;
    }

    return switch (newContent.type) {
      // A newly released movie, series, season, etc. may always show the new-content treatment.
      PosterNewContentType.release => true,

      // New episodes are relevant once the user has engaged with the title.
      PosterNewContentType.episodes => switch (widget.viewingStatus) {
        PosterViewingStatus.notStarted => false,
        PosterViewingStatus.watching => true,
        PosterViewingStatus.caughtUp => true,
        PosterViewingStatus.completed => true,
        PosterViewingStatus.rewatching => true,
        PosterViewingStatus.onHold => true,
        PosterViewingStatus.dropped => false,
      },
    };
  }

  double? get _normalisedProgress {
    final double? rawProgress = widget.progress;

    if (rawProgress == null) {
      return null;
    }

    final double progress = rawProgress.clamp(0.0, 1.0);

    if (progress >= 0.999 &&
        (widget.viewingStatus == PosterViewingStatus.completed ||
            widget.viewingStatus == PosterViewingStatus.caughtUp)) {
      return null;
    }

    return progress;
  }

  bool get _quickActionShowsWatchlist {
    final PosterQuickAction? action = widget.quickAction;

    return action != null &&
        action.isActive &&
        action.type == PosterQuickActionType.watchlist;
  }

  bool get _quickActionShowsFavourite {
    final PosterQuickAction? action = widget.quickAction;

    return action != null &&
        action.isActive &&
        action.type == PosterQuickActionType.favourite;
  }

  bool get _quickActionShowsWatched {
    final PosterQuickAction? action = widget.quickAction;

    return action != null &&
        action.isActive &&
        action.type == PosterQuickActionType.watched;
  }

  List<_PosterStatusItem> get _statusItems {
    final List<_PosterStatusItem> items = <_PosterStatusItem>[];

    if (widget.statusContext != PosterStatusContext.viewingStatus &&
        !_quickActionShowsWatched) {
      switch (widget.viewingStatus) {
        case PosterViewingStatus.notStarted:
          break;

        case PosterViewingStatus.watching:
          if (_normalisedProgress == null) {
            items.add(
              _PosterStatusItem(
                icon: Icons.play_arrow_rounded,
                semanticLabel: widget.labels.watching,
                tone: _PosterStatusTone.watching,
              ),
            );
          }
          break;

        case PosterViewingStatus.caughtUp:
          items.add(
            _PosterStatusItem(
              icon: Icons.done_all_rounded,
              semanticLabel: widget.labels.caughtUp,
              tone: _PosterStatusTone.completed,
            ),
          );
          break;

        case PosterViewingStatus.completed:
          items.add(
            _PosterStatusItem(
              icon: Icons.check_rounded,
              semanticLabel: widget.labels.completed,
              tone: _PosterStatusTone.completed,
            ),
          );
          break;

        case PosterViewingStatus.rewatching:
          items.add(
            _PosterStatusItem(
              icon: Icons.replay_rounded,
              semanticLabel: widget.labels.rewatching,
              tone: _PosterStatusTone.rewatching,
            ),
          );
          break;

        case PosterViewingStatus.onHold:
          items.add(
            _PosterStatusItem(
              icon: Icons.pause_rounded,
              semanticLabel: widget.labels.onHold,
              tone: _PosterStatusTone.onHold,
            ),
          );
          break;

        case PosterViewingStatus.dropped:
          items.add(
            _PosterStatusItem(
              icon: Icons.block_rounded,
              semanticLabel: widget.labels.dropped,
              tone: _PosterStatusTone.dropped,
            ),
          );
          break;
      }
    }

    if (widget.isInWatchlist &&
        !_quickActionShowsWatchlist &&
        widget.statusContext != PosterStatusContext.watchlist) {
      items.add(
        _PosterStatusItem(
          icon: Icons.bookmark_rounded,
          semanticLabel: widget.labels.watchlist,
          tone: _PosterStatusTone.watchlist,
        ),
      );
    }

    if (widget.isFavourite &&
        !_quickActionShowsFavourite &&
        widget.statusContext != PosterStatusContext.favourite) {
      items.add(
        _PosterStatusItem(
          icon: Icons.favorite_rounded,
          semanticLabel: widget.labels.favourite,
          tone: _PosterStatusTone.favourite,
        ),
      );
    }

    if (widget.collectionCount > 0 &&
        widget.statusContext != PosterStatusContext.collection) {
      items.add(
        _PosterStatusItem(
          icon: Icons.video_library_rounded,
          semanticLabel:
              widget.collectionSemanticLabel ??
              widget.labels.collectionCount(widget.collectionCount),
          tone: _PosterStatusTone.collection,
        ),
      );
    }

    return items;
  }

  String get _viewingStatusSemanticLabel {
    return switch (widget.viewingStatus) {
      PosterViewingStatus.notStarted => widget.labels.notStarted,
      PosterViewingStatus.watching => widget.labels.watching,
      PosterViewingStatus.caughtUp => widget.labels.caughtUp,
      PosterViewingStatus.completed => widget.labels.completed,
      PosterViewingStatus.rewatching => widget.labels.rewatching,
      PosterViewingStatus.onHold => widget.labels.onHold,
      PosterViewingStatus.dropped => widget.labels.dropped,
    };
  }

  String get _resolvedSemanticLabel {
    if (widget.semanticLabel case final String label
        when label.trim().isNotEmpty) {
      return label;
    }

    final List<String> parts = <String>[widget.title, widget.mediaTypeLabel];

    if (widget.worldIdentity case final PosterWorldIdentity identity) {
      parts.add(identity.semanticLabel);
    }

    if (widget.subtitle case final String subtitle
        when subtitle.trim().isNotEmpty) {
      parts.add(subtitle);
    }

    if (widget.secondarySubtitle case final String secondarySubtitle
        when secondarySubtitle.trim().isNotEmpty) {
      parts.add(secondarySubtitle);
    }

    if (widget.externalRating case final PosterExternalRating rating
        when widget.showExternalRating) {
      // Keep the fallback language-neutral. Apps that want a richer spoken
      // phrase can provide PosterExternalRating.semanticLabel.
      parts.add(
        rating.semanticLabel ?? '${rating.sourceLabel}, ${rating.value}',
      );
    }

    if (widget.userRating case final String rating
        when rating.trim().isNotEmpty && widget.showUserRating) {
      parts.add(widget.labels.userRating(rating));
    }

    if (widget.viewingStatus != PosterViewingStatus.notStarted) {
      parts.add(_viewingStatusSemanticLabel);
    }

    final PosterNewContent? newContent = widget.newContent;

    if (_hasNewContent && newContent != null) {
      parts.add(
        widget.newContentSemanticLabel ??
            widget.labels.newContentDescription(
              newContent.type,
              newContent.count,
            ),
      );
    }

    if (widget.isFavourite) {
      parts.add(widget.labels.favourite);
    }

    if (widget.collectionCount > 0) {
      parts.add(
        widget.collectionSemanticLabel ??
            widget.labels.collectionCount(widget.collectionCount),
      );
    }

    final PosterQuickAction? quickAction = widget.quickAction;

    if (widget.isInWatchlist ||
        (quickAction != null &&
            quickAction.type == PosterQuickActionType.watchlist &&
            quickAction.isActive)) {
      parts.add(widget.labels.watchlist);
    }

    if (_normalisedProgress case final double progress) {
      final int percentage = (progress * 100).round();

      parts.add(
        widget.progressSemanticLabel ?? widget.labels.progress(percentage),
      );
    }

    return parts.join(', ');
  }

  void _handleTapDown(TapDownDetails _) {
    if (_isPressed) {
      return;
    }

    _pressStartedAt = DateTime.now();

    setState(() {
      _isPressed = true;
    });
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

    _scheduleRelease();

    if (widget.enableHaptics) {
      HapticFeedback.mediumImpact();
    }

    callback();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final bool reduceMotion = mediaQuery.disableAnimations;
    final bool boldText = mediaQuery.boldText;
    final bool highContrast = mediaQuery.highContrast;

    final Duration interactionDuration = reduceMotion
        ? Duration.zero
        : CinearaMotion.fast;

    final Duration scaleDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 90);

    final BorderRadius artworkRadius = BorderRadius.circular(CinearaRadii.lg);

    final PosterNewContent? visibleNewContent = _hasNewContent
        ? widget.newContent
        : null;

    final Widget artwork = _PosterArtwork(
      title: widget.title,
      imageUrl: widget.imageUrl,
      worldIdentity: widget.showWorldIdentity ? widget.worldIdentity : null,
      userRating: widget.showUserRating ? widget.userRating : null,
      externalRating: widget.showExternalRating ? widget.externalRating : null,
      statusItems: widget.showStatusDock
          ? _statusItems
          : const <_PosterStatusItem>[],
      quickAction: widget.quickAction,
      progress: _normalisedProgress,
      newContent: visibleNewContent,
      labels: widget.labels,
      aspectRatio: widget.aspectRatio,
      enableHaptics: widget.enableHaptics,
      animationDuration: interactionDuration,
      boldText: boldText,
      highContrast: highContrast,
    );

    final Widget artworkCard = AnimatedScale(
      scale: _isPressed && !reduceMotion ? 0.985 : 1.0,
      duration: scaleDuration,
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: scaleDuration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: artworkRadius,

          // Theme-adaptive Cineara interaction glow.
          boxShadow: _isPressed
              ? <BoxShadow>[
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.18),
                    blurRadius: 9,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.055),
                    blurRadius: 13,
                    spreadRadius: 0,
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: artworkRadius),
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              InkWell(
                excludeFromSemantics: true,
                onTap: widget.onTap == null ? null : _handleTap,
                onTapDown: _isInteractive ? _handleTapDown : null,
                onTapCancel: _isInteractive ? _handleTapCancel : null,
                onLongPress: _supportsLongPress ? _handleLongPress : null,
                splashFactory: NoSplash.splashFactory,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                borderRadius: artworkRadius,
                child: artwork,
              ),

              // Subtle inner glow that is guaranteed to remain visible even if
              // the surrounding grid clips external shadows.
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _isPressed && !reduceMotion ? 1.0 : 0.0,
                    duration: scaleDuration,
                    curve: Curves.easeOutCubic,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: artworkRadius,
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: highContrast ? 0.88 : 0.52,
                          ),
                          width: highContrast ? 1.75 : 1.25,
                        ),
                        gradient: LinearGradient(
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                          colors: <Color>[
                            theme.colorScheme.tertiary.withValues(alpha: 0.10),
                            theme.colorScheme.primary.withValues(alpha: 0.055),
                            Colors.transparent,
                            theme.colorScheme.secondary.withValues(alpha: 0.09),
                          ],
                          stops: const <double>[0.0, 0.30, 0.60, 1.0],
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
    );

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        artworkCard,

        if (widget.layout ==
            PosterMediaCardLayout.artworkWithInformation) ...<Widget>[
          const SizedBox(height: CinearaSpacing.xs),

          _PosterInformation(
            title: widget.title,
            subtitle: widget.subtitle,
            secondarySubtitle: widget.secondarySubtitle,
            maxTitleLines: widget.maxTitleLines,
            boldText: boldText,
            highContrast: highContrast,
          ),
        ],
      ],
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      button: widget.onTap != null,
      label: _resolvedSemanticLabel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: content,
    );
  }
}

/// Responsive information density inside poster artwork.
///
/// Cineara removes low-priority information as width decreases instead of
/// simply making every element smaller.
enum _PosterDensity { tiny, compact, regular, spacious }

double _effectiveTextScale(BuildContext context) {
  final TextScaler scaler = MediaQuery.textScalerOf(context);

  // Measuring a representative font size works with both linear and nonlinear
  // TextScaler implementations without using deprecated textScaleFactor APIs.
  return scaler.scale(16) / 16;
}

/// Returns the restrained accessibility scale used by poster overlays.
///
/// Artwork overlays live inside fixed poster geometry, so following the full
/// platform text multiplier would quickly make pills collide with one another.
/// Cineara therefore applies only part of the requested growth and caps the
/// result at 20% above the normal size. Titles and metadata outside the artwork
/// still use the platform's normal text scaling.
double _overlayTextScale(BuildContext context) {
  final double textScale = _effectiveTextScale(context);

  // Apply 35% of any requested growth. Examples:
  // 1.0 system scale -> 1.00 overlay scale
  // 1.5 system scale -> 1.175 overlay scale
  // 2.0 system scale -> capped at 1.20
  final double restrainedScale = 1.0 + ((textScale - 1.0) * 0.35);

  return restrainedScale.clamp(1.0, 1.20).toDouble();
}

_PosterDensity _resolveDensity({
  required double width,
  required double height,
  required double textScale,
}) {
  // Enlarged text consumes the same finite poster surface as the overlays.
  // Resolve density from an effective width so lower-priority overlay details
  // disappear before they collide or become unreadable.
  final double effectiveWidth = width / textScale.clamp(1.0, 1.60).toDouble();

  // Custom artwork ratios can create very shallow cards. In that case width
  // alone is misleading, so progressively reduce overlay density by height.
  if (height < 86 || effectiveWidth < 100) {
    return _PosterDensity.tiny;
  }

  if (height < 112 || effectiveWidth < 145) {
    return _PosterDensity.compact;
  }

  if (height < 150 || effectiveWidth < 220) {
    return _PosterDensity.regular;
  }

  return _PosterDensity.spacious;
}

/// Poster artwork section of [PosterMediaCard].
class _PosterArtwork extends StatelessWidget {
  const _PosterArtwork({
    required this.title,
    required this.imageUrl,
    required this.worldIdentity,
    required this.externalRating,
    required this.userRating,
    required this.statusItems,
    required this.quickAction,
    required this.progress,
    required this.newContent,
    required this.labels,
    required this.aspectRatio,
    required this.enableHaptics,
    required this.animationDuration,
    required this.boldText,
    required this.highContrast,
  });

  /// Media title, also used for accessibility and image fallback content.
  final String title;

  /// Poster image URL, or null when no artwork is available.
  final String? imageUrl;

  /// Optional world-cinema identity shown on the poster.
  final PosterWorldIdentity? worldIdentity;

  /// Optional user rating.
  final String? userRating;

  /// Optional external rating such as IMDb or TMDB.
  final PosterExternalRating? externalRating;

  /// Status indicators displayed on the poster.
  final List<_PosterStatusItem> statusItems;

  /// Optional quick action displayed on the artwork.
  final PosterQuickAction? quickAction;

  /// Viewing progress from 0.0 to 1.0, or null when not shown.
  final double? progress;

  /// Newly available content, or null when the new-content treatment is hidden.
  ///
  /// The visual treatment is language-independent and theme-adaptive. Movies,
  /// series, and episodic updates all use the same corner signature; the actual
  /// content type/count remains available through the parent card semantics.
  final PosterNewContent? newContent;

  /// Localized labels used by poster controls.
  final PosterMediaCardLabels labels;

  /// Width-to-height ratio of the poster artwork.
  final double aspectRatio;

  /// Whether supported interactions should trigger haptic feedback.
  final bool enableHaptics;

  /// Duration used by artwork animations and transitions.
  final Duration animationDuration;

  /// Whether the platform has requested bolder text.
  final bool boldText;

  /// Whether the platform has requested higher visual contrast.
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : 160;
          final double height = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : width / aspectRatio;

          final double textScale = _effectiveTextScale(context);
          final _PosterDensity density = _resolveDensity(
            width: width,
            height: height,
            textScale: textScale,
          );

          final bool hasWorldIdentity = worldIdentity != null;
          final bool hasNewContent = newContent != null;
          final bool hasUserRating =
              userRating != null && userRating!.trim().isNotEmpty;

          // World identity is a core Cineara feature and therefore receives
          // higher priority than external ratings on tiny cards.
          final bool canShowExternalRating =
              externalRating != null &&
              !(density == _PosterDensity.tiny &&
                  (hasWorldIdentity || hasNewContent));

          // The personal score is lower-priority overlay information. On tiny
          // posters it is removed before core Cineara identity and state.
          final bool canShowUserRating =
              hasUserRating && density != _PosterDensity.tiny && height >= 110;

          final int baseMaxVisibleStatuses = switch (density) {
            _PosterDensity.tiny => 1,
            _PosterDensity.compact => 1,
            _PosterDensity.regular => 2,
            _PosterDensity.spacious => 3,
          };

          final int maxVisibleStatuses = textScale >= 1.80
              ? 1
              : baseMaxVisibleStatuses;

          final bool canShowStatusDock =
              statusItems.isNotEmpty &&
              height >= 92 &&
              !(quickAction != null &&
                  (density == _PosterDensity.tiny || width < 104));

          const double overlayInset = CinearaSpacing.xs;

          final bool hasTopOverlay = hasWorldIdentity || canShowExternalRating;

          final bool hasBottomOverlay =
              canShowUserRating || canShowStatusDock || quickAction != null;

          return Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              _PosterImage(title: title, imageUrl: imageUrl),

              _PosterGradient(
                showTop: hasTopOverlay,
                showBottom: hasBottomOverlay || progress != null,
              ),

              //
              // TOP METADATA
              //
              if (hasTopOverlay)
                PositionedDirectional(
                  top: overlayInset,
                  start: overlayInset,
                  end: overlayInset,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (worldIdentity case final PosterWorldIdentity identity)
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: _WorldIdentityChip(
                              identity: identity,
                              boldText: boldText,
                              highContrast: highContrast,
                            ),
                          ),
                        )
                      else
                        const Spacer(),

                      if (hasWorldIdentity && canShowExternalRating)
                        const SizedBox(width: CinearaSpacing.xxs),

                      if (canShowExternalRating)
                        _ExternalRatingMark(
                          rating: externalRating!,
                          boldText: boldText,
                          highContrast: highContrast,
                        ),
                    ],
                  ),
                ),

              //
              // NEW CONTENT CORNER SIGNATURE
              //
              // Every kind of new content uses exactly the same visual mark.
              // Release type and episode count remain semantic/domain data and
              // do not alter the artwork treatment. The mark uses the active
              // theme's brand colours so it changes naturally with the theme.
              if (newContent != null)
                Positioned.fill(
                  child: _PosterNewContentIndicator(
                    animationDuration: animationDuration,
                    highContrast: highContrast,
                  ),
                ),

              //
              // PERSONAL STATE + QUICK ACTION
              //
              if (hasBottomOverlay)
                PositionedDirectional(
                  start: overlayInset,
                  end: overlayInset,
                  bottom: progress != null ? 8 : 6,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      if (canShowUserRating || canShowStatusDock)
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.bottomStart,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Personal Cineara rating.
                                if (canShowUserRating)
                                  _UserRatingMark(
                                    value: userRating!,
                                    boldText: boldText,
                                    highContrast: highContrast,
                                  ),

                                // Small separation between rating and status
                                // dock.
                                if (canShowUserRating && canShowStatusDock)
                                  const SizedBox(height: CinearaSpacing.xxs),

                                // Passive personal/media states.
                                if (canShowStatusDock)
                                  _PosterStatusDock(
                                    items: statusItems,
                                    maxVisibleItems: maxVisibleStatuses,
                                    animationDuration: animationDuration,
                                    highContrast: highContrast,
                                  ),
                              ],
                            ),
                          ),
                        )
                      else
                        const Spacer(),

                      // Interactive quick-add / manage control.
                      if (quickAction case final PosterQuickAction action)
                        _PosterQuickActionButton(
                          action: action,
                          mediaTitle: title,
                          density: density,
                          enableHaptics: enableHaptics,
                          animationDuration: animationDuration,
                          labels: labels,
                        ),
                    ],
                  ),
                ),

              //
              // CINEARA PROGRESS EDGE
              //
              if (progress != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _PosterJourneyEdge(progress: progress!),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Loads poster artwork while preserving dimensions.
class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.title, required this.imageUrl});

  /// Media title, also used for accessibility and image fallback content.
  final String title;

  /// Poster image URL, or null when no artwork is available.
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final String? resolvedUrl = switch (imageUrl?.trim()) {
      final String value when value.isNotEmpty => value,
      _ => null,
    };

    final Widget placeholder = _PosterPlaceholder(title: title);

    if (resolvedUrl == null) {
      return placeholder;
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        placeholder,

        Image.network(
          resolvedUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          excludeFromSemantics: true,
          frameBuilder:
              (
                BuildContext context,
                Widget child,
                int? frame,
                bool wasSynchronouslyLoaded,
              ) {
                if (wasSynchronouslyLoaded) {
                  return child;
                }

                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: reduceMotion
                      ? Duration.zero
                      : CinearaMotion.standard,
                  curve: Curves.easeOut,
                  child: child,
                );
              },
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
                // The placeholder remains underneath the failed image.
                return const SizedBox.expand();
              },
        ),
      ],
    );
  }
}

/// Cineara-branded artwork fallback.
///
/// The placeholder adapts to the space provided by the parent rather than
/// assuming a poster aspect ratio. Portrait and square artwork use a vertical
/// composition, while shallow landscape artwork switches to a horizontal one.
/// Extremely small containers show only the Cineara artwork mark.
class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({required this.title});

  /// Media title used by the placeholder.
  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final CinearaThemeExtension? cinearaTheme = theme
        .extension<CinearaThemeExtension>();

    final Color backgroundColor =
        cinearaTheme?.posterPlaceholder ??
        theme.colorScheme.surfaceContainerHigh;

    return ExcludeSemantics(
      child: ColoredBox(
        color: backgroundColor,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;

            // Nothing useful can be rendered without finite positive space.
            if (!width.isFinite ||
                !height.isFinite ||
                width <= 0 ||
                height <= 0) {
              return const SizedBox.shrink();
            }

            final double shortestSide = width < height ? width : height;
            final double textScale = _effectiveTextScale(context);

            final double aspectRatio = width / height;

            // Landscape artwork benefits from placing the title beside the mark
            // instead of stacking everything vertically.
            final bool useHorizontalLayout =
                aspectRatio >= 1.25 && height < 150;

            // Very small cards cannot carry useful text without creating visual
            // noise or risking overflow.
            final bool showTitle =
                shortestSide >= (64 * textScale.clamp(1.0, 1.40)) &&
                height >= (56 * textScale.clamp(1.0, 1.40)) &&
                !(textScale >= 1.80 && shortestSide < 180);

            final int placeholderTitleLines = textScale >= 1.30 ? 3 : 2;

            final double iconSize = (shortestSide * 0.34)
                .clamp(22.0, 42.0)
                .toDouble();

            final double playIconSize = (iconSize * 0.43)
                .clamp(10.0, 18.0)
                .toDouble();

            final double outerPadding = (shortestSide * 0.12)
                .clamp(CinearaSpacing.xs, CinearaSpacing.lg)
                .toDouble();

            final double spacing = (shortestSide * 0.08)
                .clamp(CinearaSpacing.xxs, CinearaSpacing.sm)
                .toDouble();

            final Widget artworkMark = _PosterPlaceholderMark(
              globeSize: iconSize,
              playSize: playIconSize,
            );

            if (!showTitle) {
              return Center(child: artworkMark);
            }

            if (useHorizontalLayout) {
              return Padding(
                padding: EdgeInsets.all(outerPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    artworkMark,

                    SizedBox(width: spacing),

                    Flexible(
                      child: Text(
                        title,
                        maxLines: placeholderTitleLines,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: true,
                          applyHeightToLastDescent: true,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          height: 1.28,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.all(outerPadding),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    artworkMark,

                    SizedBox(height: spacing),

                    Flexible(
                      child: Text(
                        title,
                        maxLines: placeholderTitleLines,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: true,
                          applyHeightToLastDescent: true,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          height: 1.28,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Cineara globe/play mark displayed by [_PosterPlaceholder].
class _PosterPlaceholderMark extends StatelessWidget {
  const _PosterPlaceholderMark({
    required this.globeSize,
    required this.playSize,
  });

  final double globeSize;
  final double playSize;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Icon(
          Icons.public_rounded,
          size: globeSize,
          color: theme.colorScheme.primary.withValues(alpha: 0.78),
        ),
        Icon(
          Icons.play_arrow_rounded,
          size: playSize,
          color: CinearaColours.neutral0,
        ),
      ],
    );
  }
}

/// Adaptive contrast gradient used only where overlay UI requires it.
class _PosterGradient extends StatelessWidget {
  const _PosterGradient({required this.showTop, required this.showBottom});

  /// Whether to show the gradient at the top of the poster.
  final bool showTop;

  /// Whether to show the gradient at the bottom of the poster.
  final bool showBottom;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Colors.black.withValues(alpha: showTop ? 0.30 : 0),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: showBottom ? 0.40 : 0),
            ],
            stops: const <double>[0, 0.22, 0.65, 1],
          ),
        ),
      ),
    );
  }
}

/// Compact Cineara world-cinema marker.
///
/// Only the stable country/region code is rendered on poster artwork.
/// Richer cultural identity such as `K-Drama`, `Anime`, `Malayalam`, etc.
/// belongs in metadata, the detail screen, World Lens or the long-press sheet.
///
/// The marker grows slightly with accessibility text while using a restrained
/// capped scale so it remains compact inside poster artwork.
class _WorldIdentityChip extends StatelessWidget {
  const _WorldIdentityChip({
    required this.identity,
    required this.boldText,
    required this.highContrast,
  });

  final PosterWorldIdentity identity;
  final bool boldText;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final double overlayScale = _overlayTextScale(context);

    final double width = 32 * overlayScale;
    final double height = 24 * overlayScale;

    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(CinearaRadii.pill),
            border: Border.all(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.32),
              width: highContrast ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6 * overlayScale),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                identity.compactLabel,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(overlayScale),
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: true,
                  applyHeightToLastDescent: true,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontSize: CinearaFontSizes.labelSmall,
                  fontWeight: boldText ? FontWeight.w900 : FontWeight.w800,
                  height: 1.15,
                  letterSpacing: 0.1,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// External/community rating.
///
/// The rating uses the same restrained accessibility scaling as the other
/// artwork pills while keeping a predictable compact footprint.
class _ExternalRatingMark extends StatelessWidget {
  const _ExternalRatingMark({
    required this.rating,
    required this.boldText,
    required this.highContrast,
  });

  final PosterExternalRating rating;
  final bool boldText;
  final bool highContrast;

  static const double _baseWidth = 38;
  static const double _baseHeight = 20;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CinearaThemeExtension cinearaTheme = theme
        .extension<CinearaThemeExtension>()!;

    final double overlayScale = _overlayTextScale(context);

    return ExcludeSemantics(
      child: SizedBox(
        width: _baseWidth * overlayScale,
        height: _baseHeight * overlayScale,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cinearaTheme.artworkOverlaySurface,
            borderRadius: BorderRadius.circular(CinearaRadii.pill),
            border: Border.all(
              color: cinearaTheme.artworkOverlayOutline,
              width: highContrast ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4 * overlayScale),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  rating.value,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(overlayScale),
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: true,
                    applyHeightToLastDescent: true,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: CinearaColours.neutral0,
                    fontSize: 10.5,
                    fontWeight: boldText ? FontWeight.w900 : FontWeight.w800,
                    height: 1.15,
                    leadingDistribution: TextLeadingDistribution.even,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Passive personal Cineara rating.
///
/// Uses the same fixed artwork-safe neutral surface and restrained
/// accessibility scaling as the other utility overlays.
class _UserRatingMark extends StatelessWidget {
  const _UserRatingMark({
    required this.value,
    required this.boldText,
    required this.highContrast,
  });

  final String value;
  final bool boldText;
  final bool highContrast;

  static const double _baseWidth = 38;
  static const double _baseHeight = 20;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final CinearaThemeExtension cinearaTheme = theme
        .extension<CinearaThemeExtension>()!;

    final double overlayScale = _overlayTextScale(context);

    return ExcludeSemantics(
      child: SizedBox(
        width: _baseWidth * overlayScale,
        height: _baseHeight * overlayScale,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cinearaTheme.artworkOverlaySurface,
            borderRadius: BorderRadius.circular(CinearaRadii.pill),
            border: Border.all(
              color: cinearaTheme.artworkOverlayOutline,
              width: highContrast ? 1.5 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: highContrast ? 0.30 : 0.18,
                ),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4 * overlayScale),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.star_rounded,
                      size: 9 * overlayScale,
                      color: CinearaColours.userRating,
                    ),
                    SizedBox(width: 2 * overlayScale),
                    Text(
                      value,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.linear(overlayScale),
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: true,
                        applyHeightToLastDescent: true,
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: CinearaColours.userRating,
                        fontSize: 10,
                        fontWeight: boldText
                            ? FontWeight.w900
                            : FontWeight.w800,
                        height: 1.15,
                        leadingDistribution: TextLeadingDistribution.even,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
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
  }
}

/// Theme-adaptive edge signature for newly available content.
///
/// Movies, series, seasons, and episode updates all use the same compact
/// top/trailing corner mark. The visual does not encode the content type or
/// count; that information remains available through the card semantics.
///
/// The geometry stays identical across themes, while its brand colours come
/// from the active [ColorScheme].
class _PosterNewContentIndicator extends StatelessWidget {
  const _PosterNewContentIndicator({
    required this.animationDuration,
    required this.highContrast,
  });

  final Duration animationDuration;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = animationDuration == Duration.zero;

    return IgnorePointer(
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;

            if (!width.isFinite ||
                !height.isFinite ||
                width <= 0 ||
                height <= 0) {
              return const SizedBox.shrink();
            }

            final double shortestSide = width < height ? width : height;
            final double length = (shortestSide * 0.34)
                .clamp(28.0, 52.0)
                .toDouble();
            final double thickness = highContrast ? 3.25 : 2.5;

            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double value, Widget? child) {
                final double reveal = reduceMotion ? 1.0 : value;

                return Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    PositionedDirectional(
                      top: 0,
                      end: 0,
                      child: Opacity(
                        opacity: highContrast ? 1.0 : (0.42 + (0.58 * reveal)),
                        child: _PosterNewContentCornerStroke(
                          length: length * (0.38 + (0.62 * reveal)),
                          thickness: thickness,
                          highContrast: highContrast,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// One L-shaped piece of Cineara's universal new-content signature.
///
/// The shape is stable, but its colours follow the active theme so new-content
/// feedback remains part of the current Cineara visual identity.
class _PosterNewContentCornerStroke extends StatelessWidget {
  const _PosterNewContentCornerStroke({
    required this.length,
    required this.thickness,
    required this.highContrast,
  });

  final double length;
  final double thickness;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color start = theme.colorScheme.tertiary;
    final Color end = theme.colorScheme.primary;

    final List<BoxShadow> shadows = highContrast
        ? const <BoxShadow>[]
        : <BoxShadow>[
            BoxShadow(
              color: end.withValues(alpha: 0.34),
              blurRadius: 5,
              spreadRadius: 0,
            ),
          ];

    return SizedBox(
      width: length,
      height: length,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: <Widget>[
          PositionedDirectional(
            top: 0,
            start: 0,
            end: 0,
            child: Container(
              height: thickness,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CinearaRadii.pill),
                gradient: LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: <Color>[
                    start.withValues(alpha: 0),
                    start.withValues(alpha: highContrast ? 0.80 : 0.42),
                    end.withValues(alpha: highContrast ? 1.0 : 0.96),
                  ],
                  stops: const <double>[0.0, 0.48, 1.0],
                ),
                boxShadow: shadows,
              ),
            ),
          ),
          PositionedDirectional(
            top: 0,
            bottom: 0,
            end: 0,
            child: Container(
              width: thickness,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CinearaRadii.pill),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    end.withValues(alpha: highContrast ? 1.0 : 0.96),
                    start.withValues(alpha: highContrast ? 0.80 : 0.42),
                    start.withValues(alpha: 0),
                  ],
                  stops: const <double>[0.0, 0.52, 1.0],
                ),
                boxShadow: shadows,
              ),
            ),
          ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Container(
              width: thickness * 1.55,
              height: thickness * 1.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: end.withValues(alpha: highContrast ? 1.0 : 0.96),
                boxShadow: shadows,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Semantic visual category for one passive personal-state icon.
enum _PosterStatusTone {
  watching,
  completed,
  watchlist,
  favourite,
  collection,
  rewatching,
  onHold,
  dropped,
}

/// One passive status item.
@immutable
class _PosterStatusItem {
  const _PosterStatusItem({
    required this.icon,
    required this.semanticLabel,
    required this.tone,
  });

  /// Icon representing the status.
  final IconData icon;

  /// Accessibility label describing the status.
  final String semanticLabel;

  /// Visual colour category used for the status.
  final _PosterStatusTone tone;
}

/// Compact Cineara Status Dock.
///
/// The dock smoothly expands and contracts as personal states change.
/// Newly added status icons animate independently so existing states remain
/// visually stable.
class _PosterStatusDock extends StatelessWidget {
  const _PosterStatusDock({
    required this.items,
    required this.maxVisibleItems,
    required this.animationDuration,
    required this.highContrast,
  });

  /// Status items available to display.
  final List<_PosterStatusItem> items;

  /// Maximum number of status items shown at once.
  final int maxVisibleItems;

  /// Duration used for dock state transitions.
  final Duration animationDuration;

  final bool highContrast;

  /// Resolves the fixed colour associated with each personal-state category.
  ///
  /// These icon colours intentionally do not follow the active app theme.
  /// They are semantic poster-overlay colours and must remain visually stable
  /// across Light, Dark, Sunrise and future Cineara themes.
  Color _resolveStatusColor(_PosterStatusTone tone) {
    return switch (tone) {
      _PosterStatusTone.watching => CinearaColours.statusWatching,
      _PosterStatusTone.completed => CinearaColours.statusCompleted,
      _PosterStatusTone.watchlist => CinearaColours.statusWatchlist,
      _PosterStatusTone.favourite => CinearaColours.statusFavourite,
      _PosterStatusTone.collection => CinearaColours.statusCollection,
      _PosterStatusTone.rewatching => CinearaColours.statusRewatching,
      _PosterStatusTone.onHold => CinearaColours.statusOnHold,
      _PosterStatusTone.dropped => CinearaColours.statusDropped,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final CinearaThemeExtension cinearaTheme = theme
        .extension<CinearaThemeExtension>()!;

    final double overlayScale = _overlayTextScale(context);

    final int visibleCount = items.length < maxVisibleItems
        ? items.length
        : maxVisibleItems;

    final List<_PosterStatusItem> visibleItems = items
        .take(visibleCount)
        .toList(growable: false);

    final int hiddenCount = items.length - visibleItems.length;

    return ExcludeSemantics(
      child: AnimatedSize(
        duration: animationDuration,
        curve: Curves.easeOutCubic,
        alignment: AlignmentDirectional.centerStart,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cinearaTheme.artworkOverlaySurface,
            borderRadius: BorderRadius.circular(CinearaRadii.pill),
            border: Border.all(
              color: cinearaTheme.artworkOverlayOutline,
              width: highContrast ? 1.5 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: SizedBox(
            height: (20 * overlayScale).clamp(20.0, 24.0).toDouble(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6 * overlayScale),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  for (
                    int index = 0;
                    index < visibleItems.length;
                    index++
                  ) ...<Widget>[
                    _AnimatedPosterStatusIcon(
                      key: ValueKey<String>(visibleItems[index].semanticLabel),
                      icon: visibleItems[index].icon,
                      color: _resolveStatusColor(visibleItems[index].tone),
                      animationDuration: animationDuration,
                      iconSize: 13 * overlayScale,
                    ),

                    if (index != visibleItems.length - 1 || hiddenCount > 0)
                      SizedBox(width: 3 * overlayScale),
                  ],

                  if (hiddenCount > 0)
                    _AnimatedPosterStatusOverflow(
                      key: ValueKey<int>(hiddenCount),
                      hiddenCount: hiddenCount,
                      animationDuration: animationDuration,
                      textScale: overlayScale,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: CinearaColours.neutral0,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1.10,
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
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

/// Animates a newly introduced status icon.
///
/// Existing icons keep their state because each icon receives a stable key.
class _AnimatedPosterStatusIcon extends StatelessWidget {
  const _AnimatedPosterStatusIcon({
    required this.icon,
    required this.color,
    required this.animationDuration,
    required this.iconSize,
    super.key,
  });

  /// Icon representing the personal state.
  final IconData icon;

  /// Colour associated with the personal state.
  final Color color;

  /// Duration of the entrance animation.
  final Duration animationDuration;

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 2 * (1 - value)),
            child: Transform.scale(scale: 0.88 + (0.12 * value), child: child),
          ),
        );
      },
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}

/// Animated count used when additional status items are hidden.
class _AnimatedPosterStatusOverflow extends StatelessWidget {
  const _AnimatedPosterStatusOverflow({
    required this.hiddenCount,
    required this.animationDuration,
    required this.textScale,
    required this.style,
    super.key,
  });

  /// Number of status items hidden from the compact dock.
  final int hiddenCount;

  /// Duration of the count transition.
  final Duration animationDuration;

  final double textScale;

  /// Text style used by the overflow count.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: animationDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        '+$hiddenCount',
        key: ValueKey<int>(hiddenCount),
        maxLines: 1,
        softWrap: false,
        textScaler: TextScaler.linear(textScale),
        textHeightBehavior: const TextHeightBehavior(
          applyHeightToFirstAscent: true,
          applyHeightToLastDescent: true,
          leadingDistribution: TextLeadingDistribution.even,
        ),
        style: style,
      ),
    );
  }
}

/// Single interactive shortcut displayed at the bottom-right of the artwork.
///
/// Interaction:
/// - compresses slightly while pressed;
/// - gives a short spring-like pop after activation;
/// - emits a restrained Cineara-coloured confirmation ring;
/// - optionally provides light haptic feedback.
class _PosterQuickActionButton extends StatefulWidget {
  const _PosterQuickActionButton({
    required this.action,
    required this.mediaTitle,
    required this.density,
    required this.enableHaptics,
    required this.animationDuration,
    required this.labels,
  });

  final PosterQuickAction action;
  final String mediaTitle;
  final _PosterDensity density;
  final bool enableHaptics;
  final Duration animationDuration;
  final PosterMediaCardLabels labels;

  @override
  State<_PosterQuickActionButton> createState() =>
      _PosterQuickActionButtonState();
}

/// State for the poster quick-action button.
///
/// Tracks the pressed interaction state and controls the short confirmation
/// animation shown after the action is triggered.
class _PosterQuickActionButtonState extends State<_PosterQuickActionButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  late final AnimationController _confirmationController;

  late final Animation<double> _popScale;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  PosterQuickAction get action => widget.action;

  IconData get _icon {
    return switch (action.type) {
      PosterQuickActionType.watchlist =>
        action.isActive ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
      PosterQuickActionType.favourite =>
        action.isActive
            ? Icons.favorite_rounded
            : Icons.favorite_border_rounded,
      PosterQuickActionType.watched =>
        action.isActive
            ? Icons.check_circle_rounded
            : Icons.check_circle_outline_rounded,
    };
  }

  String get _semanticLabel {
    if (action.semanticLabel case final String label
        when label.trim().isNotEmpty) {
      return label;
    }

    return widget.labels.quickAction(
      action.type,
      action.isActive,
      widget.mediaTitle,
    );
  }

  @override
  void initState() {
    super.initState();

    _confirmationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Small overshoot after the user releases the button.
    _popScale = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.10,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.10,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
    ]).animate(_confirmationController);

    // Expanding ring behind the button.
    _ringScale = Tween<double>(begin: 0.82, end: 1.70).animate(
      CurvedAnimation(
        parent: _confirmationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Ring disappears as it expands.
    _ringOpacity = Tween<double>(begin: 0.42, end: 0.0).animate(
      CurvedAnimation(parent: _confirmationController, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _confirmationController.stop();
      _confirmationController.value = 0;
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
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    // Do not run decorative motion when the platform requests reduced motion.
    if (!reduceMotion) {
      _confirmationController.forward(from: 0);
    }

    // Let the parent update the actual watchlist/favourite/watched state.
    action.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // Keep the interactive target at least 48 logical pixels even though the
    // visible circular control remains intentionally compact over artwork.
    const double hitSize = 48;

    final double overlayScale = _overlayTextScale(context);

    final double baseVisualSize = switch (widget.density) {
      _PosterDensity.tiny => 27,
      _PosterDensity.compact => 29,
      _PosterDensity.regular => 32,
      _PosterDensity.spacious => 34,
    };

    final double baseIconSize = switch (widget.density) {
      _PosterDensity.tiny => 16,
      _PosterDensity.compact => 17,
      _PosterDensity.regular => 18,
      _PosterDensity.spacious => 19,
    };

    final double visualSize = baseVisualSize * overlayScale;
    final double iconSize = baseIconSize * overlayScale;

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool reduceMotion = mediaQuery.disableAnimations;
    final bool highContrast = mediaQuery.highContrast;

    final Duration pressDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 80);
    final Duration releaseDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 120);

    return Semantics(
      button: true,
      enabled: true,
      label: _semanticLabel,
      onTap: _handleTap,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: hitSize,
          child: InkResponse(
            onTap: _handleTap,
            onHighlightChanged: _handleHighlightChanged,
            radius: hitSize / 2,
            containedInkWell: false,
            highlightShape: BoxShape.circle,

            child: Center(
              child: AnimatedBuilder(
                animation: _confirmationController,
                builder: (BuildContext context, Widget? child) {
                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      // -------------------------------------------------------
                      // CONFIRMATION RING
                      // -------------------------------------------------------
                      IgnorePointer(
                        child: Opacity(
                          opacity: reduceMotion ? 0 : _ringOpacity.value,
                          child: Transform.scale(
                            scale: _ringScale.value,
                            child: Container(
                              width: visualSize,
                              height: visualSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 1.5,
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: highContrast ? 1.0 : 0.85,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ---------------------------------------------------------
                      // BUTTON
                      // ---------------------------------------------------------
                      AnimatedScale(
                        // Immediate physical compression while the finger
                        // remains on the button.
                        scale: reduceMotion
                            ? 1.0
                            : (_isPressed ? 0.88 : _popScale.value),
                        duration: _isPressed ? pressDuration : releaseDuration,
                        curve: _isPressed
                            ? Curves.easeOutCubic
                            : Curves.easeOutBack,
                        child: AnimatedContainer(
                          duration: widget.animationDuration,
                          curve: Curves.easeOutCubic,
                          width: visualSize,
                          height: visualSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: action.isActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHigh
                                      .withValues(
                                        alpha: highContrast ? 1.0 : 0.92,
                                      ),
                            border: Border.all(
                              color: action.isActive
                                  ? theme.colorScheme.onPrimary.withValues(
                                      alpha: highContrast ? 0.85 : 0.28,
                                    )
                                  : theme.colorScheme.outline.withValues(
                                      alpha: highContrast ? 1.0 : 0.65,
                                    ),
                              width: highContrast ? 1.5 : 1,
                            ),
                            boxShadow: action.isActive
                                ? <BoxShadow>[
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.30),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : const <BoxShadow>[],
                          ),
                          child: AnimatedSwitcher(
                            duration: widget.animationDuration,
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.72,
                                        end: 1.0,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                            child: Icon(
                              _icon,
                              key: ValueKey<String>(
                                '${action.type.name}-${action.isActive}',
                              ),
                              size: iconSize,
                              color: action.isActive
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
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
    );
  }
}

/// Cineara's viewing progress edge at the bottom of the artwork.
class _PosterJourneyEdge extends StatelessWidget {
  const _PosterJourneyEdge({required this.progress});

  /// Viewing progress from 0.0 to 1.0.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final CinearaThemeExtension? cinearaTheme = theme
        .extension<CinearaThemeExtension>();

    final Color trackColor =
        cinearaTheme?.progressTrack ??
        theme.colorScheme.surfaceContainerHighest;

    return SizedBox(
      height: 3.5,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ColoredBox(color: trackColor.withValues(alpha: 0.78)),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: progress,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: <Color>[
                      theme.colorScheme.tertiary,
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Information displayed beneath the physical poster artwork.
///
/// This area is intentionally limited to textual media information:
///
/// - title;
/// - primary contextual metadata;
/// - optional secondary contextual metadata.
///
/// Ratings are handled inside the poster artwork so the information block
/// remains compact and visually consistent between rated and unrated media.
class _PosterInformation extends StatelessWidget {
  const _PosterInformation({
    required this.title,
    required this.subtitle,
    required this.secondarySubtitle,
    required this.maxTitleLines,
    required this.boldText,
    required this.highContrast,
  });

  final String title;
  final String? subtitle;
  final String? secondarySubtitle;
  final int maxTitleLines;
  final bool boldText;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double textScale = _effectiveTextScale(context);

    final bool hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final bool hasSecondarySubtitle =
        secondarySubtitle != null && secondarySubtitle!.trim().isNotEmpty;

    const TextHeightBehavior textHeightBehavior = TextHeightBehavior(
      applyHeightToFirstAscent: true,
      applyHeightToLastDescent: true,
      leadingDistribution: TextLeadingDistribution.even,
    );

    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : 160;

          final bool narrow = width < 130;

          // Keep poster grids scannable at accessibility sizes. The parent card
          // already exposes the complete title and metadata semantically, so
          // visual text uses progressive disclosure instead of expanding into
          // a tall block of wrapped lines.
          final int resolvedTitleLines = textScale >= 1.30
              ? maxTitleLines.clamp(1, 2).toInt()
              : maxTitleLines;

          // Primary metadata stays visible, but always as one concise line.
          const int primaryMetadataLines = 1;

          // Secondary metadata is the first textual detail removed as either
          // width or text scale becomes constrained.
          final bool showSecondarySubtitle =
              hasSecondarySubtitle &&
              textScale < 1.80 &&
              !(narrow && textScale >= 1.30);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                maxLines: resolvedTitleLines,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                textHeightBehavior: textHeightBehavior,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: 14,
                  height: 1.24,
                  fontWeight: boldText ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: 0,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
              if (hasSubtitle) ...<Widget>[
                const SizedBox(height: CinearaSpacing.xxs),
                Text(
                  subtitle!,
                  maxLines: primaryMetadataLines,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  textHeightBehavior: textHeightBehavior,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    height: 1.26,
                    fontWeight: boldText ? FontWeight.w600 : FontWeight.w400,
                    color: theme.colorScheme.onSurfaceVariant,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
              ],
              if (showSecondarySubtitle) ...<Widget>[
                const SizedBox(height: CinearaSpacing.xxs),
                Text(
                  secondarySubtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  textHeightBehavior: textHeightBehavior,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11.5,
                    height: 1.26,
                    fontWeight: boldText ? FontWeight.w600 : FontWeight.w400,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: highContrast ? 1.0 : 0.82,
                    ),
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
