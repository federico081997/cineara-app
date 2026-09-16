import 'package:flutter/material.dart';

import '../tokens/geometry.dart';

/// Centralised semantic shape definitions for the Cineara design system.
///
/// [CinearaShapes] translates Cineara's geometry tokens into reusable Flutter
/// [ShapeBorder] implementations.
///
/// Feature and component code should prefer semantic shapes such as:
///
/// ```dart
/// shape: CinearaShapes.card(),
/// ```
///
/// rather than constructing [RoundedRectangleBorder], [StadiumBorder], or
/// [CircleBorder] instances directly.
///
/// This keeps geometry consistent across the application and allows Cineara's
/// visual language to evolve centrally without requiring changes throughout
/// individual feature widgets.
///
/// ## Shape language
///
/// Cineara uses four primary shape families:
///
/// - continuous surfaces for substantial interface regions;
/// - rounded rectangles for controls, navigation, artwork, and compact badges;
/// - capsules for chips and selected-state indicators;
/// - circles for inherently circular controls and identity elements.
///
/// Border colour and width remain component or theme concerns, so each helper
/// accepts an optional [BorderSide].
abstract final class CinearaShapes {
  // ---------------------------------------------------------------------------
  // Surfaces
  // ---------------------------------------------------------------------------

  /// Standard card shape.
  ///
  /// Suitable for:
  ///
  /// - media information;
  /// - statistics;
  /// - summaries;
  /// - dashboard cards;
  /// - settings groups;
  /// - reusable content panels.
  ///
  /// Continuous corners give substantial Cineara surfaces a softer visual
  /// character without introducing asymmetric or decorative geometry.
  static ContinuousRectangleBorder card({BorderSide side = BorderSide.none}) {
    return ContinuousRectangleBorder(
      side: side,
      borderRadius: BorderRadius.circular(CinearaGeometry.surfaceRadius),
    );
  }

  /// Standard low-emphasis grouped surface.
  ///
  /// This currently shares its geometry with [card], but retains a separate
  /// semantic role so grouped surfaces and cards may evolve independently.
  static ContinuousRectangleBorder surface({
    BorderSide side = BorderSide.none,
  }) {
    return ContinuousRectangleBorder(
      side: side,
      borderRadius: BorderRadius.circular(CinearaGeometry.surfaceRadius),
    );
  }

