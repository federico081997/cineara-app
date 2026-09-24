import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/spacing.dart';
import '../media/media_poster_overlay.dart';
import '../media/media_status_dock.dart';
import 'entity_grid_item.dart';

// =============================================================================
// Entity List item
// =============================================================================

/// Editorial Cineara row for collection-, studio- and topic-like entities.
///
/// List interaction intentionally mirrors `CinearaMediaListItem`, not the
/// Grid/rail poster interaction used by [CinearaEntityGridItem].
///
/// ```text
/// rest
/// -> cardless editorial row
/// -> compact, type-appropriate leading visual when one exists
///
/// pointer down
/// -> raw entity artwork zooms inside the fixed frame
/// -> artwork shadow contracts toward the surface
/// -> one restrained full-row pressure surface appears
///
/// tap confirmation
/// -> row pressure deepens slightly
/// -> artwork shadow tightens further
/// -> chevron moves toward the destination and blends to primary
///
/// confirmed hold
/// -> light haptic on touch/stylus
/// -> raw artwork reaches 1.030 zoom
/// -> artwork elevation approaches the underlying surface
/// -> deeper full-row held treatment
/// -> [onLongPress]
/// ```
///
/// The entity frame, rim, title, Favorite state, chevron and row geometry never
/// scale or translate. When a leading visual exists, only its raw image/fallback
/// content zooms internally.
///
/// List geometry deliberately aligns with `CinearaMediaListItem` wherever an
/// entity has a real leading visual. Collections use the exact same 84 x 126
/// poster footprint as media List rows, while Studios reserve the same 84 dp
/// leading rail but keep their native 84 x 56 horizontal logo plate. This keeps
/// the press/highlight inset, metadata start and chevron rhythm consistent with
/// media without stretching brand logos.
///
/// ```text
/// collection poster -> 84 x 126
/// studio logo       -> 84 x 56 inside the same 84 dp leading rail;
///                      missing/failed artwork uses the shared company fallback
/// semantic icon     -> 56 x 56 when a caller genuinely has one
/// topic / keyword   -> no visual
/// ```
///
/// Collections use [CinearaEntityVisualVariant.poster] and studios use
/// [CinearaEntityVisualVariant.logo]. A null [variant] means that the entity has
/// no visual identity and should be rendered as a text-only List row. This is the
/// intended representation for API-backed topics/keywords that provide only a
/// name. No fabricated icon or empty artwork slot is introduced.
///
/// Favorite is deliberately presentation-specific in List mode:
///
/// - visual entities (Collection, Studio, genuine icon entities) place Favorite
///   on the visual at logical bottom-end, using the same artwork dock language
///   as media posters;
/// - text-only entities such as Topics keep Favorite inline beside the title,
///   because there is no artwork to host it.
///
/// Favorite never changes the vertical metadata stack. The title stays vertically
/// centered against the visual's normal envelope at ordinary text sizes. The item
/// deliberately owns neither a tablet/desktop width cap nor row separators: width,
/// alignment and the single separator between siblings belong to the parent List.
/// Larger accessibility text may still grow the row naturally, matching the media
/// List accessibility contract.
final class CinearaEntityListItem extends StatefulWidget {
  const CinearaEntityListItem({
    required this.title,
    required this.statusDockLabels,
    super.key,
    this.variant,
    this.image,
    this.favorite = false,
    this.showFavorite = true,
    this.fallbackIcon,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.semanticHint,
    this.heroTag,
    this.heroTransitionOnUserGestures = false,
    this.showChevron = true,
    this.visualWidth,
    this.logoPadding = CinearaSpacing.sm,
  }) : assert(title != '', 'title must not be empty.'),
       assert(
         visualWidth == null || visualWidth > 0,
         'visualWidth must be greater than zero when provided.',
       ),
       assert(logoPadding >= 0, 'logoPadding must not be negative.');

  // ---------------------------------------------------------------------------
  // Canonical List geometry
  // ---------------------------------------------------------------------------

  /// Canonical media-List leading width.
  ///
  /// Collections deliberately reuse the exact same width as
  /// `CinearaMediaListItem.defaultPosterWidth`. Studios reserve this same leading
  /// rail so their title starts on the same metadata axis as media/collections.
  static const double defaultVisualWidth = 84;

