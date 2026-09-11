import 'package:flutter/material.dart';

// =============================================================================
// Public API
// =============================================================================

/// Presentation treatment used by [CinearaExternalRatingBadge].
///
/// External ratings are media metadata rather than personal Cineara state.
///
/// Use:
///
/// - [artwork] over posters and backdrops;
/// - [surface] on ordinary cards, sheets, and content surfaces;
/// - [inline] inside list/search metadata.
///
/// Personal ratings do not belong here. They are represented by
/// `CinearaStatusDock`.
enum CinearaExternalRatingBadgeVariant {
  /// Compact neutral pill intended for arbitrary media artwork.
  artwork,

  /// Theme-aware compact pill intended for ordinary application surfaces.
  surface,

  /// Lightweight metadata presentation with no surrounding pill.
  inline,
}

/// Physical size used by [CinearaExternalRatingBadge].
///
/// External ratings deliberately remain smaller and quieter than the viewing
/// status badge.
enum CinearaExternalRatingBadgeDensity {
  /// Intended for grid posters, rails, and other artwork-dense layouts.
  compact,

  /// Intended for larger cards and ordinary application surfaces.
  standard,
}

/// External/community/provider rating displayed by Cineara.
///
/// The design system deliberately knows nothing about individual providers such
/// as TMDB, IMDb, AniList, Rotten Tomatoes, or Metacritic.
///
/// Instead, the application supplies:
///
/// - an already-formatted [value];
/// - an optional [sourceLabel];
/// - a complete localized [semanticLabel].
///
/// The compact presentation intentionally contains no rating icon.
///
/// The numerical value itself is the complete visual signal:
///
/// ```text
/// ╭──────╮
/// │ 8.7  │
/// ╰──────╯
/// ```
///
/// This keeps poster artwork cleaner and distinguishes an external rating from
/// the icon-led lifecycle and personal-state systems.
///
/// The pill curvature follows the same geometric language as Cineara's
/// personal-rating presentation: the radius is always exactly half the badge
/// height.
///
/// Artwork/surface pills use explicit centered line-box typography:
///
/// - symmetric horizontal padding;
/// - [Alignment.center] at the pill level;
/// - centered text alignment;
/// - a forced 1.0-height strut;
/// - zero strut leading;
/// - even leading distribution.
///
/// This keeps the numerical line box geometrically centered in the capsule.
///
/// The visible glyph ink can still vary by font because font ascenders and
/// descenders are not necessarily optically symmetric. Cineara intentionally
/// does not apply a hard-coded vertical translation because that would be
/// font-, weight-, and accessibility-scale-specific.
///
/// List/search metadata:
///
/// ```dart
/// CinearaExternalRatingBadge(
///   value: '8.7',
///   sourceLabel: 'TMDB',
///   semanticLabel: 'TMDB rating 8.7 out of 10',
///   variant: CinearaExternalRatingBadgeVariant.inline,
/// )
/// ```
///
/// renders approximately:
///
/// ```text
/// 8.7 · TMDB
/// ```
///
/// ## Visual hierarchy
///
/// External ratings are intentionally quieter than:
///
/// - `CinearaStatusBadge`, which communicates viewing state;
/// - `CinearaStatusDock`, which communicates personal state.
///
/// Provider branding is therefore never introduced into the artwork pill.
/// [sourceLabel] is shown visually only in [inline] mode.
final class CinearaExternalRatingBadge extends StatelessWidget {
  const CinearaExternalRatingBadge({
    required this.value,
    required this.semanticLabel,
    super.key,
    this.sourceLabel,
    this.variant = CinearaExternalRatingBadgeVariant.artwork,
    this.density = CinearaExternalRatingBadgeDensity.compact,
    this.showTooltip = true,
  }) : assert(value != '', 'value must not be empty.'),
       assert(semanticLabel != '', 'semanticLabel must not be empty.');

  /// Already-formatted visible rating value.
  ///
  /// The component deliberately makes no assumptions about the rating scale.
  ///
  /// Examples:
  ///
  /// ```text
  /// 8.7
  /// 4.5
  /// 92%
  /// A
  /// ```
  final String value;

  /// Optional human-readable source name.
  ///
  /// Examples:
  ///
  /// ```text
  /// TMDB
  /// IMDb
  /// Metacritic
  /// ```
  ///
  /// This is shown visually only by
  /// [CinearaExternalRatingBadgeVariant.inline].
  ///
  /// Artwork and surface pills intentionally remain provider-neutral.
  final String? sourceLabel;

