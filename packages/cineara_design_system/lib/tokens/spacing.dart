/// Spacing sizes used throughout the Cineara design system.
enum CinearaSpacingSize { xxs, xs, sm, md, lg, xl, xxl, xxxl }

/// Centralised spacing values used by the Cineara design system.
///
/// Spacing values:
/// - XXS:  4
/// - XS:   8
/// - SM:   12
/// - MD:   16
/// - LG:   24
/// - XL:   32
/// - XXL:  40
/// - XXXL: 64
abstract final class CinearaSpacing {
  /// Extra-extra-small spacing for very tight gaps.
  static const double xxs = 4;

  /// Extra-small spacing for compact gaps.
  static const double xs = 8;

  /// Small spacing between closely related elements.
  static const double sm = 12;

  /// Default spacing for common layout gaps and padding.
  static const double md = 16;

  /// Large spacing between sections or prominent elements.
  static const double lg = 24;

  /// Extra-large spacing for larger layout separation.
  static const double xl = 32;

  /// Extra-extra-large spacing for major layout separation.
  static const double xxl = 40;

  /// Maximum standard spacing for large structural gaps.
  static const double xxxl = 64;

  /// Returns the spacing associated with [size].
  static double value(CinearaSpacingSize size) {
    return switch (size) {
      CinearaSpacingSize.xxs => xxs,
      CinearaSpacingSize.xs => xs,
      CinearaSpacingSize.sm => sm,
      CinearaSpacingSize.md => md,
      CinearaSpacingSize.lg => lg,
      CinearaSpacingSize.xl => xl,
      CinearaSpacingSize.xxl => xxl,
      CinearaSpacingSize.xxxl => xxxl,
    };
  }
}
