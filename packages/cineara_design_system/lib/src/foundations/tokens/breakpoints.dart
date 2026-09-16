/// Responsive layout sizes used throughout the Cineara design system.
enum CinearaWindowSize { compact, medium, expanded, large }

/// Responsive layout breakpoints used by the Cineara design system.
///
/// Breakpoints use the available logical width of the layout rather than
/// the physical dimensions of the device.
///
/// Layout ranges:
/// - Compact:  < 600
/// - Medium:   600–839
/// - Expanded: 840–1199
/// - Large:    >= 1200
abstract final class CinearaBreakpoints {
  /// Minimum width for a medium layout.
  static const double medium = 600;

  /// Minimum width for an expanded layout.
  static const double expanded = 840;

  /// Minimum width for a large layout.
  static const double large = 1200;

  /// Returns the responsive window size for [width].
  static CinearaWindowSize fromWidth(double width) {
    if (width >= large) {
      return CinearaWindowSize.large;
    }

    if (width >= expanded) {
      return CinearaWindowSize.expanded;
    }

    if (width >= medium) {
      return CinearaWindowSize.medium;
    }

    return CinearaWindowSize.compact;
  }
}
