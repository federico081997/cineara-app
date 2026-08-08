import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/theme_extensions.dart';
import '../tokens/colour_tokens.dart';
import '../tokens/motion_tokens.dart';
import '../tokens/radius_tokens.dart';
import '../tokens/spacing_tokens.dart';

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

class PosterMediaCardLabels {
  /// Defines the localized labels used by the poster media card.
  const PosterMediaCardLabels({
    this.notStarted = 'Not started',
    this.watching = 'Watching',
    this.caughtUp = 'Caught up',
    this.completed = 'Completed',
    this.rewatching = 'Rewatching',
    this.onHold = 'On hold',
    this.dropped = 'Dropped',
    this.newEpisodes = 'NEW',
    this.favorite = 'Favorite',
  });

  /// Label for media that was not started to watch.
  final String notStarted;

  /// Label for media currently being watched.
  final String watching;

  /// label for media where all available episodes are watched.
  final String caughtUp;

  /// Label for completed media.
  final String completed;

  /// Label for media being watched again.
  final String rewatching;

  /// Label for media temporarily paused by the user.
  final String onHold;

  /// Label for media the user stopped watching.
  final String dropped;

  /// Label shown for media the user has hearted.
  final String favorite;

  /// Label shown when new episodes are available.
  final String newEpisodes;
}

/// Reusable poster-style media card used throughout Cineara.
///
/// The component deliberately separates:
///
/// - Cineara world/cultural identity;
/// - external ratings;
/// - the user's personal rating;
/// - viewing status;
/// - favorite and collection relationships;
/// - new-episode availability;
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
///   newEpisodeCount: 2,
///   isFavourite: true,
///   collectionCount: 2,
///   quickAction: PosterQuickAction(
///     type: PosterQuickActionType.watchlist,
///     isActive: true,
///     onPressed: () {},
///   ),
///   onTap: () {},
///   onLongPress: () {},
///   onWorldIdentityTap: () {},
/// )
/// ```
class PosterMediaCard extends StatefulWidget {
  /// Creates a Cineara poster media card.
  const PosterMediaCard({
    required this.title,
    required this.mediaTypeLabel,
    super.key,
    this.imageUrl,
    this.subtitle,
    this.worldIdentity,
    this.externalRating,
    this.userRating,
    this.viewingStatus = PosterViewingStatus.notStarted,
    this.isFavourite = false,
    this.collectionCount = 0,
    this.quickAction,
    this.progress,
    this.newEpisodeCount = 0,
    this.labels = const PosterMediaCardLabels(),
    this.newEpisodesSemanticLabel,
    this.collectionSemanticLabel,
    this.onTap,
    this.onLongPress,
    this.onWorldIdentityTap,
    this.onUserRatingTap,
    this.semanticLabel,
    this.aspectRatio = 2 / 3,
    this.maxTitleLines = 2,
    this.layout = PosterMediaCardLayout.artworkWithInformation,
    this.showWorldIdentity = true,
    this.showExternalRating = true,
    this.showUserRating = true,
    this.showStatusDock = true,
    this.showWorldline = true,
    this.showNewEpisodes = true,
    this.enableHaptics = true,
  }) : assert(aspectRatio > 0),
       assert(maxTitleLines > 0),
       assert(collectionCount >= 0),
       assert(newEpisodeCount >= 0);

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

  /// Optional Cineara world-cinema identity.
  final PosterWorldIdentity? worldIdentity;

  /// Optional IMDb, TMDb, Rotten Tomatoes, etc. rating.
  final PosterExternalRating? externalRating;

  /// Rating personally assigned by the current user.
  ///
  /// This is deliberately displayed separately from [externalRating].
  final String? userRating;

  /// Current viewing status.
  final PosterViewingStatus viewingStatus;

  /// Whether the title is a favourite.
  final bool isFavourite;

  /// Number of user collections containing this media.
  final int collectionCount;

  /// Optional single quick action.
  final PosterQuickAction? quickAction;

  /// Viewing progress between `0.0` and `1.0`.
  final double? progress;

  /// Number of newly available episodes the user has not yet watched.
  ///
  /// The NEW marker is only rendered for media that the user has already
  /// started. The feature layer should only provide this value for episodic
  /// media.
  final int newEpisodeCount;

