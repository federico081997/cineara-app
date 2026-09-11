import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../tokens/colour.dart';
import '../../tokens/motion.dart';

// =============================================================================
// Public API
// =============================================================================

/// Semantic viewing state represented by [CinearaStatusBadge].
///
/// This is a presentation-level enum. It describes the visual status rendered
/// by the design system and does not own library-transition or progress rules.
enum CinearaStatusBadgeType {
  /// The user is actively watching the media.
  watching,

  /// The user has watched every currently released standard episode.
  caughtUp,

  /// The media has been fully completed.
  completed,

  /// The user is watching the media again.
  rewatching,

  /// Viewing has temporarily been paused.
  onHold,

  /// The user stopped watching the media.
  dropped,
}

/// Surface treatment used by [CinearaStatusBadge].
enum CinearaStatusBadgeVariant {
  /// Predictable dark treatment intended for arbitrary poster/backdrop artwork.
  artwork,

  /// Theme-aware treatment intended for ordinary content surfaces.
  surface,
}

/// Physical density used by [CinearaStatusBadge].
enum CinearaStatusBadgeDensity {
  /// Compact treatment intended primarily for poster artwork.
  compact,

  /// Slightly larger treatment intended for rows, cards, and sheets.
  standard,
}

/// Expansion behaviour used by [CinearaStatusBadge].
enum CinearaStatusBadgeBehavior {
  /// Keep the localized status label visible.
  ///
  /// Appropriate for list rows and layouts with sufficient horizontal room.
  persistent,

  /// Normally show only the compact status indicator.
  ///
  /// The outer capsule temporarily unfolds toward logical inline-end to reveal
  /// the localized status label.
  collapsible,
}

/// Compact Cineara viewing-status indicator.
///
/// The badge consists of:
///
/// 1. an outer neutral/tinted capsule;
/// 2. a smaller semantic-colour circle;
/// 3. a centred status glyph.
///
/// In the collapsed state:
///
/// ```text
/// ╭────────╮
/// │ ╭────╮ │
/// │ │ ▶  │ │
/// │ ╰────╯ │
/// ╰────────╯
/// ```
///
/// The outer capsule is the only geometry that expands:
///
/// ```text
/// ╭──────────────────────────╮
/// │ ╭────╮  Watching         │
/// │ │ ▶  │                   │
/// │ ╰────╯                   │
/// ╰──────────────────────────╯
/// ```
///
/// The fixed leading cell is always square and equal to the badge height.
/// The semantic circle is positioned using equal physical inset on all sides,
/// keeping it concentric with the collapsed capsule.
///
/// Normal rendering deliberately uses no inner or outer decorative outlines.
/// When system high-contrast mode is active, a paint-only outline is added
/// around the complete outer capsule without affecting its geometry.
///
/// Expansion follows [Directionality], so LTR expands toward the right and RTL
/// expands toward the left.
///
/// Long localized labels are never replaced with an ellipsis. When the label
/// exceeds [maxWidth], it performs one restrained horizontal reveal.
///
/// Reduced-motion accessibility settings suppress decorative entrance scaling
/// and marquee movement.
///
/// [label] and [semanticLabel] remain application-owned so localized strings do
/// not leak into the shared design system.
final class CinearaStatusBadge extends StatefulWidget {
  const CinearaStatusBadge({
    required this.type,
    required this.label,
    super.key,
    this.semanticLabel,
    this.variant = CinearaStatusBadgeVariant.artwork,
    this.density = CinearaStatusBadgeDensity.compact,
    this.behavior = CinearaStatusBadgeBehavior.collapsible,
    this.animate = true,
    this.revealOnMount = false,
    this.revealOnStatusChange = true,
    this.autoCollapse = true,
    this.autoCollapseDelay = const Duration(milliseconds: 1600),
    this.expandOnTap = true,
    this.marqueeLongLabels = true,
    this.accentColor,
    this.icon,
    this.maxWidth,
    this.onExpandedChanged,
  }) : assert(label != '', 'label must not be empty.'),
       assert(
         maxWidth == null || maxWidth > 0,
         'maxWidth must be greater than zero.',
       );

