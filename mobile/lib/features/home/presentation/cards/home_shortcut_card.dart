import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Compact Home shortcut used to open a major Cineara destination or action.
///
/// Typical uses include Random Picker, Calendar, Cinema Passport,
/// Achievements, Collections and Spin the Globe.
///
/// This is a presentation-only component. Navigation and application logic
/// should be provided through [onTap] by the surrounding Home feature.
///
/// Accessibility behavior:
///
/// - layout density responds to the width actually available to the card;
/// - large accessibility text receives additional label lines;
/// - supporting descriptions are the first visual detail removed when space
///   becomes constrained, while remaining available to Semantics;
/// - CJK, Arabic, Hebrew, Devanagari and other fallback fonts receive generous
///   line metrics to avoid clipped glyphs;
/// - the optional badge follows Cineara's tilted NEW-marker language, sizes
///   itself from the full localized word, can reduce its font slightly when
///   space is tight, and disappears rather than ever showing an ellipsis;
/// - reduced motion, bold text and high contrast are respected;
/// - RTL direction is inherited naturally from the surrounding app.
///
/// The parent layout still controls the physical size of each shortcut. At
/// very large text sizes, the Home grid should reduce its column count and/or
/// increase row height instead of forcing the card into a small fixed cell.
class HomeShortcutCard extends StatefulWidget {
  const HomeShortcutCard({
    required this.icon,
    required this.label,
    super.key,
    this.description,
    this.badgeLabel,
    this.semanticLabel,
    this.onTap,
    this.enableHaptics = false,
  });

  final IconData icon;
  final String label;
  final String? description;
  final String? badgeLabel;
  final String? semanticLabel;
  final VoidCallback? onTap;
  final bool enableHaptics;

  @override
  State<HomeShortcutCard> createState() => _HomeShortcutCardState();
}

class _HomeShortcutCardState extends State<HomeShortcutCard> {
  static const Duration _minimumPressDuration = Duration(milliseconds: 90);

  bool _isPressed = false;
  DateTime? _pressStartedAt;

  bool get _isInteractive => widget.onTap != null;

  String get _resolvedSemanticLabel {
    if (widget.semanticLabel case final String label
        when label.trim().isNotEmpty) {
      return label;
    }

    final List<String> parts = <String>[widget.label];

    if (widget.description case final String description
        when description.trim().isNotEmpty) {
      parts.add(description);
    }

    if (widget.badgeLabel case final String badge
        when badge.trim().isNotEmpty) {
      parts.add(badge);
    }

    return parts.join(', ');
  }

  void _handleTapDown(TapDownDetails _) {
    if (!_isInteractive || _isPressed) {
      return;
    }

    _pressStartedAt = DateTime.now();

    setState(() {
      _isPressed = true;
    });
  }

  void _handleTap() {
    final VoidCallback? callback = widget.onTap;

    if (callback == null) {
      return;
    }

    _scheduleRelease();

    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    callback();
  }

  void _handleTapCancel() {
    _scheduleRelease();
  }

  void _scheduleRelease() {
    if (!_isPressed) {
      return;
    }

    final DateTime startedAt = _pressStartedAt ?? DateTime.now();
    final Duration elapsed = DateTime.now().difference(startedAt);

    final Duration remaining = elapsed >= _minimumPressDuration
        ? Duration.zero
        : _minimumPressDuration - elapsed;

    if (remaining == Duration.zero) {
      _releasePressedState();
      return;
    }

    Future<void>.delayed(remaining, () {
      if (!mounted) {
        return;
      }

      _releasePressedState();
    });
  }

  void _releasePressedState() {
    if (!_isPressed) {
      return;
    }

    setState(() {
      _isPressed = false;
    });

    _pressStartedAt = null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final bool reduceMotion = mediaQuery.disableAnimations;
    final bool highContrast = mediaQuery.highContrast;
    final bool boldText = mediaQuery.boldText;

    final Duration interactionDuration = reduceMotion
        ? Duration.zero
        : CinearaMotion.fast;

    final Duration scaleDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 90);

    final BorderRadius borderRadius = BorderRadius.circular(CinearaRadii.lg);

    final Color borderColor = theme.colorScheme.outlineVariant.withValues(
      alpha: highContrast ? 0.88 : 0.55,
    );

