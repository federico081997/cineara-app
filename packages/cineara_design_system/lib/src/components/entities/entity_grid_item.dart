import 'dart:async';

import 'package:flutter/material.dart';

import '../../foundations/tokens/elevation.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/spacing.dart';
import '../media/media_poster.dart';
import '../media/media_poster_overlay.dart';
import '../media/media_status_dock.dart';

// =============================================================================
// Entity visual variant
// =============================================================================

/// Visual treatment used by Cineara entity results.
///
/// These values describe presentation rather than backend domain types:
///
/// - [poster] is a fixed 2:3 image, currently used by TMDB collections.
/// - [logo] is contained artwork on an adaptive light logo plate, currently
///   used by studios/companies.
/// - [icon] is a square symbolic surface, currently used by topics/keywords.
enum CinearaEntityVisualVariant { poster, logo, icon }

/// Shared presentation values for entity artwork.
///
/// Interactive entity components intentionally reuse [CinearaMediaPoster]
/// rather than maintaining a second press-animation implementation. Therefore
/// entity artwork inherits the exact media-poster compression, downward travel,
/// scrim, shadow contraction, long-hold outline/glow, reduced-motion behavior,
/// keyboard activation and scroll-abandonment choreography.
extension CinearaEntityVisualVariantPresentation on CinearaEntityVisualVariant {
  /// Width-to-height ratio used by the shared interactive artwork surface.
  double get aspectRatio {
    return switch (this) {
      CinearaEntityVisualVariant.poster => 2 / 3,
      CinearaEntityVisualVariant.logo => 3 / 2,
      CinearaEntityVisualVariant.icon => 1,
    };
  }

  /// Height produced for a known fixed width.
  double heightForWidth(double width) => width / aspectRatio;

  /// Entity artwork uses the same frame radius as the media-poster primitive.
  BorderRadius get borderRadius =>
      const BorderRadius.all(Radius.circular(CinearaRadii.md));

  /// Base frame surface.
  ///
  /// The base is deliberately neutral for every entity family. A successful
  /// Studio/company logo paints its own light logo plate inside
  /// [CinearaEntityArtwork]. Keeping the frame neutral means a missing, loading or
  /// failed logo naturally falls back to the same Cineara artwork surface used by
  /// posters instead of leaving a white plate behind.
  ///
  /// [hasArtwork] is retained for source compatibility with callers that already
  /// pass it, but background selection no longer depends on that flag.
  Color backgroundColor(BuildContext context, {bool hasArtwork = true}) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return colors.surfaceContainerHighest;
  }

  /// Light, theme-aware plate used only after a real Studio/company logo has
  /// produced an image frame successfully.
  Color logoPlateColor(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return theme.brightness == Brightness.dark
        ? Color.lerp(colors.inverseSurface, colors.surface, 0.06)!
        : Color.lerp(colors.surface, colors.surfaceContainerHighest, 0.30)!;
  }
}

// =============================================================================
// Raw entity artwork
// =============================================================================

/// Raw entity artwork intended to live inside a frame-owning component.
///
/// This widget owns only image/fallback presentation:
///
/// ```text
/// poster -> BoxFit.cover
/// logo   -> successful logo: full light plate + contained artwork;
///           missing/loading/failed logo: full neutral fallback + one shared icon
/// icon   -> centered symbolic fallback when no image exists
/// ```
///
/// It deliberately owns no shadow, rim, press motion, Hero, semantics or input
/// handling. [CinearaEntityGridItem] and [CinearaEntityListItem] place it inside
/// [CinearaMediaPoster], which is the single interaction authority.
final class CinearaEntityArtwork extends StatelessWidget {
  const CinearaEntityArtwork({
    required this.title,
    required this.variant,
    super.key,
    this.image,
    this.fallbackIcon,
    this.logoPadding = CinearaSpacing.md,
  }) : assert(title != '', 'title must not be empty.'),
       assert(logoPadding >= 0, 'logoPadding must not be negative.');

  final String title;
  final CinearaEntityVisualVariant variant;
  final ImageProvider<Object>? image;
  final IconData? fallbackIcon;
  final double logoPadding;

  @override
  Widget build(BuildContext context) {
    final ImageProvider<Object>? resolvedImage = image;

    if (variant == CinearaEntityVisualVariant.logo) {
      return _EntityStudioLogoArtwork(
        title: title,
        image: resolvedImage,
        logoPadding: logoPadding,
      );
    }

    if (resolvedImage == null) {
      return _EntityArtworkFallback(
        title: title,
        variant: variant,
        fallbackIcon: fallbackIcon,
      );
    }

    return Image(
      image: resolvedImage,
      fit: variant == CinearaEntityVisualVariant.poster
          ? BoxFit.cover
          : BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return _EntityArtworkFallback(
              title: title,
              variant: variant,
              fallbackIcon: fallbackIcon,
            );
          },
    );
  }
}

