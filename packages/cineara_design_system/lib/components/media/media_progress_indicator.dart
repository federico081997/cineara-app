import 'package:flutter/material.dart';

import '../../themes/theme_extensions.dart';
import '../../tokens/motion.dart';

/// Visual treatment used by [CinearaMediaProgressIndicator].
///
/// The same progress primitive can therefore be used:
///
/// - flush with the bottom edge of poster artwork;
/// - as a compact indicator inside a media list row;
/// - as a more prominent standalone progress indicator in cards and pages.
///
/// These variants only control presentation. They do not encode feature or
/// domain behaviour.
enum CinearaMediaProgressVariant {
  /// Very thin progress edge intended to sit flush against artwork.
  ///
  /// The containing poster should own its outer clipping. The indicator itself
  /// deliberately has square geometry so it visually becomes part of the
  /// artwork edge rather than appearing as a floating pill.
  posterEdge,

  /// Compact standalone progress bar for dense layouts such as media list rows.
  compact,

  /// Standard standalone progress bar for larger cards and detail surfaces.
  standard,
}

/// Shared Cineara viewing-progress indicator.
///
/// The component deliberately knows nothing about Search, Library, Home,
/// Continue Watching, movies, series, seasons, or episodes. It only represents
/// a progress value.
///
/// Progress can be supplied either directly:
///
/// ```dart
/// CinearaMediaProgressIndicator(
///   value: 0.65,
///   semanticLabel: 'Viewing progress',
/// )
/// ```
///
/// or as watched/total counts:
///
/// ```dart
/// CinearaMediaProgressIndicator(
///   watched: 18,
///   total: 24,
///   semanticLabel: 'Episode progress',
/// )
/// ```
///
/// Supplying neither [value] nor watched/total counts represents an unknown
/// progress value. Unknown progress is intentionally different from `0%`:
///
/// - `0%` renders an ordinary empty track;
/// - unknown progress renders a restrained static stripe treatment.
///
/// This distinction prevents "we do not know the progress" from being visually
/// interpreted as "the user has watched nothing".
///
/// Progress changes animate smoothly by default. Animation is automatically
/// disabled when the operating system requests reduced motion.
///
/// Accessibility copy remains application-owned. This design-system component
/// accepts semantic labels rather than embedding English strings that would
/// bypass Cineara localisation.
final class CinearaMediaProgressIndicator extends StatelessWidget {
  const CinearaMediaProgressIndicator({
    super.key,
    this.value,
    this.watched,
    this.total,
    this.variant = CinearaMediaProgressVariant.standard,
    this.enabled = true,
    this.animate = true,
    this.height,
    this.semanticLabel,
    this.semanticValue,
    this.unknownSemanticValue,
    this.excludeFromSemantics = false,
    this.progressColor,
    this.trackColor,
  }) : assert(
         value == null || (watched == null && total == null),
         'Provide either value or watched/total counts, not both.',
       ),
       assert(
         (watched == null) == (total == null),
         'watched and total must either both be supplied or both be null.',
       ),
       assert(
         value == null || (value >= 0 && value <= 1),
         'value must be between 0 and 1.',
       ),
       assert(watched == null || watched >= 0, 'watched must not be negative.'),
       assert(total == null || total >= 0, 'total must not be negative.'),
       assert(
         watched == null || total == null || watched <= total,
         'watched must not exceed total.',
       ),
       assert(
         height == null || height > 0,
         'height must be greater than zero.',
       );

  /// Normalized progress between `0` and `1`.
  ///
  /// Use either [value] or [watched]/[total].
  ///
  /// A null value with no valid count pair represents unknown progress.
  final double? value;

  /// Number of completed/watched units.
  ///
  /// This may represent episodes, chapters, parts, or another progress unit.
  /// The indicator intentionally does not attach media-specific meaning to it.
  final int? watched;

  /// Total number of eligible units.
  ///
  /// When this is zero, progress is considered unknown because there is no
  /// meaningful denominator.
  final int? total;

  /// Visual density and placement treatment.
  final CinearaMediaProgressVariant variant;

