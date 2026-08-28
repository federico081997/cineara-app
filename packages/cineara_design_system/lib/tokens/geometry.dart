import 'radius.dart';

/// Centralised geometry values used throughout the Cineara design system.
///
/// This token layer defines Cineara's structural visual language:
///
/// - semantic corner radii;
/// - circular and capsule geometry;
/// - media aspect ratios.
///
/// Raw radius values remain defined by [CinearaRadii]. This class maps those
/// values onto semantic interface roles so individual components do not choose
/// arbitrary geometry.
///
/// Cineara uses a restrained rounded visual language:
///
/// - compact controls use tighter radii;
/// - cards and surfaces use soft rounded corners;
/// - chips, badges, and selected indicators may use capsule geometry;
/// - circular geometry is reserved for icon-only controls, avatars, and
///   similarly compact elements.
///
/// Geometry should remain relatively stable across screen sizes. Responsive
/// dimensions such as page padding, grid columns, content widths, and card
/// widths belong in layout-specific tokens instead.
abstract final class CinearaGeometry {
  // ---------------------------------------------------------------------------
  // Semantic corner radii
  // ---------------------------------------------------------------------------

  /// Corner radius for poster artwork.
  ///
  /// Artwork remains slightly quieter than surrounding interface surfaces so
  /// the media itself stays visually dominant.
  static const double posterRadius = CinearaRadii.md;

  /// Corner radius for landscape artwork such as episode thumbnails.
  static const double thumbnailRadius = CinearaRadii.md;

  /// Radius for compact interface surfaces.
  static const double compactSurfaceRadius = CinearaRadii.md;

  /// Default radius for standard cards and interface surfaces.
  static const double surfaceRadius = CinearaRadii.lg;

  /// Radius for large or visually prominent surfaces.
  static const double prominentSurfaceRadius = CinearaRadii.xl;

  /// Radius for ordinary controls such as buttons and segmented actions.
  static const double controlRadius = CinearaRadii.md;

  /// Radius for dense or compact controls.
  static const double compactControlRadius = CinearaRadii.sm;

  /// Radius for compact metadata and status badges.
  static const double badgeRadius = CinearaRadii.sm;

  /// Radius for Cineara's floating bottom-navigation surface.
  static const double navigationRadius = CinearaRadii.xl;

  /// Radius for fully rounded chips, filters, badges, and selected indicators.
  static const double capsuleRadius = CinearaRadii.pill;

  // ---------------------------------------------------------------------------
  // Media aspect ratios
  // ---------------------------------------------------------------------------

  /// Standard theatrical poster aspect ratio.
  ///
  /// Equivalent to width : height = 2 : 3.
  static const double posterAspectRatio = 2 / 3;

  /// Standard widescreen artwork aspect ratio.
  ///
  /// Used for backdrops, stills, and episode thumbnails.
  static const double landscapeAspectRatio = 16 / 9;

  /// Square aspect ratio used by avatars, artwork, or identity elements.
  static const double squareAspectRatio = 1;
}
