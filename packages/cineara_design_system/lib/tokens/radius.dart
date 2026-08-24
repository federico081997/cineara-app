/// Corner radius sizes used throughout the Cineara design system.
enum CinearaRadiusSize { xs, sm, md, lg, xl, pill }

/// Centralised corner radii used by the Cineara design system.
///
/// Radius values:
/// - XS:   4
/// - SM:   8
/// - MD:   12
/// - LG:   16
/// - XL:   24
/// - Pill: 999
abstract final class CinearaRadii {
  /// Extra-small radius for subtle rounding.
  static const double xs = 4;

  /// Small radius for compact controls and elements.
  static const double sm = 8;

  /// Medium radius for common UI components.
  static const double md = 12;

  /// Large radius for cards and prominent surfaces.
  static const double lg = 16;

  /// Extra-large radius for large surfaces and containers.
  static const double xl = 24;

  /// Fully rounded radius for pills and capsule-shaped controls.
  static const double pill = 999;

  /// Returns the radius associated with [size].
  static double radius(CinearaRadiusSize size) {
    return switch (size) {
      CinearaRadiusSize.xs => xs,
      CinearaRadiusSize.sm => sm,
      CinearaRadiusSize.md => md,
      CinearaRadiusSize.lg => lg,
      CinearaRadiusSize.xl => xl,
      CinearaRadiusSize.pill => pill,
    };
  }
}
