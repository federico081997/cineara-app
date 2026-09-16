import 'package:flutter/material.dart';

import '../../foundations/shapes/cineara_shapes.dart';
import '../../foundations/tokens/geometry.dart';

// =============================================================================
// Poster image
// =============================================================================

/// Reusable Cineara poster-artwork primitive.
///
/// [CinearaPosterImage] owns only artwork presentation:
///
/// - Cineara's canonical poster geometry;
/// - asynchronous image loading;
/// - loading / empty state;
/// - image failure state;
/// - artwork clipping through [CinearaShapes.poster];
/// - optional artwork-only Hero transition;
/// - optional decorative artwork overlay;
/// - artwork accessibility semantics.
///
/// It deliberately does not own:
///
/// - media titles;
/// - years or metadata;
/// - viewing-status badges;
/// - external ratings;
/// - personal-state indicators;
/// - viewing progress;
/// - tap / long-press interaction.
///
/// Those responsibilities belong to higher-level components such as
/// `CinearaMediaPoster`, `CinearaMediaGridItem`, and `CinearaMediaListItem`.
///
/// ## Standalone usage
///
/// ```dart
/// CinearaPosterImage(
///   image: NetworkImage(posterUrl),
/// )
/// ```
///
/// ## Inside CinearaMediaPoster
///
/// [CinearaMediaPoster] already owns the outer 2:3 poster frame.
///
/// Avoid introducing a redundant nested [AspectRatio]:
///
/// ```dart
/// CinearaMediaPoster(
///   artwork: CinearaPosterImage(
///     image: NetworkImage(posterUrl),
///     constrainToPosterAspectRatio: false,
///     excludeFromSemantics: true,
///   ),
///   semanticLabel: title,
/// )
/// ```
///
/// If [CinearaMediaPoster] owns the Hero transition, also leave [heroTag] null:
///
/// ```dart
/// CinearaMediaPoster(
///   heroTag: 'movie-550-poster',
///   artwork: CinearaPosterImage(
///     image: NetworkImage(posterUrl),
///     constrainToPosterAspectRatio: false,
///     heroTag: null,
///   ),
/// )
/// ```
///
/// ## Standalone Hero usage
///
/// [CinearaPosterImage] may still own a Hero when used independently:
///
/// ```dart
/// CinearaPosterImage(
///   image: NetworkImage(posterUrl),
///   heroTag: 'movie-550-poster',
/// )
/// ```
///
/// The Cineara poster clip is inside the Hero subtree. The shared element
/// therefore keeps the same poster silhouette while flying between routes.
///
/// ## Artwork overlay
///
/// [overlay] is reserved for decorative artwork treatment:
///
/// ```text
/// gradient
/// vignette
/// tonal treatment
/// artwork scrim
/// ```
///
/// It should not contain:
///
/// ```text
/// viewing status
/// ratings
/// personal state
/// progress
/// buttons
/// ```
///
/// Those belong to `CinearaMediaPosterOverlay`.
///
/// The artwork overlay is intentionally outside the Hero subtree so temporary
/// visual treatment does not automatically travel with shared-element
/// navigation.
///
/// It is nevertheless clipped using the same [CinearaShapes.poster] geometry
/// as the artwork itself.
final class CinearaPosterImage extends StatelessWidget {
  const CinearaPosterImage({
    this.image,
    this.placeholderBuilder,
    this.errorBuilder,
    this.overlay,
    this.heroTag,
    this.heroTransitionOnUserGestures = false,
    this.constrainToPosterAspectRatio = true,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.medium,
    this.gaplessPlayback = true,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.clipBehavior = Clip.antiAlias,
    this.fadeInDuration = const Duration(milliseconds: 180),
    this.fadeInCurve = Curves.easeOutCubic,
    super.key,
  }) : assert(
         semanticLabel == null || semanticLabel != '',
         'semanticLabel must not be empty.',
       );

  // ===========================================================================
  // Image
  // ===========================================================================

  /// Poster image to display.
  ///
  /// When null, [placeholderBuilder] is displayed instead.
  final ImageProvider<Object>? image;

  /// Optional custom placeholder shown when:
  ///
  /// - [image] is null; or
  /// - an asynchronous image is waiting for its first decoded frame.
  ///
  /// When omitted, Cineara's neutral poster placeholder is used.
  final WidgetBuilder? placeholderBuilder;