  /// Status represented by this badge.
  final CinearaStatusBadgeType type;

  /// Localized visible status label.
  final String label;

  /// Optional localized accessibility description.
  ///
  /// Defaults to [label].
  final String? semanticLabel;

  /// Artwork or ordinary-surface treatment.
  final CinearaStatusBadgeVariant variant;

  /// Physical visual density.
  final CinearaStatusBadgeDensity density;

  /// Persistent or collapsible label behaviour.
  final CinearaStatusBadgeBehavior behavior;

  /// Whether decorative motion is enabled.
  ///
  /// System reduced-motion settings always take precedence.
  final bool animate;

  /// Whether a newly mounted badge performs its entrance treatment and
  /// temporarily reveals its label.
  ///
  /// Set this when the badge has just appeared because the user assigned a
  /// status.
  final bool revealOnMount;

  /// Whether changing [type], [label], or [icon] temporarily reveals the
  /// updated status label.
  final bool revealOnStatusChange;

  /// Whether temporary expansion automatically returns to compact form.
  final bool autoCollapse;

  /// Time a normal fitting label remains visible before automatic collapse.
  final Duration autoCollapseDelay;

  /// Whether tapping a collapsible badge toggles its label.
  final bool expandOnTap;

  /// Whether overflowing localized text performs a one-shot horizontal reveal.
  final bool marqueeLongLabels;

  /// Optional semantic status-colour override.
  final Color? accentColor;

  /// Optional status glyph override.
  final IconData? icon;

  /// Maximum expanded badge width.
  ///
  /// Values smaller than the collapsed badge are normalized automatically.
  final double? maxWidth;

  /// Called whenever a collapsible badge changes expansion state.
  final ValueChanged<bool>? onExpandedChanged;

  @override
  State<CinearaStatusBadge> createState() => _CinearaStatusBadgeState();
}

// =============================================================================
// State
// =============================================================================

