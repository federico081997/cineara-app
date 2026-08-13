import 'package:flutter/material.dart';

/// Defines Cineara-specific theme values that are not covered by Flutter's
/// standard ThemeData, such as progress, skeleton, backdrop and other semantic
/// UI colors.

@immutable
class CinearaThemeExtension extends ThemeExtension<CinearaThemeExtension> {
  const CinearaThemeExtension({
    required this.heroOverlay,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.progressTrack,
    required this.posterPlaceholder,
    required this.artworkOverlaySurface,
    required this.artworkOverlayOutline,
  });

  final Color heroOverlay;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color progressTrack;
  final Color posterPlaceholder;

  /// Neutral surface used by controls displayed over unpredictable artwork.
  ///
  /// Examples include external-rating pills, personal-rating pills, and
  /// passive status docks.
  final Color artworkOverlaySurface;

  /// Outline used around neutral controls displayed over artwork.
  final Color artworkOverlayOutline;

  @override
  CinearaThemeExtension copyWith({
    Color? heroOverlay,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? progressTrack,
    Color? posterPlaceholder,
    Color? artworkOverlaySurface,
    Color? artworkOverlayOutline,
  }) {
    return CinearaThemeExtension(
      heroOverlay: heroOverlay ?? this.heroOverlay,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      progressTrack: progressTrack ?? this.progressTrack,
      posterPlaceholder: posterPlaceholder ?? this.posterPlaceholder,
      artworkOverlaySurface:
          artworkOverlaySurface ?? this.artworkOverlaySurface,
      artworkOverlayOutline:
          artworkOverlayOutline ?? this.artworkOverlayOutline,
    );
  }

  @override
  CinearaThemeExtension lerp(covariant CinearaThemeExtension? other, double t) {
    if (other == null) {
      return this;
    }

    return CinearaThemeExtension(
      heroOverlay: Color.lerp(heroOverlay, other.heroOverlay, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      posterPlaceholder: Color.lerp(
        posterPlaceholder,
        other.posterPlaceholder,
        t,
      )!,
      artworkOverlaySurface: Color.lerp(
        artworkOverlaySurface,
        other.artworkOverlaySurface,
        t,
      )!,
      artworkOverlayOutline: Color.lerp(
        artworkOverlayOutline,
        other.artworkOverlayOutline,
        t,
      )!,
    );
  }
}
