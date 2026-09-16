import 'package:flutter/material.dart';

import '../../foundations/shapes/cineara_shapes.dart';
import '../../foundations/tokens/elevation.dart';

/// Semantic visual treatments supported by [CinearaSurface].
///
/// Variants describe the role and visual emphasis of a surface rather than
/// exposing implementation details such as colours, borders, and elevation to
/// feature code.
///
/// Most Cineara surfaces are intentionally quiet. Stronger treatments should be
/// reserved for content that genuinely requires additional visual hierarchy.
enum CinearaSurfaceVariant {
  /// Low-emphasis surface used for secondary grouping.
  ///
  /// Suitable for:
  ///
  /// - secondary information regions;
  /// - passive grouped content;
  /// - quiet supporting sections.
  subtle,

  /// Default Cineara surface.
  ///
  /// Suitable for:
  ///
  /// - ordinary cards;
  /// - settings groups;
  /// - summaries;
  /// - reusable content regions.
  standard,

  /// Surface with additional separation from surrounding content.
  ///
  /// Suitable for:
  ///
  /// - floating information;
  /// - interactive card families;
  /// - controls or panels that need modest depth.
  elevated,

  /// Higher-emphasis surface for important content.
  ///
  /// Suitable for:
  ///
  /// - featured recommendations;
  /// - key statistics;
  /// - milestones;
  /// - important summaries.
  prominent,

  /// Translucent surface intended to sit over artwork.
  ///
  /// Suitable for:
  ///
  /// - metadata overlays;
  /// - poster and backdrop controls;
  /// - artwork labels;
  /// - compact information panels layered over imagery.
  artworkOverlay,
}

/// Reusable semantic surface used throughout the Cineara design system.
///
/// [CinearaSurface] centralises the visual treatment of card-like regions,
/// including:
///
/// - background colour;
/// - border treatment;
/// - shape;
/// - elevation;
/// - shadow;
/// - clipping;
/// - high-contrast behaviour.
///
/// Feature code should describe the semantic role of a surface:
///
/// ```dart
/// CinearaSurface(
///   variant: CinearaSurfaceVariant.standard,
///   padding: const EdgeInsets.all(16),
///   child: ...,
/// )
/// ```
///
/// rather than manually constructing equivalent styling:
///
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     color: ...,
///     border: ...,
///     borderRadius: ...,
///   ),
///   child: ...,
/// )
/// ```
///
/// Internal spacing remains the responsibility of the caller because different
/// surface families require different layouts. Feature code should still use
/// Cineara spacing tokens rather than arbitrary values.
///
/// This primitive is deliberately non-interactive. Components that require tap,
/// hover, focus, or selection behaviour should compose those behaviours around
/// [CinearaSurface] rather than turning every surface into an implicit control.
final class CinearaSurface extends StatelessWidget {
  const CinearaSurface({
    required this.child,
    this.variant = CinearaSurfaceVariant.standard,
    this.padding,
    this.clipBehavior = Clip.antiAlias,
    super.key,
  });

  /// Content rendered inside the surface.
  final Widget child;

  /// Semantic visual treatment applied to the surface.
  final CinearaSurfaceVariant variant;

  /// Optional internal padding.
  ///
  /// No default padding is imposed because the appropriate spacing depends on
  /// the component using the surface.
  final EdgeInsetsGeometry? padding;

  /// How descendants are clipped to the surface shape.
  ///
  /// [Clip.antiAlias] is appropriate for Cineara surfaces because they commonly
  /// contain coloured regions or artwork that should follow the outer shape.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final style = _CinearaSurfaceStyle.resolve(context, variant);

    final content = switch (padding) {
      final EdgeInsetsGeometry resolvedPadding => Padding(
        padding: resolvedPadding,
        child: child,
      ),
      null => child,
    };

    return Material(
      color: style.backgroundColor,
      elevation: style.elevation,
      shadowColor: style.shadowColor,

      // Cineara resolves surface colours explicitly. Disabling Material's
      // automatic elevation tint keeps those colours stable and predictable.
      surfaceTintColor: Colors.transparent,

      shape: style.shape,
      clipBehavior: clipBehavior,
      child: content,
    );
  }
}

/// Fully resolved visual style for a [CinearaSurface].
///
/// Resolution remains private so feature code depends only on semantic surface
/// variants rather than low-level visual values.
final class _CinearaSurfaceStyle {
  const _CinearaSurfaceStyle({
    required this.backgroundColor,
    required this.shape,
    required this.elevation,
    required this.shadowColor,
  });

  final Color backgroundColor;
  final ShapeBorder shape;
  final double elevation;
  final Color shadowColor;

  // ---------------------------------------------------------------------------
  // Border
  // ---------------------------------------------------------------------------

  static const double _borderWidth = 1;
  static const double _highContrastBorderWidth = 1.5;

  static const double _subtleBorderOpacity = .20;
  static const double _standardBorderOpacity = .28;
  static const double _elevatedBorderOpacity = .22;
  static const double _prominentBorderOpacity = .26;
  static const double _artworkOverlayBorderOpacity = .16;

  // ---------------------------------------------------------------------------
  // Surface treatment
  // ---------------------------------------------------------------------------

  /// Small accent tint used by prominent surfaces.
  ///
  /// This remains deliberately restrained so prominent content does not turn
  /// into a large block of brand colour.
  static const double _prominentTintOpacity = .05;

  /// Artwork overlays remain more opaque in light themes to preserve text
  /// contrast over bright imagery.
  static const double _artworkOverlayLightOpacity = .92;

  /// Dark themes can retain slightly more of the underlying artwork.
  static const double _artworkOverlayDarkOpacity = .84;