final class _CinearaStatusBadgeState extends State<CinearaStatusBadge>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _marqueeController;

  bool _expanded = false;

  bool _reduceMotion = false;
  bool _didResolveDependencies = false;

  int _sequenceGeneration = 0;

  // ===========================================================================
  // Lifecycle
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    assert(
      widget.label.trim().isNotEmpty,
      'label must contain visible characters.',
    );

    assert(
      widget.autoCollapseDelay.inMicroseconds >= 0,
      'autoCollapseDelay must not be negative.',
    );

    _expanded = widget.behavior == CinearaStatusBadgeBehavior.persistent;

    _entranceController = AnimationController(
      vsync: this,
      duration: CinearaMotion.standard,
      value: widget.revealOnMount ? 0 : 1,
    );

    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final bool reduceMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;

    final bool firstResolution = !_didResolveDependencies;

    _didResolveDependencies = true;
    _reduceMotion = reduceMotion;

    if (!_animationsEnabled) {
      _entranceController.value = 1;
      _marqueeController.value = 0;
    }

    if (!firstResolution) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (widget.revealOnMount) {
        unawaited(_reveal(playEntrance: true));
        return;
      }

      _entranceController.value = 1;

      if (widget.behavior == CinearaStatusBadgeBehavior.persistent) {
        unawaited(_runPersistentMarquee());
      }
    });
  }

  @override
  void didUpdateWidget(CinearaStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    assert(
      widget.label.trim().isNotEmpty,
      'label must contain visible characters.',
    );

    assert(
      widget.autoCollapseDelay.inMicroseconds >= 0,
      'autoCollapseDelay must not be negative.',
    );

    final bool statusChanged =
        oldWidget.type != widget.type ||
        oldWidget.label != widget.label ||
        oldWidget.icon != widget.icon;

    final bool behaviorChanged = oldWidget.behavior != widget.behavior;

    if (behaviorChanged) {
      _cancelSequence();

      if (widget.behavior == CinearaStatusBadgeBehavior.persistent) {
        _setExpanded(true, notify: false);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }

          unawaited(_runPersistentMarquee());
        });
      } else {
        _setExpanded(false, notify: false);
      }
    }

    if (!statusChanged) {
      return;
    }

    _marqueeController
      ..stop()
      ..value = 0;

    if (widget.behavior == CinearaStatusBadgeBehavior.collapsible &&
        widget.revealOnStatusChange) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        unawaited(_reveal(playEntrance: false));
      });

      return;
    }

    if (widget.behavior == CinearaStatusBadgeBehavior.persistent &&
        !behaviorChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        unawaited(_runPersistentMarquee());
      });
    }
  }

  @override
  void dispose() {
    _sequenceGeneration++;

    _entranceController.dispose();
    _marqueeController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // Behaviour
  // ===========================================================================

  bool get _animationsEnabled => widget.animate && !_reduceMotion;

  bool get _isCollapsible =>
      widget.behavior == CinearaStatusBadgeBehavior.collapsible;

  bool get _isInteractive => _isCollapsible && widget.expandOnTap;

  void _handleTap() {
    if (!_isInteractive) {
      return;
    }

    if (_expanded) {
      _cancelSequence();
      _setExpanded(false);
      return;
    }

    unawaited(_reveal(playEntrance: false));
  }

  Future<void> _reveal({required bool playEntrance}) async {
    if (!mounted) {
      return;
    }

    final int generation = ++_sequenceGeneration;

    _marqueeController
      ..stop()
      ..value = 0;

    // -------------------------------------------------------------------------
    // Entrance
    // -------------------------------------------------------------------------

    if (playEntrance) {
      if (_animationsEnabled) {
        _entranceController.value = 0;

        try {
          await _entranceController.forward().orCancel;
        } on TickerCanceled {
          return;
        }
      } else {
        _entranceController.value = 1;
      }
    } else {
      _entranceController.value = 1;
    }

    if (!_isCurrentSequence(generation)) {
      return;
    }

    // -------------------------------------------------------------------------
    // Expand
    // -------------------------------------------------------------------------

    _setExpanded(true);

    await _waitForExpansion(generation);

    if (!_isCurrentSequence(generation)) {
      return;
    }

    final _StatusLabelLayout labelLayout = _resolveLabelLayout(
      _resolveMetrics(),
    );

    final bool shouldMarquee =
        widget.marqueeLongLabels &&
        _animationsEnabled &&
        labelLayout.overflowDistance > 0;

    // -------------------------------------------------------------------------
    // Hold / marquee
    // -------------------------------------------------------------------------

    if (shouldMarquee) {
      await _wait(const Duration(milliseconds: 320), generation);

      if (!_isCurrentSequence(generation)) {
        return;
      }

      await _runMarquee(
        overflowDistance: labelLayout.overflowDistance,
        generation: generation,
      );

      if (!_isCurrentSequence(generation)) {
        return;
      }

      await _wait(const Duration(milliseconds: 380), generation);
    } else {
      await _wait(widget.autoCollapseDelay, generation);
    }

    // -------------------------------------------------------------------------
    // Collapse
    // -------------------------------------------------------------------------

    if (!_isCurrentSequence(generation) ||
        !_isCollapsible ||
        !widget.autoCollapse) {
      return;
    }

    _setExpanded(false);

    if (_animationsEnabled) {
      await _wait(CinearaMotion.standard, generation);
    }

    if (_isCurrentSequence(generation)) {
      _marqueeController.value = 0;
    }
  }

  Future<void> _runPersistentMarquee() async {
    if (!mounted ||
        widget.behavior != CinearaStatusBadgeBehavior.persistent ||
        !widget.marqueeLongLabels ||
        !_animationsEnabled) {
      return;
    }

    final int generation = ++_sequenceGeneration;

    final _StatusLabelLayout labelLayout = _resolveLabelLayout(
      _resolveMetrics(),
    );

    if (labelLayout.overflowDistance <= 0) {
      return;
    }

    await _wait(const Duration(milliseconds: 450), generation);

    if (!_isCurrentSequence(generation)) {
      return;
    }

    await _runMarquee(
      overflowDistance: labelLayout.overflowDistance,
      generation: generation,
    );

    if (!_isCurrentSequence(generation)) {
      return;
    }

    await _wait(const Duration(milliseconds: 350), generation);

    if (!_isCurrentSequence(generation)) {
      return;
    }

    // A persistent badge should return smoothly to the beginning instead of
    // remaining parked at the end of an overflowing label.
    try {
      await _marqueeController.reverse().orCancel;
    } on TickerCanceled {
      return;
    }
  }

  Future<void> _runMarquee({
    required double overflowDistance,
    required int generation,
  }) async {
    if (overflowDistance <= 0 ||
        !_animationsEnabled ||
        !_isCurrentSequence(generation)) {
      return;
    }

    final int milliseconds = (700 + (overflowDistance * 12))
        .round()
        .clamp(750, 1500)
        .toInt();

    _marqueeController.duration = Duration(milliseconds: milliseconds);

    try {
      await _marqueeController.forward(from: 0).orCancel;
    } on TickerCanceled {
      return;
    }
  }

  Future<void> _waitForExpansion(int generation) async {
    if (!_animationsEnabled) {
      return;
    }

    await _wait(CinearaMotion.standard, generation);
  }

  Future<void> _wait(Duration duration, int generation) async {
    if (duration.inMicroseconds <= 0) {
      return;
    }

    await Future<void>.delayed(duration);

    if (!_isCurrentSequence(generation)) {
      return;
    }
  }

  void _cancelSequence() {
    _sequenceGeneration++;

    _marqueeController
      ..stop()
      ..value = 0;
  }

  bool _isCurrentSequence(int generation) {
    return mounted && generation == _sequenceGeneration;
  }

  void _setExpanded(bool expanded, {bool notify = true}) {
    if (_expanded == expanded) {
      return;
    }

    setState(() {
      _expanded = expanded;
    });

    if (notify) {
      widget.onExpandedChanged?.call(expanded);
    }
  }

  // ===========================================================================
  // Status metadata
  // ===========================================================================

  Color get _statusColor {
    final Color? override = widget.accentColor;

    if (override != null) {
      return override;
    }

    return switch (widget.type) {
      CinearaStatusBadgeType.watching => CinearaStatusColours.statusWatching,

      CinearaStatusBadgeType.caughtUp => CinearaStatusColours.statusCaughtUp,

      CinearaStatusBadgeType.completed => CinearaStatusColours.statusCompleted,

      CinearaStatusBadgeType.rewatching =>
        CinearaStatusColours.statusRewatching,

      CinearaStatusBadgeType.onHold => CinearaStatusColours.statusOnHold,

      CinearaStatusBadgeType.dropped => CinearaStatusColours.statusDropped,
    };
  }

  IconData get _statusIcon {
    final IconData? override = widget.icon;

    if (override != null) {
      return override;
    }

    return switch (widget.type) {
      CinearaStatusBadgeType.watching => Icons.play_arrow_rounded,
      CinearaStatusBadgeType.caughtUp => Icons.done_all_rounded,
      CinearaStatusBadgeType.completed => Icons.check_rounded,
      CinearaStatusBadgeType.rewatching => Icons.replay_rounded,
      CinearaStatusBadgeType.onHold => Icons.pause_rounded,
      CinearaStatusBadgeType.dropped => Icons.close_rounded,
    };
  }

  String get _resolvedSemanticLabel {
    final String? explicit = widget.semanticLabel?.trim();

    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }

    return widget.label.trim();
  }

  // ===========================================================================
  // Layout
  // ===========================================================================

  _StatusBadgeMetrics _resolveMetrics() {
    return _StatusBadgeMetrics.resolve(
      context: context,
      density: widget.density,
      maxWidthOverride: widget.maxWidth,
    );
  }

  _StatusLabelLayout _resolveLabelLayout(_StatusBadgeMetrics metrics) {
    final TextDirection textDirection = Directionality.of(context);

    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: widget.label.trim(),
        style: metrics.labelStyle(Colors.white),
      ),
      maxLines: 1,
      textDirection: textDirection,
      textScaler: TextScaler.noScaling,
    )..layout();

    final double textWidth = painter.width;

    final double fixedExpandedWidth =
        metrics.labelStart + metrics.trailingPadding;

    final double maximumViewportWidth = math
        .max(0, metrics.maxWidth - fixedExpandedWidth)
        .toDouble();

    final double viewportWidth = math
        .min(textWidth, maximumViewportWidth)
        .toDouble();

    final double naturalExpandedWidth = fixedExpandedWidth + textWidth;

    final double expandedWidth = math
        .max(
          metrics.outerDiameter,
          math.min(metrics.maxWidth, naturalExpandedWidth),
        )
        .toDouble();

    return _StatusLabelLayout(
      textWidth: textWidth,
      viewportWidth: viewportWidth,
      expandedWidth: expandedWidth,
      overflowDistance: math.max(0, textWidth - viewportWidth).toDouble(),
    );
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final bool highContrast = mediaQuery.highContrast;

    final _StatusBadgeMetrics metrics = _resolveMetrics();

    final _StatusLabelLayout labelLayout = _resolveLabelLayout(metrics);

    final _StatusBadgePalette palette = _StatusBadgePalette.resolve(
      context: context,
      variant: widget.variant,
      accent: _statusColor,
      highContrast: highContrast,
    );

    final bool visuallyExpanded =
        widget.behavior == CinearaStatusBadgeBehavior.persistent || _expanded;

    final double badgeWidth = visuallyExpanded
        ? labelLayout.expandedWidth
        : metrics.outerDiameter;

    final Duration transitionDuration = _animationsEnabled
        ? CinearaMotion.standard
        : Duration.zero;

    final Widget visualBadge = AnimatedBuilder(
      animation: _entranceController,
      builder: (BuildContext context, Widget? child) {
        final double progress = _entranceController.value;

        return Opacity(
          opacity: progress,
          child: Transform.scale(
            scale: _entranceScale(progress),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: _StatusBadgeVisual(
        type: widget.type,
        label: widget.label.trim(),
        icon: _statusIcon,
        palette: palette,
        metrics: metrics,
        labelLayout: labelLayout,
        expanded: visuallyExpanded,
        animationDuration: transitionDuration,
        marqueeAnimation: _marqueeController,
        highContrast: highContrast,
      ),
    );

    final double interactionWidth = _isInteractive
        ? math.max(badgeWidth, _minimumTouchTarget).toDouble()
        : badgeWidth;

    final double interactionHeight = _isInteractive
        ? math.max(metrics.outerDiameter, _minimumTouchTarget).toDouble()
        : metrics.outerDiameter;

    return Semantics(
      label: _resolvedSemanticLabel,
      button: _isInteractive,
      onTap: _isInteractive ? _handleTap : null,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: transitionDuration,
          curve: Curves.easeOutCubic,
          width: interactionWidth,
          height: interactionHeight,
          alignment: AlignmentDirectional.topStart,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _isInteractive ? _handleTap : null,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: visualBadge,
            ),
          ),
        ),
      ),
    );
  }

  double _entranceScale(double progress) {
    if (!_animationsEnabled) {
      return 1;
    }

    // Restrained entrance:
    //
    // 0.92 -> 1.02 -> 1.0
    if (progress <= 0.72) {
      final double localProgress = progress / 0.72;

      return _lerp(0.92, 1.02, Curves.easeOutCubic.transform(localProgress));
    }

    final double localProgress = ((progress - 0.72) / 0.28).clamp(0.0, 1.0);

    return _lerp(1.02, 1, Curves.easeOutCubic.transform(localProgress));
  }
}