    return Semantics(
      container: true,
      button: _isInteractive,
      enabled: _isInteractive,
      label: _resolvedSemanticLabel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed && !reduceMotion ? 0.985 : 1.0,
        duration: scaleDuration,
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: interactionDuration,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(
                  alpha: highContrast ? 0.12 : 0.08,
                ),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: borderRadius,
                border: Border.all(color: borderColor),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    theme.colorScheme.surfaceContainerHigh,
                    theme.colorScheme.primary.withValues(alpha: 0.060),
                    theme.colorScheme.secondary.withValues(alpha: 0.045),
                  ],
                  stops: const <double>[0.0, 0.62, 1.0],
                ),
              ),
              child: InkWell(
                excludeFromSemantics: true,
                onTap: _isInteractive ? _handleTap : null,
                onTapDown: _isInteractive ? _handleTapDown : null,
                onTapCancel: _isInteractive ? _handleTapCancel : null,
                splashFactory: NoSplash.splashFactory,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double width = constraints.hasBoundedWidth
                        ? constraints.maxWidth
                        : 160;

                    final double? boundedHeight = constraints.hasBoundedHeight
                        ? constraints.maxHeight
                        : null;

                    final double textScale = _effectiveTextScale(context);

                    final _HomeShortcutLayout layout =
                        _HomeShortcutLayout.resolve(
                          width: width,
                          boundedHeight: boundedHeight,
                          textScale: textScale,
                        );

                    return _HomeShortcutContent(
                      icon: widget.icon,
                      label: widget.label,
                      description: widget.description,
                      badgeLabel: widget.badgeLabel,
                      layout: layout,
                      isInteractive: _isInteractive,
                      isPressed: _isPressed,
                      boldText: boldText,
                      highContrast: highContrast,
                      animationDuration: interactionDuration,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _HomeShortcutDensity { compact, regular, spacious }

_HomeShortcutDensity _resolveShortcutDensity(double width) {
  if (width < 120) {
    return _HomeShortcutDensity.compact;
  }

  if (width < 180) {
    return _HomeShortcutDensity.regular;
  }

  return _HomeShortcutDensity.spacious;
}

double _effectiveTextScale(BuildContext context) {
  final TextScaler scaler = MediaQuery.textScalerOf(context);
  return scaler.scale(16) / 16;
}

@immutable
class _HomeShortcutLayout {
  const _HomeShortcutLayout({
    required this.density,
    required this.padding,
    required this.iconContainerSize,
    required this.iconSize,
    required this.labelFontSize,
    required this.descriptionFontSize,
    required this.labelMaxLines,
    required this.descriptionMaxLines,
    required this.showDescription,
    required this.topToLabelSpacing,
    required this.labelToDescriptionSpacing,
    required this.contentToFooterSpacing,
    required this.footerIconSize,
    required this.fillBoundedHeight,
  });

  final _HomeShortcutDensity density;
  final EdgeInsets padding;
  final double iconContainerSize;
  final double iconSize;
  final double labelFontSize;
  final double descriptionFontSize;
  final int labelMaxLines;
  final int descriptionMaxLines;
  final bool showDescription;
  final double topToLabelSpacing;
  final double labelToDescriptionSpacing;
  final double contentToFooterSpacing;
  final double footerIconSize;
  final bool fillBoundedHeight;

  static _HomeShortcutLayout resolve({
    required double width,
    required double? boundedHeight,
    required double textScale,
  }) {
    final _HomeShortcutDensity density = _resolveShortcutDensity(width);

    final bool enlargedText = textScale >= 1.30;
    final bool veryLargeText = textScale >= 1.80;

    final bool heightConstrained = boundedHeight != null && boundedHeight < 175;

    final bool veryHeightConstrained =
        boundedHeight != null && boundedHeight < 145;

    final EdgeInsets padding = veryHeightConstrained
        ? const EdgeInsets.all(10)
        : heightConstrained
        ? const EdgeInsets.all(CinearaSpacing.sm)
        : switch (density) {
            _HomeShortcutDensity.compact => const EdgeInsets.all(
              CinearaSpacing.sm,
            ),
            _HomeShortcutDensity.regular => const EdgeInsets.all(
              CinearaSpacing.md,
            ),
            _HomeShortcutDensity.spacious => const EdgeInsets.all(
              CinearaSpacing.md,
            ),
          };

    final double iconContainerSize = veryHeightConstrained
        ? 32
        : heightConstrained
        ? 34
        : switch (density) {
            _HomeShortcutDensity.compact => 34,
            _HomeShortcutDensity.regular => 40,
            _HomeShortcutDensity.spacious => 44,
          };

    final double iconSize = veryHeightConstrained
        ? 17
        : heightConstrained
        ? 18
        : switch (density) {
            _HomeShortcutDensity.compact => 18,
            _HomeShortcutDensity.regular => 21,
            _HomeShortcutDensity.spacious => 23,
          };

    final double labelFontSize = switch (density) {
      _HomeShortcutDensity.compact => 13,
      _HomeShortcutDensity.regular => 14,
      _HomeShortcutDensity.spacious => 14,
    };

    final int labelMaxLines = enlargedText ? 3 : 2;
    final int descriptionMaxLines = enlargedText ? 3 : 2;

    final bool shortBoundedCell =
        boundedHeight != null && boundedHeight < (veryLargeText ? 170 : 145);

    final bool showDescription =
        density != _HomeShortcutDensity.compact &&
        !shortBoundedCell &&
        (!veryLargeText || width >= 220);

    return _HomeShortcutLayout(
      density: density,
      padding: padding,
      iconContainerSize: iconContainerSize,
      iconSize: iconSize,
      labelFontSize: labelFontSize,
      descriptionFontSize: 11.5,
      labelMaxLines: labelMaxLines,
      descriptionMaxLines: descriptionMaxLines,
      showDescription: showDescription,
      topToLabelSpacing: veryHeightConstrained
          ? 6
          : heightConstrained
          ? CinearaSpacing.xs
          : veryLargeText
          ? CinearaSpacing.sm
          : CinearaSpacing.md,
      labelToDescriptionSpacing: CinearaSpacing.xxs,
      contentToFooterSpacing: veryHeightConstrained
          ? 6
          : heightConstrained
          ? CinearaSpacing.xs
          : enlargedText
          ? CinearaSpacing.sm
          : CinearaSpacing.md,
      footerIconSize: veryHeightConstrained
          ? 14
          : heightConstrained
          ? 15
          : density == _HomeShortcutDensity.compact
          ? 15
          : 17,
      fillBoundedHeight: boundedHeight != null,
    );
  }
}

class _HomeShortcutContent extends StatelessWidget {
  const _HomeShortcutContent({
    required this.icon,
    required this.label,
    required this.description,
    required this.badgeLabel,
    required this.layout,
    required this.isInteractive,
    required this.isPressed,
    required this.boldText,
    required this.highContrast,
    required this.animationDuration,
  });

  final IconData icon;
  final String label;
  final String? description;
  final String? badgeLabel;
  final _HomeShortcutLayout layout;
  final bool isInteractive;
  final bool isPressed;
  final bool boldText;
  final bool highContrast;
  final Duration animationDuration;

  bool get _hasDescription =>
      description != null && description!.trim().isNotEmpty;

  bool get _hasBadge => badgeLabel != null && badgeLabel!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final TextDirection direction = Directionality.of(context);

    final double arrowShift = direction == TextDirection.rtl ? -0.15 : 0.15;

    final bool showDescription = _hasDescription && layout.showDescription;

    return ExcludeSemantics(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          Padding(
            padding: layout.padding,
            child: Column(
              mainAxisSize: layout.fillBoundedHeight
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _ShortcutIcon(
                      icon: icon,
                      size: layout.iconContainerSize,
                      iconSize: layout.iconSize,
                      isPressed: isPressed,
                      highContrast: highContrast,
                      animationDuration: animationDuration,
                    ),
                    const SizedBox(width: CinearaSpacing.sm),

                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: _hasBadge
                            ? _ShortcutBadge(
                                label: badgeLabel!,
                                boldText: boldText,
                                highContrast: highContrast,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: layout.topToLabelSpacing),

                if (layout.fillBoundedHeight)
                  Expanded(
                    child: _ShortcutTextBlock(
                      label: label,
                      description: showDescription ? description : null,
                      labelFontSize: layout.labelFontSize,
                      descriptionFontSize: layout.descriptionFontSize,
                      desiredLabelMaxLines: layout.labelMaxLines,
                      desiredDescriptionMaxLines: layout.descriptionMaxLines,
                      labelToDescriptionSpacing:
                          layout.labelToDescriptionSpacing,
                      boldText: boldText,
                      highContrast: highContrast,
                    ),
                  )
                else
                  _ShortcutTextBlock(
                    label: label,
                    description: showDescription ? description : null,
                    labelFontSize: layout.labelFontSize,
                    descriptionFontSize: layout.descriptionFontSize,
                    desiredLabelMaxLines: layout.labelMaxLines,
                    desiredDescriptionMaxLines: layout.descriptionMaxLines,
                    labelToDescriptionSpacing: layout.labelToDescriptionSpacing,
                    boldText: boldText,
                    highContrast: highContrast,
                  ),

                SizedBox(height: layout.contentToFooterSpacing),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const _ShortcutAccentEdge(),
                    if (isInteractive) ...<Widget>[
                      const Spacer(),

                      AnimatedSlide(
                        offset: isPressed ? Offset(arrowShift, 0) : Offset.zero,
                        duration: animationDuration,
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: layout.footerIconSize,
                          color: isPressed
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: highContrast ? 0.90 : 0.62,
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: isPressed ? 1 : 0,
                duration: animationDuration,
                curve: Curves.easeOutCubic,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(CinearaRadii.lg),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        theme.colorScheme.primary.withValues(alpha: 0.050),
                        Colors.transparent,
                        theme.colorScheme.secondary.withValues(alpha: 0.045),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutTextBlock extends StatelessWidget {
  const _ShortcutTextBlock({
    required this.label,
    required this.description,
    required this.labelFontSize,
    required this.descriptionFontSize,
    required this.desiredLabelMaxLines,
    required this.desiredDescriptionMaxLines,
    required this.labelToDescriptionSpacing,
    required this.boldText,
    required this.highContrast,
  });

  final String label;
  final String? description;
  final double labelFontSize;
  final double descriptionFontSize;
  final int desiredLabelMaxLines;
  final int desiredDescriptionMaxLines;
  final double labelToDescriptionSpacing;
  final bool boldText;
  final bool highContrast;

  bool get _hasDescription =>
      description != null && description!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextDirection direction = Directionality.of(context);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    final TextStyle labelStyle =
        (theme.textTheme.titleSmall ?? const TextStyle()).copyWith(
          fontSize: labelFontSize,
          height: 1.30,
          fontWeight: boldText ? FontWeight.w800 : FontWeight.w700,
          letterSpacing: 0,
          leadingDistribution: TextLeadingDistribution.even,
        );

    final TextStyle descriptionStyle =
        (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
          fontSize: descriptionFontSize,
          height: 1.32,
          color: theme.colorScheme.onSurfaceVariant.withValues(
            alpha: highContrast ? 1.0 : 0.86,
          ),
          fontWeight: boldText ? FontWeight.w600 : FontWeight.w400,
          leadingDistribution: TextLeadingDistribution.even,
        );

    const TextHeightBehavior textHeightBehavior = TextHeightBehavior(
      applyHeightToFirstAscent: true,
      applyHeightToLastDescent: true,
      leadingDistribution: TextLeadingDistribution.even,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        int labelLines = desiredLabelMaxLines;
        int descriptionLines = _hasDescription ? desiredDescriptionMaxLines : 0;

        if (constraints.hasBoundedHeight && constraints.hasBoundedWidth) {
          double totalHeight() {
            final double labelHeight = _measureShortcutTextHeight(
              text: label,
              style: labelStyle,
              textScaler: textScaler,
              textDirection: direction,
              maxWidth: constraints.maxWidth,
              maxLines: labelLines,
              textHeightBehavior: textHeightBehavior,
            );

            if (descriptionLines <= 0) {
              return labelHeight;
            }

            final double descriptionHeight = _measureShortcutTextHeight(
              text: description!,
              style: descriptionStyle,
              textScaler: textScaler,
              textDirection: direction,
              maxWidth: constraints.maxWidth,
              maxLines: descriptionLines,
              textHeightBehavior: textHeightBehavior,
            );

            return labelHeight + labelToDescriptionSpacing + descriptionHeight;
          }

          // Secondary text gives way first. This preserves the shortcut's
          // primary action name instead of allowing a RenderFlex overflow.
          while (descriptionLines > 0 &&
              totalHeight() > constraints.maxHeight) {
            descriptionLines--;
          }

          while (labelLines > 1 && totalHeight() > constraints.maxHeight) {
            labelLines--;
          }

          // If even one description line cannot coexist safely with the
          // primary label, remove it visually. It remains in Semantics on the
          // outer card.
          if (descriptionLines > 0 && totalHeight() > constraints.maxHeight) {
            descriptionLines = 0;
          }
        }

        final Widget content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              label,
              maxLines: labelLines,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              textHeightBehavior: textHeightBehavior,
              style: labelStyle,
            ),
            if (descriptionLines > 0) ...<Widget>[
              SizedBox(height: labelToDescriptionSpacing),
              Text(
                description!,
                maxLines: descriptionLines,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                textHeightBehavior: textHeightBehavior,
                style: descriptionStyle,
              ),
            ],
          ],
        );

        if (!constraints.hasBoundedHeight) {
          return content;
        }

        // Clip as a final defensive guard against platform/font-metric
        // differences. The measured line allocation above should already fit.
        return ClipRect(
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: content,
          ),
        );
      },
    );
  }
}

double _measureShortcutTextHeight({
  required String text,
  required TextStyle style,
  required TextScaler textScaler,
  required TextDirection textDirection,
  required double maxWidth,
  required int maxLines,
  required TextHeightBehavior textHeightBehavior,
}) {
  final TextPainter painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: textDirection,
    textScaler: textScaler,
    maxLines: maxLines,
    ellipsis: '…',
    textHeightBehavior: textHeightBehavior,
  )..layout(maxWidth: maxWidth);

  return painter.height;
}

class _ShortcutIcon extends StatelessWidget {
  const _ShortcutIcon({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.isPressed,
    required this.highContrast,
    required this.animationDuration,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final bool isPressed;
  final bool highContrast;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CinearaRadii.md),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            theme.colorScheme.primary.withValues(alpha: isPressed ? 1.0 : 0.94),
            theme.colorScheme.tertiary,
            theme.colorScheme.secondary.withValues(
              alpha: isPressed ? 1.0 : 0.94,
            ),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.onPrimary.withValues(
            alpha: highContrast ? 0.42 : 0.18,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.colorScheme.primary.withValues(
              alpha: isPressed ? 0.22 : 0.14,
            ),
            blurRadius: isPressed ? 8 : 7,
          ),
        ],
      ),
      child: Icon(icon, size: iconSize, color: CinearaColours.neutral0),
    );
  }
}

