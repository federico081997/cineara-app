import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/tokens/elevation.dart';
import '../../foundations/tokens/radius.dart';
import '../badges/external_rating_badge.dart';
import '../badges/status_badge.dart';
import 'media_metadata.dart';
import 'media_poster_overlay.dart';
import 'media_progress_indicator.dart';
import 'media_status_dock.dart';

// =============================================================================
// Public API
// =============================================================================

/// Editorial Cineara media row extracted from the approved Search preview.
///
/// This component owns one *media-shaped* row. It does not own the surrounding
/// list, separators, pagination, query state, or feature-specific data model.
///
/// The generic [CinearaMediaList] container may host this component or any
/// completely different tile type.
///
/// Final interaction language:
///
/// ```text
/// rest
/// → cardless editorial row
/// → poster sits slightly above the page through shared artwork elevation
///
/// pointer down
/// → raw artwork zooms inside a fixed poster frame
/// → poster shadow contracts toward the surface
/// → one restrained full-row pressure surface appears
///
/// tap confirmation
/// → row pressure deepens slightly
/// → poster shadow tightens further
/// → chevron moves toward destination and blends to primary
///
/// confirmed hold
/// → light haptic
/// → artwork reaches 1.030 zoom
/// → artwork elevation approaches the underlying surface
/// → deeper full-row held treatment
/// → quick-action callback
/// ```
///
/// The poster frame, rating, progress, metadata, lifecycle state, personal dock,
/// and row geometry never scale or translate.
///
/// Only the raw artwork zooms. The poster's optical depth changes independently
/// through [CinearaElevation.artworkShadows].
///
/// The progress indicator is painted above the artwork rim so the progress edge
/// visually owns the physical bottom boundary instead of exposing a second rim
/// line beneath it.
///
/// Accessibility text may make the row taller than the poster. The poster stays
/// top-aligned and the chevron remains anchored to the poster's vertical center.
final class CinearaMediaListItem extends StatefulWidget {
  const CinearaMediaListItem({
    required this.artwork,
    required this.title,
    required this.descriptor,
    required this.onTap,
    super.key,
    this.year,
    this.primaryGenre,
    this.externalRatingBadge,
    this.progressIndicator,
    this.lifecycleStatus,
    this.personalDock,
    this.onLongPress,
    this.semanticHint,
    this.posterWidth = defaultPosterWidth,
  }) : assert(posterWidth > 0, 'posterWidth must be greater than zero.');

  // ---------------------------------------------------------------------------
  // Canonical geometry
  // ---------------------------------------------------------------------------

  static const double defaultPosterWidth = 84;
  static const double defaultPosterHeight = defaultPosterWidth * 1.5;

  /// Uniform inset between the temporary pressed silhouette and row content.
  static const double tileInset = 8;

  static const double posterToMetadataGap = 14;

  static const double chevronLeadGap = 10;
  static const double chevronWidth = 36;
  static const double chevronTrailingGap = 2;

  /// Separator start used by Search when this row is placed inside
  /// [CinearaMediaList].
  ///
  /// The generic List container does not assume this inset automatically.
  static const double defaultMetadataRailInset =
      tileInset + defaultPosterWidth + posterToMetadataGap;

  final Widget artwork;

  final String title;
  final String descriptor;
  final int? year;
  final String? primaryGenre;

  /// Passive external/public rating painted at logical poster top-start.
  ///
  /// List intentionally differs from Grid here: status has moved out of the
  /// poster, so the external rating owns the poster's top-start position.
  final CinearaExternalRatingBadge? externalRatingBadge;

  /// Poster-edge viewing progress.
  final CinearaMediaProgressIndicator? progressIndicator;

  /// Optional lifecycle state shown in the metadata/state row.
  ///
  /// Search should configure this as a non-expanding surface badge, matching the
  /// preview (`expandOnTap: false`, `autoCollapse: false`).
  final CinearaStatusBadge? lifecycleStatus;