  /// Complete localized accessibility description.
  ///
  /// Examples:
  ///
  /// ```text
  /// External rating 8.7 out of 10
  /// TMDB rating 8.7 out of 10
  /// Rotten Tomatoes rating 92 percent
  /// ```
  final String semanticLabel;

  /// Visual treatment appropriate for the current layout.
  final CinearaExternalRatingBadgeVariant variant;

  /// Physical visual density.
  final CinearaExternalRatingBadgeDensity density;

  /// Whether [semanticLabel] should also be exposed as a tooltip.
  ///
  /// Accessibility semantics remain present even when this is false.
  final bool showTooltip;

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final String resolvedValue = value.trim();
    final String resolvedSemanticLabel = semanticLabel.trim();

    assert(resolvedValue.isNotEmpty, 'value must contain visible characters.');

    assert(
      resolvedSemanticLabel.isNotEmpty,
      'semanticLabel must contain visible characters.',
    );

    final bool highContrast = MediaQuery.highContrastOf(context);

    final _ExternalRatingMetrics metrics = _ExternalRatingMetrics.resolve(
      context: context,
      density: density,
    );

    final _ExternalRatingPalette palette = _ExternalRatingPalette.resolve(
      context: context,
      variant: variant,
      highContrast: highContrast,
    );

    final Widget visual = switch (variant) {
      CinearaExternalRatingBadgeVariant.artwork => _PillPresentation(
        value: resolvedValue,
        metrics: metrics,
        palette: palette,
        highContrast: highContrast,
        showShadow: true,
      ),

      CinearaExternalRatingBadgeVariant.surface => _PillPresentation(
        value: resolvedValue,
        metrics: metrics,
        palette: palette,
        highContrast: highContrast,
        showShadow: false,
      ),

      CinearaExternalRatingBadgeVariant.inline => _InlinePresentation(
        value: resolvedValue,
        sourceLabel: _resolvedSourceLabel,
        palette: palette,
      ),
    };

    final Widget semantic = Semantics(
      container: true,
      label: resolvedSemanticLabel,
      child: ExcludeSemantics(child: visual),
    );

    if (!showTooltip) {
      return semantic;
    }

    return Tooltip(
      message: resolvedSemanticLabel,
      excludeFromSemantics: true,
      child: semantic,
    );
  }

  String? get _resolvedSourceLabel {
    final String? source = sourceLabel?.trim();

    if (source == null || source.isEmpty) {
      return null;
    }

    return source;
  }
}

// =============================================================================
// Artwork / surface pill
// =============================================================================

/// Compact external-rating pill.
///
/// Unlike lifecycle status and personal-state nodes, this contains no icon.
///
/// Its identity comes purely from:
///
/// - compact numerical typography;
/// - tabular figures;
/// - neutral surface treatment;
/// - full capsule geometry.
///
/// Example:
///
/// ```text
/// ╭───────╮
/// │  8.7  │
/// ╰───────╯
/// ```
///
/// The [Text] line box is centered geometrically in the pill. The component
/// deliberately avoids a fixed baseline/translation correction because the
/// optical center of glyph ink varies between fonts and font weights.
final class _PillPresentation extends StatelessWidget {
  const _PillPresentation({
    required this.value,
    required this.metrics,
    required this.palette,
    required this.highContrast,
    required this.showShadow,
  });

  final String value;

  final _ExternalRatingMetrics metrics;
  final _ExternalRatingPalette palette;

