/// Content width constraints used throughout the Cineara design system.
///
/// These values limit the width of content independently of the available
/// window size.
///
/// Typical usage:
/// - Narrow: focused content such as forms, error states, and empty states.
/// - Medium: settings, details, and text-heavy content.
/// - Wide: richer page layouts and multi-column content.
/// - Extra wide: large-screen layouts, grids, and dashboards.
abstract final class CinearaContentWidths {
  /// Maximum width for narrow, focused content.
  static const double narrow = 480;

  /// Maximum width for standard page content.
  static const double medium = 720;

  /// Maximum width for wide page content.
  static const double wide = 960;

  /// Maximum width for large-screen page content.
  static const double extraWide = 1200;
}