  /// Whether the progress is currently available/enabled.
  ///
  /// Disabled progress remains visible but uses a quieter neutral treatment.
  /// This is useful when a card remains visible while progress interaction or
  /// data is temporarily unavailable.
  final bool enabled;

  /// Whether changes to known progress should animate.
  ///
  /// Reduced-motion accessibility settings always take precedence.
  final bool animate;

  /// Optional explicit indicator height.
  ///
  /// Normally the semantic [variant] should determine height.
  final double? height;

  /// Localized semantic description, for example:
  ///
  /// `Viewing progress`
  ///
  /// or:
  ///
  /// `Season progress`
  ///
  /// No English label is generated internally because this component belongs
  /// to the shared design-system layer.
  final String? semanticLabel;

  /// Optional fully localized semantic value.
  ///
  /// For example:
  ///
  /// `18 of 24 episodes, 75 percent`
  ///
  /// When omitted, the component generates a language-independent compact
  /// numeric representation such as `18 / 24 · 75%`.
  final String? semanticValue;

  /// Localized semantic value used when progress is unknown.
  ///
  /// For example:
  ///
  /// `Progress unavailable`
  ///
  /// When omitted, no semantic value is announced for unknown progress.
  final String? unknownSemanticValue;

  /// Removes this indicator from the semantics tree.
  ///
  /// This is useful when a parent media card already exposes the same progress
  /// information through one consolidated semantic description.
  final bool excludeFromSemantics;

  /// Optional explicit progress colour.
  ///
  /// When omitted, Cineara's primary/secondary/tertiary colour roles form the
  /// normal branded gradient.
  ///
  /// An explicit colour creates a solid fill rather than a gradient.
  final Color? progressColor;

  /// Optional explicit empty-track colour.
  ///
  /// Normally the Cineara theme extension's semantic progress-track colour is
  /// used.
  final Color? trackColor;

  // ---------------------------------------------------------------------------
  // Resolved progress
  // ---------------------------------------------------------------------------

  double? get _resolvedProgress {
    final double? directValue = value;

    if (directValue != null) {
      if (!directValue.isFinite) {
        return null;
      }

      return directValue.clamp(0.0, 1.0).toDouble();
    }

    final int? watchedCount = watched;
    final int? totalCount = total;

    if (watchedCount == null || totalCount == null || totalCount <= 0) {
      return null;
    }

    return (watchedCount / totalCount).clamp(0.0, 1.0).toDouble();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final bool highContrast = mediaQuery.highContrast;

    final bool reduceMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;

    final double? progress = _resolvedProgress;

    final double resolvedHeight =
        height ??
        switch (variant) {
          CinearaMediaProgressVariant.posterEdge => 3.5,
          CinearaMediaProgressVariant.compact => 5,
          CinearaMediaProgressVariant.standard => 7,
        };

    final Duration animationDuration = !animate || reduceMotion
        ? Duration.zero
        : CinearaMotion.verySlow;

    final CinearaThemeExtension? cinearaTheme = theme
        .extension<CinearaThemeExtension>();

    final Color baseTrack =
        cinearaTheme?.progressTrack ??
        theme.progressIndicatorTheme.linearTrackColor ??
        colors.surfaceContainerHigh;

    final Color resolvedTrackColor = _resolveTrackColor(
      colors: colors,
      baseTrack: baseTrack,
      highContrast: highContrast,
    );

    final List<Color> progressColors = _resolveProgressColors(
      colors: colors,
      track: resolvedTrackColor,
      highContrast: highContrast,
    );

    final Color outlineColor = highContrast
        ? colors.outline
        : colors.outlineVariant.withValues(alpha: 0.62);

    final Color unknownPatternColor = enabled
        ? colors.onSurfaceVariant.withValues(alpha: highContrast ? 0.72 : 0.30)
        : colors.onSurface.withValues(alpha: highContrast ? 0.42 : 0.20);

    final Widget indicator = _CinearaProgressVisual(
      progress: progress,
      variant: variant,
      height: resolvedHeight,
      trackColor: resolvedTrackColor,
      progressColors: progressColors,
      outlineColor: outlineColor,
      unknownPatternColor: unknownPatternColor,
      animationDuration: animationDuration,
      highContrast: highContrast,
      enabled: enabled,
    );

    if (excludeFromSemantics) {
      return ExcludeSemantics(child: indicator);
    }

    return Semantics(
      label: _normalizedSemanticText(semanticLabel),
      value: _resolvedSemanticValue(progress),
      enabled: enabled,
      child: ExcludeSemantics(child: indicator),
    );
  }

