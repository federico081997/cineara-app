import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/tokens/elevation.dart';
import '../../foundations/tokens/radius.dart';
import 'media_poster_overlay.dart';

// =============================================================================
// Media poster
// =============================================================================

/// Reusable Cineara poster primitive.
///
/// [CinearaMediaPoster] owns the poster frame and the interaction that belongs
/// to opening or acting on the media itself.
///
/// It combines:
///
/// - poster artwork;
/// - consistent 2:3 media geometry;
/// - Cineara poster corner radius;
/// - optional [CinearaMediaPosterOverlay];
/// - tap-to-open interaction;
/// - long-press quick-action interaction;
/// - tactile poster-surface motion;
/// - subtle shared Cineara artwork elevation;
/// - keyboard activation;
/// - accessibility semantics;
/// - an optional artwork-only Hero transition.
///
/// Typical composition:
///
/// ```dart
/// CinearaMediaPoster(
///   artwork: CinearaPosterImage(...),
///   overlay: CinearaMediaPosterOverlay(
///     statusBadge: ...,
///     externalRatingBadge: ...,
///     statusDock: ...,
///     progressIndicator: ...,
///   ),
///   semanticLabel: 'Frieren: Beyond Journey\\'s End',
///   onTap: openDetails,
///   onLongPress: openQuickActions,
/// )
/// ```
///
/// ## Interaction language
///
/// Poster motion belongs only to the media poster itself.
///
/// ```text
/// ordinary artwork
/// → tactile poster motion
/// → tap opens details
/// → hold opens quick actions
///
/// viewing-status control
/// → status interaction only
/// → no poster motion
///
/// personal-state dock
/// → dock interaction only
/// → no poster motion
/// ```
///
/// Passive overlay metadata, such as an external rating or viewing progress,
/// deliberately remains part of the poster surface.
///
/// ## Optical depth
///
/// At rest, the poster uses [CinearaElevation.artworkShadows] plus the shared
/// Cineara artwork rim so it sits slightly above the surrounding page without
/// turning the complete media item into an elevated card.
///
/// During pointer interaction, the existing press controller also tightens the
/// artwork shadow:
///
/// ```text
/// rest
/// → subtle contact + ambient lift
///
/// pointer down
/// → shadow begins to contract
///
/// tap confirmation
/// → shadow tightens further
///
/// confirmed hold
/// → artwork approaches the underlying surface
///
/// release
/// → shadow returns smoothly with the existing press animation
/// ```
///
/// Reduced-motion mode keeps the resting artwork elevation static rather than
/// animating depth.
///
/// ## Tap choreography
///
/// ```text
/// pointer down
///     ↓
/// 70 ms
/// shallow compression
/// + tiny downward travel
/// + restrained artwork darkening
///     ↓
/// tap recognised
///     ↓
/// 58 ms
/// slightly deeper confirmation
/// + slightly stronger artwork darkening
///     ↓
/// smooth release begins
///     ↓
/// onTap
/// ```
///
/// The short confirmation phase makes even a fast tap perceptible without
/// making navigation feel delayed.
///
/// ## Long-press choreography
///
/// ```text
/// pointer down
///     ↓
/// shallow compression
///     ↓
/// long press recognised
///     ↓
/// light haptic
///     ↓
/// 135 ms
/// deeper compression
/// + darker artwork
/// + primary outline
/// + restrained glow
///     ↓
/// onLongPress
/// ```
///
/// Importantly, tap cancellation does *not* cancel the underlying poster
/// interaction while the pointer is still down. Flutter normally cancels the
/// tap recognizer when its long-press recognizer wins the gesture arena. The
/// same physical press is therefore allowed to transition cleanly from:
///
/// ```text
/// possible tap
/// → confirmed long press
/// ```
///
/// ## Overlay isolation
///
/// Raw pointer feedback is attached to the artwork surface *inside* the poster
/// stack.
///
/// Interactive overlay controls are painted above that surface. Their protected
/// hit regions therefore win hit testing before the artwork listener is
/// reached.
///
/// As a result, pressing the viewing-status badge or personal-state dock does
/// not even begin the poster compression animation.
///
/// This avoids coupling [CinearaMediaPoster] to hard-coded overlay geometry.
///
/// ## Scrolling / gesture abandonment
///
/// If the pointer moves beyond Flutter's normal touch slop before a long press
/// is recognised, the poster smoothly releases and stops treating the gesture
/// as a media-card action.
///
/// This prevents a poster from remaining visibly pressed while the user scrolls
/// a grid or list.
///
/// ## Reduced motion
///
/// When animation reduction is active:
///
/// - scale is disabled;
/// - vertical travel is disabled;
/// - artificial confirmation delays are removed;
/// - a small static artwork scrim remains as immediate feedback;
/// - touch/stylus long-press haptic confirmation remains available.
///
/// ## Clipping
///
/// Artwork is clipped to [borderRadius].
///
/// The optical shadow is painted outside the artwork clip so it remains
/// visible. The subtle artwork rim is painted as a foreground decoration around
/// the clipped artwork.
///
/// The poster overlay itself is deliberately not clipped. Expandable status and
/// dock components may need to paint outside their compact geometry.
///
/// Poster-bound overlay elements, such as progress, are responsible for their
/// own clipping inside [CinearaMediaPosterOverlay].
///
/// ## Hero transition
///
/// When [heroTag] is supplied, only the artwork participates in the Hero
/// transition.
///
/// Temporary UI state such as status, progress and personal-state indicators
/// remains on the source route.
final class CinearaMediaPoster extends StatefulWidget {
  const CinearaMediaPoster({
    required this.artwork,
    super.key,
    this.overlay,
    this.aspectRatio = 2 / 3,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(CinearaRadii.md),
    ),
    this.backgroundColor,
    this.clipBehavior = Clip.antiAlias,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.semanticHint,
    this.excludeArtworkFromSemantics = true,
    this.focusNode,
    this.autofocus = false,
    this.mouseCursor,
    this.heroTag,
    this.heroTransitionOnUserGestures = false,
  }) : assert(aspectRatio > 0, 'aspectRatio must be greater than zero.'),
       assert(
         semanticLabel == null || semanticLabel != '',
         'semanticLabel must not be empty.',
       ),
       assert(
         semanticHint == null || semanticHint != '',
         'semanticHint must not be empty.',
       );

  // ===========================================================================
  // Content
  // ===========================================================================

  /// Poster artwork.
  ///
  /// This will normally be a `CinearaPosterImage`, but accepting [Widget]
  /// keeps this primitive independent from image loading and data sources.
  final Widget artwork;

  /// Optional poster overlay.
  ///
  /// This normally composes:
  ///
  /// ```text
  /// CinearaStatusBadge
  /// CinearaExternalRatingBadge
  /// CinearaStatusDock
  /// CinearaMediaProgressIndicator
  /// ```
  final CinearaMediaPosterOverlay? overlay;

  // ===========================================================================
  // Geometry
  // ===========================================================================

  /// Poster width-to-height ratio.
  ///
  /// Cineara's default movie/series poster treatment is 2:3.
  final double aspectRatio;

  /// Radius applied to the artwork frame.
  final BorderRadius borderRadius;

  /// Background visible while artwork is loading or transparent.
  ///
  /// Defaults to [ColorScheme.surfaceContainerHighest].
  final Color? backgroundColor;

  /// Artwork clipping behaviour.
  final Clip clipBehavior;

  // ===========================================================================
  // Interaction
  // ===========================================================================

  /// Opens the media destination.
  final VoidCallback? onTap;

  /// Opens media quick actions.
  ///
  /// Pointer-based touch/stylus long press emits
  /// [HapticFeedback.lightImpact] before invoking this callback.
  final VoidCallback? onLongPress;

  // ===========================================================================
  // Accessibility
  // ===========================================================================

  /// Localized accessible media label.
  ///
  /// Normally this should be the media title.
  final String? semanticLabel;

  /// Optional localized interaction hint.
  final String? semanticHint;

  /// Whether semantics originating from [artwork] should be excluded.
  ///
  /// Overlay semantics are unaffected.
  final bool excludeArtworkFromSemantics;

  // ===========================================================================
  // Focus / desktop
  // ===========================================================================

  final FocusNode? focusNode;

  final bool autofocus;

  /// Pointer cursor override.
  ///
  /// Interactive posters default to [SystemMouseCursors.click].
  final MouseCursor? mouseCursor;

  // ===========================================================================
  // Shared-element navigation
  // ===========================================================================

  /// Optional Hero tag for the artwork.
  ///
  /// Only artwork participates in the transition.
  final Object? heroTag;

  /// Whether the Hero may transition during user-gesture navigation.
  final bool heroTransitionOnUserGestures;

  @override
  State<CinearaMediaPoster> createState() => _CinearaMediaPosterState();
}