// =============================================================================
// Badge visual
// =============================================================================

final class _StatusBadgeVisual extends StatelessWidget {
  const _StatusBadgeVisual({
    required this.type,
    required this.label,
    required this.icon,
    required this.palette,
    required this.metrics,
    required this.labelLayout,
    required this.expanded,
    required this.animationDuration,
    required this.marqueeAnimation,
    required this.highContrast,
  });

  final CinearaStatusBadgeType type;

  final String label;
  final IconData icon;

  final _StatusBadgePalette palette;
  final _StatusBadgeMetrics metrics;
  final _StatusLabelLayout labelLayout;

  final bool expanded;

  final Duration animationDuration;

  final Animation<double> marqueeAnimation;

  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final double targetWidth = expanded
        ? labelLayout.expandedWidth
        : metrics.outerDiameter;

    final BorderRadius borderRadius = BorderRadius.circular(
      metrics.outerDiameter / 2,
    );

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      width: targetWidth,
      height: metrics.outerDiameter,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // -----------------------------------------------------------------
            // Outer capsule surface
            // -----------------------------------------------------------------
            Positioned.fill(
              child: AnimatedContainer(
                duration: animationDuration,
                curve: Curves.easeOutCubic,
                color: palette.surface,
              ),
            ),

            // -----------------------------------------------------------------
            // Permanently fixed leading status signal
            // -----------------------------------------------------------------
            PositionedDirectional(
              start: 0,
              top: 0,
              width: metrics.outerDiameter,
              height: metrics.outerDiameter,
              child: _StatusSignal(
                type: type,
                icon: icon,
                palette: palette,
                metrics: metrics,
                animationDuration: animationDuration,
              ),
            ),