  // ---------------------------------------------------------------------------
  // Colours
  // ---------------------------------------------------------------------------

  Color _resolveTrackColor({
    required ColorScheme colors,
    required Color baseTrack,
    required bool highContrast,
  }) {
    final Color? override = trackColor;

    if (override != null) {
      return enabled
          ? override
          : Color.alphaBlend(
              colors.onSurface.withValues(alpha: highContrast ? 0.16 : 0.08),
              override,
            );
    }

    // Artwork-edge progress must remain readable regardless of the colours in
    // the underlying poster. A translucent dark track provides much more
    // predictable separation than using the ordinary page/card surface.
    if (variant == CinearaMediaProgressVariant.posterEdge) {
      return Colors.black.withValues(
        alpha: enabled
            ? highContrast
                  ? 0.88
                  : 0.62
            : highContrast
            ? 0.72
            : 0.46,
      );
    }

    if (!enabled) {
      return Color.alphaBlend(
        colors.onSurface.withValues(alpha: highContrast ? 0.16 : 0.07),
        baseTrack,
      );
    }

    // Give the empty portion a little more definition than the surrounding
    // surface without turning the track into an outline-heavy control.
    return Color.alphaBlend(
      colors.onSurface.withValues(alpha: highContrast ? 0.08 : 0.035),
      baseTrack,
    );
  }

  List<Color> _resolveProgressColors({
    required ColorScheme colors,
    required Color track,
    required bool highContrast,
  }) {
    if (!enabled) {
      final Color muted = Color.alphaBlend(
        colors.onSurface.withValues(alpha: highContrast ? 0.48 : 0.30),
        track,
      );

      return <Color>[muted, muted];
    }

    final Color? override = progressColor;

    if (override != null) {
      return <Color>[override, override];
    }

    // High contrast favours one strong colour rather than relying on subtle
    // hue changes to communicate the filled state.
    if (highContrast) {
      return <Color>[colors.primary, colors.primary];
    }

    // Restrained Cineara brand flow. The gradient moves from the warmer accent
    // through the primary violet into the cooler secondary accent.
    return <Color>[colors.tertiary, colors.primary, colors.secondary];
  }

  // ---------------------------------------------------------------------------
  // Semantics
  // ---------------------------------------------------------------------------

  String? _resolvedSemanticValue(double? progress) {
    final String? explicitValue = _normalizedSemanticText(semanticValue);

    if (explicitValue != null) {
      return explicitValue;
    }

    if (progress == null) {
      return _normalizedSemanticText(unknownSemanticValue);
    }

    final int percentage = (progress * 100).round();

    final int? watchedCount = watched;
    final int? totalCount = total;

    if (watchedCount != null && totalCount != null && totalCount > 0) {
      return '$watchedCount / $totalCount · $percentage%';
    }

    return '$percentage%';
  }

  static String? _normalizedSemanticText(String? value) {
    final String? text = value?.trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }
}

// =============================================================================
// Visual implementation
// =============================================================================

final class _CinearaProgressVisual extends StatelessWidget {
  const _CinearaProgressVisual({
    required this.progress,
    required this.variant,
    required this.height,
    required this.trackColor,
    required this.progressColors,
    required this.outlineColor,
    required this.unknownPatternColor,
    required this.animationDuration,
    required this.highContrast,
    required this.enabled,
  });

  final double? progress;

  final CinearaMediaProgressVariant variant;

  final double height;

  final Color trackColor;

  final List<Color> progressColors;

  final Color outlineColor;

  final Color unknownPatternColor;

  final Duration animationDuration;

  final bool highContrast;

  final bool enabled;

  bool get _isPosterEdge => variant == CinearaMediaProgressVariant.posterEdge;

