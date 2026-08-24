import 'package:flutter/material.dart';

/// Cineara-specific semantic colours that are not represented by Material's
/// standard [ColorScheme].
///
/// These values may differ between light, dark, and future themes.
@immutable
final class CinearaThemeExtension
    extends ThemeExtension<CinearaThemeExtension> {
  const CinearaThemeExtension({
    required this.heroOverlay,
    required this.artworkOverlaySurface,
    required this.artworkOverlayOutline,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.progressTrack,
    required this.posterPlaceholder,
    required this.actionSurface,
    required this.actionSurfacePressed,
    required this.actionOutline,
  });

  // Artwork

  /// Overlay applied over hero artwork for readability.
  final Color heroOverlay;

  /// Surface for controls displayed over unpredictable artwork.
  final Color artworkOverlaySurface;

  /// Outline for controls displayed over unpredictable artwork.
  final Color artworkOverlayOutline;

  // Loading and media

  /// Base colour used by loading skeletons.
  final Color skeletonBase;

  /// Highlight colour used by loading skeletons.
  final Color skeletonHighlight;

  /// Background track for progress indicators.
  final Color progressTrack;

  /// Placeholder colour used when poster artwork is unavailable.
  final Color posterPlaceholder;

  // Actions

  /// Surface for custom app-level actions such as Search and Notifications.
  final Color actionSurface;

  /// Pressed or selected state of [actionSurface].
  final Color actionSurfacePressed;

  /// Outline used around app-level action controls.
  final Color actionOutline;

  @override
  CinearaThemeExtension copyWith({
    Color? heroOverlay,
    Color? artworkOverlaySurface,
    Color? artworkOverlayOutline,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? progressTrack,
    Color? posterPlaceholder,
    Color? actionSurface,
    Color? actionSurfacePressed,
    Color? actionOutline,
  }) {
    return CinearaThemeExtension(
      heroOverlay: heroOverlay ?? this.heroOverlay,
      artworkOverlaySurface:
          artworkOverlaySurface ?? this.artworkOverlaySurface,
      artworkOverlayOutline:
          artworkOverlayOutline ?? this.artworkOverlayOutline,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      progressTrack: progressTrack ?? this.progressTrack,
      posterPlaceholder: posterPlaceholder ?? this.posterPlaceholder,
      actionSurface: actionSurface ?? this.actionSurface,
      actionSurfacePressed: actionSurfacePressed ?? this.actionSurfacePressed,
      actionOutline: actionOutline ?? this.actionOutline,
    );
  }

  @override
  CinearaThemeExtension lerp(covariant CinearaThemeExtension? other, double t) {
    if (other == null) {
      return this;
    }

    return CinearaThemeExtension(
      heroOverlay: Color.lerp(heroOverlay, other.heroOverlay, t)!,
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
      actionSurface: Color.lerp(actionSurface, other.actionSurface, t)!,
      actionSurfacePressed: Color.lerp(
        actionSurfacePressed,
        other.actionSurfacePressed,
        t,
      )!,
      actionOutline: Color.lerp(actionOutline, other.actionOutline, t)!,
    );
  }
}

/// Provides convenient access to Cineara-specific theme values.
extension CinearaThemeDataExtension on ThemeData {
  CinearaThemeExtension get cineara {
    final extension = this.extension<CinearaThemeExtension>();

    if (extension == null) {
      throw StateError(
        'CinearaThemeExtension is missing from the current ThemeData.',
      );
    }

    return extension;
  }
}
