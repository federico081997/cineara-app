import 'package:flutter/material.dart';

/// Centralised elevation values and shared artwork-edge treatment used
/// throughout the Cineara design system.
///
/// Cineara uses elevation sparingly. Visual hierarchy should primarily come
/// from:
///
/// - surface colour;
/// - borders;
/// - spacing;
/// - typography;
/// - artwork;
/// - component geometry.
///
/// Cards and grouped surfaces remain intentionally flat.
///
/// Media posters and person portraits are also intentionally shadowless.
/// Their separation from the surrounding page comes from a subtle, centralized
/// physical rim rather than a drop shadow or glow.
///
/// Keeping artwork shadowless is especially important in Cineara because:
///
/// - posters already contain visually dense imagery;
/// - circular portraits should not look like floating avatar buttons;
/// - large blurred shadows look heavy in dark mode;
/// - tinted shadows can look unnatural in light mode;
/// - the artwork rim is enough to preserve edge definition.
///
/// Components should consume the helpers in this file rather than defining
/// their own artwork rim colours or widths. Small People portraits use the
/// dedicated portrait-rim helpers because their compact circular edge needs
/// slightly stronger optical definition than a poster.
abstract final class CinearaElevation {
  const CinearaElevation._();

  // ===========================================================================
  // Base scale
  // ===========================================================================

  /// Flat surface with no elevation.
  static const double none = 0;

  /// Low elevation for elements that genuinely require slight separation.
  static const double low = 2;

  /// Standard elevation for floating controls.
  static const double medium = 4;

  /// Strong elevation for persistent floating surfaces.
  static const double high = 6;

  /// Maximum standard elevation for temporary overlays.
  static const double overlay = 8;

  // ===========================================================================
  // Semantic elevations
  // ===========================================================================

  /// Standard card elevation.
  ///
  /// Cineara cards are intentionally flat.
  static const double card = none;

  /// Standard grouped or informational surface.
  static const double surface = none;

  /// Raised surface requiring additional separation.
  static const double raisedSurface = low;

  // ===========================================================================
  // Artwork elevation
  // ===========================================================================

  /// Artwork is intentionally shadowless.
  ///
  /// Posters and portraits are separated from the page through the centralized
  /// artwork rim rather than a persistent drop shadow.
  static const double artwork = none;

  /// Artwork remains shadowless while pressed.
  static const double artworkPressed = none;

  // ===========================================================================
  // Floating UI
  // ===========================================================================

  /// Compact floating control displayed above content.
  static const double floatingControl = medium;

  /// Persistent floating bottom-navigation surface.
  static const double navigation = high;

  /// Popup or contextual menu.
  static const double menu = overlay;

  /// Transient floating feedback such as a snackbar.
  static const double snackbar = high;

  /// Dialog surface.
  static const double dialog = overlay;

  /// Modal or temporary overlay surface.
  static const double modal = overlay;

  // ===========================================================================
  // Artwork optical treatment
  // ===========================================================================

  /// Artwork intentionally has no resting or pressed drop shadow.
  ///
  /// This method remains part of the public design-system API so media and
  /// People components do not need to special-case the shadowless treatment.
  ///
  /// [interactionProgress] is retained for API stability and future tuning.
  static List<BoxShadow> artworkShadows(
    BuildContext context, {
    required double interactionProgress,
  }) {
    return const <BoxShadow>[];
  }

  /// Circular People portraits use the same shadowless treatment as posters.
  ///
  /// The stronger portrait separation previously supplied by extra circular
  /// shadows is deliberately removed. Edge definition comes from the same
  /// centralized rim used by all artwork.
  ///
  /// [interactionProgress] is retained for API stability and future tuning.
  static List<BoxShadow> portraitShadows(
    BuildContext context, {
    required double interactionProgress,
  }) {
    return const <BoxShadow>[];
  }

  /// No paint-only portrait lift is required without a corresponding shadow.
  ///
  /// Person components may continue multiplying this value by their depth
  /// factor without needing any structural change.
  static const double portraitRestingLift = 0;

  // ===========================================================================
  // Shared artwork rim
  // ===========================================================================

  /// Shared physical edge colour for posters and person portraits.
  ///
  /// Dark mode uses a neutral translucent white edge.
  ///
  /// Light mode deliberately uses neutral black rather than
  /// [ColorScheme.outlineVariant]. `outlineVariant` can inherit noticeable
  /// seed-colour toning in generated Material colour schemes, which can make
  /// poster and portrait edges look pink, purple, or muddy against a light
  /// Cineara page.
  ///
  /// The rim is a physical artwork boundary, not a glow or selection state.
  static Color artworkRimColor(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool highContrast = MediaQuery.highContrastOf(context);

    if (theme.brightness == Brightness.dark) {
      return Colors.white.withValues(alpha: highContrast ? 0.24 : 0.14);
    }

    return Colors.black.withValues(alpha: highContrast ? 0.24 : 0.12);
  }

  /// Shared artwork rim width.
  ///
  /// One logical pixel gives posters and portraits a clearly readable edge
  /// without making them look framed. High-contrast mode strengthens the
  /// boundary slightly.
  static double artworkRimWidth(BuildContext context) {
    return MediaQuery.highContrastOf(context) ? 1.75 : 1.0;
  }

  /// Stronger physical edge colour for small circular People portraits.
  ///
  /// Circular portraits are only ~72-88 dp in most Cineara surfaces, so the
  /// normal poster rim can become visually lost against the image edge. People
  /// therefore use a slightly stronger neutral rim while remaining shadowless.
  static Color portraitRimColor(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool highContrast = MediaQuery.highContrastOf(context);

    if (theme.brightness == Brightness.dark) {
      return Colors.white.withValues(alpha: highContrast ? 0.34 : 0.24);
    }

    return Colors.black.withValues(alpha: highContrast ? 0.28 : 0.18);
  }

  /// Rim width for small circular People portraits.
  ///
  /// Slightly thicker than the poster rim so the circular boundary remains
  /// visible after anti-aliasing at compact portrait sizes.
  static double portraitRimWidth(BuildContext context) {
    return MediaQuery.highContrastOf(context) ? 2.0 : 1.25;
  }

  /// Resolves the People portrait rim for rest vs hover/focus.
  ///
  /// The resting rim stays neutral. Hover/focus adds only a restrained primary
  /// tint so the edge still reads as a physical boundary rather than selection.
  static Color portraitRimColorForState(
    BuildContext context, {
    required bool emphasized,
  }) {
    final Color resting = portraitRimColor(context);

    if (!emphasized) {
      return resting;
    }

    return Color.lerp(resting, Theme.of(context).colorScheme.primary, 0.24)!;
  }

  /// Resolves an artwork rim that may be gently emphasized by hover or focus.
  ///
  /// Resting artwork remains neutral. Hover/focus introduces only a restrained
  /// primary tint so the physical edge does not become a bright selection ring.
  static Color artworkRimColorForState(
    BuildContext context, {
    required bool emphasized,
  }) {
    final Color resting = artworkRimColor(context);

    if (!emphasized) {
      return resting;
    }

    return Color.lerp(resting, Theme.of(context).colorScheme.primary, 0.28)!;
  }
}