/// Temporary status/count marker shown by a Home shortcut.
///
/// Visually this belongs to the same family as the tilted NEW marker used by
/// [PosterMediaCard]: a compact tertiary-to-primary gradient, light border,
/// small shadow and subtle rotation.
///
/// Unlike a conventional fixed-width pill, this marker is localization-first:
///
/// - the full label is always measured before rendering;
/// - its width follows the complete localized content;
/// - preferred typography is retained whenever possible;
/// - when space is tight, the font can reduce only within a small safe range;
/// - the label is never ellipsized, clipped or abbreviated;
/// - if the complete label still cannot fit, the marker disappears visually;
/// - [HomeShortcutCard] still exposes [badgeLabel] through Semantics.
class _ShortcutBadge extends StatelessWidget {
  const _ShortcutBadge({
    required this.label,
    required this.boldText,
    required this.highContrast,
  });

  final String label;
  final bool boldText;
  final bool highContrast;

  static const double _preferredFontSize = 12;
  static const double _minimumFontSize = 10;

  // Base breathing room. The final padding is resolved dynamically from the
  // active TextScaler and writing system.
  static const double _baseHorizontalPadding = 11;
  static const double _baseVerticalPadding = 6;

  // Rotation needs a little extra paint safety near the trailing card edge.
  static const double _rotationSafety = 6;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final TextDirection textDirection = Directionality.of(context);