  /// Optional custom artwork failure state.
  ///
  /// When omitted, Cineara's standard poster failure treatment is used.
  final WidgetBuilder? errorBuilder;

  // ===========================================================================
  // Artwork treatment
  // ===========================================================================

  /// Optional decorative layer rendered above the artwork.
  ///
  /// Appropriate uses include:
  ///
  /// - gradients;
  /// - vignettes;
  /// - tonal overlays;
  /// - artwork-specific scrims.
  ///
  /// The overlay:
  ///
  /// - is clipped to [CinearaShapes.poster];
  /// - ignores pointer interaction;
  /// - remains outside the Hero subtree.
  ///
  /// Media-state UI belongs to `CinearaMediaPosterOverlay`, not here.
  final Widget? overlay;

  // ===========================================================================
  // Hero
  // ===========================================================================

  /// Optional Hero tag for standalone shared-element transitions.
  ///
  /// The Hero child includes the Cineara poster clip so the poster keeps its
  /// canonical silhouette throughout the flight.
  ///
  /// When this widget is placed inside a `CinearaMediaPoster` that already
  /// owns the Hero transition, leave this null.
  final Object? heroTag;

  /// Whether the Hero may transition during user-gesture navigation.
  final bool heroTransitionOnUserGestures;

  // ===========================================================================
  // Geometry
  // ===========================================================================

  /// Whether this component should enforce Cineara's canonical poster aspect
  /// ratio.
  ///
  /// Defaults to true for standalone usage.
  ///
  /// Set this to false when the parent already provides the poster geometry,
  /// such as `CinearaMediaPoster`.
  ///
  /// When false, this widget expands into the constraints supplied by its
  /// parent.
  final bool constrainToPosterAspectRatio;

  /// How the artwork should fit within its poster bounds.
  final BoxFit fit;

  /// Alignment of the artwork within its poster bounds.
  final AlignmentGeometry alignment;

  /// Sampling quality used while scaling the artwork.
  final FilterQuality filterQuality;

  /// Whether a previous image frame should remain visible while a replacement
  /// image provider resolves.
  ///
  /// This defaults to true to reduce flashes when poster providers change
  /// during rebuilds.
  final bool gaplessPlayback;

  /// How artwork and decorative artwork overlays are clipped to Cineara's
  /// poster shape.
  final Clip clipBehavior;

  // ===========================================================================
  // Loading motion
  // ===========================================================================

  /// Duration used to reveal the first decoded asynchronous image frame.
  ///
  /// The transition is automatically disabled when the platform requests
  /// reduced motion.
  final Duration fadeInDuration;

  /// Curve used by the first-frame fade.
  final Curve fadeInCurve;

  // ===========================================================================
  // Accessibility
  // ===========================================================================

  /// Optional accessible description for the artwork.
  ///
  /// Unlike relying only on [Image.semanticLabel], this component-level
  /// semantic treatment also remains meaningful while the placeholder or
  /// failure state is visible.
  ///
  /// Higher-level media cards should normally set
  /// [excludeFromSemantics] to true and provide one media-level semantic label
  /// instead.
  final String? semanticLabel;

  /// Whether the entire artwork subtree should be excluded from accessibility
  /// semantics.
  ///
  /// This is normally true when a parent media card already exposes the title
  /// and interaction semantics.
  final bool excludeFromSemantics;

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final Widget poster = _buildPoster(context);

    if (!constrainToPosterAspectRatio) {
      return SizedBox.expand(child: poster);
    }

