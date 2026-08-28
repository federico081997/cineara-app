/// Centralised elevation values used throughout the Cineara design system.
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
/// Shadows are reserved for elements that genuinely float above surrounding
/// content, such as navigation, menus, dialogs, and overlay controls.
///
/// Shadow colour and opacity belong to the theme or component styling layer
/// rather than this token file.
abstract final class CinearaElevation {
  // ---------------------------------------------------------------------------
  // Base scale
  // ---------------------------------------------------------------------------

  /// Flat surface with no elevation.
  static const double none = 0;

  /// Low elevation for elements that require slight separation.
  static const double low = 2;

  /// Standard elevation for floating controls.
  static const double medium = 4;

  /// Strong elevation for persistent floating surfaces.
  static const double high = 6;

  /// Maximum standard elevation for temporary overlays.
  static const double overlay = 8;

  // ---------------------------------------------------------------------------
  // Semantic elevations
  // ---------------------------------------------------------------------------

  /// Standard card elevation.
  ///
  /// Cineara cards are intentionally flat. Separation should come from their
  /// surface treatment or border rather than a persistent shadow.
  static const double card = none;

  /// Standard grouped or informational surface.
  static const double surface = none;

  /// Raised surface requiring additional separation.
  static const double raisedSurface = low;

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
}