// =============================================================================
// State
// =============================================================================

final class _CinearaMediaPosterState extends State<CinearaMediaPoster>
    with SingleTickerProviderStateMixin {
  // ===========================================================================
  // Interaction intensity
  // ===========================================================================

  /// Resting pointer-down depth.
  static const double _pressedIntensity = 0.40;

  /// Brief depth used to confirm a normal tap.
  static const double _tapActivationIntensity = 0.62;

  /// Maximum poster compression at confirmed long press.
  ///
  /// ```text
  /// long press:
  /// 1 - 0.030 = 0.970
  ///
  /// ordinary press:
  /// 1 - (0.030 × 0.40) = 0.988
  ///
  /// tap confirmation:
  /// 1 - (0.030 × 0.62) ≈ 0.981
  /// ```
  static const double _maximumScaleCompression = 0.030;

  /// Maximum physical-looking downward travel.
  static const double _maximumVerticalTravel = 1.2;

  /// Maximum artwork darkening at full hold.
  static const double _maximumScrimOpacity = 0.074;

  /// Primary outline at confirmed long press.
  static const double _maximumHoldOutlineOpacity = 0.40;

  /// Restrained glow at confirmed long press.
  static const double _maximumHoldGlowOpacity = 0.13;

  // ===========================================================================
  // Timing
  // ===========================================================================

  /// Press-in response after touch/stylus arming, or immediately for mouse.
  ///
  /// Slightly longer than the original preview so compression and scrim arrive
  /// as one continuous physical motion rather than a sharp snap.
  static const Duration _pressInDuration = Duration(milliseconds: 95);

  /// Extra confirmation for a normal tap.
  static const Duration _tapActivationDuration = Duration(milliseconds: 88);

  /// Deepening after long-press recognition.
  static const Duration _longPressDepthDuration = Duration(milliseconds: 165);

  /// Return to rest.
  static const Duration _releaseDuration = Duration(milliseconds: 215);

  /// Smooth, zero-velocity endpoints prevent visible acceleration jumps when
  /// interaction phases hand off to one another.
  static const Curve _interactionCurve = Curves.easeInOutCubic;

  /// Short grace period between raw pointer-up and GestureDetector.onTap.
  static const Duration _pointerUpFallbackDelay = Duration(milliseconds: 80);

  /// Touch/stylus posters live inside scrollable grids and rails. Do not begin
  /// visual press feedback immediately on raw pointer-down; briefly arm it so
  /// a normal scroll does not make posters flash as though they were tapped.
  static const Duration _touchPressArmDelay = Duration(milliseconds: 85);

  /// Cancel only the visual press response after a small drag.
  ///
  /// Actual tap eligibility still uses Flutter's normal [kTouchSlop].
  static const double _visualScrollSlop = 6;

  // ===========================================================================
  // State
  // ===========================================================================

  late final AnimationController _pressController;

  Timer? _pointerUpReleaseTimer;
  Timer? _pressArmTimer;

  int? _activeSurfacePointer;
  Offset? _surfacePointerDownPosition;
  PointerDeviceKind? _surfacePointerKind;

  int _interactionGeneration = 0;

  /// True only when pointer-down was received by the poster artwork surface.
  ///
  /// Interactive overlay controls never set this.
  bool _surfaceGestureEligible = false;

  bool _longPressRecognized = false;
  bool _longPressActionDispatched = false;
  bool _releaseAfterLongPressDispatch = false;

  bool _showFocusHighlight = false;
  bool _reduceMotion = false;

  // ===========================================================================
  // Derived state
  // ===========================================================================

  bool get _isInteractive => widget.onTap != null || widget.onLongPress != null;

  bool get _keyboardActivatable => widget.onTap != null;

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

    final bool reduceMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;

    if (_reduceMotion == reduceMotion) {
      return;
    }

    _reduceMotion = reduceMotion;

    if (!_reduceMotion) {
      return;
    }

    _pointerUpReleaseTimer?.cancel();
    _pressArmTimer?.cancel();
    _pressController.stop();

    if (_longPressRecognized) {
      _pressController.value = 1;
      return;
    }

    if (_surfacePointerIsDown && _surfaceGestureEligible) {
      _pressController.value = _pressedIntensity;
      return;
    }

    _pressController.value = 0;
  }

  @override
  void didUpdateWidget(CinearaMediaPoster oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool wasInteractive =
        oldWidget.onTap != null || oldWidget.onLongPress != null;

    if (!_isInteractive && wasInteractive) {
      _resetInteractionImmediately();
    }
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
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final MouseCursor resolvedMouseCursor =
        widget.mouseCursor ??
        (_isInteractive ? SystemMouseCursors.click : MouseCursor.defer);

    final Widget poster = Semantics(
      container: true,
      label: _resolvedSemanticLabel,
      hint: _resolvedSemanticHint,
      button: _isInteractive,
      onTap: widget.onTap == null ? null : _handleSemanticTap,
      onLongPress: widget.onLongPress == null ? null : _handleSemanticLongPress,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        // Poster-level semantics are supplied by the wrapping Semantics widget.
        // Overlay semantics remain independently available.
        excludeFromSemantics: true,

        // -------------------------------------------------------------------
        // Tap recognizer
        // -------------------------------------------------------------------
        onTap: widget.onTap == null ? null : _handleTap,

        onTapCancel: widget.onTap == null ? null : _handleTapCancel,

        // -------------------------------------------------------------------
        // Long-press recognizer
        // -------------------------------------------------------------------
        onLongPressStart: widget.onLongPress == null
            ? null
            : _handleLongPressStart,

        onLongPressEnd: widget.onLongPress == null ? null : _handleLongPressEnd,

        onLongPressCancel: widget.onLongPress == null
            ? null
            : _handleLongPressCancel,

        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: AnimatedBuilder(
            animation: _pressController,
            builder: (BuildContext context, Widget? child) {
              final double progress = _pressController.value;

              // Keep optical depth static in reduced-motion mode. Otherwise the
              // same controller that owns compression/travel also contracts the
              // artwork shadow, so no second animation system is introduced.
              final double depthProgress = _reduceMotion ? 0 : progress;

              final List<BoxShadow> artworkShadows =
                  CinearaElevation.artworkShadows(
                    context,
                    interactionProgress: depthProgress,
                  );

              return Transform.translate(
                offset: Offset(0, _resolveVerticalTravel(progress)),
                child: Transform.scale(
                  scale: _resolveScale(progress),
                  alignment: Alignment.center,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: widget.borderRadius,
                      boxShadow: artworkShadows,
                    ),
                    child: child,
                  ),
                ),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                // -----------------------------------------------------------
                // Poster interaction surface
                //
                // This Listener is deliberately BELOW the overlay.
                //
                // A protected status/dock region above it wins hit testing and
                // prevents pointer-down from reaching this surface. Therefore
                // no media-card animation begins for overlay interaction.
                // -----------------------------------------------------------
                Positioned.fill(
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: _isInteractive
                        ? _handleSurfacePointerDown
                        : null,
                    onPointerMove: _isInteractive
                        ? _handleSurfacePointerMove
                        : null,
                    onPointerUp: _isInteractive
                        ? _handleSurfacePointerUp
                        : null,
                    onPointerCancel: _isInteractive
                        ? _handleSurfacePointerCancel
                        : null,
                    child: _buildArtwork(context),
                  ),
                ),

                // -----------------------------------------------------------
                // Artwork press scrim
                //
                // The artwork darkens slightly while overlay controls stay
                // crisp and readable.
                // -----------------------------------------------------------
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _pressController,
                      builder: (BuildContext context, Widget? child) {
                        final double opacity = _resolveScrimOpacity(
                          _pressController.value,
                        );

                        if (opacity <= 0) {
                          return const SizedBox.shrink();
                        }

                        return ClipRRect(
                          borderRadius: widget.borderRadius,
                          clipBehavior: widget.clipBehavior,
                          child: ColoredBox(
                            color: Colors.black.withValues(alpha: opacity),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // -----------------------------------------------------------
                // Poster overlays
                //
                // Interactive controls live above the raw poster surface.
                //
                // Passive elements use IgnorePointer inside the overlay and
                // therefore continue to behave like poster artwork.
                // -----------------------------------------------------------
                if (widget.overlay != null)
                  Positioned.fill(child: widget.overlay!),

                // -----------------------------------------------------------
                // Confirmed-hold frame
                //
                // Ordinary press/tap feedback stays quiet: compression,
                // downward travel and artwork darkening only.
                //
                // The primary outline + restrained glow are reserved for a
                // confirmed long press so Quick Actions has a clearly stronger
                // interaction state without making normal navigation look
                // selected.
                // -----------------------------------------------------------
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _pressController,
                      builder: (BuildContext context, Widget? child) {
                        final double holdOpacity = _resolveHoldOutlineOpacity(
                          _pressController.value,
                        );

                        final double glowOpacity = _resolveHoldGlowOpacity(
                          _pressController.value,
                        );

                        if (holdOpacity <= 0 && glowOpacity <= 0) {
                          return const SizedBox.shrink();
                        }

                        return DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: widget.borderRadius,
                            border: Border.all(
                              color: colors.primary.withValues(
                                alpha: holdOpacity,
                              ),
                              width: 1.30,
                            ),
                            boxShadow: glowOpacity <= 0
                                ? const <BoxShadow>[]
                                : <BoxShadow>[
                                    BoxShadow(
                                      color: colors.primary.withValues(
                                        alpha: glowOpacity,
                                      ),
                                      blurRadius: 11,
                                      spreadRadius: 0.35,
                                    ),
                                  ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // -----------------------------------------------------------
                // Keyboard focus
                // -----------------------------------------------------------
                if (_showFocusHighlight && _keyboardActivatable)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: widget.borderRadius,
                          border: Border.all(color: colors.primary, width: 2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!_keyboardActivatable) {
      return poster;
    }

    return FocusableActionDetector(
      enabled: true,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mouseCursor: resolvedMouseCursor,
      onShowFocusHighlight: _handleFocusHighlight,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: _handleKeyboardActivate,
        ),
      },
      child: poster,
    );
  }

  // ===========================================================================
  // Artwork
  // ===========================================================================

  Widget _buildArtwork(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    Widget artwork = DecoratedBox(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colors.surfaceContainerHighest,
      ),
      child: SizedBox.expand(child: widget.artwork),
    );

    // Clip only the actual artwork. The optical shadow is owned by the outer
    // press builder and therefore remains outside this clipping boundary.
    artwork = ClipRRect(
      borderRadius: widget.borderRadius,
      clipBehavior: widget.clipBehavior,
      child: artwork,
    );

    if (widget.excludeArtworkFromSemantics) {
      artwork = ExcludeSemantics(child: artwork);
    }

    final Object? heroTag = widget.heroTag;

    if (heroTag != null) {
      artwork = Hero(
        tag: heroTag,
        transitionOnUserGestures: widget.heroTransitionOnUserGestures,
        child: artwork,
      );
    }

    // Keep the shared-element transition artwork-only. The subtle physical rim
    // stays with the poster frame instead of becoming temporary Hero UI.
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        border: Border.all(
          color: CinearaElevation.artworkRimColor(context),
          width: CinearaElevation.artworkRimWidth(context),
        ),
      ),
      child: artwork,
    );
  }

  // ===========================================================================
  // Poster-surface raw pointer feedback
  // ===========================================================================

  void _handleSurfacePointerDown(PointerDownEvent event) {
    if (_activeSurfacePointer != null) {
      return;
    }

    // Only the primary pointer action represents normal media-card activation.
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

    // Reduced-motion mode does not need an ordinary decorative pointer-down
    // animation. A confirmed long press can still show its static held state.
    if (_reduceMotion) {
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

    // Mouse/trackpad primary clicks are not ambiguous with a finger drag, so
    // desktop keeps the immediate response.
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

    if (_reduceMotion) {
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

    // A small drag is enough to make this look like scrolling. Cancel the
    // *visual* poster press before Flutter has necessarily rejected the tap.
    // This prevents Grid posters from flashing/compressing during a scroll.
    if (distanceSquared > _visualScrollSlop * _visualScrollSlop) {
      _pressArmTimer?.cancel();

      if (_pressController.value > 0) {
        _releaseVisualFeedbackForScroll();
      }
    }

    // Preserve Flutter's normal gesture tolerance for actual tap eligibility.
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

    if (_reduceMotion) {
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

        _releasePress();
      } else {
        // Long press has already been recognised. Allow its visual confirmation
        // to complete and dispatch the action even if the user releases during
        // the final 135 ms depth transition.
        _releaseAfterLongPressDispatch = true;
      }

      return;
    }

    // GestureDetector.onTap should follow immediately after raw pointer-up.
    //
    // Keep the shallow press alive for a tiny grace period so the explicit tap
    // confirmation can start from it instead of visually snapping to rest.
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

    _releasePress();
  }

  void _schedulePointerUpFallbackRelease() {
    _pointerUpReleaseTimer?.cancel();

    if (_reduceMotion) {
      _surfaceGestureEligible = false;
      _surfacePointerKind = null;
      _releasePress();
      return;
    }

    _pointerUpReleaseTimer = Timer(_pointerUpFallbackDelay, () {
      if (!mounted || _longPressRecognized || _surfacePointerIsDown) {
        return;
      }

      _surfaceGestureEligible = false;
      _surfacePointerKind = null;

      _releasePress();
    });
  }

  // ===========================================================================
  // Tap
  // ===========================================================================

  void _handleTap() {
    // Only a pointer that actually began on the poster interaction surface can
    // dispatch the media-card tap.
    //
    // Status/dock interactions never make this true.
    if (!_surfaceGestureEligible) {
      return;
    }

    _pointerUpReleaseTimer?.cancel();
    _pressArmTimer?.cancel();

    _surfaceGestureEligible = false;
    _surfacePointerKind = null;

    unawaited(_runTapActivation(callback: widget.onTap!));
  }

  void _handleTapCancel() {
    if (!_surfaceGestureEligible) {
      return;
    }

    // Critical:
    //
    // Flutter normally cancels its TapGestureRecognizer when the
    // LongPressGestureRecognizer wins.
    //
    // If the physical pointer is still down, this is not yet evidence that the
    // poster interaction should be abandoned. Keep the surface eligible so
    // _handleLongPressStart can promote the same press into a long press.
    if (_surfacePointerIsDown) {
      return;
    }

    // If long-press recognition has already started, that lifecycle owns the
    // rest of this gesture.
    if (_longPressRecognized) {
      return;
    }

    // No tap was delivered after pointer-up. Let the fallback restore the card.
    _schedulePointerUpFallbackRelease();
  }

  Future<void> _runTapActivation({required VoidCallback callback}) async {
    final int generation = ++_interactionGeneration;

    if (_reduceMotion) {
      _pressController
        ..stop()
        ..value = _pressedIntensity;

      callback();
      _releasePress();

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

    // Normal navigation never gains an outline. The return begins before the
    // callback so the compressed/darkened poster resolves naturally into the
    // route transition.
    _releasePress();

    callback();
  }

  // ===========================================================================
  // Long press
  // ===========================================================================

  void _handleLongPressStart(LongPressStartDetails details) {
    // A long press is a poster action only if pointer-down came from the poster
    // interaction surface. Interactive overlay controls never set this flag.
    if (!_surfaceGestureEligible) {
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

    if (_reduceMotion) {
      _pressController
        ..stop()
        ..value = 1;
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

    // If the user released while the depth animation was completing, dispatch
    // the already-recognised action first, then restore the poster.
    if (_releaseAfterLongPressDispatch || !_surfacePointerIsDown) {
      _surfaceGestureEligible = false;

      _longPressRecognized = false;
      _longPressActionDispatched = false;
      _releaseAfterLongPressDispatch = false;

      _surfacePointerKind = null;

      _releasePress();
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (!_surfaceGestureEligible || !_longPressRecognized) {
      return;
    }

    if (!_longPressActionDispatched) {
      // Recognition already occurred. Do not cancel the action merely because
      // the user released during the final visual confirmation phase.
      _releaseAfterLongPressDispatch = true;
      return;
    }

    _surfaceGestureEligible = false;

    _longPressRecognized = false;
    _longPressActionDispatched = false;
    _releaseAfterLongPressDispatch = false;

    _surfacePointerKind = null;

    _releasePress();
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

    _releasePress();
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
  // Press animation
  // ===========================================================================

  Future<bool> _animatePressTo(
    double value, {
    required Duration duration,
    required Curve curve,
  }) async {
    final double target = value.clamp(0.0, 1.0).toDouble();

    if (_reduceMotion) {
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

  void _releasePress() {
    _pointerUpReleaseTimer?.cancel();
    _pressArmTimer?.cancel();

    if (_reduceMotion) {
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

  void _resetInteractionImmediately() {
    _interactionGeneration++;

    _pointerUpReleaseTimer?.cancel();
    _pressArmTimer?.cancel();

    _activeSurfacePointer = null;
    _surfacePointerDownPosition = null;
    _surfacePointerKind = null;

    _surfaceGestureEligible = false;
    _longPressRecognized = false;
    _longPressActionDispatched = false;
    _releaseAfterLongPressDispatch = false;

    _pressController
      ..stop()
      ..value = 0;
  }

  // ===========================================================================
  // Visual interpolation
  // ===========================================================================

  double _resolveScale(double progress) {
    if (_reduceMotion) {
      return 1;
    }

    final double t = progress.clamp(0.0, 1.0).toDouble();

    return 1 - (_maximumScaleCompression * t);
  }

  double _resolveVerticalTravel(double progress) {
    if (_reduceMotion) {
      return 0;
    }

    final double t = progress.clamp(0.0, 1.0).toDouble();

    return _maximumVerticalTravel * Curves.easeInOutCubic.transform(t);
  }

  double _resolveScrimOpacity(double progress) {
    final double t = progress.clamp(0.0, 1.0).toDouble();

    if (t <= 0) {
      return 0;
    }

    if (_reduceMotion) {
      if (_longPressRecognized) {
        return 0.050;
      }

      return 0.026;
    }

    // Keep ordinary taps quiet while allowing a confirmed hold to acquire more
    // visual depth.
    if (t <= _tapActivationIntensity) {
      final double local = (t / _tapActivationIntensity)
          .clamp(0.0, 1.0)
          .toDouble();

      return 0.040 * Curves.easeInOutCubic.transform(local);
    }

    final double local =
        ((t - _tapActivationIntensity) / (1 - _tapActivationIntensity))
            .clamp(0.0, 1.0)
            .toDouble();

    return 0.040 +
        ((_maximumScrimOpacity - 0.040) *
            Curves.easeInOutCubic.transform(local));
  }

  double _resolveHoldOutlineOpacity(double progress) {
    if (!_longPressRecognized) {
      return 0;
    }

    if (_reduceMotion) {
      return _maximumHoldOutlineOpacity;
    }

    final double local = ((progress - 0.50) / 0.50).clamp(0.0, 1.0).toDouble();

    return _maximumHoldOutlineOpacity * Curves.easeInOutCubic.transform(local);
  }

  double _resolveHoldGlowOpacity(double progress) {
    if (!_longPressRecognized || _reduceMotion) {
      return 0;
    }

    final double local = ((progress - 0.66) / 0.34).clamp(0.0, 1.0).toDouble();

    return _maximumHoldGlowOpacity * Curves.easeInOutCubic.transform(local);
  }

  // ===========================================================================
  // Focus / keyboard
  // ===========================================================================

  void _handleFocusHighlight(bool value) {
    if (_showFocusHighlight == value) {
      return;
    }

    setState(() {
      _showFocusHighlight = value;
    });
  }

  Object? _handleKeyboardActivate(ActivateIntent intent) {
    final VoidCallback? callback = widget.onTap;

    if (callback != null) {
      unawaited(_runTapActivation(callback: callback));
    }

    return null;
  }

  // ===========================================================================
  // Accessibility actions
  // ===========================================================================

  void _handleSemanticTap() {
    final VoidCallback? callback = widget.onTap;

    if (callback == null) {
      return;
    }

    unawaited(_runTapActivation(callback: callback));
  }

  void _handleSemanticLongPress() {
    final VoidCallback? callback = widget.onLongPress;

    if (callback == null) {
      return;
    }

    // Semantic actions are explicit accessibility actions and do not have a
    // physical pointer/hold phase. Keep them immediate and do not synthesize a
    // haptic or artificial hold animation.
    callback();
  }

  // ===========================================================================
  // Semantics
  // ===========================================================================

  String? get _resolvedSemanticLabel {
    final String? label = widget.semanticLabel?.trim();

    if (label == null || label.isEmpty) {
      return null;
    }

    return label;
  }

  String? get _resolvedSemanticHint {
    final String? hint = widget.semanticHint?.trim();

    if (hint == null || hint.isEmpty) {
      return null;
    }

    return hint;
  }
}