  /// Collection geometry is intentionally identical to media List poster
  /// geometry: 84 x 126, i.e. a true 2:3 poster.
  static const double collectionVisualWidth = 84;
  static const double collectionVisualHeight = 126;

  /// Studio logos remain horizontal so wide wordmarks stay legible. The plate
  /// uses the same 84 dp leading width as media/collections but keeps 3:2 height.
  /// It deliberately does not use circular People-style geometry.
  static const double studioVisualWidth = 84;
  static const double studioVisualHeight = 56;

  /// Reserved for callers that genuinely have a semantic icon source.
  static const double iconVisualWidth = 56;
  static const double iconVisualHeight = 56;

  /// Minimum inner row heights.
  ///
  /// Collections stay on the exact 126 dp media-List poster envelope.
  ///
  /// Studio/icon rows now collapse to their real 56 dp visual height because
  /// Favorite no longer needs a second metadata line. Text-only Topic rows use
  /// the same 56 dp baseline so their title, optional inline Favorite and
  /// chevron share one compact centered axis. Larger accessibility text may grow
  /// the row naturally beyond these baselines.
  static const double collectionContentMinimumHeight = 126;
  static const double studioContentMinimumHeight = 56;
  static const double iconContentMinimumHeight = 56;
  static const double textOnlyMinimumHeight = 56;

  /// Uniform inset between the temporary pressed silhouette and row content.
  /// This is intentionally the same 8 dp inset used by media List rows, so a
  /// collection poster sits exactly 8 dp from both the highlight's top and its
  /// logical leading edge.
  static const double tileInset = 8;

  /// Exact media-List artwork-to-metadata gap.
  static const double visualToMetadataGap = 14;

  static const double chevronLeadGap = 10;
  static const double chevronWidth = 36;
  static const double chevronTrailingGap = 2;

  /// Default separator/metadata rail for visual entity rows.
  ///
  /// `8 dp tile inset + 84 dp leading rail + 14 dp gap = 106 dp`, matching the
  /// media List metadata axis exactly.
  static const double defaultMetadataRailInset =
      tileInset + defaultVisualWidth + visualToMetadataGap;

  static const double collectionMetadataRailInset =
      tileInset + collectionVisualWidth + visualToMetadataGap;

  static const double studioMetadataRailInset =
      tileInset + studioVisualWidth + visualToMetadataGap;

  static const double iconMetadataRailInset =
      tileInset + iconVisualWidth + visualToMetadataGap;

  /// Recommended separator start for text-only rows such as Topics.
  static const double textOnlyMetadataRailInset = tileInset;

  /// Returns the standard metadata-rail inset for one entity variant.
  ///
  /// If [visualWidth] is supplied, it is treated as an explicit caller override.
  static double metadataRailInsetFor(
    CinearaEntityVisualVariant? variant, {
    double? visualWidth,
  }) {
    if (variant == null) {
      return textOnlyMetadataRailInset;
    }

    final double resolvedWidth =
        visualWidth ??
        switch (variant) {
          CinearaEntityVisualVariant.poster => collectionVisualWidth,
          CinearaEntityVisualVariant.logo => studioVisualWidth,
          CinearaEntityVisualVariant.icon => iconVisualWidth,
        };

    return tileInset + resolvedWidth + visualToMetadataGap;
  }

  final String title;

  /// Optional leading visual treatment.
  ///
  /// `null` means text-only. In that state [image], [fallbackIcon], [heroTag] and
  /// visual-only configuration are intentionally ignored.
  final CinearaEntityVisualVariant? variant;
  final ImageProvider<Object>? image;

  final bool favorite;
  final bool showFavorite;
  final CinearaStatusDockLabels statusDockLabels;

  final IconData? fallbackIcon;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final String? semanticLabel;
  final String? semanticHint;

  final Object? heroTag;
  final bool heroTransitionOnUserGestures;

  final bool showChevron;

  /// Optional explicit List visual width override.
  ///
  /// Leave null for the canonical geometry above. In normal Search/List usage,
  /// Collections and Studios both reserve an 84 dp leading rail.
  final double? visualWidth;

  final double logoPadding;