            // -----------------------------------------------------------------
            // Expanding label viewport
            // -----------------------------------------------------------------
            PositionedDirectional(
              start: metrics.labelStart,
              top: 0,
              bottom: 0,
              width: labelLayout.viewportWidth,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: animationDuration == Duration.zero
                      ? Duration.zero
                      : const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  opacity: expanded ? 1 : 0,
                  child: ClipRect(
                    child: _MarqueeLabel(
                      label: label,
                      textWidth: labelLayout.textWidth,
                      viewportWidth: labelLayout.viewportWidth,
                      style: metrics.labelStyle(palette.foreground),
                      animation: marqueeAnimation,
                    ),
                  ),
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // High-contrast outer outline
            // -----------------------------------------------------------------
            if (highContrast)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      border: Border.all(
                        color: palette.outerOutline,
                        width: metrics.highContrastOuterBorderWidth,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Status signal
// =============================================================================

/// Fixed leading semantic status signal.
///
/// Both densities retain exactly 2 dp between the outer capsule and semantic
/// circle before accessibility scaling:
///
/// ```text
/// compact:
///
/// outer  28 × 28
/// inner  24 × 24
/// inset   2 dp
///
/// standard:
///
/// outer  32 × 32
/// inner  28 × 28
/// inset   2 dp
/// ```
///
/// The outer neutral/tinted capsule is painted by [_StatusBadgeVisual].
/// This widget therefore owns only the semantic circle and status glyph.
///
/// No outline is painted around the semantic circle.
final class _StatusSignal extends StatelessWidget {
  const _StatusSignal({
    required this.type,
    required this.icon,
    required this.palette,
    required this.metrics,
    required this.animationDuration,
  });

  final CinearaStatusBadgeType type;

  final IconData icon;

  final _StatusBadgePalette palette;

  final _StatusBadgeMetrics metrics;

  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: metrics.outerDiameter,
      child: Padding(
        padding: EdgeInsets.all(metrics.statusCircleInset),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: palette.accent,
          ),
          child: _StatusGlyph(
            type: type,
            icon: icon,
            color: palette.onAccent,
            size: metrics.iconSize,
            animationDuration: animationDuration,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Status glyph
// =============================================================================

/// Cross-fades status glyphs while preserving one centred layout box.
///
/// No per-icon translation is applied. This keeps the geometry objectively
/// centred; asymmetric glyphs are left to their Material icon metrics rather
/// than introducing status-specific layout corrections.
final class _StatusGlyph extends StatelessWidget {
  const _StatusGlyph({
    required this.type,
    required this.icon,
    required this.color,
    required this.size,
    required this.animationDuration,
  });

  final CinearaStatusBadgeType type;

  final IconData icon;

  final Color color;

  final double size;

  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSwitcher(
        duration: animationDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[...previousChildren, ?currentChild],
          );
        },
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Icon(
          icon,
          key: ValueKey<CinearaStatusBadgeType>(type),
          size: size,
          color: color,
        ),
      ),
    );
  }
}

// =============================================================================
// One-shot marquee
// =============================================================================

final class _MarqueeLabel extends StatelessWidget {
  const _MarqueeLabel({
    required this.label,
    required this.textWidth,
    required this.viewportWidth,
    required this.style,
    required this.animation,
  });

