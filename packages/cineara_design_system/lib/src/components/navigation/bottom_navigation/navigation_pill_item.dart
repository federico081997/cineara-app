import 'package:flutter/material.dart';

import '../../../foundations/tokens/accessibility.dart';
import '../../../foundations/tokens/geometry.dart';
import '../../../foundations/tokens/motion.dart';
import '../../interactions/press_scale.dart';
import 'navigation_destination.dart';
import 'navigation_pill_metrics.dart';
import 'navigation_pill_style.dart';

/// One interactive destination inside [CinearaNavigationPill].
///
/// The bottom navigation is visually icon-only. Destination labels remain
/// available through tooltips and accessibility semantics.
///
/// The parent navigation surface owns the moving selection capsule so one
/// shared highlight can animate continuously between destinations.
///
/// The interactive region intentionally follows the soft capsule geometry of
/// the moving selection indicator rather than the chamfered geometry of the
/// outer Cineara navigation surface. This keeps destination interactions
/// visually familiar while the surrounding frame carries the stronger Cineara
/// identity.
final class CinearaNavigationPillItem extends StatefulWidget {
  const CinearaNavigationPillItem({
    required this.destination,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  /// Destination represented by this item.
  final CinearaNavigationDestination destination;

  /// Whether this destination is currently selected.
  final bool selected;

  /// Called when the destination is activated.
  final VoidCallback onPressed;

  @override
  State<CinearaNavigationPillItem> createState() =>
      _CinearaNavigationPillItemState();
}

final class _CinearaNavigationPillItemState
    extends State<CinearaNavigationPillItem> {
  bool _pressed = false;

  void _handleHighlightChanged(bool value) {
    if (_pressed == value) {
      return;
    }

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transitionDuration = CinearaAccessibility.adaptiveDuration(
      context,
      CinearaMotion.fast,
    );

    final iconSize = CinearaNavigationPillMetrics.iconSizeFor(context);

    final selectedIconScale = CinearaNavigationPillMetrics.selectedIconScaleFor(
      context,
    );

    final icon = widget.selected
        ? widget.destination.effectiveSelectedIcon
        : widget.destination.icon;

    final iconColor = CinearaNavigationPillStyle.iconColor(
      context,
      selected: widget.selected,
    );

    final interactionRadius = BorderRadius.circular(
      CinearaGeometry.capsuleRadius,
    );

    final visual = InkWell(
      onTap: widget.onPressed,
      onHighlightChanged: _handleHighlightChanged,
      enableFeedback: true,
      excludeFromSemantics: true,

      // The moving indicator already provides the primary selection animation.
      // Disabling the default Material splash avoids competing visual effects.
      splashFactory: NoSplash.splashFactory,
      overlayColor: CinearaNavigationPillStyle.itemOverlay(context),

      // Individual destinations retain capsule interaction geometry even
      // though the surrounding navigation container uses Cineara's chamfered
      // frame.
      borderRadius: interactionRadius,

      child: CinearaPressScale(
        pressed: _pressed,
        child: Center(
          child: AnimatedSlide(
            offset: widget.selected ? const Offset(0, -0.05) : Offset.zero,
            duration: transitionDuration,
            curve: CinearaMotion.standardCurve,
            child: AnimatedScale(
              scale: widget.selected ? selectedIconScale : 1,
              duration: transitionDuration,
              curve: CinearaMotion.standardCurve,
              child: AnimatedSwitcher(
                duration: transitionDuration,
                switchInCurve: CinearaMotion.standardCurve,
                switchOutCurve: CinearaMotion.standardCurve,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Icon(
                  icon,
                  key: ValueKey<bool>(widget.selected),
                  size: iconSize,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Tooltip(
      message: widget.destination.label,
      excludeFromSemantics: true,
      child: Semantics(
        container: true,
        button: true,
        selected: widget.selected,
        label: widget.destination.effectiveSemanticLabel,
        onTap: widget.onPressed,
        child: ExcludeSemantics(child: visual),
      ),
    );
  }
}
