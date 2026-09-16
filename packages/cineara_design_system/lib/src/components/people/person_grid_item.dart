import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/tokens/elevation.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/spacing.dart';
import '../media/media_status_dock.dart';

// =============================================================================
// Shared People presentation data
// =============================================================================

/// Lightweight known-for entry shared by Cineara People result components.
///
/// It mirrors the information Cineara Search already exposes without coupling
/// the design system to an application/domain model.
@immutable
final class CinearaPersonKnownForItem {
  const CinearaPersonKnownForItem({required this.title, this.year})
    : assert(title != '', 'title must not be empty.');

  final String title;
  final int? year;

  String get label {
    final int? resolvedYear = year;

    if (resolvedYear == null) {
      return title;
    }

    return '$title ($resolvedYear)';
  }
}

// =============================================================================
// Grid / rail item
// =============================================================================

/// Portrait-led Cineara person result for grids and horizontal rails.
///
/// People deliberately use circular portraits so they remain visually distinct
/// from rectangular media posters.
///
/// The complete item owns tap and long press:
///
/// ```text
/// rest
/// → circular portrait + metadata
/// → portrait sits slightly above the page through shared artwork elevation
///
/// pointer down
/// → raw portrait artwork zooms inside its fixed circular frame
/// → portrait shadow contracts toward the surface
/// → one restrained full-item pressure highlight appears
///
/// tap confirmation
/// → pressure highlight deepens slightly
/// → portrait shadow tightens further
///
/// confirmed hold
/// → light haptic on touch/stylus
/// → portrait artwork reaches 1.030 zoom
/// → artwork elevation approaches the underlying surface
/// → held pressure treatment deepens
/// → [onLongPress]
///
/// release / scroll cancel
/// → shadow and pressure treatment return smoothly to rest
/// ```
///
/// This is intentionally the same pressure language used by
/// [CinearaPersonListItem]. Grid/rail and List therefore feel like the same
/// Cineara control expressed through different geometry.
///
/// ## Optical depth
///
/// Portrait rim, shadow compensation and resting lift all come from
/// [CinearaElevation]. Small circular portraits use
/// [CinearaElevation.portraitShadows] rather than the poster-only artwork
/// shadow helper so People Grid and People List share exactly the same stronger
/// optical separation.
///
/// The existing press controller drives raw-image zoom, portrait-shadow
/// contraction and the tiny paint-only resting lift, so no second animation
/// controller is introduced.
///
/// Hover/focus may tint the centralized People portrait rim gently toward
/// primary, while ordinary press feedback continues to come from the
/// complete-item pressure treatment. The rim is painted in the foreground so
/// the clipped portrait image cannot cover it.
///
/// Reduced-motion mode keeps the resting portrait depth static.
///
/// ## Favorite
///
/// Favorite is not recreated here. The portrait embeds a real
/// [CinearaStatusDock] restricted to only
/// [CinearaStatusDockIndicator.favorite]. This means People reuse the exact
/// same Favorite icon, artwork shell, colors, high-contrast treatment and
/// structural add/remove animation as media posters.
///
/// The dock stays mounted even when Favorite is false. When [favorite] changes,
/// this wrapper calls [CinearaStatusDockController.revealChanges] after the
/// rebuilt frame so the existing dock performs its native magnetic mutation
/// animation.
///
/// The Favorite dock is passive. The whole person item owns pointer input, which
/// avoids introducing a tiny competing target inside horizontally scrolling
/// Search rails.
///
/// Feature code should apply Favorite state only once a Quick Actions surface is
/// no longer visually covering the result. That keeps the inherited dock
/// animation visible, matching media-state choreography.
final class CinearaPersonGridItem extends StatefulWidget {
  const CinearaPersonGridItem({
    required this.name,
    required this.statusDockLabels,
    super.key,
    this.image,
    this.knownForDepartment,
    this.knownFor = const <CinearaPersonKnownForItem>[],
    this.favorite = false,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.semanticHint,
    this.heroTag,
    this.heroTransitionOnUserGestures = false,
    this.showKnownFor = true,
    this.portraitSize = 88,
  }) : assert(name != '', 'name must not be empty.'),
       assert(portraitSize > 0, 'portraitSize must be greater than zero.');