    return AspectRatio(
      aspectRatio: CinearaGeometry.posterAspectRatio,
      child: poster,
    );
  }

  Widget _buildPoster(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: <Widget>[
        // ---------------------------------------------------------------------
        // Artwork
        //
        // The artwork clip lives INSIDE the Hero subtree.
        // ---------------------------------------------------------------------
        Positioned.fill(child: _buildArtworkLayer(context)),

        // ---------------------------------------------------------------------
        // Decorative artwork overlay
        //
        // Deliberately outside the Hero, but clipped through exactly the same
        // canonical Cineara poster shape.
        // ---------------------------------------------------------------------
        if (overlay case final Widget artworkOverlay?)
          Positioned.fill(
            child: IgnorePointer(
              child: _clipToPosterShape(child: artworkOverlay),
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // Artwork layer
  // ===========================================================================

  Widget _buildArtworkLayer(BuildContext context) {
    Widget artwork = _clipToPosterShape(child: _buildArtworkContent(context));

    final Object? tag = heroTag;

    if (tag != null) {
      artwork = Hero(
        tag: tag,
        transitionOnUserGestures: heroTransitionOnUserGestures,
        child: artwork,
      );
    }

    return _applyArtworkSemantics(child: artwork);
  }

  Widget _buildArtworkContent(BuildContext context) {
    final ImageProvider<Object>? imageProvider = image;

    if (imageProvider == null) {
      return _buildPlaceholder(context);
    }

    final bool reduceMotion = _reduceMotion(context);

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // The placeholder remains beneath the image until the first decoded
        // frame arrives.
        //
        // This guarantees stable geometry and prevents blank flashes.
        _buildPlaceholder(context),

        Image(
          image: imageProvider,
          fit: fit,
          alignment: alignment,
          filterQuality: filterQuality,
          gaplessPlayback: gaplessPlayback,

          // Artwork semantics are owned by the surrounding component-level
          // Semantics node so placeholder/error/loading states are covered too.
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

                final double opacity = frame == null ? 0 : 1;

                if (reduceMotion || fadeInDuration == Duration.zero) {
                  return Opacity(opacity: opacity, child: child);
                }

                return AnimatedOpacity(
                  opacity: opacity,
                  duration: fadeInDuration,
                  curve: fadeInCurve,
                  child: child,
                );
              },

          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
                return _buildError(context);
              },
        ),
      ],
    );
  }

  // ===========================================================================
  // Poster shape
  // ===========================================================================

  /// Applies Cineara's canonical poster silhouette.
  ///
  /// Poster consumers should not reproduce this geometry using an independent
  /// BorderRadius. [CinearaShapes.poster] is the geometric source of truth.
  Widget _clipToPosterShape({required Widget child}) {
    return ClipPath(
      clipper: ShapeBorderClipper(shape: CinearaShapes.poster()),
      clipBehavior: clipBehavior,
      child: child,
    );
  }

  // ===========================================================================
  // Semantics
  // ===========================================================================

  Widget _applyArtworkSemantics({required Widget child}) {
    if (excludeFromSemantics) {
      return ExcludeSemantics(child: child);
    }

    final String? resolvedLabel = semanticLabel?.trim();

    if (resolvedLabel == null || resolvedLabel.isEmpty) {
      return child;
    }

    return Semantics(
      image: true,
      label: resolvedLabel,

      // Custom placeholders or error builders may contain their own internal
      // semantics. The poster-level artwork label should be the single
      // accessible representation when one is explicitly supplied.
      excludeSemantics: true,
      child: child,
    );
  }

  // ===========================================================================
  // Placeholder / failure
  // ===========================================================================

  Widget _buildPlaceholder(BuildContext context) {
    final WidgetBuilder? builder = placeholderBuilder;

    if (builder != null) {
      return builder(context);
    }

    return const _DefaultPosterPlaceholder();
  }

  Widget _buildError(BuildContext context) {
    final WidgetBuilder? builder = errorBuilder;

    if (builder != null) {
      return builder(context);
    }

    return const _DefaultPosterFailure();
  }

  // ===========================================================================
  // Accessibility motion
  // ===========================================================================

  bool _reduceMotion(BuildContext context) {
    final MediaQueryData? mediaQuery = MediaQuery.maybeOf(context);

    if (mediaQuery == null) {
      return false;
    }

    return mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;
  }
}

// =============================================================================
// Default placeholder
// =============================================================================

/// Default Cineara poster placeholder.
///
/// It stays intentionally quiet because a page may display many poster
/// placeholders simultaneously while artwork is being resolved.
///
/// Avoiding progress spinners here prevents a loading grid from turning into a
/// collection of competing animated indicators.
final class _DefaultPosterPlaceholder extends StatelessWidget {
  const _DefaultPosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 30,
          color: colors.onSurfaceVariant.withValues(alpha: 0.46),
        ),
      ),
    );
  }
}

// =============================================================================
// Default failure
// =============================================================================

/// Default state shown when poster artwork cannot be loaded or decoded.
final class _DefaultPosterFailure extends StatelessWidget {
  const _DefaultPosterFailure();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 30,
          color: colors.onSurfaceVariant.withValues(alpha: 0.62),
        ),
      ),
    );
  }
}
