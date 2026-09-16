import 'package:flutter/material.dart';

/// Visual form rendered by [CinearaBrandMark].
enum CinearaBrandMarkVariant {
  /// Full horizontal Cineara wordmark.
  ///
  /// The current typographic implementation renders:
  ///
  /// ```text
  /// CINEΛRΛ
  /// ```
  wordmark,

  /// Compact Cineara symbol.
  ///
  /// Used only where the full wordmark does not fit.
  symbol,
}

/// Preset visual sizes for [CinearaBrandMark].
///
/// The appropriate size is selected by the surface displaying the brand.
/// For example, the top app bar may use [compact] on compact layouts and
/// [standard] on wider layouts.
enum CinearaBrandMarkSize { compact, standard, large }

/// Reusable Cineara brand mark.
///
/// The current wordmark is rendered typographically as:
///
/// ```text
/// CINEΛRΛ
/// ```
///
/// The first barless `A` uses the active theme's primary colour, while the
/// final barless `A` uses the normal foreground colour.
///
/// The component is theme-aware rather than owning separate hard-coded
/// light and dark assets:
///
/// - foreground derives from [ColorScheme.onSurface];
/// - accent derives from [ColorScheme.primary];
/// - bold-text accessibility is respected;
/// - predefined size variants provide deterministic geometry;
/// - the mark scales down when horizontal space is constrained.
///
/// The internal typographic implementation can later be replaced by Cineara's
/// final vector artwork without changing call sites.
///
/// Example:
///
/// ```dart
/// const CinearaBrandMark(
///   size: CinearaBrandMarkSize.compact,
/// )
/// ```
///
/// The semantic label exposes the normal brand name (`Cineara`) rather than
/// allowing accessibility services to interpret the visual `Λ` glyphs as
/// Greek characters.
final class CinearaBrandMark extends StatelessWidget {
  const CinearaBrandMark({
    super.key,
    this.variant = CinearaBrandMarkVariant.wordmark,
    this.size = CinearaBrandMarkSize.compact,
    this.semanticLabel = 'Cineara',
  });

  /// Visual form of the brand.
  final CinearaBrandMarkVariant variant;

  /// Preset visual size.
  final CinearaBrandMarkSize size;

  /// Accessibility label for the brand.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      CinearaBrandMarkVariant.wordmark => _CinearaWordmark(
        size: size,
        semanticLabel: semanticLabel,
      ),
      CinearaBrandMarkVariant.symbol => _CinearaSymbol(
        size: size,
        semanticLabel: semanticLabel,
      ),
    };
  }
}

/// Horizontal Cineara wordmark.
final class _CinearaWordmark extends StatelessWidget {
  const _CinearaWordmark({required this.size, required this.semanticLabel});

  final CinearaBrandMarkSize size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final boldText = MediaQuery.boldTextOf(context);
    final geometry = _BrandMarkGeometry.forSize(size);

    final baseStyle =
        theme.textTheme.titleMedium?.copyWith(
          color: colors.onSurface,
          fontSize: geometry.fontSize,
          fontWeight: boldText ? FontWeight.w800 : FontWeight.w700,
          letterSpacing: geometry.letterSpacing,
          height: 1,
        ) ??
        TextStyle(
          color: colors.onSurface,
          fontSize: geometry.fontSize,
          fontWeight: boldText ? FontWeight.w800 : FontWeight.w700,
          letterSpacing: geometry.letterSpacing,
          height: 1,
        );

    final accentedAStyle = baseStyle.copyWith(
      color: colors.primary,
      fontWeight: FontWeight.w800,
      letterSpacing: geometry.barlessALetterSpacing,
    );

    final finalAStyle = baseStyle.copyWith(
      color: colors.onSurface,
      fontWeight: boldText ? FontWeight.w800 : FontWeight.w700,
      letterSpacing: geometry.barlessALetterSpacing,
    );

    return Semantics(
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text.rich(
            TextSpan(
              style: baseStyle,
              children: <InlineSpan>[
                const TextSpan(text: 'CINE'),
                TextSpan(text: 'Λ', style: accentedAStyle),
                const TextSpan(text: 'R'),
                TextSpan(text: 'Λ', style: finalAStyle),
              ],
            ),
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}

/// Compact Cineara identity symbol for surfaces that cannot accommodate the
/// full wordmark.
///
/// This remains typographic until Cineara's final vector symbol is available.
/// The full wordmark should remain preferred whenever sufficient horizontal
/// space is available.
final class _CinearaSymbol extends StatelessWidget {
  const _CinearaSymbol({required this.size, required this.semanticLabel});

  final CinearaBrandMarkSize size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final boldText = MediaQuery.boldTextOf(context);
    final geometry = _BrandMarkGeometry.forSize(size);

    final style =
        theme.textTheme.titleMedium?.copyWith(
          color: colors.primary,
          fontSize: geometry.symbolFontSize,
          fontWeight: boldText ? FontWeight.w900 : FontWeight.w800,
          height: 1,
        ) ??
        TextStyle(
          color: colors.primary,
          fontSize: geometry.symbolFontSize,
          fontWeight: boldText ? FontWeight.w900 : FontWeight.w800,
          height: 1,
        );

    return Semantics(
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            'C',
            maxLines: 1,
            softWrap: false,
            textScaler: TextScaler.noScaling,
            style: style,
          ),
        ),
      ),
    );
  }
}

/// Internal geometry for each [CinearaBrandMarkSize].
///
/// Sizes are explicit rather than inherited from the active typography theme
/// so the brand maintains predictable geometry across themes.
///
/// Wordmark sizes:
///
/// - compact: 18 dp;
/// - standard: 22 dp;
/// - large: 28 dp.
@immutable
final class _BrandMarkGeometry {
  const _BrandMarkGeometry({
    required this.fontSize,
    required this.symbolFontSize,
    required this.letterSpacing,
    required this.barlessALetterSpacing,
  });

  /// Wordmark font size.
  final double fontSize;

  /// Compact-symbol font size.
  final double symbolFontSize;

  /// Letter spacing applied to the standard wordmark characters.
  final double letterSpacing;

  /// Letter spacing applied to the barless `A` glyphs.
  final double barlessALetterSpacing;

  factory _BrandMarkGeometry.forSize(CinearaBrandMarkSize size) {
    return switch (size) {
      CinearaBrandMarkSize.compact => const _BrandMarkGeometry(
        fontSize: 18,
        symbolFontSize: 22,
        letterSpacing: 3.2,
        barlessALetterSpacing: 2.6,
      ),
      CinearaBrandMarkSize.standard => const _BrandMarkGeometry(
        fontSize: 22,
        symbolFontSize: 28,
        letterSpacing: 3.6,
        barlessALetterSpacing: 3.0,
      ),
      CinearaBrandMarkSize.large => const _BrandMarkGeometry(
        fontSize: 28,
        symbolFontSize: 36,
        letterSpacing: 4.0,
        barlessALetterSpacing: 3.4,
      ),
    };
  }
}