  /// Localized labels used by the card.
  ///
  /// Defaults to English labels when no localized values are supplied.
  final PosterMediaCardLabels labels;

  /// Optional accessibility description for the new-episode marker.
  final String? newEpisodesSemanticLabel;

  /// Optional localized accessibility description for collection membership.
  final String? collectionSemanticLabel;

  /// Opens the media detail screen.
  final VoidCallback? onTap;

  /// Opens the complete state-aware action sheet.
  final VoidCallback? onLongPress;

  /// Opens Cineara's World Lens.
  final VoidCallback? onWorldIdentityTap;

  /// Allows the personal rating to be edited where appropriate.
  final VoidCallback? onUserRatingTap;

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

  /// Whether the subtle Cineara Worldline appears when progress is absent.
  final bool showWorldline;

  /// Whether the NEW episode marker is shown.
  final bool showNewEpisodes;

  /// Whether interaction haptics are enabled.
  final bool enableHaptics;

  @override
  State<PosterMediaCard> createState() => _PosterMediaCardState();
}

class _PosterMediaCardState extends State<PosterMediaCard> {
  bool _isPressed = false;

  bool get _isInteractive => widget.onTap != null || widget.onLongPress != null;

  bool get _hasNewEpisodes {
    if (!widget.showNewEpisodes || widget.newEpisodeCount <= 0) {
      return false;
    }

    // NEW is meaningful only after the user has started this media.
    return switch (widget.viewingStatus) {
      PosterViewingStatus.notStarted => false,
      PosterViewingStatus.dropped => false,
      PosterViewingStatus.watching => true,
      PosterViewingStatus.caughtUp => true,
      PosterViewingStatus.completed => true,
      PosterViewingStatus.rewatching => true,
      PosterViewingStatus.onHold => true,
    };
  }

  double? get _normalisedProgress {
    final double? rawProgress = widget.progress;

    if (rawProgress == null) {
      return null;
    }

    final double progress = rawProgress.clamp(0.0, 1.0);

    // A permanently full progress bar adds little information once a title is
    // already represented as completed/caught-up.
    if (progress >= 0.999 &&
        (widget.viewingStatus == PosterViewingStatus.completed ||
            widget.viewingStatus == PosterViewingStatus.caughtUp)) {
      return null;
    }

    return progress;
  }

  List<_PosterStatusItem> get _statusItems {
    final List<_PosterStatusItem> items = <_PosterStatusItem>[];

    switch (widget.viewingStatus) {
      case PosterViewingStatus.notStarted:
        break;

      case PosterViewingStatus.watching:
        // The progress edge already communicates "watching" when available.
        if (_normalisedProgress == null) {
          items.add(
            _PosterStatusItem(
              icon: Icons.play_arrow_rounded,
              semanticLabel: widget.labels.watching,
              tone: _PosterStatusTone.info,
            ),
          );
        }
        break;

      case PosterViewingStatus.caughtUp:
        items.add(
          _PosterStatusItem(
            icon: Icons.done_all_rounded,
            semanticLabel: widget.labels.caughtUp,
            tone: _PosterStatusTone.success,
          ),
        );
        break;

      case PosterViewingStatus.completed:
        items.add(
          _PosterStatusItem(
            icon: Icons.check_rounded,
            semanticLabel: widget.labels.completed,
            tone: _PosterStatusTone.success,
          ),
        );
        break;

      case PosterViewingStatus.rewatching:
        // Rewatching already implies previous completion, so a second
        // completed icon would be redundant.
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
            tone: _PosterStatusTone.warning,
          ),
        );
        break;