    const TextHeightBehavior textHeightBehavior = TextHeightBehavior(
      applyHeightToFirstAscent: true,
      applyHeightToLastDescent: true,
      leadingDistribution: TextLeadingDistribution.even,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth - _rotationSafety
            : double.infinity;

        if (availableWidth <= 0) {
          return const SizedBox.shrink();
        }

        final double effectiveScale =
            textScaler.scale(_preferredFontSize) / _preferredFontSize;

        // Ideographic and complex-script glyphs tend to occupy more of their
        // line box than Latin capitals. Give them extra optical breathing room
        // instead of shrinking the glyphs.
        final bool denseScript = RegExp(
          r'[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff'
          r'\uf900-\ufaff\uac00-\ud7af\u0600-\u06ff'
          r'\u0900-\u097f]',
        ).hasMatch(label);

        final double horizontalPadding =
            _baseHorizontalPadding +
            (denseScript ? 2 : 0) +
            (effectiveScale >= 1.80 ? 1 : 0);

        final double verticalPadding =
            (_baseVerticalPadding +
                    (denseScript ? 1.5 : 0) +
                    ((effectiveScale - 1).clamp(0.0, 1.5) * 1.5))
                .clamp(6.0, 9.5)
                .toDouble();

        TextStyle styleFor(double fontSize) {
          return (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
            color: CinearaColours.neutral0,
            fontSize: fontSize,
            height: 1.0,
            fontWeight: boldText ? FontWeight.w900 : FontWeight.w800,

            // Keep this nearly neutral for Arabic/CJK/Devanagari while still
            // retaining a slightly crisp event-marker character.
            letterSpacing: 0.15,
            leadingDistribution: TextLeadingDistribution.even,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          );
        }

        double measuredWidth(double fontSize) {
          final TextPainter painter = TextPainter(
            text: TextSpan(text: label, style: styleFor(fontSize)),
            textDirection: textDirection,
            textScaler: textScaler,
            maxLines: 1,
            textHeightBehavior: textHeightBehavior,
          )..layout();

          return painter.width;
        }

        double measuredHeight(double fontSize) {
          final TextPainter painter = TextPainter(
            text: TextSpan(text: label, style: styleFor(fontSize)),
            textDirection: textDirection,
            textScaler: textScaler,
            maxLines: 1,
            textHeightBehavior: textHeightBehavior,
          )..layout();

          return painter.height;
        }

        final double maximumTextWidth = availableWidth.isFinite
            ? availableWidth - (horizontalPadding * 2)
            : double.infinity;

        if (maximumTextWidth <= 0) {
          return const SizedBox.shrink();
        }

        final double preferredTextWidth = measuredWidth(_preferredFontSize);

        double resolvedFontSize = _preferredFontSize;

        if (preferredTextWidth > maximumTextWidth) {
          final double minimumTextWidth = measuredWidth(_minimumFontSize);

          // Never render a partial/ellipsized marker. If even the smallest
          // approved typography cannot show the complete localized label,
          // remove the marker visually.
          if (minimumTextWidth > maximumTextWidth) {
            return const SizedBox.shrink();
          }

          // Find the largest font size that can display the full label.
          double low = _minimumFontSize;
          double high = _preferredFontSize;

          for (int iteration = 0; iteration < 8; iteration++) {
            final double candidate = (low + high) / 2;

            if (measuredWidth(candidate) <= maximumTextWidth) {
              low = candidate;
            } else {
              high = candidate;
            }
          }

          resolvedFontSize = low;
        }

        final TextStyle resolvedStyle = styleFor(resolvedFontSize);

        final double textWidth = measuredWidth(resolvedFontSize);
        final double textHeight = measuredHeight(resolvedFontSize);

        final double badgeWidth = textWidth + (horizontalPadding * 2);

        final double badgeHeight = textHeight + (verticalPadding * 2);

        final double angle = textDirection == TextDirection.rtl ? 0.10 : -0.10;

        return IgnorePointer(
          child: Transform.rotate(
            angle: angle,
            child: SizedBox(
              width: badgeWidth,
              height: badgeHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      theme.colorScheme.tertiary.withValues(alpha: 0.92),
                      theme.colorScheme.primary.withValues(alpha: 0.94),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(CinearaRadii.sm),
                  border: Border.all(
                    color: CinearaColours.neutral0.withValues(
                      alpha: highContrast ? 0.46 : 0.28,
                    ),
                    width: highContrast ? 1.25 : 1,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: highContrast ? 0.42 : 0.30,
                      ),
                      blurRadius: 7,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      textHeightBehavior: textHeightBehavior,
                      style: resolvedStyle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShortcutAccentEdge extends StatelessWidget {
  const _ShortcutAccentEdge();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CinearaRadii.pill),
        gradient: LinearGradient(
          colors: <Color>[colors.tertiary, colors.primary, colors.secondary],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.18),
            blurRadius: 5,
          ),
        ],
      ),
    );
  }
}