  /// Optional horizontal personal-state dock.
  ///
  /// Compact mode is treated as its own interactive control and is protected
  /// from the surrounding row's raw-pointer press choreography.
  final CinearaStatusDock? personalDock;

  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// Localized semantics hint.
  final String? semanticHint;

  final double posterWidth;

  double get posterHeight => posterWidth * 1.5;

  @override
  State<CinearaMediaListItem> createState() => _CinearaMediaListItemState();
}

// =============================================================================
// State
// =============================================================================

final class _CinearaMediaListItemState extends State<CinearaMediaListItem>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // Interaction intensity
  // ---------------------------------------------------------------------------

  static const double _pressedIntensity = 0.40;
  static const double _tapActivationIntensity = 0.62;

  /// Full confirmed hold reaches 1.030.
  static const double _maximumArtworkZoom = 0.030;

  // ---------------------------------------------------------------------------
  // Timing
  // ---------------------------------------------------------------------------

  static const Duration _pressInDuration = Duration(milliseconds: 95);
  static const Duration _tapActivationDuration = Duration(milliseconds: 88);
  static const Duration _longPressDepthDuration = Duration(milliseconds: 165);
  static const Duration _releaseDuration = Duration(milliseconds: 215);
  static const Duration _pointerUpFallbackDelay = Duration(milliseconds: 80);

  /// Shared motion curve for pointer-down, tap confirmation, hold depth and
  /// release. Zero-velocity endpoints make the phase changes feel continuous.
  static const Curve _interactionCurve = Curves.easeInOutCubic;

  /// Touch/stylus press feedback is armed briefly so normal scrolling does not
  /// make rows flash as though they were tapped.
  static const Duration _touchPressArmDelay = Duration(milliseconds: 85);

  /// Visual press abandons earlier than Flutter's normal tap slop.
  static const double _visualScrollSlop = 6;

  // ---------------------------------------------------------------------------
  // Controllers / gesture state
  // ---------------------------------------------------------------------------

  late final AnimationController _pressController;

  final GlobalKey _personalDockKey = GlobalKey();

  Timer? _pointerUpReleaseTimer;
  Timer? _pressArmTimer;

  int? _activeSurfacePointer;
  Offset? _surfacePointerDownPosition;
  PointerDeviceKind? _surfacePointerKind;

  int _interactionGeneration = 0;

  bool _surfaceGestureEligible = false;

  bool _longPressRecognized = false;
  bool _longPressActionDispatched = false;
  bool _releaseAfterLongPressDispatch = false;

  bool _hovered = false;
  bool _focused = false;
  bool _reducedMotion = false;

  // ===========================================================================
  // Derived state
  // ===========================================================================

  bool get _hasLifecycleStatus => widget.lifecycleStatus != null;

  bool get _dockEnabled => widget.personalDock != null;

  bool get _hasPersonalState {
    final CinearaStatusDock? dock = widget.personalDock;

    if (dock == null) {
      return false;
    }

    final Set<CinearaStatusDockIndicator> visible = dock.visibleIndicators;

    final bool hasRating =
        visible.contains(CinearaStatusDockIndicator.rating) &&
        dock.personalRating != null;

    final bool hasWatchlist =
        visible.contains(CinearaStatusDockIndicator.watchlist) &&
        dock.watchlist;

    final bool hasFavorite =
        visible.contains(CinearaStatusDockIndicator.favorite) && dock.favorite;

    final bool hasCollection =
        visible.contains(CinearaStatusDockIndicator.collection) &&
        dock.collection;

    return hasRating || hasWatchlist || hasFavorite || hasCollection;
  }

  bool get _hasStateLine {
    return _hasLifecycleStatus || (_dockEnabled && _hasPersonalState);
  }

  bool get _surfacePointerIsDown => _activeSurfacePointer != null;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final MediaQueryData mediaQuery = MediaQuery.of(context);

    _reducedMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;
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

  void _handleSurfacePointerDown(PointerDownEvent event) {
    if (_activeSurfacePointer != null) {
      return;
    }

    if ((event.buttons & kPrimaryButton) == 0) {
      return;
    }

    // A compact personal-state dock is its own control. Starting there must not
    // begin the media-row press choreography.
    if (_isInteractiveDockHit(event.position)) {
      return;
    }

    _pointerUpReleaseTimer?.cancel();
    _pressArmTimer?.cancel();

    _activeSurfacePointer = event.pointer;
    _surfacePointerDownPosition = event.localPosition;
    _surfacePointerKind = event.kind;

    _surfaceGestureEligible = true;

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
            _activeSurfacePointer != pointer ||
            !_surfaceGestureEligible ||
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
        !_surfaceGestureEligible ||
        _activeSurfacePointer == null ||
        _longPressRecognized) {
      return;
    }

    if (_reducedMotion) {
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

  void _handleSurfacePointerMove(PointerMoveEvent event) {
    if (_activeSurfacePointer != event.pointer ||
        !_surfaceGestureEligible ||
        _longPressRecognized) {
      return;
    }

    final Offset? origin = _surfacePointerDownPosition;

    if (origin == null) {
      return;
    }

    final Offset delta = event.localPosition - origin;
    final double distanceSquared = delta.distanceSquared;

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

    _surfaceGestureEligible = false;

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

  void _handleSurfacePointerUp(PointerUpEvent event) {
    if (_activeSurfacePointer != event.pointer) {
      return;
    }

    _activeSurfacePointer = null;
    _surfacePointerDownPosition = null;
    _pressArmTimer?.cancel();

    if (!_surfaceGestureEligible) {
      _surfacePointerKind = null;
      return;
    }

    if (_longPressRecognized) {
      if (_longPressActionDispatched) {
        _surfaceGestureEligible = false;
        _longPressRecognized = false;
        _releaseAfterLongPressDispatch = false;
        _surfacePointerKind = null;

        _releaseInteraction();
      } else {
        _releaseAfterLongPressDispatch = true;
      }

      return;
    }

    _schedulePointerUpFallbackRelease();
  }

  void _handleSurfacePointerCancel(PointerCancelEvent event) {
    if (_activeSurfacePointer != event.pointer) {
      return;
    }

    _activeSurfacePointer = null;
    _surfacePointerDownPosition = null;

    _pointerUpReleaseTimer?.cancel();
    _pressArmTimer?.cancel();

    if (!_surfaceGestureEligible) {
      _surfacePointerKind = null;
      return;
    }

    if (_longPressRecognized && !_longPressActionDispatched) {
      _releaseAfterLongPressDispatch = true;
      return;
    }

    _interactionGeneration++;

    _surfaceGestureEligible = false;

    _longPressRecognized = false;
    _longPressActionDispatched = false;
    _releaseAfterLongPressDispatch = false;

    _surfacePointerKind = null;

    _releaseInteraction();
  }

  bool _isInteractiveDockHit(Offset globalPosition) {
    final CinearaStatusDock? dock = widget.personalDock;

    if (dock == null ||
        dock.mode != CinearaStatusDockMode.compact ||
        !_hasPersonalState) {
      return false;
    }

    final BuildContext? dockContext = _personalDockKey.currentContext;

    if (dockContext == null) {
      return false;
    }

    final RenderObject? renderObject = dockContext.findRenderObject();

    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      return false;
    }

    final Offset local = renderObject.globalToLocal(globalPosition);

    return (Offset.zero & renderObject.size).contains(local);
  }

  void _schedulePointerUpFallbackRelease() {
    _pointerUpReleaseTimer?.cancel();

    if (_reducedMotion) {
      _surfaceGestureEligible = false;
      _surfacePointerKind = null;
      _releaseInteraction();
      return;
    }

    _pointerUpReleaseTimer = Timer(_pointerUpFallbackDelay, () {
      if (!mounted || _longPressRecognized || _surfacePointerIsDown) {
        return;
      }

      _surfaceGestureEligible = false;
      _surfacePointerKind = null;

      _releaseInteraction();
    });
  }

  // ===========================================================================
  // Tap
  // ===========================================================================

  void _handleTap() {
    if (!_surfaceGestureEligible) {
      return;
    }

    _pointerUpReleaseTimer?.cancel();
    _pressArmTimer?.cancel();

    _surfaceGestureEligible = false;
    _surfacePointerKind = null;

    unawaited(_runTapActivation(callback: widget.onTap));
  }

  void _handleTapCancel() {
    if (!_surfaceGestureEligible) {
      return;
    }

    if (_surfacePointerIsDown || _longPressRecognized) {
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
    if (!_surfaceGestureEligible || widget.onLongPress == null) {
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
        !_surfaceGestureEligible) {
      return;
    }

    _longPressActionDispatched = true;

    widget.onLongPress?.call();

    if (_releaseAfterLongPressDispatch || !_surfacePointerIsDown) {
      _surfaceGestureEligible = false;

      _longPressRecognized = false;
      _longPressActionDispatched = false;
      _releaseAfterLongPressDispatch = false;

      _surfacePointerKind = null;

      _releaseInteraction();
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (!_surfaceGestureEligible || !_longPressRecognized) {
      return;
    }

    if (!_longPressActionDispatched) {
      _releaseAfterLongPressDispatch = true;
      return;
    }

    _surfaceGestureEligible = false;

    _longPressRecognized = false;
    _longPressActionDispatched = false;
    _releaseAfterLongPressDispatch = false;

    _surfacePointerKind = null;

    _releaseInteraction();
  }

  void _handleLongPressCancel() {
    if (!_surfaceGestureEligible || !_longPressRecognized) {
      return;
    }

    _interactionGeneration++;

    _surfaceGestureEligible = false;

    _longPressRecognized = false;
    _longPressActionDispatched = false;
    _releaseAfterLongPressDispatch = false;

    _surfacePointerKind = null;

    _releaseInteraction();
  }

  bool get _shouldEmitPointerHaptic {
    return switch (_surfacePointerKind) {
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

  // ===========================================================================
  // Visual interpolation
  // ===========================================================================

  double _resolveArtworkZoom(double progress) {
    if (_reducedMotion) {
      return 1;
    }

    final double t = progress.clamp(0.0, 1.0).toDouble();

    return 1 + (_maximumArtworkZoom * t);
  }

  double _resolveNavigationCueProgress(double progress) {
    if (_reducedMotion) {
      return 0;
    }

    final double t = progress.clamp(0.0, 1.0).toDouble();

    // Pointer-down should suggest navigation without making the chevron jump
    // most of the way to its destination immediately. Tap confirmation then
    // completes the remaining travel. Long press never moves it farther.
    if (t <= _pressedIntensity) {
      final double local = (t / _pressedIntensity).clamp(0.0, 1.0).toDouble();

      return ui.lerpDouble(0, 0.45, local)!;
    }

    if (t <= _tapActivationIntensity) {
      final double local =
          ((t - _pressedIntensity) /
                  (_tapActivationIntensity - _pressedIntensity))
              .clamp(0.0, 1.0)
              .toDouble();

      return ui.lerpDouble(0.45, 1, local)!;
    }

    return 1;
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final bool emphasized = _hovered || _focused;
    final bool highContrast = MediaQuery.highContrastOf(context);

    final String descriptorLine = widget.year == null
        ? widget.descriptor
        : '${widget.descriptor} · ${widget.year}';

    return Semantics(
      button: true,
      label: widget.title,
      value: <String>[
        descriptorLine,
        if (_normalizedPrimaryGenre case final String genre) genre,
      ].join(', '),
      hint: widget.semanticHint,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
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
            onPointerDown: _handleSurfacePointerDown,
            onPointerMove: _handleSurfacePointerMove,
            onPointerUp: _handleSurfacePointerUp,
            onPointerCancel: _handleSurfacePointerCancel,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTap: _handleTap,
              onTapCancel: _handleTapCancel,
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

                  return Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(
                          CinearaMediaListItem.tileInset,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: widget.posterWidth,
                              child: _ListInteractivePosterVisual(
                                artwork: widget.artwork,
                                externalRatingBadge: widget.externalRatingBadge,
                                progressIndicator: widget.progressIndicator,
                                artworkZoom: _resolveArtworkZoom(pressProgress),

                                // The row keeps geometry fixed. Only optical
                                // depth contracts with the row interaction.
                                interactionProgress: _reducedMotion
                                    ? 0
                                    : pressProgress,
                              ),
                            ),
                            const SizedBox(
                              width: CinearaMediaListItem.posterToMetadataGap,
                            ),
                            Expanded(
                              child: _ListContent(
                                title: widget.title,
                                descriptor: widget.descriptor,
                                year: widget.year,
                                primaryGenre: _normalizedPrimaryGenre,
                                minimumHeight: widget.posterHeight,
                                hasStateLine: _hasStateLine,
                                hasPersonalState: _hasPersonalState,
                                dockEnabled: _dockEnabled,
                                reducedMotion: _reducedMotion,
                                lifecycleStatus: widget.lifecycleStatus,
                                personalDock: widget.personalDock == null
                                    ? null
                                    : KeyedSubtree(
                                        key: _personalDockKey,
                                        child: widget.personalDock!,
                                      ),
                              ),
                            ),
                            const SizedBox(
                              width: CinearaMediaListItem.chevronLeadGap,
                            ),

                            // The navigation affordance is anchored to the
                            // poster's vertical center, not the total row
                            // height. Large accessibility text may grow the row
                            // below this stable media anchor.
                            SizedBox(
                              height: widget.posterHeight,
                              child: Center(
                                child: _AnimatedListChevron(
                                  emphasized: emphasized,
                                  interactionProgress:
                                      _resolveNavigationCueProgress(
                                        pressProgress,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: CinearaMediaListItem.chevronTrailingGap,
                            ),
                          ],
                        ),
                      ),

                      // Paint-only complete-tile press surface.
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _ListTilePressPainter(
                              progress: pressProgress,
                              colorScheme: colors,
                              brightness: theme.brightness,
                              highContrast: highContrast,
                              longPressRecognized: _longPressRecognized,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? get _normalizedPrimaryGenre {
    final String? value = widget.primaryGenre?.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }
}

// =============================================================================
// Poster interaction visual
// =============================================================================

/// Fixed List poster frame.
///
/// Unlike Grid/rail posters, the List row owns the gesture choreography. This
/// visual therefore does not use [CinearaMediaPoster]: doing so would create an
/// independent poster interaction/elevation controller that could not follow
/// the row's press progress.
///
/// Instead this fixed frame directly reuses Cineara's shared:
///
/// - 2:3 geometry;
/// - `CinearaRadii.md` poster radius;
/// - [CinearaElevation.artworkShadows];
/// - artwork rim;
/// - [CinearaMediaPosterOverlay].
///
/// The raw artwork may zoom internally, but the frame, rim, external rating and
/// progress indicator remain physically fixed.
final class _ListInteractivePosterVisual extends StatelessWidget {
  const _ListInteractivePosterVisual({
    required this.artwork,
    required this.externalRatingBadge,
    required this.progressIndicator,
    required this.artworkZoom,
    required this.interactionProgress,
  });

  static const BorderRadius _borderRadius = BorderRadius.all(
    Radius.circular(CinearaRadii.md),
  );

  final Widget artwork;
  final CinearaExternalRatingBadge? externalRatingBadge;
  final CinearaMediaProgressIndicator? progressIndicator;

  /// Raw artwork zoom inside the fixed poster frame.
  final double artworkZoom;

  /// Row interaction depth in the range `0..1`.
  ///
  /// Reduced-motion mode passes zero so optical elevation remains static.
  final double interactionProgress;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 2 / 3,
      child: DecoratedBox(
        // Shadow lives outside every artwork clip.
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          boxShadow: CinearaElevation.artworkShadows(
            context,
            interactionProgress: interactionProgress,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            // -----------------------------------------------------------------
            // Fixed artwork frame
            //
            // The rim is a foreground decoration so artwork cannot cover it.
            // -----------------------------------------------------------------
            Positioned.fill(
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  borderRadius: _borderRadius,
                  border: Border.all(
                    color: CinearaElevation.artworkRimColor(context),
                    width: CinearaElevation.artworkRimWidth(context),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: _borderRadius,
                  clipBehavior: Clip.antiAlias,
                  child: ColoredBox(
                    color: colors.surfaceContainerHighest,
                    child: _ListPosterArtwork(
                      artwork: artwork,
                      externalRatingBadge: externalRatingBadge,
                      artworkZoom: artworkZoom,
                    ),
                  ),
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // Poster-edge progress
            //
            // This overlay is intentionally painted AFTER the rimmed artwork
            // frame. Progress therefore visually replaces the bottom rim
            // instead of allowing the rim to show as another line underneath.
            // -----------------------------------------------------------------
            if (progressIndicator != null)
              Positioned.fill(
                child: CinearaMediaPosterOverlay(
                  statusBadge: null,
                  externalRatingBadge: null,
                  statusDock: null,
                  progressIndicator: progressIndicator,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

final class _ListPosterArtwork extends StatelessWidget {
  const _ListPosterArtwork({
    required this.artwork,
    required this.externalRatingBadge,
    required this.artworkZoom,
  });

  final Widget artwork;
  final CinearaExternalRatingBadge? externalRatingBadge;
  final double artworkZoom;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ClipRect(
          child: Transform.scale(
            scale: artworkZoom,
            alignment: Alignment.center,
            child: artwork,
          ),
        ),

        // Rating is fixed relative to the poster frame and never participates
        // in the raw-artwork zoom.
        if (externalRatingBadge != null)
          PositionedDirectional(
            start: 7,
            top: 7,
            child: IgnorePointer(child: externalRatingBadge!),
          ),
      ],
    );
  }
}

// =============================================================================
// Complete-tile press surface
// =============================================================================

final class _ListTilePressPainter extends CustomPainter {
  const _ListTilePressPainter({
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
      const Radius.circular(CinearaRadii.md + CinearaMediaListItem.tileInset),
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

    const double tileRadius = CinearaRadii.md + CinearaMediaListItem.tileInset;

    final Path lowerEdge = Path()
      ..moveTo(tileRadius + 2, size.height - 1.2)
      ..lineTo(size.width - tileRadius - 2, size.height - 1.2);

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
  bool shouldRepaint(covariant _ListTilePressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.brightness != brightness ||
        oldDelegate.highContrast != highContrast ||
        oldDelegate.longPressRecognized != longPressRecognized;
  }
}

// =============================================================================
// Adaptive metadata/state composition
// =============================================================================

final class _ListContent extends StatelessWidget {
  const _ListContent({
    required this.title,
    required this.descriptor,
    required this.year,
    required this.primaryGenre,
    required this.minimumHeight,
    required this.hasStateLine,
    required this.hasPersonalState,
    required this.dockEnabled,
    required this.reducedMotion,
    required this.lifecycleStatus,
    required this.personalDock,
  });

  static const double _activeMetadataTop = 10;
  static const double _metadataToStateGap = 8;
  static const double _stateLineHeight = 42;
  static const double _minimumBottomPadding = 4;
  static const double _noStateVerticalPadding = 8;

  final String title;
  final String descriptor;
  final int? year;
  final String? primaryGenre;

  final double minimumHeight;

  final bool hasStateLine;
  final bool hasPersonalState;
  final bool dockEnabled;
  final bool reducedMotion;

  final Widget? lifecycleStatus;
  final Widget? personalDock;

  Duration get _layoutDuration {
    return reducedMotion ? Duration.zero : const Duration(milliseconds: 340);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        final double metadataHeight = CinearaMediaMetadata.measureListHeight(
          context,
          title: title,
          descriptor: descriptor,
          year: year,
          primaryGenre: primaryGenre,
          maxWidth: availableWidth,
        );

        final double noStateHeight = math.max(
          minimumHeight,
          metadataHeight + (_noStateVerticalPadding * 2),
        );

        final double centeredMetadataTop = math.max(
          _noStateVerticalPadding,
          (noStateHeight - metadataHeight) / 2,
        );

        final double stateTop =
            _activeMetadataTop + metadataHeight + _metadataToStateGap;

        final double stateHeight = math.max(
          minimumHeight,
          stateTop + _stateLineHeight + _minimumBottomPadding,
        );

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: hasStateLine ? 1 : 0),
          duration: _layoutDuration,
          curve: Curves.easeInOutCubic,
          builder: (BuildContext context, double progress, Widget? child) {
            final double metadataTop = ui.lerpDouble(
              centeredMetadataTop,
              _activeMetadataTop,
              progress,
            )!;

            final double animatedHeight = ui.lerpDouble(
              noStateHeight,
              stateHeight,
              progress,
            )!;

            final double animatedStateTop =
                metadataTop + metadataHeight + _metadataToStateGap;

            return SizedBox(
              height: animatedHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  PositionedDirectional(
                    start: 0,
                    end: 0,
                    top: metadataTop,
                    child: CinearaMediaMetadata.list(
                      title: title,
                      descriptor: descriptor,
                      year: year,
                      primaryGenre: primaryGenre,
                    ),
                  ),
                  PositionedDirectional(
                    start: 0,
                    top: animatedStateTop,
                    child: IgnorePointer(
                      ignoring: !hasStateLine,
                      child: Opacity(
                        opacity: progress,
                        child: Transform.translate(
                          offset: Offset(0, (1 - progress) * 5),
                          child: SizedBox(
                            height: _stateLineHeight,
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  _AnimatedLifecycleStatus(
                                    status: lifecycleStatus,
                                    hasTrailingDock:
                                        dockEnabled && hasPersonalState,
                                    reducedMotion: reducedMotion,
                                  ),
                                  if (personalDock case final Widget dock) dock,
                                ],
                              ),
                            ),
                          ),
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
    );
  }
}

// =============================================================================
// Lifecycle status transition
// =============================================================================

final class _AnimatedLifecycleStatus extends StatefulWidget {
  const _AnimatedLifecycleStatus({
    required this.status,
    required this.hasTrailingDock,
    required this.reducedMotion,
  });

  final Widget? status;
  final bool hasTrailingDock;
  final bool reducedMotion;

  @override
  State<_AnimatedLifecycleStatus> createState() =>
      _AnimatedLifecycleStatusState();
}

final class _AnimatedLifecycleStatusState
    extends State<_AnimatedLifecycleStatus>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Widget? _displayedStatus;
  int _transitionGeneration = 0;

  Duration get _switchDuration {
    return widget.reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 300);
  }

  @override
  void initState() {
    super.initState();

    _displayedStatus = widget.status;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: widget.status == null ? 0 : 1,
    );
  }

  @override
  void didUpdateWidget(_AnimatedLifecycleStatus oldWidget) {
    super.didUpdateWidget(oldWidget);

    final Widget? oldStatus = oldWidget.status;
    final Widget? newStatus = widget.status;

    if (oldStatus == null && newStatus != null) {
      _transitionGeneration++;

      setState(() {
        _displayedStatus = newStatus;
      });

      if (widget.reducedMotion) {
        _controller.value = 1;
      } else {
        unawaited(
          _controller.animateTo(
            1,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
          ),
        );
      }

      return;
    }

    if (oldStatus != null && newStatus == null) {
      final int generation = ++_transitionGeneration;

      if (widget.reducedMotion) {
        _controller.value = 0;

        setState(() {
          _displayedStatus = null;
        });

        return;
      }

      unawaited(
        _controller
            .animateTo(
              0,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
            )
            .whenComplete(() {
              if (!mounted ||
                  generation != _transitionGeneration ||
                  widget.status != null) {
                return;
              }

              setState(() {
                _displayedStatus = null;
              });
            }),
      );

      return;
    }

    if (newStatus != null) {
      _transitionGeneration++;

      setState(() {
        _displayedStatus = newStatus;
      });

      if (_controller.value < 1) {
        if (widget.reducedMotion) {
          _controller.value = 1;
        } else {
          unawaited(
            _controller.animateTo(
              1,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = widget.reducedMotion
            ? (widget.status == null ? 0 : 1)
            : Curves.easeInOutCubic.transform(
                _controller.value.clamp(0.0, 1.0),
              );

        return ClipRect(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: t,
            child: Opacity(
              opacity: t,
              child: Transform.scale(
                scale: 0.94 + (0.06 * t),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AnimatedSwitcher(
                      duration: _switchDuration,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      layoutBuilder:
                          (
                            Widget? currentChild,
                            List<Widget> previousChildren,
                          ) {
                            return Stack(
                              alignment: AlignmentDirectional.centerStart,
                              children: <Widget>[
                                ...previousChildren,
                                ?currentChild,
                              ],
                            );
                          },
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            if (widget.reducedMotion) {
                              return child;
                            }

                            final Animation<double> curved = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                              reverseCurve: Curves.easeInCubic,
                            );

                            return FadeTransition(
                              opacity: curved,
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.94,
                                  end: 1,
                                ).animate(curved),
                                child: child,
                              ),
                            );
                          },
                      child:
                          _displayedStatus ??
                          const SizedBox.shrink(
                            key: ValueKey<String>(
                              'cineara-media-list-no-lifecycle-status',
                            ),
                          ),
                    ),
                    SizedBox(width: widget.hasTrailingDock ? 9 : 0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// Animated navigation affordance
// =============================================================================

final class _AnimatedListChevron extends StatelessWidget {
  const _AnimatedListChevron({
    required this.emphasized,
    required this.interactionProgress,
  });

  final bool emphasized;
  final double interactionProgress;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextDirection direction = Directionality.of(context);

    final double t = Curves.easeInOutCubic.transform(
      interactionProgress.clamp(0.0, 1.0),
    );

    final double translationSign = direction == TextDirection.ltr ? 1 : -1;

    final double opacity = interactionProgress > 0
        ? 0.50 + (0.50 * t)
        : emphasized
        ? 0.76
        : 0.50;

    final Color foreground = interactionProgress > 0
        ? Color.lerp(colors.onSurfaceVariant, colors.primary, t)!
        : colors.onSurfaceVariant;

    // Pick the physical glyph explicitly, then force the Icon itself to LTR so
    // Flutter cannot mirror the already-resolved glyph a second time.
    final IconData icon = direction == TextDirection.ltr
        ? Icons.chevron_right_rounded
        : Icons.chevron_left_rounded;

    return SizedBox(
      width: CinearaMediaListItem.chevronWidth,
      height: 42,
      child: Center(
        child: Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(4.8 * t * translationSign, 0),
            child: Icon(
              icon,
              size: 24,
              color: foreground,
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
  }
}