      case PosterViewingStatus.dropped:
        items.add(
          _PosterStatusItem(
            icon: Icons.block_rounded,
            semanticLabel: widget.labels.dropped,
            tone: _PosterStatusTone.error,
          ),
        );
        break;
    }

    if (widget.isFavourite) {
      items.add(
        _PosterStatusItem(
          icon: Icons.favorite_rounded,
          semanticLabel: widget.labels.favorite,
          tone: _PosterStatusTone.favourite,
        ),
      );
    }

    if (widget.collectionCount > 0) {
      items.add(
        _PosterStatusItem(
          icon: Icons.video_library_rounded,
          semanticLabel:
              widget.collectionSemanticLabel ??
              (widget.collectionCount == 1
                  ? 'In one collection'
                  : 'In ${widget.collectionCount} collections'),
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

    if (widget.externalRating case final PosterExternalRating rating
        when widget.showExternalRating) {
      parts.add(
        rating.semanticLabel ?? '${rating.sourceLabel} rating ${rating.value}',
      );
    }

    if (widget.userRating case final String rating
        when rating.trim().isNotEmpty && widget.showUserRating) {
      parts.add('Your rating $rating');
    }

    if (widget.viewingStatus != PosterViewingStatus.notStarted) {
      parts.add(_viewingStatusSemanticLabel);
    }

    if (_hasNewEpisodes) {
      parts.add(
        widget.newEpisodesSemanticLabel ??
            (widget.newEpisodeCount == 1
                ? 'One new episode available'
                : '${widget.newEpisodeCount} new episodes available'),
      );
    }

    if (widget.isFavourite) {
      parts.add('Favourite');
    }

    if (widget.collectionCount > 0) {
      parts.add(
        widget.collectionCount == 1
            ? 'In one collection'
            : 'In ${widget.collectionCount} collections',
      );
    }

    if (widget.quickAction case final PosterQuickAction quickAction) {
      if (quickAction.type == PosterQuickActionType.watchlist &&
          quickAction.isActive) {
        parts.add('In watchlist');
      }
    }

    if (_normalisedProgress case final double progress) {
      parts.add('${(progress * 100).round()} percent watched');
    }

    return parts.join(', ');
  }

  void _handleHighlightChanged(bool highlighted) {
    if (_isPressed == highlighted) {
      return;
    }

    setState(() {
      _isPressed = highlighted;
    });
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final Duration interactionDuration = reduceMotion
        ? Duration.zero
        : CinearaMotion.fast;

    final BorderRadius artworkRadius = BorderRadius.circular(CinearaRadii.lg);

    final Widget artwork = _PosterArtwork(
      title: widget.title,
      imageUrl: widget.imageUrl,
      worldIdentity: widget.showWorldIdentity ? widget.worldIdentity : null,
      externalRating: widget.showExternalRating ? widget.externalRating : null,
      statusItems: widget.showStatusDock
          ? _statusItems
          : const <_PosterStatusItem>[],
      quickAction: widget.quickAction,
      progress: _normalisedProgress,
      newEpisodeCount: _hasNewEpisodes ? widget.newEpisodeCount : 0,
      newEpisodesLabel: widget.labels.newEpisodes,
      aspectRatio: widget.aspectRatio,
      showWorldline: widget.showWorldline,
      onWorldIdentityTap: widget.onWorldIdentityTap,
      enableHaptics: widget.enableHaptics,
      animationDuration: interactionDuration,
    );

    final Widget artworkCard = AnimatedScale(
      scale: _isPressed && !reduceMotion ? 0.975 : 1.0,
      duration: interactionDuration,
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: interactionDuration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: artworkRadius,
          boxShadow: _isPressed
              ? <BoxShadow>[
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.20),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : const <BoxShadow>[],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: artworkRadius,
          border: Border.all(
            color: _isPressed
                ? colorScheme.primary.withValues(alpha: 0.82)
                : colorScheme.outlineVariant.withValues(alpha: 0.24),
            width: _isPressed ? 1.5 : 0.75,
          ),
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: artworkRadius),
          child: InkWell(
            excludeFromSemantics: true,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress == null ? null : _handleLongPress,
            onHighlightChanged: _isInteractive ? _handleHighlightChanged : null,
            splashColor: colorScheme.primary.withValues(alpha: 0.10),
            highlightColor: colorScheme.primary.withValues(alpha: 0.05),
            child: artwork,
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
            userRating: widget.showUserRating ? widget.userRating : null,
            maxTitleLines: widget.maxTitleLines,
            onUserRatingTap: widget.onUserRatingTap,
            enableHaptics: widget.enableHaptics,
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
    required this.statusItems,
    required this.quickAction,
    required this.progress,
    required this.newEpisodeCount,
    required this.newEpisodesLabel,
    required this.aspectRatio,
    required this.showWorldline,
    required this.onWorldIdentityTap,
    required this.enableHaptics,
    required this.animationDuration,
  });

  final String title;
  final String? imageUrl;

  final PosterWorldIdentity? worldIdentity;
  final PosterExternalRating? externalRating;

  final List<_PosterStatusItem> statusItems;
  final PosterQuickAction? quickAction;

  final double? progress;

  final int newEpisodeCount;
  final String newEpisodesLabel;

  final double aspectRatio;

  final bool showWorldline;

  final VoidCallback? onWorldIdentityTap;

  final bool enableHaptics;
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
          final bool hasNewEpisodes = newEpisodeCount > 0;

          // World identity is a core Cineara feature and therefore receives
          // higher priority than external ratings on tiny cards.
          final bool canShowExternalRating =
              externalRating != null &&
              !(density == _PosterDensity.tiny &&
                  (hasWorldIdentity || hasNewEpisodes));

          final bool useCompactWorldLabel =
              density == _PosterDensity.tiny ||
              density == _PosterDensity.compact;

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

          final double overlayInset = switch (density) {
            _PosterDensity.tiny => CinearaSpacing.xxs,
            _PosterDensity.compact => CinearaSpacing.xxs,
            _PosterDensity.regular => CinearaSpacing.xs,
            _PosterDensity.spacious => CinearaSpacing.xs,
          };

          final bool hasTopOverlay = hasWorldIdentity || canShowExternalRating;

          final bool hasBottomOverlay =
              canShowStatusDock || quickAction != null;

          final double newBadgeTop = hasTopOverlay
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
                showTop: hasTopOverlay || hasNewEpisodes,
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
                            child: _WorldIdentityChip(
                              identity: identity,
                              compact: useCompactWorldLabel,
                              onTap: onWorldIdentityTap,
                              enableHaptics: enableHaptics,
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
                          showSource: showExternalRatingSource,
                        ),
                    ],
                  ),
                ),

              //
              // NEW EPISODES
              //
              if (hasNewEpisodes)
                Positioned(
                  top: newBadgeTop,
                  right: overlayInset + 2,
                  child: _NewEpisodesBadge(
                    count: newEpisodeCount,
                    label: newEpisodesLabel,
                    compact:
                        density == _PosterDensity.tiny ||
                        density == _PosterDensity.compact,
                  ),
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
                      if (canShowStatusDock)
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: _PosterStatusDock(
                              items: statusItems,
                              maxVisibleItems: maxVisibleStatuses,
                              animationDuration: animationDuration,
                            ),
                          ),
                        )
                      else
                        const Spacer(),

                      if (quickAction case final PosterQuickAction action)
                        _PosterQuickActionButton(
                          action: action,
                          mediaTitle: title,
                          density: density,
                          enableHaptics: enableHaptics,
                          animationDuration: animationDuration,
                        ),
                    ],
                  ),
                ),

              //
              // CINEARA WORLDLINE / PROGRESS EDGE
              //
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _PosterJourneyEdge(
                  progress: progress,
                  showWorldline: showWorldline,
                ),
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

  final String title;
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

  final bool showTop;
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