  final bool highContrast;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return Container(
      height: metrics.badgeHeight,
      constraints: BoxConstraints(minWidth: metrics.minimumWidth),

      // Centers the text's layout box in the complete pill.
      alignment: Alignment.center,

      // Symmetric padding preserves horizontal centering regardless of the
      // rendered rating width.
      padding: EdgeInsets.symmetric(horizontal: metrics.horizontalPadding),

      decoration: BoxDecoration(
        color: palette.surface,

        // Full pill/capsule curvature.
        //
        // Deriving this directly from the current physical height guarantees
        // that compact, standard, and accessibility-scaled variants retain
        // exactly the same geometric language.
        borderRadius: BorderRadius.circular(metrics.badgeHeight / 2),

        border: Border.all(
          color: palette.border,
          width: highContrast
              ? metrics.highContrastBorderWidth
              : metrics.borderWidth,
        ),

        boxShadow: highContrast || !showShadow
            ? const <BoxShadow>[]
            : <BoxShadow>[
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.14),
                  blurRadius: metrics.shadowBlur,
                  offset: Offset(0, metrics.shadowOffset),
                ),
              ],
      ),

      child: Text(
        value,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,

        // Explicitly communicate the intended horizontal alignment even though
        // the surrounding Container already centers the Text widget itself.
        textAlign: TextAlign.center,

        textScaler: TextScaler.linear(metrics.microTextScale),

        // Force a predictable one-line box without extra font leading.
        strutStyle: StrutStyle(
          fontSize: metrics.fontSize,
          height: 1,
          leading: 0,
          forceStrutHeight: true,
        ),

        // Keep line-height distribution symmetric instead of allowing the
        // configured line height to bias the first ascent or final descent.
        textHeightBehavior: const TextHeightBehavior(
          applyHeightToFirstAscent: false,
          applyHeightToLastDescent: false,
          leadingDistribution: TextLeadingDistribution.even,
        ),

        style: TextStyle(
          color: palette.foreground,
          fontSize: metrics.fontSize,
          fontWeight: mediaQuery.boldText ? FontWeight.w900 : FontWeight.w800,
          height: 1,
          leadingDistribution: TextLeadingDistribution.even,
          letterSpacing: 0,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// =============================================================================
// Inline presentation
// =============================================================================

/// Lightweight external-rating metadata intended primarily for list/search
/// layouts.
///
/// This intentionally has:
///
/// - no star;
/// - no surrounding pill;
/// - no provider icon.
///
/// Examples:
///
/// ```text
/// 8.7
/// ```
///
/// or:
///
/// ```text
/// 8.7 · TMDB
/// ```
final class _InlinePresentation extends StatelessWidget {
  const _InlinePresentation({
    required this.value,
    required this.sourceLabel,
    required this.palette,
  });

  final String value;
  final String? sourceLabel;

  final _ExternalRatingPalette palette;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final TextStyle valueStyle =
        theme.textTheme.labelMedium?.copyWith(
          color: palette.foreground,
          fontWeight: mediaQuery.boldText ? FontWeight.w800 : FontWeight.w700,
          height: 1.1,
          letterSpacing: 0,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ) ??
        TextStyle(
          color: palette.foreground,
          fontSize: 12,
          fontWeight: mediaQuery.boldText ? FontWeight.w800 : FontWeight.w700,
          height: 1.1,
          letterSpacing: 0,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        );

    final TextStyle metadataStyle =
        theme.textTheme.labelMedium?.copyWith(
          color: palette.secondaryForeground,
          fontWeight: FontWeight.w500,
          height: 1.1,
        ) ??
        TextStyle(
          color: palette.secondaryForeground,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.1,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          value,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
          style: valueStyle,
        ),

        if (sourceLabel != null) ...<Widget>[
          const SizedBox(width: 5),

          Text('·', maxLines: 1, softWrap: false, style: metadataStyle),

          const SizedBox(width: 5),

          Flexible(
            child: Text(
              sourceLabel!,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: metadataStyle,
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// Metrics
// =============================================================================

@immutable
final class _ExternalRatingMetrics {
  const _ExternalRatingMetrics({
    required this.badgeHeight,
    required this.minimumWidth,
    required this.fontSize,
    required this.horizontalPadding,
    required this.borderWidth,
    required this.highContrastBorderWidth,
    required this.shadowBlur,
    required this.shadowOffset,
    required this.microTextScale,
  });

  /// Exact physical height of the artwork/surface pill.
  final double badgeHeight;

  /// Minimum pill width.
  ///
  /// The width remains free to grow for values such as `92%`.
  final double minimumWidth;

  /// Numerical text size.
  final double fontSize;

  /// Horizontal clearance around the numerical value.
  final double horizontalPadding;

  final double borderWidth;
  final double highContrastBorderWidth;

  final double shadowBlur;
  final double shadowOffset;

  /// Restrained accessibility scaling used by fixed artwork/surface
  /// presentation.
  ///
  /// Inline text follows normal application typography instead.
  final double microTextScale;

  factory _ExternalRatingMetrics.resolve({
    required BuildContext context,
    required CinearaExternalRatingBadgeDensity density,
  }) {
    final TextScaler scaler = MediaQuery.textScalerOf(context);

    final double rawControlScale = scaler.scale(16) / 16;

    final double controlScale = (1 + ((rawControlScale - 1) * 0.24))
        .clamp(1.0, 1.12)
        .toDouble();

    final double rawMicroTextScale = scaler.scale(12) / 12;

    final double microTextScale = (1 + ((rawMicroTextScale - 1) * 0.30))
        .clamp(1.0, 1.16)
        .toDouble();

    final _ExternalRatingMetrics base = switch (density) {
      // ---------------------------------------------------------------------
      // Compact
      // ---------------------------------------------------------------------
      CinearaExternalRatingBadgeDensity.compact => const _ExternalRatingMetrics(
        // Small enough to remain secondary on poster artwork while
        // preserving the same capsule language as the personal rating.
        badgeHeight: 22,

        // Slightly wider than the height so a normal x.x score reads as a
        // deliberate pill instead of a cramped circle.
        minimumWidth: 31,

        fontSize: 9.5,

        horizontalPadding: 7,

        borderWidth: 0.8,

        highContrastBorderWidth: 1.4,

        shadowBlur: 4,

        shadowOffset: 1,

        microTextScale: 1,
      ),

      // ---------------------------------------------------------------------
      // Standard
      // ---------------------------------------------------------------------
      CinearaExternalRatingBadgeDensity.standard =>
        const _ExternalRatingMetrics(
          badgeHeight: 26,

          minimumWidth: 36,

          fontSize: 10.5,

          horizontalPadding: 8,

          borderWidth: 0.85,

          highContrastBorderWidth: 1.5,

          shadowBlur: 4,

          shadowOffset: 1,

          microTextScale: 1,
        ),
    };

    return _ExternalRatingMetrics(
      badgeHeight: base.badgeHeight * controlScale,

      minimumWidth: base.minimumWidth * controlScale,

      fontSize: base.fontSize,

      horizontalPadding: base.horizontalPadding * controlScale,

      borderWidth: base.borderWidth,

      highContrastBorderWidth: base.highContrastBorderWidth,

      shadowBlur: base.shadowBlur * controlScale,

      shadowOffset: base.shadowOffset * controlScale,

      microTextScale: microTextScale,
    );
  }
}

// =============================================================================
// Palette
// =============================================================================

@immutable
final class _ExternalRatingPalette {
  const _ExternalRatingPalette({
    required this.surface,
    required this.border,
    required this.foreground,
    required this.secondaryForeground,
  });

  /// Pill background.
  final Color surface;

  /// Pill outline.
  final Color border;

  /// Numerical rating colour.
  final Color foreground;

  /// Secondary inline metadata colour.
  final Color secondaryForeground;

  factory _ExternalRatingPalette.resolve({
    required BuildContext context,
    required CinearaExternalRatingBadgeVariant variant,
    required bool highContrast,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return switch (variant) {
      // ---------------------------------------------------------------------
      // Artwork
      // ---------------------------------------------------------------------
      CinearaExternalRatingBadgeVariant.artwork => _ExternalRatingPalette(
        surface: Colors.black.withValues(alpha: highContrast ? 0.95 : 0.82),

        border: Colors.white.withValues(alpha: highContrast ? 0.72 : 0.22),

        foreground: Colors.white.withValues(alpha: highContrast ? 1 : 0.96),

        secondaryForeground: Colors.white.withValues(
          alpha: highContrast ? 0.90 : 0.72,
        ),
      ),

      // ---------------------------------------------------------------------
      // Ordinary surface
      // ---------------------------------------------------------------------
      CinearaExternalRatingBadgeVariant.surface => _ExternalRatingPalette(
        surface: colors.surfaceContainerHigh,

        border: colors.outlineVariant.withValues(
          alpha: highContrast ? 1 : 0.55,
        ),

        foreground: colors.onSurface,

        secondaryForeground: colors.onSurfaceVariant,
      ),

      // ---------------------------------------------------------------------
      // Inline metadata
      // ---------------------------------------------------------------------
      CinearaExternalRatingBadgeVariant.inline => _ExternalRatingPalette(
        surface: Colors.transparent,

        border: Colors.transparent,

        foreground: colors.onSurface,

        secondaryForeground: colors.onSurfaceVariant,
      ),
    };
  }
}