  bool get hasVisual => variant != null;

  double? get resolvedVisualWidth {
    final CinearaEntityVisualVariant? resolvedVariant = variant;

    if (resolvedVariant == null) {
      return null;
    }

    return visualWidth ??
        switch (resolvedVariant) {
          CinearaEntityVisualVariant.poster => collectionVisualWidth,
          CinearaEntityVisualVariant.logo => studioVisualWidth,
          CinearaEntityVisualVariant.icon => iconVisualWidth,
        };
  }

  double? get visualHeight {
    final CinearaEntityVisualVariant? resolvedVariant = variant;
    final double? width = resolvedVisualWidth;

    if (resolvedVariant == null || width == null) {
      return null;
    }

    return resolvedVariant.heightForWidth(width);
  }

  double get baseContentMinimumHeight {
    return switch (variant) {
      CinearaEntityVisualVariant.poster => collectionContentMinimumHeight,
      CinearaEntityVisualVariant.logo => studioContentMinimumHeight,
      CinearaEntityVisualVariant.icon => iconContentMinimumHeight,
      null => textOnlyMinimumHeight,
    };
  }

  @override
  State<CinearaEntityListItem> createState() => _CinearaEntityListItemState();
}

// =============================================================================
// State
// =============================================================================

final class _CinearaEntityListItemState extends State<CinearaEntityListItem>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // Interaction intensity — identical to CinearaMediaListItem
  // ---------------------------------------------------------------------------

  static const double _pressedIntensity = 0.40;
  static const double _tapActivationIntensity = 0.62;

  /// Full confirmed hold reaches 1.030 raw-artwork zoom.
  static const double _maximumArtworkZoom = 0.030;

  // ---------------------------------------------------------------------------
  // Timing — identical to CinearaMediaListItem
  // ---------------------------------------------------------------------------

  static const Duration _pressInDuration = Duration(milliseconds: 95);
  static const Duration _tapActivationDuration = Duration(milliseconds: 88);
  static const Duration _longPressDepthDuration = Duration(milliseconds: 165);
  static const Duration _releaseDuration = Duration(milliseconds: 215);
  static const Duration _pointerUpFallbackDelay = Duration(milliseconds: 80);

  static const Curve _interactionCurve = Curves.easeInOutCubic;

  static const Duration _touchPressArmDelay = Duration(milliseconds: 85);
  static const double _visualScrollSlop = 6;

  // ---------------------------------------------------------------------------
  // Controllers / gesture state
  // ---------------------------------------------------------------------------

  late final AnimationController _pressController;
  late final CinearaStatusDockController _favoriteController;

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

  // ---------------------------------------------------------------------------
  // Derived state
  // ---------------------------------------------------------------------------

  bool get _interactive => widget.onTap != null || widget.onLongPress != null;

  bool get _surfacePointerIsDown => _activeSurfacePointer != null;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

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
  void didUpdateWidget(CinearaEntityListItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.showFavorite || oldWidget.favorite == widget.favorite) {
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

  // =============================================================================
  // Hover / focus
  // =============================================================================

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

  // =============================================================================
  // Raw pointer surface — identical choreography to CinearaMediaListItem
  // =============================================================================

  void _handleSurfacePointerDown(PointerDownEvent event) {
    if (!_interactive || _activeSurfacePointer != null) {
      return;
    }

    if ((event.buttons & kPrimaryButton) == 0) {
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

  // =============================================================================
  // Tap
  // =============================================================================

  void _handleTap() {
    if (!_surfaceGestureEligible) {
      return;
    }

    _pointerUpReleaseTimer?.cancel();
    _pressArmTimer?.cancel();

    _surfaceGestureEligible = false;
    _surfacePointerKind = null;

    final VoidCallback? callback = widget.onTap;

    if (callback == null) {
      _releaseInteraction();
      return;
    }

    unawaited(_runTapActivation(callback: callback));
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

  // =============================================================================
  // Long press
  // =============================================================================

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

  // =============================================================================
  // Animation helpers
  // =============================================================================

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

  // =============================================================================
  // Visual interpolation — identical to CinearaMediaListItem
  // =============================================================================

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

  // =============================================================================
  // Build
  // =============================================================================

  @override
  Widget build(BuildContext context) {
    assert(
      widget.title.trim().isNotEmpty,
      'title must contain visible characters.',
    );

    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final bool emphasized = _hovered || _focused;
    final bool highContrast = MediaQuery.highContrastOf(context);

    final CinearaEntityVisualVariant? variant = widget.variant;
    final double? visualWidth = widget.resolvedVisualWidth;
    final double? visualHeight = widget.visualHeight;

    // Normal Collection rows deliberately use the same 126 dp content envelope
    // as media List posters. Studio/icon/Topic rows collapse to a 56 dp baseline
    // now that Favorite no longer creates a second metadata line.
    final double minimumContentHeight = math
        .max(widget.baseContentMinimumHeight, visualHeight ?? 0.0)
        .toDouble();

    // At normal scale the metadata and visual share the exact same vertical
    // envelope, so the title is always centered on the visual. When accessibility
    // text grows beyond that envelope, media-style behavior takes over: the visual
    // remains anchored to its baseline while the row grows to fit the text.
    final AlignmentDirectional visualAlignment = switch (variant) {
      CinearaEntityVisualVariant.poster => AlignmentDirectional.topStart,
      CinearaEntityVisualVariant.logo => AlignmentDirectional.centerStart,
      CinearaEntityVisualVariant.icon => AlignmentDirectional.centerStart,
      null => AlignmentDirectional.centerStart,
    };

    final Widget row = Semantics(
      button: _interactive,
      label: _resolvedSemanticLabel,
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
            onPointerDown: _interactive ? _handleSurfacePointerDown : null,
            onPointerMove: _interactive ? _handleSurfacePointerMove : null,
            onPointerUp: _interactive ? _handleSurfacePointerUp : null,
            onPointerCancel: _interactive ? _handleSurfacePointerCancel : null,
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

                  return Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(
                          CinearaEntityListItem.tileInset,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (variant != null &&
                                visualWidth != null &&
                                visualHeight != null) ...<Widget>[
                              SizedBox(
                                width: visualWidth,
                                height: minimumContentHeight,
                                child: Align(
                                  alignment: visualAlignment,
                                  child: SizedBox(
                                    width: visualWidth,
                                    height: visualHeight,
                                    child: _EntityListInteractiveVisual(
                                      title: widget.title,
                                      variant: variant,
                                      image: widget.image,
                                      fallbackIcon:
                                          variant ==
                                              CinearaEntityVisualVariant.logo
                                          ? null
                                          : widget.fallbackIcon,
                                      artworkZoom: _resolveArtworkZoom(
                                        pressProgress,
                                      ),
                                      interactionProgress: _reducedMotion
                                          ? 0
                                          : pressProgress,
                                      heroTag: widget.heroTag,
                                      heroTransitionOnUserGestures:
                                          widget.heroTransitionOnUserGestures,
                                      visualWidth: visualWidth,
                                      logoPadding: widget.logoPadding,
                                      favoriteDock: widget.showFavorite
                                          ? _buildArtworkFavoriteDock()
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width:
                                    CinearaEntityListItem.visualToMetadataGap,
                              ),
                            ],
                            Expanded(
                              child: _EntityListMetadata(
                                title: widget.title,
                                minimumHeight: minimumContentHeight,
                                favoriteDock:
                                    variant == null && widget.showFavorite
                                    ? _buildTopicFavoriteDock()
                                    : null,
                                favoriteVisible:
                                    variant == null &&
                                    widget.showFavorite &&
                                    widget.favorite,
                                reducedMotion: _reducedMotion,
                              ),
                            ),
                            if (widget.showChevron &&
                                widget.onTap != null) ...<Widget>[
                              const SizedBox(
                                width: CinearaEntityListItem.chevronLeadGap,
                              ),
                              SizedBox(
                                height: minimumContentHeight,
                                child: Center(
                                  child: _AnimatedEntityListChevron(
                                    emphasized: emphasized,
                                    interactionProgress:
                                        _resolveNavigationCueProgress(
                                          pressProgress,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: CinearaEntityListItem.chevronTrailingGap,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Paint-only complete-row pressure treatment, matching
                      // CinearaMediaListItem. Geometry/content remain fixed.
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _EntityListTilePressPainter(
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

    // Width, horizontal placement and sibling separation are parent-owned. The
    // item fills the content width supplied by the List but never paints its own
    // divider, preventing doubled separator lines when ListView.separated or an
    // equivalent parent already provides the section rhythm.
    return SizedBox(width: double.infinity, child: row);
  }

  CinearaStatusDock _buildArtworkFavoriteDock() {
    return CinearaStatusDock(
      controller: _favoriteController,
      labels: widget.statusDockLabels,
      favorite: widget.favorite,
      visibleIndicators: const <CinearaStatusDockIndicator>{
        CinearaStatusDockIndicator.favorite,
      },
      mode: CinearaStatusDockMode.permanent,
      layout: CinearaStatusDockLayout.vertical,
      variant: CinearaStatusDockVariant.artwork,
      density: CinearaStatusDockDensity.compact,
      side: CinearaStatusDockSide.end,
      tapToExpand: false,
      autoCollapse: false,
      excludeFromSemantics: true,
    );
  }

  CinearaStatusDock _buildTopicFavoriteDock() {
    return CinearaStatusDock(
      controller: _favoriteController,
      labels: widget.statusDockLabels,
      favorite: widget.favorite,
      visibleIndicators: const <CinearaStatusDockIndicator>{
        CinearaStatusDockIndicator.favorite,
      },
      mode: CinearaStatusDockMode.permanent,
      layout: CinearaStatusDockLayout.horizontal,
      variant: CinearaStatusDockVariant.surface,
      density: CinearaStatusDockDensity.compact,
      side: CinearaStatusDockSide.start,
      tapToExpand: false,
      autoCollapse: false,
      excludeFromSemantics: true,
    );
  }

  String get _resolvedSemanticLabel {
    final String? explicit = widget.semanticLabel?.trim();

    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }

    final List<String> parts = <String>[widget.title.trim()];

    if (widget.showFavorite && widget.favorite) {
      parts.add(widget.statusDockLabels.favorite);
    }

    return parts.join('. ');
  }
}

// =============================================================================
// Fixed entity visual with media-List interaction depth
// =============================================================================

/// Fixed entity frame used by List rows that actually have a visual.
///
/// The row owns gesture state. Only raw artwork receives [artworkZoom]; the
/// frame/rim and geometry stay fixed, exactly like the media List poster's
/// rating/progress overlays stay fixed while its raw artwork zooms.
///
/// When [favoriteDock] is supplied it is painted through
/// [CinearaMediaPosterOverlay] at logical bottom-end. This keeps Favorite on the
/// artwork without changing the title/metadata geometry.
final class _EntityListInteractiveVisual extends StatelessWidget {
  const _EntityListInteractiveVisual({
    required this.title,
    required this.variant,
    required this.image,
    required this.fallbackIcon,
    required this.artworkZoom,
    required this.interactionProgress,
    required this.heroTag,
    required this.heroTransitionOnUserGestures,
    required this.visualWidth,
    required this.logoPadding,
    required this.favoriteDock,
  });

  final String title;
  final CinearaEntityVisualVariant variant;
  final ImageProvider<Object>? image;
  final IconData? fallbackIcon;

  final double artworkZoom;
  final double interactionProgress;

  final Object? heroTag;
  final bool heroTransitionOnUserGestures;

  final double visualWidth;
  final double logoPadding;

  final CinearaStatusDock? favoriteDock;

  @override
  Widget build(BuildContext context) {
    final double visualHeight = variant.heightForWidth(visualWidth);

    return SizedBox(
      width: visualWidth,
      height: visualHeight,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: <Widget>[
          CinearaEntityVisual(
            title: title,
            variant: variant,
            image: image,
            fallbackIcon: fallbackIcon,
            width: visualWidth,
            artworkZoom: artworkZoom,
            interactionProgress: interactionProgress,

            // Media List does not alter the artwork rim on hover/focus; its
            // navigation affordance carries that emphasis instead.
            emphasized: false,
            heroTag: heroTag,
            heroTransitionOnUserGestures: heroTransitionOnUserGestures,
            logoPadding: logoPadding,
          ),
          if (favoriteDock != null)
            CinearaMediaPosterOverlay(statusDock: favoriteDock),
        ],
      ),
    );
  }
}

// =============================================================================
// Metadata — centered title, with inline Favorite for text-only entities
// =============================================================================

/// Metadata for entity List rows.
///
/// Visual entities keep Favorite on their artwork, so this widget normally renders
/// only the title. Text-only entities may supply [favoriteDock]; when active it is
/// kept immediately beside the title instead of being pushed into the trailing
/// navigation rail.
///
/// At ordinary text sizes the title cluster is vertically centered against
/// [minimumHeight]. Accessibility text may grow the row beyond the baseline rather
/// than clipping. The inline Favorite remains attached to the text cluster.
final class _EntityListMetadata extends StatelessWidget {
  const _EntityListMetadata({
    required this.title,
    required this.minimumHeight,
    required this.favoriteDock,
    required this.favoriteVisible,
    required this.reducedMotion,
  });

  static const double _titleToFavoriteGap = 8;
  static const double _favoriteSlotWidth = 42;
  static const double _favoriteSlotHeight = 42;

  final String title;
  final double minimumHeight;
  final CinearaStatusDock? favoriteDock;
  final bool favoriteVisible;
  final bool reducedMotion;

  Duration get _favoriteLayoutDuration {
    return reducedMotion ? Duration.zero : const Duration(milliseconds: 220);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final TextStyle titleStyle =
        theme.textTheme.titleSmall?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w700,
          height: 1.18,
        ) ??
        TextStyle(
          color: colors.onSurface,
          fontWeight: FontWeight.w700,
          height: 1.18,
        );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        final CinearaStatusDock? resolvedFavoriteDock = favoriteDock;
        final bool hasFavoriteDock = resolvedFavoriteDock != null;
        final double favoriteReserve = hasFavoriteDock && favoriteVisible
            ? _titleToFavoriteGap + _favoriteSlotWidth
            : 0;

        final double titleMaxWidth = math.max(
          0.0,
          availableWidth - favoriteReserve,
        );

        final TextPainter painter = TextPainter(
          text: TextSpan(text: title, style: titleStyle),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 3,
          ellipsis: '…',
        )..layout(maxWidth: titleMaxWidth);

        final double clusterHeight = math.max(
          painter.height,
          favoriteVisible ? _favoriteSlotHeight : 0,
        );

        final double contentHeight = math.max(minimumHeight, clusterHeight);

        return SizedBox(
          height: contentHeight,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                ),
                if (resolvedFavoriteDock != null) ...<Widget>[
                  AnimatedContainer(
                    duration: _favoriteLayoutDuration,
                    curve: Curves.easeInOutCubic,
                    width: favoriteVisible ? _titleToFavoriteGap : 0,
                  ),
                  AnimatedSize(
                    duration: _favoriteLayoutDuration,
                    curve: Curves.easeInOutCubic,
                    alignment: AlignmentDirectional.centerStart,
                    child: Offstage(
                      offstage: !favoriteVisible,
                      child: SizedBox(
                        width: _favoriteSlotWidth,
                        height: _favoriteSlotHeight,
                        child: Center(
                          child: IgnorePointer(child: resolvedFavoriteDock),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// Complete-row pressure treatment — matched to CinearaMediaListItem
// =============================================================================

final class _EntityListTilePressPainter extends CustomPainter {
  const _EntityListTilePressPainter({
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
      const Radius.circular(CinearaRadii.md + CinearaEntityListItem.tileInset),
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

    const double tileRadius = CinearaRadii.md + CinearaEntityListItem.tileInset;

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
  bool shouldRepaint(covariant _EntityListTilePressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.brightness != brightness ||
        oldDelegate.highContrast != highContrast ||
        oldDelegate.longPressRecognized != longPressRecognized;
  }
}

// =============================================================================
// Animated navigation affordance — matched to CinearaMediaListItem
// =============================================================================

final class _AnimatedEntityListChevron extends StatelessWidget {
  const _AnimatedEntityListChevron({
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

    final IconData icon = direction == TextDirection.ltr
        ? Icons.chevron_right_rounded
        : Icons.chevron_left_rounded;

    return SizedBox(
      width: CinearaEntityListItem.chevronWidth,
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