/// Cineara's interactive world-cinema Compass.
class _WorldIdentityChip extends StatelessWidget {
  const _WorldIdentityChip({
    required this.identity,
    required this.compact,
    required this.onTap,
    required this.enableHaptics,
  });

  final PosterWorldIdentity identity;
  final bool compact;
  final VoidCallback? onTap;
  final bool enableHaptics;

  void _handleTap() {
    if (enableHaptics) {
      HapticFeedback.selectionClick();
    }

    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final String label = compact ? identity.compactLabel : identity.label;

    return Semantics(
      button: onTap != null,
      label: identity.semanticLabel,
      child: ExcludeSemantics(
        child: Material(
          color: CinearaColours.brand700.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(CinearaRadii.pill),
          child: InkWell(
            onTap: onTap == null ? null : _handleTap,
            borderRadius: BorderRadius.circular(CinearaRadii.pill),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? CinearaSpacing.xs : CinearaSpacing.sm,
                vertical: CinearaSpacing.xxs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.public_rounded,
                    size: 13,
                    color: CinearaColours.neutral0,
                  ),
                  const SizedBox(width: CinearaSpacing.xxs),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: CinearaColours.neutral0,
                        fontWeight: FontWeight.w700,
                      ),
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

/// External/community rating.
///
/// On medium cards Cineara keeps the number but removes the source label.
/// On spacious cards both source and value are displayed.
class _ExternalRatingMark extends StatelessWidget {
  const _ExternalRatingMark({required this.rating, required this.showSource});

  final PosterExternalRating rating;
  final bool showSource;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(CinearaRadii.pill),
          border: Border.all(
            color: CinearaColours.neutral0.withValues(alpha: 0.16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CinearaSpacing.xs,
            vertical: CinearaSpacing.xxs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (showSource) ...<Widget>[
                Text(
                  rating.sourceLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: CinearaColours.neutral0.withValues(alpha: 0.76),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: CinearaSpacing.xxs),
              ],
              Text(
                rating.value,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: CinearaColours.neutral0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tilted event marker shown when new episodes are available.
///
/// This intentionally looks different from normal state indicators because
/// "NEW" is a temporary event, not a permanent user relationship.
class _NewEpisodesBadge extends StatelessWidget {
  const _NewEpisodesBadge({
    required this.count,
    required this.label,
    required this.compact,
  });

  final int count;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final String displayLabel = !compact && count > 1 ? '$count $label' : label;

    return IgnorePointer(
      child: Transform.rotate(
        angle: -0.10,
        child: DecoratedBox(
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
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? CinearaSpacing.xs : CinearaSpacing.sm,
              vertical: CinearaSpacing.xxs,
            ),
            child: Text(
              displayLabel,
              maxLines: 1,
              style: theme.textTheme.labelSmall?.copyWith(
                color: CinearaColours.neutral0,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Semantic visual category for one passive personal-state icon.
enum _PosterStatusTone {
  success,
  favourite,
  collection,
  rewatching,
  warning,
  error,
  info,
}

/// One passive status item.
@immutable
class _PosterStatusItem {
  const _PosterStatusItem({
    required this.icon,
    required this.semanticLabel,
    required this.tone,
  });

  final IconData icon;
  final String semanticLabel;
  final _PosterStatusTone tone;
}

/// Compact Cineara Status Dock.
///
/// Individual icons are colour-coded, while the dock itself deliberately
/// remains visually neutral so several states can coexist without producing
/// a row of unrelated coloured badges.
class _PosterStatusDock extends StatelessWidget {
  const _PosterStatusDock({
    required this.items,
    required this.maxVisibleItems,
    required this.animationDuration,
  });

  final List<_PosterStatusItem> items;
  final int maxVisibleItems;
  final Duration animationDuration;

  Color _resolveStatusColor(BuildContext context, _PosterStatusTone tone) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return switch (tone) {
      _PosterStatusTone.success => CinearaColours.success,
      _PosterStatusTone.favourite => CinearaColours.logoPink,
      _PosterStatusTone.collection => CinearaColours.logoBlue,
      _PosterStatusTone.rewatching => CinearaColours.logoViolet,
      _PosterStatusTone.warning => CinearaColours.warning,
      _PosterStatusTone.error => colorScheme.error,
      _PosterStatusTone.info => CinearaColours.brand300,
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

    final String stateKey = <String>[
      ...visibleItems.map((_PosterStatusItem item) => item.semanticLabel),
      if (hiddenCount > 0) '+$hiddenCount',
    ].join('|');

    return ExcludeSemantics(
      child: AnimatedSize(
        duration: animationDuration,
        curve: Curves.easeOutCubic,
        child: AnimatedSwitcher(
          duration: animationDuration,
          child: DecoratedBox(
            key: ValueKey<String>(stateKey),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(CinearaRadii.pill),
              border: Border.all(
                color: CinearaColours.neutral0.withValues(alpha: 0.18),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CinearaSpacing.xs,
                vertical: CinearaSpacing.xxs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (
                    int index = 0;
                    index < visibleItems.length;
                    index++
                  ) ...<Widget>[
                    Icon(
                      visibleItems[index].icon,
                      size: 15,
                      color: _resolveStatusColor(
                        context,
                        visibleItems[index].tone,
                      ),
                    ),
                    if (index != visibleItems.length - 1)
                      const SizedBox(width: CinearaSpacing.xxs),
                  ],

                  if (hiddenCount > 0) ...<Widget>[
                    if (visibleItems.isNotEmpty)
                      const SizedBox(width: CinearaSpacing.xxs),
                    Text(
                      '+$hiddenCount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: CinearaColours.neutral0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
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
  });

  final PosterQuickAction action;
  final String mediaTitle;
  final _PosterDensity density;
  final bool enableHaptics;
  final Duration animationDuration;

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

    return switch (action.type) {
      PosterQuickActionType.watchlist =>
        action.isActive
            ? 'Remove $mediaTitle from watchlist'
            : 'Add $mediaTitle to watchlist',
      PosterQuickActionType.favourite =>
        action.isActive
            ? 'Remove $mediaTitle from favourites'
            : 'Add $mediaTitle to favourites',
      PosterQuickActionType.watched =>
        action.isActive
            ? 'Mark $mediaTitle as unwatched'
            : 'Mark $mediaTitle as watched',
    };
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

/// Cineara's bottom artwork edge.
///
/// Without progress it acts as a very subtle branded Worldline.
/// With progress it becomes the user's viewing journey.
class _PosterJourneyEdge extends StatelessWidget {
  const _PosterJourneyEdge({
    required this.progress,
    required this.showWorldline,
  });

  final double? progress;
  final bool showWorldline;

  @override
  Widget build(BuildContext context) {
    if (progress == null) {
      if (!showWorldline) {
        return const SizedBox.shrink();
      }

      return Opacity(
        opacity: 0.38,
        child: Container(
          height: 1.5,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                CinearaColours.logoPink,
                CinearaColours.logoViolet,
                CinearaColours.logoBlue,
              ],
            ),
          ),
        ),
      );
    }

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
/// The user's personal score lives here so it cannot be confused with IMDb,
/// TMDb or another external rating.
class _PosterInformation extends StatelessWidget {
  const _PosterInformation({
    required this.title,
    required this.subtitle,
    required this.userRating,
    required this.maxTitleLines,
    required this.onUserRatingTap,
    required this.enableHaptics,
  });

  final String title;
  final String? subtitle;
  final String? userRating;
  final int maxTitleLines;
  final VoidCallback? onUserRatingTap;
  final bool enableHaptics;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final bool hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    final bool hasUserRating =
        userRating != null && userRating!.trim().isNotEmpty;

    // No horizontal padding: title and metadata visually align with the
    // artwork's outer edge.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          maxLines: maxTitleLines,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        if (hasSubtitle || hasUserRating) ...<Widget>[
          const SizedBox(height: CinearaSpacing.xxs),

          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool showUserLabel = constraints.maxWidth >= 180;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (hasSubtitle)
                    Expanded(
                      child: Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    const Spacer(),

                  if (hasSubtitle && hasUserRating)
                    const SizedBox(width: CinearaSpacing.xs),

                  if (hasUserRating)
                    _UserRatingMark(
                      value: userRating!,
                      showLabel: showUserLabel,
                      onTap: onUserRatingTap,
                      enableHaptics: enableHaptics,
                    ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

/// User's personal Cineara rating.
///
/// This deliberately uses Cineara's accent treatment and lives outside the
/// artwork so it cannot be confused with external ratings.
class _UserRatingMark extends StatelessWidget {
  const _UserRatingMark({
    required this.value,
    required this.showLabel,
    required this.onTap,
    required this.enableHaptics,
  });

  final String value;
  final bool showLabel;
  final VoidCallback? onTap;
  final bool enableHaptics;

  void _handleTap() {
    if (enableHaptics) {
      HapticFeedback.selectionClick();
    }

    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showLabel) ...<Widget>[
          Text(
            'You',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 3),
        ],

        Icon(Icons.star_rounded, size: 16, color: theme.colorScheme.primary),

        const SizedBox(width: 2),

        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );

    if (onTap == null) {
      return ExcludeSemantics(child: content);
    }

    return Semantics(
      button: true,
      label: 'Your rating $value. Change rating.',
      child: ExcludeSemantics(
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(CinearaRadii.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CinearaSpacing.xxs,
              vertical: 2,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