  /// Display name, for example `Tom Hanks`.
  final String name;

  /// Optional profile portrait.
  ///
  /// Search can pass a [NetworkImage], while previews/tests may supply any
  /// [ImageProvider] without networking leaking into this component.
  final ImageProvider<Object>? image;

  /// Search API department, for example `Acting` or `Directing`.
  final String? knownForDepartment;

  /// Representative Search API credits.
  final List<CinearaPersonKnownForItem> knownFor;

  /// Whether the person is favorited.
  final bool favorite;

  /// Localized labels reused by the real status dock.
  ///
  /// Only [CinearaStatusDockLabels.favorite] is currently visible for People,
  /// but accepting the complete labels object keeps one localization contract.
  final CinearaStatusDockLabels statusDockLabels;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final String? semanticLabel;
  final String? semanticHint;

  /// Optional shared-element identity for the raw circular portrait.
  ///
  /// The Favorite dock remains outside the Hero so it behaves like a fixed
  /// overlay rather than flying with the artwork.
  final Object? heroTag;
  final bool heroTransitionOnUserGestures;

  final bool showKnownFor;

  /// Preferred circular portrait diameter.
  final double portraitSize;

  @override
  State<CinearaPersonGridItem> createState() => _CinearaPersonGridItemState();
}

// =============================================================================
// State
// =============================================================================