  // ---------------------------------------------------------------------------
  // Shadows
  // ---------------------------------------------------------------------------

  static const double _shadowLightOpacity = .10;
  static const double _shadowDarkOpacity = .24;

  // ---------------------------------------------------------------------------
  // Resolution
  // ---------------------------------------------------------------------------

  static _CinearaSurfaceStyle resolve(
    BuildContext context,
    CinearaSurfaceVariant variant,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final highContrast = MediaQuery.highContrastOf(context);
    final isDark = theme.brightness == Brightness.dark;

    final elevation = _elevationFor(variant);

    return _CinearaSurfaceStyle(
      backgroundColor: _backgroundFor(
        colors,
        variant,
        highContrast: highContrast,
        isDark: isDark,
      ),
      shape: _shapeFor(
        variant,
        side: _borderFor(colors, variant, highContrast: highContrast),
      ),
      elevation: elevation,
      shadowColor: _shadowFor(
        theme,
        elevation: elevation,
        highContrast: highContrast,
        isDark: isDark,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Background
  // ---------------------------------------------------------------------------

  static Color _backgroundFor(
    ColorScheme colors,
    CinearaSurfaceVariant variant, {
    required bool highContrast,
    required bool isDark,
  }) {
    if (highContrast) {
      return switch (variant) {
        CinearaSurfaceVariant.subtle => colors.surface,
        CinearaSurfaceVariant.standard => colors.surface,
        CinearaSurfaceVariant.elevated => colors.surfaceContainer,
        CinearaSurfaceVariant.prominent => colors.surfaceContainerHigh,
        CinearaSurfaceVariant.artworkOverlay => colors.surface,
      };
    }

    return switch (variant) {
      CinearaSurfaceVariant.subtle => colors.surfaceContainerLow,

      CinearaSurfaceVariant.standard => colors.surfaceContainer,

      CinearaSurfaceVariant.elevated => colors.surfaceContainerHigh,

      CinearaSurfaceVariant.prominent => Color.alphaBlend(
        colors.primary.withValues(alpha: _prominentTintOpacity),
        colors.surfaceContainerHigh,
      ),

      CinearaSurfaceVariant.artworkOverlay => colors.surface.withValues(
        alpha: isDark
            ? _artworkOverlayDarkOpacity
            : _artworkOverlayLightOpacity,
      ),
    };
  }

  // ---------------------------------------------------------------------------
  // Border
  // ---------------------------------------------------------------------------

  static BorderSide _borderFor(
    ColorScheme colors,
    CinearaSurfaceVariant variant, {
    required bool highContrast,
  }) {
    if (highContrast) {
      return BorderSide(color: colors.outline, width: _highContrastBorderWidth);
    }

    final color = switch (variant) {
      CinearaSurfaceVariant.subtle => colors.outlineVariant.withValues(
        alpha: _subtleBorderOpacity,
      ),

      CinearaSurfaceVariant.standard => colors.outlineVariant.withValues(
        alpha: _standardBorderOpacity,
      ),

      CinearaSurfaceVariant.elevated => colors.outlineVariant.withValues(
        alpha: _elevatedBorderOpacity,
      ),

      CinearaSurfaceVariant.prominent => colors.primary.withValues(
        alpha: _prominentBorderOpacity,
      ),

      CinearaSurfaceVariant.artworkOverlay => colors.onSurface.withValues(
        alpha: _artworkOverlayBorderOpacity,
      ),
    };

    return BorderSide(color: color, width: _borderWidth);
  }

  // ---------------------------------------------------------------------------
  // Shape
  // ---------------------------------------------------------------------------

  static ShapeBorder _shapeFor(
    CinearaSurfaceVariant variant, {
    required BorderSide side,
  }) {
    return switch (variant) {
      CinearaSurfaceVariant.subtle => CinearaShapes.surface(side: side),

      CinearaSurfaceVariant.standard => CinearaShapes.card(side: side),

      CinearaSurfaceVariant.elevated => CinearaShapes.card(side: side),

      CinearaSurfaceVariant.prominent => CinearaShapes.prominentSurface(
        side: side,
      ),

      CinearaSurfaceVariant.artworkOverlay => CinearaShapes.surface(side: side),
    };
  }

  // ---------------------------------------------------------------------------
  // Elevation
  // ---------------------------------------------------------------------------

  static double _elevationFor(CinearaSurfaceVariant variant) {
    return switch (variant) {
      // Ordinary surfaces remain flat. Their structure comes from colour,
      // spacing, and borders rather than persistent shadows.
      CinearaSurfaceVariant.subtle => CinearaElevation.none,
      CinearaSurfaceVariant.standard => CinearaElevation.card,

      // Only surfaces that genuinely need depth receive elevation.
      CinearaSurfaceVariant.elevated => CinearaElevation.raisedSurface,

      // Prominent surfaces rely primarily on their accent treatment rather than
      // a strong shadow.
      CinearaSurfaceVariant.prominent => CinearaElevation.low,

      // Artwork overlays already gain separation through translucency.
      CinearaSurfaceVariant.artworkOverlay => CinearaElevation.none,
    };
  }

  // ---------------------------------------------------------------------------
  // Shadow
  // ---------------------------------------------------------------------------

  static Color _shadowFor(
    ThemeData theme, {
    required double elevation,
    required bool highContrast,
    required bool isDark,
  }) {
    // High-contrast mode uses explicit boundaries instead of decorative
    // shadows. Flat surfaces likewise require no shadow.
    if (highContrast || elevation <= CinearaElevation.none) {
      return Colors.transparent;
    }

    return theme.shadowColor.withValues(
      alpha: isDark ? _shadowDarkOpacity : _shadowLightOpacity,
    );
  }
}
