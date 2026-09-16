import 'package:flutter/material.dart';

import '../../foundations/tokens/accessibility.dart';
import '../../foundations/tokens/motion.dart';

/// Applies Cineara's standard press-scale interaction feedback.
///
/// The animation respects the platform's reduced-motion preference and is
/// intended to be driven by the pressed state of an interactive component.
///
/// This widget does not handle gestures itself. The parent component remains
/// responsible for determining whether it is pressed.
final class CinearaPressScale extends StatelessWidget {
  const CinearaPressScale({
    required this.pressed,
    required this.child,
    this.enabled = true,
    this.scale = CinearaMotion.pressedScale,
    this.duration = CinearaMotion.press,
    this.curve = CinearaMotion.pressCurve,
    super.key,
  });

  final bool pressed;
  final Widget child;
  final bool enabled;
  final double scale;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = CinearaAccessibility.reduceMotion(context);

    return AnimatedScale(
      scale: enabled && pressed && !reduceMotion ? scale : 1,
      duration: reduceMotion ? Duration.zero : duration,
      curve: curve,
      child: child,
    );
  }
}
