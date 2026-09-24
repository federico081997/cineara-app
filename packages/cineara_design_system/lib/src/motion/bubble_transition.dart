import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../foundations/tokens/motion.dart';

/// Morphs one compact rounded surface into a larger related surface.
///
/// Both states stay mounted during the transition. Only the currently active
/// state participates in pointer interaction and accessibility semantics.
final class CinearaBubbleTransition extends StatefulWidget {
  const CinearaBubbleTransition({
    required this.expanded,
    required this.collapsedChild,
    required this.expandedChild,
    super.key,
    this.collapsedWidth = 44,
    this.collapsedHeight = 44,
    this.expandedWidth,
    this.expandedHeight = 44,
    this.alignment = AlignmentDirectional.centerEnd,
    this.collapsedBorderRadius = const BorderRadius.all(Radius.circular(999)),
    this.expandedBorderRadius = const BorderRadius.all(Radius.circular(999)),
    this.duration = CinearaMotion.bubbleTransition,
    this.reverseDuration,
    this.curve = CinearaMotion.bubbleCurve,
    this.reverseCurve = CinearaMotion.exitCurve,
    this.clipBehavior = Clip.antiAlias,
    this.animateOpacity = true,
    this.animateScale = true,
  });

  final bool expanded;
  final Widget collapsedChild;
  final Widget expandedChild;
  final double collapsedWidth;
  final double collapsedHeight;
  final double? expandedWidth;
  final double expandedHeight;
  final AlignmentGeometry alignment;
  final BorderRadiusGeometry collapsedBorderRadius;
  final BorderRadiusGeometry expandedBorderRadius;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve curve;
  final Curve reverseCurve;
  final Clip clipBehavior;
  final bool animateOpacity;
  final bool animateScale;

  @override
  State<CinearaBubbleTransition> createState() =>
      _CinearaBubbleTransitionState();
}

final class _CinearaBubbleTransitionState extends State<CinearaBubbleTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _reduceMotion {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: widget.expanded ? 1 : 0,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration ?? widget.duration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotionSettings();
  }

  @override
  void didUpdateWidget(CinearaBubbleTransition oldWidget) {
    super.didUpdateWidget(oldWidget);

    _controller
      ..duration = _reduceMotion ? Duration.zero : widget.duration
      ..reverseDuration = _reduceMotion
          ? Duration.zero
          : (widget.reverseDuration ?? widget.duration);

    if (oldWidget.expanded != widget.expanded) {
      widget.expanded ? _controller.forward() : _controller.reverse();
    }
  }

  void _syncMotionSettings() {
    _controller
      ..duration = _reduceMotion ? Duration.zero : widget.duration
      ..reverseDuration = _reduceMotion
          ? Duration.zero
          : (widget.reverseDuration ?? widget.duration);

    if (_reduceMotion) {
      _controller.value = widget.expanded ? 1 : 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double expandedWidth =
            widget.expandedWidth ?? constraints.maxWidth;

        assert(
          expandedWidth.isFinite,
          'CinearaBubbleTransition requires a bounded width when expandedWidth '
          'is not supplied.',
        );

        return AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final bool reversing =
                _controller.status == AnimationStatus.reverse;
            final Curve activeCurve = reversing
                ? widget.reverseCurve
                : widget.curve;
            final double progress = activeCurve.transform(_controller.value);

            final double width = lerpDouble(
              widget.collapsedWidth,
              expandedWidth,
              progress,
            )!;
            final double height = lerpDouble(
              widget.collapsedHeight,
              widget.expandedHeight,
              progress,
            )!;

            final BorderRadius borderRadius = BorderRadiusGeometry.lerp(
              widget.collapsedBorderRadius,
              widget.expandedBorderRadius,
              progress,
            )!.resolve(Directionality.of(context));

            return Align(
              alignment: widget.alignment,
              child: SizedBox(
                width: width,
                height: height,
                child: ClipRRect(
                  borderRadius: borderRadius,
                  clipBehavior: widget.clipBehavior,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      _BubbleStateLayer(
                        active: !widget.expanded,
                        opacity: widget.animateOpacity ? 1 - progress : 1,
                        scale: widget.animateScale
                            ? lerpDouble(
                                1,
                                CinearaMotion.bubbleExitScale,
                                progress,
                              )!
                            : 1,
                        child: widget.collapsedChild,
                      ),
                      _BubbleStateLayer(
                        active: widget.expanded,
                        opacity: widget.animateOpacity ? progress : 1,
                        scale: widget.animateScale
                            ? lerpDouble(
                                CinearaMotion.bubbleEnterScale,
                                1,
                                progress,
                              )!
                            : 1,
                        child: widget.expandedChild,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

final class _BubbleStateLayer extends StatelessWidget {
  const _BubbleStateLayer({
    required this.active,
    required this.opacity,
    required this.scale,
    required this.child,
  });

  final bool active;
  final double opacity;
  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !active,
      child: ExcludeSemantics(
        excluding: !active,
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0).toDouble(),
          child: Transform.scale(scale: scale, child: child),
        ),
      ),
    );
  }
}