final class _CinearaPersonGridItemState extends State<CinearaPersonGridItem>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // Interaction intensity
  // ---------------------------------------------------------------------------

  static const double _pressedIntensity = 0.40;
  static const double _tapActivationIntensity = 0.62;
  static const double _maximumArtworkZoom = 0.030;

  // ---------------------------------------------------------------------------
  // Timing
  // ---------------------------------------------------------------------------

  static const Duration _pressInDuration = Duration(milliseconds: 95);
  static const Duration _tapActivationDuration = Duration(milliseconds: 88);
  static const Duration _longPressDepthDuration = Duration(milliseconds: 165);
  static const Duration _releaseDuration = Duration(milliseconds: 215);
  static const Duration _pointerUpFallbackDelay = Duration(milliseconds: 80);

  static const Duration _touchPressArmDelay = Duration(milliseconds: 85);
  static const double _visualScrollSlop = 6;

  static const Curve _interactionCurve = Curves.easeInOutCubic;

  // ---------------------------------------------------------------------------
  // Controllers / gesture state
  // ---------------------------------------------------------------------------

  late final AnimationController _pressController;
  late final CinearaStatusDockController _favoriteController;

  Timer? _pointerUpReleaseTimer;
  Timer? _pressArmTimer;

  int? _activePointer;
  Offset? _pointerDownPosition;
  PointerDeviceKind? _pointerKind;

  int _interactionGeneration = 0;

  bool _gestureEligible = false;

  bool _longPressRecognized = false;
  bool _longPressActionDispatched = false;
  bool _releaseAfterLongPressDispatch = false;

  bool _hovered = false;
  bool _focused = false;
  bool _reducedMotion = false;

  bool get _interactive {
    return widget.onTap != null || widget.onLongPress != null;
  }

  bool get _pointerIsDown => _activePointer != null;

  // ===========================================================================
  // Lifecycle
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 1,
      value: 0,
    );

    _favoriteController = CinearaStatusDockController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final MediaQueryData mediaQuery = MediaQuery.of(context);

    _reducedMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;
  }

  @override
  void didUpdateWidget(CinearaPersonGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.favorite == widget.favorite) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_favoriteController.attached) {
        return;
      }

      unawaited(
        _favoriteController.revealChanges(
          changedIndicators: const <CinearaStatusDockIndicator>{
            CinearaStatusDockIndicator.favorite,
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _interactionGeneration++;

    _pointerUpReleaseTimer?.cancel();
    _pressArmTimer?.cancel();

    _pressController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // Hover / focus
  // ===========================================================================

  void _setHovered(bool value) {
    if (_hovered == value || !mounted) {
      return;
    }

    setState(() {
      _hovered = value;
    });
  }

  void _setFocused(bool value) {
    if (_focused == value || !mounted) {
      return;
    }

    setState(() {
      _focused = value;
    });
  }

  // ===========================================================================
  // Raw pointer surface
  // ===========================================================================

  void _handlePointerDown(PointerDownEvent event) {
    if (!_interactive || _activePointer != null) {
      return;
    }

    if ((event.buttons & kPrimaryButton) == 0) {
      return;
    }

    _pointerUpReleaseTimer?.cancel();
    _pressArmTimer?.cancel();

    _activePointer = event.pointer;
    _pointerDownPosition = event.localPosition;
    _pointerKind = event.kind;

    _gestureEligible = true;

    _longPressRecognized = false;
    _longPressActionDispatched = false;
    _releaseAfterLongPressDispatch = false;

    _interactionGeneration++;

    _pressController
      ..stop()
      ..value = 0;

    if (_reducedMotion) {
      return;
    }

    final int pointer = event.pointer;

    if (_shouldDelayPressForScrolling(event.kind)) {
      _pressArmTimer = Timer(_touchPressArmDelay, () {
        if (!mounted ||
            _activePointer != pointer ||
            !_gestureEligible ||
            _longPressRecognized) {
          return;
        }

        _startPointerDownFeedback();
      });

      return;
    }

    _startPointerDownFeedback();
  }

  bool _shouldDelayPressForScrolling(PointerDeviceKind kind) {
    return switch (kind) {
      PointerDeviceKind.touch ||
      PointerDeviceKind.stylus ||
      PointerDeviceKind.invertedStylus => true,
      _ => false,
    };
  }

  void _startPointerDownFeedback() {
    if (!mounted ||
        !_gestureEligible ||
        _activePointer == null ||
        _longPressRecognized ||
        _reducedMotion) {
      return;
    }

    unawaited(
      _animatePressTo(
        _pressedIntensity,
        duration: _pressInDuration,
        curve: _interactionCurve,
      ),
    );
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_activePointer != event.pointer ||
        !_gestureEligible ||
        _longPressRecognized) {
      return;
    }

    final Offset? origin = _pointerDownPosition;

    if (origin == null) {
      return;
    }

    final double distanceSquared =
        (event.localPosition - origin).distanceSquared;

    if (distanceSquared > _visualScrollSlop * _visualScrollSlop) {
      _pressArmTimer?.cancel();

      if (_pressController.value > 0) {
        _releaseVisualFeedbackForScroll();
      }
    }

    if (distanceSquared <= kTouchSlop * kTouchSlop) {
      return;
    }

    _interactionGeneration++;

    _pressArmTimer?.cancel();

    _gestureEligible = false;

    _longPressRecognized = false;
    _longPressActionDispatched = false;
    _releaseAfterLongPressDispatch = false;

    _releaseVisualFeedbackForScroll();
  }

  void _releaseVisualFeedbackForScroll() {
    _pressController.stop();

    if (_reducedMotion) {
      _pressController.value = 0;
      return;
    }

    unawaited(
      _pressController.animateBack(
        0,
        duration: const Duration(milliseconds: 110),
        curve: _interactionCurve,
      ),
    );
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_activePointer != event.pointer) {
      return;
    }

    _activePointer = null;
    _pointerDownPosition = null;
    _pressArmTimer?.cancel();

    if (!_gestureEligible) {
      _pointerKind = null;
      return;
    }

    if (_longPressRecognized) {
      if (_longPressActionDispatched) {
        _gestureEligible = false;
        _longPressRecognized = false;
        _releaseAfterLongPressDispatch = false;
        _pointerKind = null;

        _releaseInteraction();
      } else {
        _releaseAfterLongPressDispatch = true;
      }

      return;
    }

    _schedulePointerUpFallbackRelease();
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (_activePointer != event.pointer) {
      return;
    }

    _activePointer = null;
    _pointerDownPosition = null;

    _pointerUpReleaseTimer?.cancel();
    _pressArmTimer?.cancel();

    if (!_gestureEligible) {
      _pointerKind = null;
      return;
    }

    if (_longPressRecognized && !_longPressActionDispatched) {
      _releaseAfterLongPressDispatch = true;
      return;
    }

    _interactionGeneration++;

    _gestureEligible = false;

    _longPressRecognized = false;
    _longPressActionDispatched = false;
    _releaseAfterLongPressDispatch = false;

    _pointerKind = null;

    _releaseInteraction();
  }

  void _schedulePointerUpFallbackRelease() {
    _pointerUpReleaseTimer?.cancel();

    if (_reducedMotion) {
      _gestureEligible = false;
      _pointerKind = null;
      _releaseInteraction();
      return;
    }

    _pointerUpReleaseTimer = Timer(_pointerUpFallbackDelay, () {
      if (!mounted || _longPressRecognized || _pointerIsDown) {
        return;
      }

      _gestureEligible = false;
      _pointerKind = null;

      _releaseInteraction();
    });
  }

  // ===========================================================================
  // Tap
  // ===========================================================================

  void _handleTap() {
    if (!_gestureEligible) {
      return;
    }

    _pointerUpReleaseTimer?.cancel();
    _pressArmTimer?.cancel();

    _gestureEligible = false;
    _pointerKind = null;

    final VoidCallback? callback = widget.onTap;

    if (callback == null) {
      _releaseInteraction();
      return;
    }

    unawaited(_runTapActivation(callback: callback));
  }

  void _handleTapCancel() {
    if (!_gestureEligible) {
      return;
    }

    if (_pointerIsDown || _longPressRecognized) {
      return;
    }

    _schedulePointerUpFallbackRelease();
  }

  Future<void> _runTapActivation({required VoidCallback callback}) async {
    final int generation = ++_interactionGeneration;

    if (_reducedMotion) {
      callback();
      _releaseInteraction();
      return;
    }

    final bool completed = await _animatePressTo(
      _tapActivationIntensity,
      duration: _tapActivationDuration,
      curve: _interactionCurve,
    );

    if (!completed || !mounted || generation != _interactionGeneration) {
      return;
    }

    _releaseInteraction();
    callback();
  }

  // ===========================================================================
  // Long press
  // ===========================================================================

  void _handleLongPressStart(LongPressStartDetails details) {
    if (!_gestureEligible || widget.onLongPress == null) {
      return;
    }

    _pointerUpReleaseTimer?.cancel();
    _pressArmTimer?.cancel();

    _longPressRecognized = true;
    _longPressActionDispatched = false;
    _releaseAfterLongPressDispatch = false;

    final int generation = ++_interactionGeneration;

    unawaited(_runLongPressActivation(generation: generation));
  }

  Future<void> _runLongPressActivation({required int generation}) async {
    if (_shouldEmitPointerHaptic) {
      unawaited(HapticFeedback.lightImpact());
    }

    if (_reducedMotion) {
      _pressController.value = 1;
    } else {
      final bool completed = await _animatePressTo(
        1,
        duration: _longPressDepthDuration,
        curve: _interactionCurve,
      );

      if (!completed) {
        return;
      }
    }

    if (!mounted ||
        generation != _interactionGeneration ||
        !_longPressRecognized ||
        !_gestureEligible) {
      return;
    }

    _longPressActionDispatched = true;

    widget.onLongPress?.call();

    if (_releaseAfterLongPressDispatch || !_pointerIsDown) {
      _gestureEligible = false;

      _longPressRecognized = false;
      _longPressActionDispatched = false;
      _releaseAfterLongPressDispatch = false;

      _pointerKind = null;

      _releaseInteraction();
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (!_gestureEligible || !_longPressRecognized) {
      return;
    }

    if (!_longPressActionDispatched) {
      _releaseAfterLongPressDispatch = true;
      return;
    }

    _gestureEligible = false;

    _longPressRecognized = false;
    _longPressActionDispatched = false;
    _releaseAfterLongPressDispatch = false;

    _pointerKind = null;

    _releaseInteraction();
  }

  void _handleLongPressCancel() {
    if (!_gestureEligible || !_longPressRecognized) {
      return;
    }

    _interactionGeneration++;

    _gestureEligible = false;

    _longPressRecognized = false;
    _longPressActionDispatched = false;
    _releaseAfterLongPressDispatch = false;

    _pointerKind = null;

    _releaseInteraction();
  }

  bool get _shouldEmitPointerHaptic {
    return switch (_pointerKind) {
      PointerDeviceKind.touch ||
      PointerDeviceKind.stylus ||
      PointerDeviceKind.invertedStylus => true,
      _ => false,
    };
  }

  // ===========================================================================
  // Animation helpers
  // ===========================================================================

  Future<bool> _animatePressTo(
    double value, {
    required Duration duration,
    required Curve curve,
  }) async {
    final double target = value.clamp(0.0, 1.0).toDouble();

    if (_reducedMotion) {
      _pressController
        ..stop()
        ..value = target;

      return true;
    }

    _pressController.stop();

    try {
      await _pressController
          .animateTo(target, duration: duration, curve: curve)
          .orCancel;
    } on TickerCanceled {
      return false;
    }

    return true;
  }

  void _releaseInteraction() {
    _pointerUpReleaseTimer?.cancel();
    _pressArmTimer?.cancel();

    if (_reducedMotion) {
      _pressController
        ..stop()
        ..value = 0;

      return;
    }

    _pressController.stop();

    unawaited(
      _pressController.animateBack(
        0,
        duration: _releaseDuration,
        curve: _interactionCurve,
      ),
    );
  }

  double _resolveArtworkZoom(double progress) {
    if (_reducedMotion) {
      return 1;
    }

    final double t = progress.clamp(0.0, 1.0).toDouble();

    return 1 + (_maximumArtworkZoom * t);
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    assert(
      widget.name.trim().isNotEmpty,
      'name must contain visible characters.',
    );

    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);

    final bool emphasized = _hovered || _focused;

    return Semantics(
      button: _interactive,
      label: widget.semanticLabel ?? _derivedSemanticLabel(),
      hint: widget.semanticHint,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: MouseRegion(
        cursor: _interactive ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) {
          _setHovered(true);
        },
        onExit: (_) {
          _setHovered(false);
        },
        child: Focus(
          onFocusChange: _setFocused,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: _handlePointerUp,
            onPointerCancel: _handlePointerCancel,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTap: widget.onTap == null ? null : _handleTap,
              onTapCancel: widget.onTap == null ? null : _handleTapCancel,
              onLongPressStart: widget.onLongPress == null
                  ? null
                  : _handleLongPressStart,
              onLongPressEnd: widget.onLongPress == null
                  ? null
                  : _handleLongPressEnd,
              onLongPressCancel: widget.onLongPress == null
                  ? null
                  : _handleLongPressCancel,
              child: AnimatedBuilder(
                animation: _pressController,
                builder: (BuildContext context, Widget? child) {
                  final double pressProgress = _pressController.value;

                  return LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final double availableWidth = constraints.maxWidth;

                          final double portraitSize = availableWidth.isFinite
                              ? widget.portraitSize
                                    .clamp(
                                      64.0,
                                      (availableWidth * 0.78).clamp(
                                        64.0,
                                        widget.portraitSize,
                                      ),
                                    )
                                    .toDouble()
                              : widget.portraitSize;

                          return ExcludeSemantics(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: CinearaSpacing.xxs,
                                    vertical: CinearaSpacing.xs,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      _GridPersonPortrait(
                                        image: widget.image,
                                        name: widget.name,
                                        size: portraitSize,
                                        favorite: widget.favorite,
                                        statusDockLabels:
                                            widget.statusDockLabels,
                                        favoriteController: _favoriteController,
                                        heroTag: widget.heroTag,
                                        heroTransitionOnUserGestures:
                                            widget.heroTransitionOnUserGestures,
                                        artworkZoom: _resolveArtworkZoom(
                                          pressProgress,
                                        ),

                                        // Keep optical depth static in
                                        // reduced-motion mode. Otherwise the
                                        // existing press controller contracts
                                        // the portrait shadow in sync with the
                                        // raw-image zoom.
                                        interactionProgress: _reducedMotion
                                            ? 0
                                            : pressProgress,
                                        emphasized: emphasized,
                                      ),
                                      const SizedBox(height: CinearaSpacing.xs),
                                      Text(
                                        widget.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: emphasized
                                                  ? Color.lerp(
                                                      colors.onSurface,
                                                      colors.primary,
                                                      0.10,
                                                    )
                                                  : colors.onSurface,
                                              fontWeight: FontWeight.w700,
                                              height: 1.16,
                                            ),
                                      ),
                                      if (_hasDepartment) ...<Widget>[
                                        const SizedBox(
                                          height: CinearaSpacing.xxs,
                                        ),
                                        Text(
                                          widget.knownForDepartment!.trim(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                color: colors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                      if (_visibleKnownFor(
                                        2,
                                      ).isNotEmpty) ...<Widget>[
                                        const SizedBox(
                                          height: CinearaSpacing.xxs,
                                        ),
                                        Text(
                                          _knownForLabel(maxItems: 2),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: colors.onSurfaceVariant,
                                                height: 1.20,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Same complete-item pressure language as the
                                // focused People List item.
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: _GridPersonPressPainter(
                                        progress: pressProgress,
                                        colorScheme: colors,
                                        brightness: theme.brightness,
                                        highContrast: highContrast,
                                        longPressRecognized:
                                            _longPressRecognized,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Content helpers
  // ===========================================================================

  bool get _hasDepartment {
    return widget.knownForDepartment != null &&
        widget.knownForDepartment!.trim().isNotEmpty;
  }

  List<CinearaPersonKnownForItem> _visibleKnownFor(int maxItems) {
    if (!widget.showKnownFor || widget.knownFor.isEmpty) {
      return const <CinearaPersonKnownForItem>[];
    }

    return widget.knownFor.take(maxItems).toList(growable: false);
  }

  String _knownForLabel({required int maxItems}) {
    return _visibleKnownFor(
      maxItems,
    ).map((CinearaPersonKnownForItem item) => item.label).join(' · ');
  }

  String _derivedSemanticLabel() {
    final List<String> parts = <String>[widget.name.trim()];

    if (_hasDepartment) {
      parts.add(widget.knownForDepartment!.trim());
    }

    final List<CinearaPersonKnownForItem> semanticKnownFor = _visibleKnownFor(
      3,
    );

    if (semanticKnownFor.isNotEmpty) {
      parts.add(
        semanticKnownFor
            .map((CinearaPersonKnownForItem item) => item.label)
            .join(', '),
      );
    }

    if (widget.favorite) {
      parts.add(widget.statusDockLabels.favorite);
    }

    return parts.join('. ');
  }
}

// =============================================================================
// Portrait
// =============================================================================

final class _GridPersonPortrait extends StatelessWidget {
  const _GridPersonPortrait({
    required this.image,
    required this.name,
    required this.size,
    required this.favorite,
    required this.statusDockLabels,
    required this.favoriteController,
    required this.heroTag,
    required this.heroTransitionOnUserGestures,
    required this.artworkZoom,
    required this.interactionProgress,
    required this.emphasized,
  });

  final ImageProvider<Object>? image;
  final String name;
  final double size;

  final bool favorite;
  final CinearaStatusDockLabels statusDockLabels;
  final CinearaStatusDockController favoriteController;

  final Object? heroTag;
  final bool heroTransitionOnUserGestures;

  /// Raw image zoom inside the fixed circular portrait frame.
  final double artworkZoom;

  /// Complete-item interaction depth in the range `0..1`.
  ///
  /// This controls optical depth: portrait-shadow contraction and the tiny
  /// paint-only resting lift. It does not change layout geometry.
  final double interactionProgress;

  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final double depth = 1 - interactionProgress.clamp(0.0, 1.0).toDouble();

    final Color borderColor = CinearaElevation.portraitRimColorForState(
      context,
      emphasized: emphasized,
    );

    final double borderWidth = CinearaElevation.portraitRimWidth(context);

    Widget circle = DecoratedBox(
      // The rim must paint ABOVE the clipped photo. With the default
      // DecorationPosition.background the full-size ClipOval child can cover
      // most of a thin circular border, making the rim appear absent.
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: CinearaElevation.portraitShadows(
          context,
          interactionProgress: interactionProgress,
        ),
      ),
      child: ClipOval(
        child: ClipRect(
          child: Transform.scale(
            scale: artworkZoom,
            alignment: Alignment.center,
            child: image == null
                ? _GridPersonFallback(name: name)
                : Image(
                    image: image!,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return _GridPersonFallback(name: name);
                        },
                  ),
          ),
        ),
      ),
    );

    final Object? resolvedHeroTag = heroTag;

    if (resolvedHeroTag != null) {
      circle = Hero(
        tag: resolvedHeroTag,
        transitionOnUserGestures: heroTransitionOnUserGestures,
        child: circle,
      );
    }

    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // Apply the centralized paint-only People portrait lift.
          //
          // Item geometry remains unchanged. As interaction deepens, the
          // portrait settles toward its normal position while the centralized
          // portrait shadow contracts.
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(0, -CinearaElevation.portraitRestingLift * depth),
              child: circle,
            ),
          ),

          // Keep the real dock mounted in both true and false Favorite states.
          // Its own mutation engine therefore has the before/after structure
          // required for the exact media-poster Favorite animation.
          //
          // The dock deliberately remains outside the portrait depth
          // transform: shadow/rim/lift describe the artwork layer, while the
          // Favorite node remains crisp and anchored to the item geometry.
          PositionedDirectional(
            end: -1,
            bottom: -1,
            child: IgnorePointer(
              child: CinearaStatusDock(
                controller: favoriteController,
                labels: statusDockLabels,
                favorite: favorite,
                visibleIndicators: const <CinearaStatusDockIndicator>{
                  CinearaStatusDockIndicator.favorite,
                },
                mode: CinearaStatusDockMode.permanent,
                variant: CinearaStatusDockVariant.artwork,
                density: CinearaStatusDockDensity.compact,
                layout: CinearaStatusDockLayout.vertical,
                side: CinearaStatusDockSide.end,
                tapToExpand: false,
                autoCollapse: false,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _GridPersonFallback extends StatelessWidget {
  const _GridPersonFallback({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surfaceContainerHigh,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 36,
          color: colors.primary.withValues(alpha: 0.78),
          semanticLabel: name,
        ),
      ),
    );
  }
}

// =============================================================================
// Complete-item pressure treatment
// =============================================================================

final class _GridPersonPressPainter extends CustomPainter {
  const _GridPersonPressPainter({
    required this.progress,
    required this.colorScheme,
    required this.brightness,
    required this.highContrast,
    required this.longPressRecognized,
  });

  final double progress;
  final ColorScheme colorScheme;
  final Brightness brightness;
  final bool highContrast;
  final bool longPressRecognized;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || progress <= 0) {
      return;
    }

    final double t = progress.clamp(0.0, 1.0).toDouble();

    final RRect tile = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(CinearaRadii.lg),
    );

    final double fillOpacity = _resolveFillOpacity(t);

    final Color flushColor = brightness == Brightness.dark
        ? Color.lerp(
            colorScheme.surfaceContainerHighest,
            colorScheme.primary,
            0.30,
          )!
        : Color.lerp(
            colorScheme.surfaceContainerHighest,
            colorScheme.primary,
            0.18,
          )!;

    final Paint flushPaint = Paint()
      ..color = flushColor.withValues(
        alpha: fillOpacity * (highContrast ? 1.12 : 1),
      );

    canvas.drawRRect(tile, flushPaint);

    final double edgeOpacity = _resolveEdgeOpacity(t);

    if (edgeOpacity > 0) {
      final Paint innerEdgePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = highContrast ? 1.25 : 0.85
        ..color = colorScheme.primary.withValues(alpha: edgeOpacity);

      canvas.drawRRect(
        tile.deflate(highContrast ? 0.80 : 0.55),
        innerEdgePaint,
      );
    }

    if (!longPressRecognized) {
      return;
    }

    final double hold = ((t - 0.62) / 0.38).clamp(0.0, 1.0).toDouble();

    final double holdEase = Curves.easeInOutCubic.transform(hold);

    final double tonalOpacity = (highContrast ? 0.060 : 0.034) * holdEase;

    final Paint holdTonePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.white.withValues(alpha: tonalOpacity * 0.36),
          Colors.transparent,
          Colors.black.withValues(alpha: tonalOpacity),
        ],
        stops: const <double>[0, 0.48, 1],
      ).createShader(Offset.zero & size);

    canvas.drawRRect(tile, holdTonePaint);

    final Paint lowerInsetPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = highContrast ? 1.30 : 0.95
      ..color = Colors.black.withValues(
        alpha: (highContrast ? 0.095 : 0.055) * holdEase,
      );

    final double safeRadius = CinearaRadii.lg.clamp(0.0, size.width / 2);

    final Path lowerEdge = Path()
      ..moveTo(safeRadius + 2, size.height - 1.2)
      ..lineTo(size.width - safeRadius - 2, size.height - 1.2);

    canvas.drawPath(lowerEdge, lowerInsetPaint);
  }

  double _resolveFillOpacity(double progress) {
    if (progress <= 0.40) {
      final double local = (progress / 0.40).clamp(0.0, 1.0).toDouble();

      return ui.lerpDouble(
        0,
        highContrast ? 0.070 : 0.044,
        Curves.easeInOutCubic.transform(local),
      )!;
    }

    if (progress <= 0.62) {
      final double local = ((progress - 0.40) / 0.22)
          .clamp(0.0, 1.0)
          .toDouble();

      return ui.lerpDouble(
        highContrast ? 0.070 : 0.044,
        highContrast ? 0.100 : 0.066,
        Curves.easeInOutCubic.transform(local),
      )!;
    }

    final double local = ((progress - 0.62) / 0.38).clamp(0.0, 1.0).toDouble();

    return ui.lerpDouble(
      highContrast ? 0.100 : 0.066,
      highContrast ? 0.145 : 0.098,
      Curves.easeInOutCubic.transform(local),
    )!;
  }

  double _resolveEdgeOpacity(double progress) {
    if (progress <= 0.18) {
      return 0;
    }

    final double local = ((progress - 0.18) / 0.82).clamp(0.0, 1.0).toDouble();

    final double maxOpacity = longPressRecognized
        ? (highContrast ? 0.28 : 0.16)
        : (highContrast ? 0.17 : 0.085);

    return maxOpacity * Curves.easeInOutCubic.transform(local);
  }

  @override
  bool shouldRepaint(covariant _GridPersonPressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.brightness != brightness ||
        oldDelegate.highContrast != highContrast ||
        oldDelegate.longPressRecognized != longPressRecognized;
  }
}