  /// Large or visually prominent surface.
  ///
  /// Suitable for:
  ///
  /// - featured recommendations;
  /// - major summary regions;
  /// - important statistics;
  /// - hero-adjacent content;
  /// - high-emphasis panels.
  static ContinuousRectangleBorder prominentSurface({
    BorderSide side = BorderSide.none,
  }) {
    return ContinuousRectangleBorder(
      side: side,
      borderRadius: BorderRadius.circular(
        CinearaGeometry.prominentSurfaceRadius,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Controls
  // ---------------------------------------------------------------------------

  /// Standard interactive-control shape.
  ///
  /// Suitable for buttons, segmented controls, input-adjacent actions, and
  /// other conventional interactive elements.
  static RoundedRectangleBorder control({BorderSide side = BorderSide.none}) {
    return RoundedRectangleBorder(
      side: side,
      borderRadius: BorderRadius.circular(CinearaGeometry.controlRadius),
    );
  }

  /// Compact interactive-control shape.
  ///
  /// Suitable for dense actions and controls where the standard control radius
  /// would appear visually oversized.
  static RoundedRectangleBorder compactControl({
    BorderSide side = BorderSide.none,
  }) {
    return RoundedRectangleBorder(
      side: side,
      borderRadius: BorderRadius.circular(CinearaGeometry.compactControlRadius),
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  /// Outer floating-navigation surface.
  ///
  /// The persistent navigation container uses a generously rounded rectangle
  /// rather than a full capsule. This keeps the navigation soft and modern
  /// while allowing its selected indicator to remain visually distinct.
  static RoundedRectangleBorder navigation({
    BorderSide side = BorderSide.none,
  }) {
    return RoundedRectangleBorder(
      side: side,
      borderRadius: BorderRadius.circular(CinearaGeometry.navigationRadius),
    );
  }

  /// Selected navigation-destination indicator.
  ///
  /// A true capsule communicates selection clearly inside the larger
  /// navigation container.
  static StadiumBorder navigationIndicator({
    BorderSide side = BorderSide.none,
  }) {
    return StadiumBorder(side: side);
  }

  // ---------------------------------------------------------------------------
  // Badges
  // ---------------------------------------------------------------------------

  /// Compact status or metadata badge.
  ///
  /// Suitable for:
  ///
  /// - watching state;
  /// - favourites;
  /// - collections;
  /// - ratings;
  /// - compact poster metadata.
  ///
  /// Badges use conventional rounded geometry because their small dimensions
  /// benefit from a simple, predictable silhouette.
  static RoundedRectangleBorder badge({BorderSide side = BorderSide.none}) {
    return RoundedRectangleBorder(
      side: side,
      borderRadius: BorderRadius.circular(CinearaGeometry.badgeRadius),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialogs and overlays
  // ---------------------------------------------------------------------------

  /// Dialog surface.
  ///
  /// Dialogs share the softer continuous geometry of prominent Cineara
  /// surfaces while remaining visually distinct through their surrounding
  /// modal treatment.
  static ContinuousRectangleBorder dialog({BorderSide side = BorderSide.none}) {
    return ContinuousRectangleBorder(
      side: side,
      borderRadius: BorderRadius.circular(
        CinearaGeometry.prominentSurfaceRadius,
      ),
    );
  }

  /// Popup or contextual-menu surface.
  static ContinuousRectangleBorder menu({BorderSide side = BorderSide.none}) {
    return ContinuousRectangleBorder(
      side: side,
      borderRadius: BorderRadius.circular(CinearaGeometry.surfaceRadius),
    );
  }

  /// Snackbar or compact transient-feedback surface.
  static RoundedRectangleBorder snackbar({BorderSide side = BorderSide.none}) {
    return RoundedRectangleBorder(
      side: side,
      borderRadius: BorderRadius.circular(CinearaGeometry.controlRadius),
    );
  }

  // ---------------------------------------------------------------------------
  // Artwork
  // ---------------------------------------------------------------------------

  /// Standard poster-artwork shape.
  ///
  /// Artwork intentionally uses conventional rounded corners rather than
  /// Cineara's stronger continuous surface treatment so the image remains the
  /// dominant visual element.
  static RoundedRectangleBorder poster({BorderSide side = BorderSide.none}) {
    return RoundedRectangleBorder(
      side: side,
      borderRadius: BorderRadius.circular(CinearaGeometry.posterRadius),
    );
  }

  /// Standard landscape-artwork shape.
  ///
  /// Suitable for:
  ///
  /// - episode stills;
  /// - backdrops;
  /// - preview imagery;
  /// - landscape media thumbnails.
  static RoundedRectangleBorder thumbnail({BorderSide side = BorderSide.none}) {
    return RoundedRectangleBorder(
      side: side,
      borderRadius: BorderRadius.circular(CinearaGeometry.thumbnailRadius),
    );
  }

  // ---------------------------------------------------------------------------
  // Primitive semantic shapes
  // ---------------------------------------------------------------------------

  /// Fully rounded capsule shape.
  ///
  /// Suitable for:
  ///
  /// - filter chips;
  /// - short metadata labels;
  /// - compact selectors;
  /// - selected-state indicators;
  /// - pill-style actions.
  static StadiumBorder capsule({BorderSide side = BorderSide.none}) {
    return StadiumBorder(side: side);
  }

  /// Circular shape.
  ///
  /// Suitable for:
  ///
  /// - avatars;
  /// - icon-only controls;
  /// - circular artwork;
  /// - compact floating actions;
  /// - other inherently circular elements.
  static CircleBorder circle({BorderSide side = BorderSide.none}) {
    return CircleBorder(side: side);
  }
}
