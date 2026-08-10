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

  /// Short visual label for newly available content.
  final String newContent;

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

  /// Whether the NEW content marker is shown.
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

  bool get _hasNewContent {
    final PosterNewContent? newContent = widget.newContent;

    if (!widget.showNewContent || newContent == null) {
      return false;
    }

    return switch (newContent.type) {
      // A newly released movie, series, season, etc. may always show NEW.
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
      parts.add(
        rating.semanticLabel ?? '${rating.sourceLabel} rating ${rating.value}',
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

    if (widget.quickAction case final PosterQuickAction quickAction) {
      if (quickAction.type == PosterQuickActionType.watchlist &&
          quickAction.isActive) {
        parts.add(widget.labels.watchlist);
      }
    }

    if (_normalisedProgress case final double progress) {
      final int percentage = (progress * 100).round();

      parts.add(
        widget.progressSemanticLabel ?? widget.labels.progress(percentage),
      );
    }

    return parts.join(', ');
  }

  void _handleTapDown(TapDownDetails details) {
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

    if (widget.enableHaptics) {
      HapticFeedback.mediumImpact();
    }

    callback();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final Duration interactionDuration = reduceMotion
        ? Duration.zero
        : CinearaMotion.fast;

    final Duration scaleDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 90);

    final BorderRadius artworkRadius = BorderRadius.circular(CinearaRadii.lg);

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
      newContent: _hasNewContent ? widget.newContent : null,
      newContentLabel: widget.labels.newContent,
      labels: widget.labels,
      aspectRatio: widget.aspectRatio,
      enableHaptics: widget.enableHaptics,
      animationDuration: interactionDuration,
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

          // Soft Cineara outer glow.
          boxShadow: _isPressed
              ? <BoxShadow>[
                  BoxShadow(
                    color: CinearaColours.logoViolet.withValues(alpha: 0.28),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: CinearaColours.logoBlue.withValues(alpha: 0.10),
                    blurRadius: 22,
                    spreadRadius: 2,
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
                onTapDown: _isTappable ? _handleTapDown : null,
                onTapCancel: _isTappable ? _handleTapCancel : null,
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
                          color: CinearaColours.logoViolet.withValues(
                            alpha: 0.55,
                          ),
                          width: 1.25,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            CinearaColours.logoPink.withValues(alpha: 0.10),
                            CinearaColours.logoViolet.withValues(alpha: 0.055),
                            Colors.transparent,
                            CinearaColours.logoBlue.withValues(alpha: 0.09),
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

_PosterDensity _resolveDensity(double width) {
  if (width < 100) {
    return _PosterDensity.tiny;
  }

  if (width < 145) {
    return _PosterDensity.compact;
  }

  if (width < 220) {
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
    required this.newContentLabel,
    required this.labels,
    required this.aspectRatio,
    required this.enableHaptics,
    required this.animationDuration,
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

  /// Newly available content, or null when the NEW marker is hidden.
  final PosterNewContent? newContent;

  /// Short localized label used by the NEW marker.
  final String newContentLabel;

  /// Localized labels used by poster controls.
  final PosterMediaCardLabels labels;

  /// Width-to-height ratio of the poster artwork.
  final double aspectRatio;

  /// Whether supported interactions should trigger haptic feedback.
  final bool enableHaptics;

  /// Duration used by artwork animations and transitions.
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : 160;

          final _PosterDensity density = _resolveDensity(width);

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
              hasUserRating && density != _PosterDensity.tiny;

          // IMDb/TMDb source names are hidden before the rating itself when
          // horizontal space becomes limited.
          final bool showExternalRatingSource =
              density == _PosterDensity.spacious;

          final int maxVisibleStatuses = switch (density) {
            _PosterDensity.tiny => 1,
            _PosterDensity.compact => 1,
            _PosterDensity.regular => 2,
            _PosterDensity.spacious => 3,
          };

          final bool canShowStatusDock =
              statusItems.isNotEmpty &&
              !(density == _PosterDensity.tiny &&
                  quickAction != null &&
                  width < 84);

          const double overlayInset = CinearaSpacing.xs;

          final bool hasTopOverlay = hasWorldIdentity || canShowExternalRating;

          final bool hasBottomOverlay =
              canShowUserRating || canShowStatusDock || quickAction != null;

          // NEW belongs to the world-identity side of the poster rather than
          // the rating side. It therefore only needs to clear the
          // world-identity chip.
          final double newBadgeTop = hasWorldIdentity
              ? switch (density) {
                  _PosterDensity.tiny => 34,
                  _PosterDensity.compact => 36,
                  _PosterDensity.regular => 40,
                  _PosterDensity.spacious => 42,
                }
              : overlayInset;

          return Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              _PosterImage(title: title, imageUrl: imageUrl),

              _PosterGradient(
                showTop: hasTopOverlay || hasNewContent,
                showBottom: hasBottomOverlay || progress != null,
              ),

              //
              // TOP METADATA
              //
              if (hasTopOverlay)
                Positioned(
                  top: overlayInset,
                  left: overlayInset,
                  right: overlayInset,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (worldIdentity case final PosterWorldIdentity identity)
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _WorldIdentityChip(identity: identity),
                          ),
                        )
                      else
                        const Spacer(),

                      if (hasWorldIdentity && canShowExternalRating)
                        const SizedBox(width: CinearaSpacing.xxs),

                      if (canShowExternalRating)
                        _ExternalRatingMark(
                          rating: externalRating!,
                          showSource: showExternalRatingSource,
                        ),
                    ],
                  ),
                ),

              //
              // NEW CONTENT
              //
              if (hasNewContent)
                Positioned(
                  top: newBadgeTop,
                  right: overlayInset + 2,
                  child: _NewContentBadge(label: newContentLabel),
                ),

              //
              // PERSONAL STATE + QUICK ACTION
              //
              if (hasBottomOverlay)
                Positioned(
                  left: overlayInset,
                  right: overlayInset,
                  bottom: progress != null ? 8 : 6,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      if (canShowUserRating || canShowStatusDock)
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Personal Cineara rating.
                                if (canShowUserRating)
                                  _UserRatingMark(value: userRating!),

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
                  duration: CinearaMotion.standard,
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

/// Cineara-branded poster fallback.
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

    return ColoredBox(
      color: backgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(CinearaSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Icon(
                    Icons.public_rounded,
                    size: 42,
                    color: theme.colorScheme.primary.withValues(alpha: 0.72),
                  ),
                  Icon(
                    Icons.play_arrow_rounded,
                    size: 18,
                    color: theme.colorScheme.onPrimary,
                  ),
                ],
              ),
              const SizedBox(height: CinearaSpacing.sm),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
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
/// The marker uses fixed dimensions and fixed line metrics so its visual
/// footprint remains consistent across cards, glyphs and fonts.
class _WorldIdentityChip extends StatelessWidget {
  const _WorldIdentityChip({required this.identity});

  final PosterWorldIdentity identity;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Semantics(
      label: identity.semanticLabel,
      child: ExcludeSemantics(
        child: Container(
          width: CinearaSpacing.xl,
          height: CinearaSpacing.lg,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: CinearaColours.brand700.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(CinearaRadii.pill),
            border: Border.all(
              color: CinearaColours.neutral0.withValues(alpha: 0.16),
              width: 1,
            ),
          ),
          child: Text(
            identity.compactLabel,
            maxLines: 1,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
            strutStyle: const StrutStyle(
              fontSize: CinearaFontSizes.labelSmall,
              height: 1,
              forceStrutHeight: true,
            ),
            style: theme.textTheme.labelSmall?.copyWith(
              color: CinearaColours.neutral0,
              fontSize: CinearaFontSizes.labelSmall,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// External/community rating.
///
/// The rating uses the same compact geometry and line metrics as Cineara's
/// world marker. On spacious cards the source is shown alongside the value;
/// otherwise only the rating value is displayed.
class _ExternalRatingMark extends StatelessWidget {
  const _ExternalRatingMark({required this.rating, required this.showSource});

  /// External rating value and source information.
  final PosterExternalRating rating;

  /// Whether to show the rating source label.
  final bool showSource;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ExcludeSemantics(
      child: Container(
        width: showSource ? null : CinearaSpacing.xl,
        height: CinearaSpacing.lg,
        constraints: showSource ? const BoxConstraints(minWidth: 32) : null,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(CinearaRadii.pill),
          border: Border.all(
            color: CinearaColours.neutral0.withValues(alpha: 0.16),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (showSource) ...<Widget>[
              Text(
                rating.sourceLabel,
                maxLines: 1,
                overflow: TextOverflow.clip,
                strutStyle: const StrutStyle(
                  fontSize: CinearaFontSizes.labelSmall,
                  height: 1,
                  forceStrutHeight: true,
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: CinearaColours.neutral0.withValues(alpha: 0.76),
                  fontSize: CinearaFontSizes.labelSmall,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              const SizedBox(width: CinearaSpacing.xxs),
            ],
            Text(
              rating.value,
              maxLines: 1,
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
              strutStyle: const StrutStyle(
                fontSize: CinearaFontSizes.labelSmall,
                height: 1,
                forceStrutHeight: true,
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: CinearaColours.neutral0,
                fontSize: CinearaFontSizes.labelSmall,
                fontWeight: FontWeight.w800,
                height: 1,

                // Keeps rating digits visually consistent.
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Passive personal Cineara rating.
///
/// Uses the same compact height and visual treatment as the status dock.
/// The fixed width keeps values such as `9.2` and `10` visually consistent.
class _UserRatingMark extends StatelessWidget {
  const _UserRatingMark({required this.value});

  /// Rating personally assigned by the current user.
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ExcludeSemantics(
      child: Container(
        width: 38,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(CinearaRadii.pill),
          border: Border.all(
            color: CinearaColours.neutral0.withValues(alpha: 0.16),
            width: 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.star_rounded,
              size: 9,
              color: CinearaColours.userRating,
            ),
            const SizedBox(width: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
              strutStyle: const StrutStyle(
                fontSize: 10,
                height: 1,
                forceStrutHeight: true,
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: CinearaColours.userRating,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                height: 1,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tilted event marker shown when newly available content exists.
///
/// This intentionally looks different from normal state indicators because
/// "NEW" is a temporary event, not a permanent user relationship.
///
/// The badge uses a fixed height and fixed line metrics so translated labels
/// and fallback fonts do not change its vertical footprint.
class _NewContentBadge extends StatelessWidget {
  const _NewContentBadge({required this.label});

  /// Short localized label displayed by the marker.
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return IgnorePointer(
      child: Transform.rotate(
        angle: -0.10,
        child: Container(
          height: 20,
          padding: const EdgeInsets.symmetric(horizontal: CinearaSpacing.xs),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                CinearaColours.logoPink,
                CinearaColours.logoViolet,
              ],
            ),
            borderRadius: BorderRadius.circular(CinearaRadii.sm),
            border: Border.all(
              color: CinearaColours.neutral0.withValues(alpha: 0.28),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.50),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
            strutStyle: const StrutStyle(
              fontSize: CinearaFontSizes.labelSmall,
              height: 1,
              forceStrutHeight: true,
            ),
            style: theme.textTheme.labelSmall?.copyWith(
              color: CinearaColours.neutral0,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              height: 1,
            ),
          ),
        ),
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
  });

  /// Status items available to display.
  final List<_PosterStatusItem> items;

  /// Maximum number of status items shown at once.
  final int maxVisibleItems;

  /// Duration used for dock state transitions.
  final Duration animationDuration;

  /// Resolves the colour associated with each personal-state category.
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
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(CinearaRadii.pill),
            border: Border.all(
              color: CinearaColours.neutral0.withValues(alpha: 0.18),
              width: 1,
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
            height: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
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
                    ),

                    if (index != visibleItems.length - 1 || hiddenCount > 0)
                      const SizedBox(width: 3),
                  ],

                  if (hiddenCount > 0)
                    _AnimatedPosterStatusOverflow(
                      key: ValueKey<int>(hiddenCount),
                      hiddenCount: hiddenCount,
                      animationDuration: animationDuration,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: CinearaColours.neutral0,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1,
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
    super.key,
  });

  /// Icon representing the personal state.
  final IconData icon;

  /// Colour associated with the personal state.
  final Color color;

  /// Duration of the entrance animation.
  final Duration animationDuration;

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
      child: Icon(icon, size: 13, color: color),
    );
  }
}

/// Animated count used when additional status items are hidden.
class _AnimatedPosterStatusOverflow extends StatelessWidget {
  const _AnimatedPosterStatusOverflow({
    required this.hiddenCount,
    required this.animationDuration,
    required this.style,
    super.key,
  });

  /// Number of status items hidden from the compact dock.
  final int hiddenCount;

  /// Duration of the count transition.
  final Duration animationDuration;

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
        strutStyle: const StrutStyle(
          fontSize: 9,
          height: 1,
          forceStrutHeight: true,
        ),
        style: style,
      ),
    );
  }
}

/// Single interactive shortcut displayed at the bottom-right of the artwork.
class _PosterQuickActionButton extends StatelessWidget {
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

    return labels.quickAction(action.type, action.isActive, mediaTitle);
  }

  void _handleTap() {
    if (enableHaptics) {
      HapticFeedback.lightImpact();
    }

    action.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final double hitSize = switch (density) {
      _PosterDensity.tiny => 36,
      _PosterDensity.compact => 38,
      _PosterDensity.regular => 42,
      _PosterDensity.spacious => 44,
    };

    final double visualSize = switch (density) {
      _PosterDensity.tiny => 27,
      _PosterDensity.compact => 29,
      _PosterDensity.regular => 32,
      _PosterDensity.spacious => 34,
    };

    final double iconSize = switch (density) {
      _PosterDensity.tiny => 16,
      _PosterDensity.compact => 17,
      _PosterDensity.regular => 18,
      _PosterDensity.spacious => 19,
    };

    return Semantics(
      button: true,
      label: _semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: hitSize,
          child: InkResponse(
            onTap: _handleTap,
            radius: hitSize / 2,
            containedInkWell: false,
            highlightShape: BoxShape.circle,
            child: Center(
              child: AnimatedContainer(
                duration: animationDuration,
                curve: Curves.easeOutCubic,
                width: visualSize,
                height: visualSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: action.isActive
                      ? CinearaColours.brand600.withValues(alpha: 0.96)
                      : Colors.black.withValues(alpha: 0.70),
                  border: Border.all(
                    color: action.isActive
                        ? CinearaColours.brand300.withValues(alpha: 0.62)
                        : CinearaColours.neutral0.withValues(alpha: 0.20),
                  ),
                  boxShadow: action.isActive
                      ? <BoxShadow>[
                          BoxShadow(
                            color: CinearaColours.logoViolet.withValues(
                              alpha: 0.24,
                            ),
                            blurRadius: 8,
                          ),
                        ]
                      : const <BoxShadow>[],
                ),
                child: AnimatedSwitcher(
                  duration: animationDuration,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
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
                    color: CinearaColours.neutral0,
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

/// Cineara's viewing progress edge at the bottom of the artwork.
class _PosterJourneyEdge extends StatelessWidget {
  const _PosterJourneyEdge({required this.progress});

  /// Viewing progress from 0.0 to 1.0.
  final double? progress;

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
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              heightFactor: 1,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      CinearaColours.logoPink,
                      CinearaColours.logoViolet,
                      CinearaColours.logoBlue,
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
  });

  final String title;
  final String? subtitle;
  final String? secondarySubtitle;
  final int maxTitleLines;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final bool hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    final bool hasSecondarySubtitle =
        secondarySubtitle != null && secondarySubtitle!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        //
        // TITLE
        //
        Text(
          title,
          maxLines: maxTitleLines,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontSize: 14,
            height: 1.18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),

        //
        // PRIMARY METADATA
        //
        if (hasSubtitle) ...<Widget>[
          const SizedBox(height: CinearaSpacing.xxs),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              height: 1.2,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],

        //
        // SECONDARY METADATA
        //
        if (hasSecondarySubtitle) ...<Widget>[
          const SizedBox(height: CinearaSpacing.xxs),
          Text(
            secondarySubtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.5,
              height: 1.2,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.82),
            ),
          ),
        ],
      ],
    );
  }
}
