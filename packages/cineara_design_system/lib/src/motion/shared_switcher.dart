import 'package:flutter/material.dart';

import '../foundations/tokens/motion.dart';

/// Axis along which [CinearaSharedSwitcher] introduces subtle directional
/// movement.
enum CinearaSharedSwitcherAxis { none, horizontal, vertical }

/// Replaces closely related pieces of Cineara UI with a restrained shared
/// transition.
///
/// The supplied [child] should have a stable key identifying its visual state.
/// Motion is removed automatically when accessibility settings request reduced
/// animation.
final class CinearaSharedSwitcher extends StatelessWidget {
  const CinearaSharedSwitcher({
    required this.child,
    super.key,
    this.axis = CinearaSharedSwitcherAxis.none,
    this.reverse = false,
    this.distance = 0.035,
    this.scaleFrom = 0.985,
    this.duration = CinearaMotion.contentTransition,
    this.reverseDuration,
    this.curve = CinearaMotion.enterCurve,
    this.reverseCurve = CinearaMotion.exitCurve,
    this.sizeCurve = CinearaMotion.layoutCurve,
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.hardEdge,
    this.animateSize = true,
    this.layoutBuilder,
  }) : assert(distance >= 0),
       assert(scaleFrom > 0);

  final Widget child;
  final CinearaSharedSwitcherAxis axis;
  final bool reverse;
  final double distance;
  final double scaleFrom;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve curve;
  final Curve reverseCurve;
  final Curve sizeCurve;
  final AlignmentGeometry alignment;
  final Clip clipBehavior;
  final bool animateSize;
  final AnimatedSwitcherLayoutBuilder? layoutBuilder;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool reduceMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;

    final Duration resolvedDuration = reduceMotion ? Duration.zero : duration;
    final Duration resolvedReverseDuration = reduceMotion
        ? Duration.zero
        : (reverseDuration ?? duration);

    final Widget switcher = AnimatedSwitcher(
      duration: resolvedDuration,
      reverseDuration: resolvedReverseDuration,
      switchInCurve: curve,
      switchOutCurve: reverseCurve,
      layoutBuilder: layoutBuilder ?? AnimatedSwitcher.defaultLayoutBuilder,
      transitionBuilder:
          (Widget transitioningChild, Animation<double> animation) {
            if (reduceMotion) {
              return transitioningChild;
            }

            final Animation<Offset> position = Tween<Offset>(
              begin: _beginOffset(context),
              end: Offset.zero,
            ).animate(animation);

            final Animation<double> scale = Tween<double>(
              begin: scaleFrom,
              end: 1,
            ).animate(animation);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: position,
                child: ScaleTransition(
                  scale: scale,
                  alignment: alignment.resolve(Directionality.of(context)),
                  child: transitioningChild,
                ),
              ),
            );
          },
      child: child,
    );

    if (!animateSize || reduceMotion) {
      return switcher;
    }

    return AnimatedSize(
      duration: duration,
      reverseDuration: reverseDuration ?? duration,
      curve: sizeCurve,
      alignment: alignment,
      clipBehavior: clipBehavior,
      child: switcher,
    );
  }

  Offset _beginOffset(BuildContext context) {
    if (axis == CinearaSharedSwitcherAxis.none || distance == 0) {
      return Offset.zero;
    }

    final double direction = reverse ? -1 : 1;

    return switch (axis) {
      CinearaSharedSwitcherAxis.none => Offset.zero,
      CinearaSharedSwitcherAxis.vertical => Offset(0, distance * direction),
      CinearaSharedSwitcherAxis.horizontal => Offset(
        _horizontalDirection(context) * distance * direction,
        0,
      ),
    };
  }

  double _horizontalDirection(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl ? -1 : 1;
  }
}