/// Studio/company artwork has a deliberately different success/fallback contract.
///
/// The neutral fallback always fills the complete frame. A real logo is placed on
/// the light logo plate only after an image frame has been produced successfully.
/// If the provider is absent, still loading, or ultimately fails, the full-frame
/// fallback remains visible. This prevents an inset fallback rectangle inside a
/// white/light Studio plate.
final class _EntityStudioLogoArtwork extends StatelessWidget {
  const _EntityStudioLogoArtwork({
    required this.title,
    required this.image,
    required this.logoPadding,
  });

  final String title;
  final ImageProvider<Object>? image;
  final double logoPadding;

  @override
  Widget build(BuildContext context) {
    final Widget fallback = _EntityArtworkFallback(
      title: title,
      variant: CinearaEntityVisualVariant.logo,
      fallbackIcon: null,
    );

    final ImageProvider<Object>? resolvedImage = image;

    if (resolvedImage == null) {
      return fallback;
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        fallback,
        Image(
          image: resolvedImage,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          frameBuilder:
              (
                BuildContext context,
                Widget child,
                int? frame,
                bool wasSynchronouslyLoaded,
              ) {
                if (!wasSynchronouslyLoaded && frame == null) {
                  return const SizedBox.shrink();
                }

                return ColoredBox(
                  color: CinearaEntityVisualVariant.logo.logoPlateColor(
                    context,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(logoPadding),
                    child: child,
                  ),
                );
              },
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
                // Leave the full-size neutral fallback underneath visible.
                return const SizedBox.shrink();
              },
        ),
      ],
    );
  }
}

final class _EntityArtworkFallback extends StatelessWidget {
  const _EntityArtworkFallback({
    required this.title,
    required this.variant,
    required this.fallbackIcon,
  });

  final String title;
  final CinearaEntityVisualVariant variant;
  final IconData? fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    if (variant == CinearaEntityVisualVariant.logo) {
      return ColoredBox(
        color: colors.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.apartment_rounded,
            size: 34,
            color: colors.primary.withValues(alpha: 0.78),
          ),
        ),
      );
    }

    final IconData icon =
        fallbackIcon ??
        switch (variant) {
          CinearaEntityVisualVariant.poster =>
            Icons.collections_bookmark_rounded,
          CinearaEntityVisualVariant.logo => Icons.apartment_rounded,
          CinearaEntityVisualVariant.icon => Icons.tag_rounded,
        };

    return Center(
      child: Icon(
        icon,
        size: variant == CinearaEntityVisualVariant.icon ? 34 : 38,
        color: colors.primary.withValues(alpha: 0.78),
      ),
    );
  }
}

// =============================================================================
// Low-level fixed visual
// =============================================================================

/// Low-level fixed-frame entity visual.
///
/// Most feature code should use [CinearaEntityGridItem] or
/// `CinearaEntityListItem`. This primitive remains available for specialized
/// composition that already owns interaction externally.
///
/// Unlike the interactive entity items, this widget does not own pointer
/// gestures. [artworkZoom] and [interactionProgress] are supplied by its parent.
final class CinearaEntityVisual extends StatelessWidget {
  const CinearaEntityVisual({
    required this.title,
    required this.variant,
    required this.width,
    required this.artworkZoom,
    required this.interactionProgress,
    required this.emphasized,
    super.key,
    this.image,
    this.fallbackIcon,
    this.heroTag,
    this.heroTransitionOnUserGestures = false,
    this.logoPadding = CinearaSpacing.md,
  }) : assert(title != '', 'title must not be empty.'),
       assert(width > 0, 'width must be greater than zero.'),
       assert(artworkZoom > 0, 'artworkZoom must be greater than zero.'),
       assert(
         interactionProgress >= 0 && interactionProgress <= 1,
         'interactionProgress must be in the range 0..1.',
       ),
       assert(logoPadding >= 0, 'logoPadding must not be negative.');

  final String title;
  final CinearaEntityVisualVariant variant;
  final ImageProvider<Object>? image;
  final double width;
  final IconData? fallbackIcon;
  final Object? heroTag;
  final bool heroTransitionOnUserGestures;
  final double artworkZoom;
  final double interactionProgress;
  final bool emphasized;
  final double logoPadding;

  double get height => variant.heightForWidth(width);

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = variant.borderRadius;