  BorderRadius get _borderRadius {
    if (_isPosterEdge) {
      return BorderRadius.zero;
    }

    // The radius derives from the actual indicator height instead of using a
    // fixed arbitrary radius. Compact and standard bars therefore remain true
    // capsules even when a custom height is supplied.
    return BorderRadius.circular(height / 2);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 0;

          final Widget content = Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // ---------------------------------------------------------------
              // Empty track
              // ---------------------------------------------------------------
              ColoredBox(color: trackColor),

              // ---------------------------------------------------------------
              // Unknown / determinate value
              // ---------------------------------------------------------------
              AnimatedSwitcher(
                duration: animationDuration,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder:
                    (Widget? currentChild, List<Widget> previousChildren) {
                      return Stack(
                        fit: StackFit.expand,
                        children: <Widget>[...previousChildren, ?currentChild],
                      );
                    },
                child: progress == null
                    ? _UnknownProgressPattern(
                        key: const ValueKey<String>('unknown'),
                        color: unknownPatternColor,
                      )
                    : _DeterminateProgressFill(
                        key: const ValueKey<String>('determinate'),
                        progress: progress!,
                        availableWidth: availableWidth,
                        height: height,
                        colors: progressColors,
                        borderRadius: _borderRadius,
                        animationDuration: animationDuration,
                        showLeadingHighlight:
                            enabled &&
                            !highContrast &&
                            progress! > 0 &&
                            progress! < 1,
                      ),
              ),
            ],
          );

          final Widget clipped = _isPosterEdge
              ? ClipRect(child: content)
              : ClipRRect(
                  borderRadius: _borderRadius,
                  clipBehavior: Clip.antiAlias,
                  child: content,
                );

          if (_isPosterEdge) {
            // Poster-edge bars deliberately avoid their own enclosing border.
            // The artwork/poster component owns the outer silhouette.
            return clipped;
          }

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              clipped,

              // ---------------------------------------------------------------
              // Standalone outer definition
              // ---------------------------------------------------------------
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: _borderRadius,
                    border: Border.all(
                      color: outlineColor,
                      width: highContrast ? 1.25 : 0.75,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =============================================================================
// Determinate progress
// =============================================================================

final class _DeterminateProgressFill extends StatelessWidget {
  const _DeterminateProgressFill({
    required this.progress,
    required this.availableWidth,
    required this.height,
    required this.colors,
    required this.borderRadius,
    required this.animationDuration,
    required this.showLeadingHighlight,
    super.key,
  });

  final double progress;
  final double availableWidth;
  final double height;

  final List<Color> colors;

  final BorderRadius borderRadius;

  final Duration animationDuration;

  final bool showLeadingHighlight;

  @override
  Widget build(BuildContext context) {
    final double fillWidth = availableWidth * progress;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeOutCubic,
        width: fillWidth,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
            colors: colors,
            stops: colors.length == 3 ? const <double>[0, 0.56, 1] : null,
          ),
        ),
        child: showLeadingHighlight
            ? Align(
                alignment: AlignmentDirectional.centerEnd,
                child: SizedBox(
                  width: height * 2.4,
                  height: height,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.centerStart,
                        end: AlignmentDirectional.centerEnd,
                        colors: <Color>[
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.22),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

// =============================================================================
// Unknown progress
// =============================================================================

final class _UnknownProgressPattern extends StatelessWidget {
  const _UnknownProgressPattern({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _UnknownProgressPainter(color: color)),
    );
  }
}

/// Static diagonal pattern used specifically for unknown progress.
///
/// This is intentionally not animated:
///
/// - movement would look like buffering/loading;
/// - unknown progress is a data state, not an in-progress network operation;
/// - the static treatment remains calm in dense media grids.
final class _UnknownProgressPainter extends CustomPainter {
  const _UnknownProgressPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final double calculatedStroke = size.height * 0.34;
    final double strokeWidth = calculatedStroke < 1 ? 1 : calculatedStroke;

    final double stripeSpan = size.height * 1.5;
    final double spacing = size.height * 3.2;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    double x = -stripeSpan;

    while (x < size.width + stripeSpan) {
      canvas.drawLine(Offset(x, size.height), Offset(x + stripeSpan, 0), paint);

      x += spacing;
    }
  }

  @override
  bool shouldRepaint(_UnknownProgressPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