  final String label;

  final double textWidth;
  final double viewportWidth;

  final TextStyle style;

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);

    final double overflowDistance = math
        .max(0, textWidth - viewportWidth)
        .toDouble();

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double travelled = overflowDistance * animation.value;

        final double horizontalOffset = textDirection == TextDirection.rtl
            ? travelled
            : -travelled;

        return Transform.translate(
          offset: Offset(horizontalOffset, 0),
          child: child,
        );
      },
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(
          width: textWidth,
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,

            // A semantic status should never become ambiguous through
            // automatic ellipsis.
            overflow: TextOverflow.visible,

            textScaler: TextScaler.noScaling,

            strutStyle: StrutStyle(
              fontSize: style.fontSize,
              height: 1,
              forceStrutHeight: true,
            ),

            style: style,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Label layout
// =============================================================================

@immutable
final class _StatusLabelLayout {
  const _StatusLabelLayout({
    required this.textWidth,
    required this.viewportWidth,
    required this.expandedWidth,
    required this.overflowDistance,
  });

  final double textWidth;

  final double viewportWidth;

  final double expandedWidth;

  final double overflowDistance;
}

// =============================================================================
// Metrics
// =============================================================================

@immutable
final class _StatusBadgeMetrics {
  const _StatusBadgeMetrics({
    required this.outerDiameter,
    required this.statusCircleDiameter,
    required this.iconSize,
    required this.fontSize,
    required this.labelGap,
    required this.trailingPadding,
    required this.maxWidth,
    required this.highContrastOuterBorderWidth,
  });

  /// Height and collapsed width of the complete badge.
  ///
  /// Compact: 28 dp.
  /// Standard: 32 dp.
  final double outerDiameter;

  /// Diameter of the semantic status circle.
  ///
  /// Compact: 24 dp.
  /// Standard: 28 dp.
  final double statusCircleDiameter;

  /// Status glyph size.
  final double iconSize;

  /// Expanded-label font size.
  final double fontSize;

  /// Space between the semantic circle and label.
  final double labelGap;

  /// Space after the label before the capsule end.
  final double trailingPadding;

  /// Maximum expanded width.
  final double maxWidth;

  /// Accessibility outline used only when high-contrast mode is enabled.
  final double highContrastOuterBorderWidth;

  /// Equal inset surrounding the semantic status circle.
  ///
  /// Compact:
  ///
  /// ```text
  /// (28 - 24) / 2 = 2
  /// ```
  ///
  /// Standard:
  ///
  /// ```text
  /// (32 - 28) / 2 = 2
  /// ```
  double get statusCircleInset => (outerDiameter - statusCircleDiameter) / 2;

  /// Exact logical position at which label content begins.
  ///
  /// The gap is measured from the semantic-circle edge.
  double get labelStart => statusCircleInset + statusCircleDiameter + labelGap;

  TextStyle labelStyle(Color color) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.05,
      height: 1,
    );
  }

  factory _StatusBadgeMetrics.resolve({
    required BuildContext context,
    required CinearaStatusBadgeDensity density,
    required double? maxWidthOverride,
  }) {
    final TextScaler scaler = MediaQuery.textScalerOf(context);

    final double rawScale = scaler.scale(12) / 12;

    // Poster overlays have finite physical space. Visual geometry therefore
    // scales conservatively while semantics remain fully available.
    final double visualScale = (1 + ((rawScale - 1) * 0.24))
        .clamp(1.0, 1.16)
        .toDouble();

    final _StatusBadgeMetrics base = switch (density) {
      CinearaStatusBadgeDensity.compact => const _StatusBadgeMetrics(
        outerDiameter: 28,

        // Only 2 dp of neutral shell remains visible around the semantic
        // circle, keeping the construction lightweight over artwork.
        statusCircleDiameter: 24,

        iconSize: 13,

        fontSize: 10.5,

        labelGap: 5,

        trailingPadding: 10,

        maxWidth: 126,

        highContrastOuterBorderWidth: 0.75,
      ),

      CinearaStatusBadgeDensity.standard => const _StatusBadgeMetrics(
        outerDiameter: 32,

        statusCircleDiameter: 28,

        iconSize: 15,

        fontSize: 11.5,

        labelGap: 6,

        trailingPadding: 12,

        maxWidth: 190,

        highContrastOuterBorderWidth: 0.85,
      ),
    };

    final double outerDiameter = base.outerDiameter * visualScale;

    final double defaultMaximum = base.maxWidth * visualScale;

    final double requestedMaximum = maxWidthOverride ?? defaultMaximum;

    return _StatusBadgeMetrics(
      outerDiameter: outerDiameter,

      statusCircleDiameter: base.statusCircleDiameter * visualScale,

      iconSize: base.iconSize * visualScale,

      fontSize: base.fontSize * visualScale,

      labelGap: base.labelGap * visualScale,

      trailingPadding: base.trailingPadding * visualScale,

      maxWidth: math.max(outerDiameter, requestedMaximum).toDouble(),

      highContrastOuterBorderWidth:
          base.highContrastOuterBorderWidth * visualScale,
    );
  }
}

