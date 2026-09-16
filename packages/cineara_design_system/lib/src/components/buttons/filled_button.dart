import 'package:flutter/material.dart';

import '../../foundations/tokens/icon_sizes.dart';
import '../interactions/press_scale.dart';

/// Primary filled action button used throughout the Cineara design system.
///
/// Visual styling is inherited from the application's
/// [FilledButtonThemeData].
///
/// The button uses Cineara's standard press feedback and respects the
/// platform's accessibility motion preferences.
final class CinearaFilledButton extends StatefulWidget {
  const CinearaFilledButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    super.key,
  });

  /// Button label.
  final String label;

  /// Called when the button is pressed.
  ///
  /// When null, the button is disabled.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether the button fills the available horizontal space.
  final bool expand;

  @override
  State<CinearaFilledButton> createState() => _CinearaFilledButtonState();
}

final class _CinearaFilledButtonState extends State<CinearaFilledButton> {
  final WidgetStatesController _statesController = WidgetStatesController();

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _statesController,
      builder: (context, _) {
        final isPressed = _statesController.value.contains(WidgetState.pressed);

        final button = widget.icon == null
            ? FilledButton(
                statesController: _statesController,
                onPressed: widget.onPressed,
                child: Text(widget.label),
              )
            : FilledButton.icon(
                statesController: _statesController,
                onPressed: widget.onPressed,
                icon: Icon(
                  widget.icon,
                  size: CinearaIconSizes.inline,
                  applyTextScaling: true,
                ),
                label: Text(widget.label),
              );

        final animatedButton = CinearaPressScale(
          pressed: isPressed,
          enabled: widget.onPressed != null,
          child: button,
        );

        if (!widget.expand) {
          return animatedButton;
        }

        return SizedBox(width: double.infinity, child: animatedButton);
      },
    );
  }
}