    Widget frame = SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: CinearaElevation.artworkRimColorForState(
              context,
              emphasized: emphasized,
            ),
            width: CinearaElevation.artworkRimWidth(context),
          ),
          boxShadow: CinearaElevation.artworkShadows(
            context,
            interactionProgress: interactionProgress,
          ),
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: ColoredBox(
            color: variant.backgroundColor(context, hasArtwork: image != null),
            child: ClipRect(
              child: Transform.scale(
                scale: artworkZoom,
                alignment: Alignment.center,
                child: CinearaEntityArtwork(
                  title: title,
                  variant: variant,
                  image: image,
                  fallbackIcon: fallbackIcon,
                  logoPadding: logoPadding,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final Object? resolvedHeroTag = heroTag;

    if (resolvedHeroTag != null) {
      frame = Hero(
        tag: resolvedHeroTag,
        transitionOnUserGestures: heroTransitionOnUserGestures,
        child: frame,
      );
    }

    return frame;
  }
}

// =============================================================================
// Entity Grid / rail item
// =============================================================================

/// Grid/rail result for collection-, studio- and topic-like entities.
///
/// Interaction is intentionally delegated to [CinearaMediaPoster]. This keeps
/// entity artwork mechanically identical to media posters:
///
/// ```text
/// pointer down
/// -> 0.988 scale at ordinary press depth
/// -> tiny downward travel
/// -> restrained darkening
/// -> shared artwork shadow contracts
///
/// tap confirmation
/// -> ~0.981 scale
/// -> smooth release
/// -> onTap
///
/// confirmed hold
/// -> 0.970 scale
/// -> darker artwork
/// -> primary outline + restrained glow
/// -> light haptic on touch/stylus
/// -> onLongPress
/// ```
///
/// The title remains passive, matching [CinearaMediaGridItem]'s poster-only
/// interaction contract. The Favorite dock is also passive and stays mounted so
/// its own mutation animation can run without competing with poster gestures.
final class CinearaEntityGridItem extends StatefulWidget {
  const CinearaEntityGridItem({
    required this.title,
    required this.variant,
    required this.statusDockLabels,
    super.key,
    this.image,
    this.favorite = false,
    this.showFavorite = true,
    this.fallbackIcon,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.semanticHint,
    this.heroTag,
    this.heroTransitionOnUserGestures = false,
    this.logoPadding = CinearaSpacing.md,
    this.metadataTopGap = 10,
  }) : assert(title != '', 'title must not be empty.'),
       assert(logoPadding >= 0, 'logoPadding must not be negative.'),
       assert(metadataTopGap >= 0, 'metadataTopGap must not be negative.');

  final String title;
  final CinearaEntityVisualVariant variant;
  final ImageProvider<Object>? image;

  final bool favorite;
  final bool showFavorite;
  final CinearaStatusDockLabels statusDockLabels;

  final IconData? fallbackIcon;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final String? semanticLabel;
  final String? semanticHint;

  final Object? heroTag;
  final bool heroTransitionOnUserGestures;

  final double logoPadding;
  final double metadataTopGap;

  @override
  State<CinearaEntityGridItem> createState() => _CinearaEntityGridItemState();
}

final class _CinearaEntityGridItemState extends State<CinearaEntityGridItem> {
  late final CinearaStatusDockController _favoriteController;

  @override
  void initState() {
    super.initState();
    _favoriteController = CinearaStatusDockController();
  }

  @override
  void didUpdateWidget(CinearaEntityGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.showFavorite || oldWidget.favorite == widget.favorite) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_favoriteController.attached) {
        return;
      }

      unawaited(
        _favoriteController.revealChanges(
          changedIndicators: const <CinearaStatusDockIndicator>{
            CinearaStatusDockIndicator.favorite,
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // The parent grid/rail owns horizontal spacing. Do not introduce a second
        // entity-specific gutter here: doing so would make a 2:3 Collection poster
        // physically narrower than a media poster placed in an equally wide cell.
        final double availableWidth = constraints.maxWidth;
        final double visualWidth = availableWidth.isFinite
            ? availableWidth.clamp(64.0, double.infinity).toDouble()
            : 120;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: visualWidth,
              child: CinearaMediaPoster(
                artwork: CinearaEntityArtwork(
                  title: widget.title,
                  variant: widget.variant,
                  image: widget.image,
                  fallbackIcon: widget.fallbackIcon,
                  logoPadding: widget.logoPadding,
                ),
                aspectRatio: widget.variant.aspectRatio,
                borderRadius: widget.variant.borderRadius,
                backgroundColor: widget.variant.backgroundColor(
                  context,
                  hasArtwork: widget.image != null,
                ),
                semanticLabel: _resolvedSemanticLabel,
                semanticHint: widget.semanticHint,
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                heroTag: widget.heroTag,
                heroTransitionOnUserGestures:
                    widget.heroTransitionOnUserGestures,
                overlay: widget.showFavorite
                    ? CinearaMediaPosterOverlay(
                        statusDock: _buildFavoriteDock(),
                      )
                    : null,
              ),
            ),
            SizedBox(height: widget.metadataTopGap),
            Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                height: 1.16,
              ),
            ),
          ],
        );
      },
    );
  }

  CinearaStatusDock _buildFavoriteDock() {
    return CinearaStatusDock(
      controller: _favoriteController,
      labels: widget.statusDockLabels,
      favorite: widget.favorite,
      visibleIndicators: const <CinearaStatusDockIndicator>{
        CinearaStatusDockIndicator.favorite,
      },
      mode: CinearaStatusDockMode.permanent,
      variant: CinearaStatusDockVariant.artwork,
      density: CinearaStatusDockDensity.compact,
      layout: CinearaStatusDockLayout.vertical,
      side: CinearaStatusDockSide.end,
      tapToExpand: false,
      autoCollapse: false,
      excludeFromSemantics: true,
    );
  }

  String get _resolvedSemanticLabel {
    final String? explicit = widget.semanticLabel?.trim();

    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }

    final List<String> parts = <String>[widget.title.trim()];

    if (widget.showFavorite && widget.favorite) {
      parts.add(widget.statusDockLabels.favorite);
    }

    return parts.join('. ');
  }
}