// =============================================================================
// Palette
// =============================================================================

@immutable
final class _StatusBadgePalette {
  const _StatusBadgePalette({
    required this.accent,
    required this.onAccent,
    required this.surface,
    required this.foreground,
    required this.outerOutline,
  });

  /// Semantic status colour.
  final Color accent;

  /// Glyph colour rendered over [accent].
  final Color onAccent;

  /// Outer neutral/tinted capsule surface.
  final Color surface;

  /// Expanded-label colour.
  final Color foreground;

  /// Accessibility outline used only in high-contrast mode.
  final Color outerOutline;

  factory _StatusBadgePalette.resolve({
    required BuildContext context,
    required CinearaStatusBadgeVariant variant,
    required Color accent,
    required bool highContrast,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Color onAccent = CinearaColourUtils.foregroundFor(accent);

    return switch (variant) {
      // -----------------------------------------------------------------------
      // Artwork
      // -----------------------------------------------------------------------
      CinearaStatusBadgeVariant.artwork => _StatusBadgePalette(
        accent: accent,

        onAccent: onAccent,

        // Match the personal-state dock: a predominantly neutral dark
        // surface with only a restrained semantic tint.
        surface: Color.alphaBlend(
          accent.withValues(alpha: highContrast ? 0.14 : 0.08),
          Colors.black.withValues(alpha: highContrast ? 0.95 : 0.82),
        ),

        foreground: Colors.white.withValues(alpha: highContrast ? 1 : 0.96),

        outerOutline: accent.withValues(alpha: 0.78),
      ),

      // -----------------------------------------------------------------------
      // Ordinary surface
      // -----------------------------------------------------------------------
      CinearaStatusBadgeVariant.surface => _StatusBadgePalette(
        accent: accent,

        onAccent: onAccent,

        surface: Color.alphaBlend(
          accent.withValues(alpha: highContrast ? 0.14 : 0.08),
          colors.surfaceContainerHigh,
        ),

        foreground: colors.onSurface,

        outerOutline: Color.alphaBlend(
          accent.withValues(alpha: 0.70),
          colors.outlineVariant,
        ),
      ),
    };
  }
}

// =============================================================================
// Helpers
// =============================================================================

const double _minimumTouchTarget = 44;

double _lerp(double start, double end, double progress) {
  return start + ((end - start) * progress);
}
