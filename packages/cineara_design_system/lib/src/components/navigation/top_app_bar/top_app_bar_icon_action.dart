import 'package:flutter/material.dart';

import '../../../foundations/tokens/accessibility.dart';
import '../../../foundations/tokens/motion.dart';
import 'top_app_bar_metrics.dart';
import 'top_app_bar_style.dart';

/// Standard icon action used in Cineara's top application bar.
///
/// Pointer feedback appears immediately through the shared icon-button style.
/// After activation the highlight is held for one short press interval before
/// the callback runs, giving route and surface transitions a stable visual
/// starting point.
final class CinearaTopAppBarIconAction extends StatefulWidget {
  const CinearaTopAppBarIconAction({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.selectedIcon,
    this.isSelected = false,
    super.key,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String semanticLabel;
  final bool isSelected;
  final VoidCallback? onPressed;

  @override
  State<CinearaTopAppBarIconAction> createState() =>
      _CinearaTopAppBarIconActionState();
}

final class _CinearaTopAppBarIconActionState
    extends State<CinearaTopAppBarIconAction> {
  bool _activating = false;

  Future<void> _activate() async {
    final VoidCallback? callback = widget.onPressed;

    if (callback == null || _activating) {
      return;
    }

    setState(() {
      _activating = true;
    });

    final Duration feedbackDuration = CinearaAccessibility.adaptiveDuration(
      context,
      CinearaMotion.press,
    );

    if (feedbackDuration != Duration.zero) {
      await Future<void>.delayed(feedbackDuration);
    }

    if (!mounted) {
      return;
    }

    callback();

    if (mounted) {
      setState(() {
        _activating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool selected = widget.isSelected || _activating;

    return IconButton(
      tooltip: widget.semanticLabel,
      onPressed: widget.onPressed == null ? null : _activate,
      iconSize: CinearaTopAppBarMetrics.actionIconSizeFor(context),
      style: CinearaTopAppBarStyle.iconAction(context, selected: selected),
      isSelected: selected,
      selectedIcon: Icon(widget.selectedIcon ?? widget.icon),
      icon: Icon(widget.icon),
    );
  }
}
