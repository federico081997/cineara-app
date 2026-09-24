import 'package:flutter/material.dart';

import '../../../foundations/tokens/accessibility.dart';
import '../../../foundations/tokens/motion.dart';
import '../../identity/avatar.dart';
import 'top_app_bar_metrics.dart';
import 'top_app_bar_style.dart';

/// Profile action used in Cineara's top application bar.
///
/// The accessible hit target surrounds the avatar while visual interaction
/// feedback remains constrained to the avatar surface.
///
/// Press feedback is held through activation so navigation begins only after
/// the interaction has been visually acknowledged.
final class CinearaProfileAppBarAction extends StatefulWidget {
  const CinearaProfileAppBarAction({
    required this.semanticLabel,
    required this.onPressed,
    this.imageProvider,
    this.fallbackInitials,
    this.isSelected = false,
    super.key,
  });

  /// Localized tooltip and accessibility label.
  final String semanticLabel;

  /// Opens the profile experience after interaction feedback completes.
  ///
  /// When null, the action is disabled.
  final VoidCallback? onPressed;

  /// Optional profile image.
  final ImageProvider<Object>? imageProvider;

  /// Optional profile initials used when no usable image is available.
  final String? fallbackInitials;

  /// Whether the profile action represents the active application state.
  final bool isSelected;

  @override
  State<CinearaProfileAppBarAction> createState() =>
      _CinearaProfileAppBarActionState();
}

final class _CinearaProfileAppBarActionState
    extends State<CinearaProfileAppBarAction> {
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;
  bool _activating = false;

  bool get _enabled => widget.onPressed != null;

  bool get _highlighted => widget.isSelected || _pressed || _activating;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) {
      return;
    }

    setState(() {
      _pressed = value;
    });
  }

  void _setHovered(bool value) {
    if (_hovered == value) {
      return;
    }

    setState(() {
      _hovered = value;
    });
  }

  void _setFocused(bool value) {
    if (_focused == value) {
      return;
    }

    setState(() {
      _focused = value;
    });
  }

  Future<void> _activate() async {
    final VoidCallback? callback = widget.onPressed;

    if (callback == null || _activating) {
      return;
    }

    setState(() {
      _activating = true;
      _pressed = false;
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
    final double hitExtent = CinearaTopAppBarMetrics.actionExtentFor(context);

    final double avatarExtent = CinearaTopAppBarMetrics.avatarExtentFor(
      context,
    );

    final double fallbackIconSize =
        CinearaTopAppBarMetrics.avatarFallbackIconSizeFor(context);

    final double initialsFontSize =
        CinearaTopAppBarMetrics.avatarInitialsFontSize *
        CinearaTopAppBarMetrics.initialsScale(context);

    final Duration motionDuration = CinearaAccessibility.adaptiveDuration(
      context,
      CinearaMotion.press,
    );

    final Color overlayColor = CinearaTopAppBarStyle.profileOverlay(
      context,
      pressed: _highlighted,
      hovered: _hovered,
      focused: _focused,
      enabled: _enabled,
    );

    final double scale = _highlighted ? CinearaMotion.pressedScale : 1;

    return Tooltip(
      message: widget.semanticLabel,
      child: Semantics(
        button: true,
        enabled: _enabled,
        selected: widget.isSelected,
        label: widget.semanticLabel,
        onTap: _enabled ? _activate : null,
        child: ExcludeSemantics(
          child: SizedBox.square(
            dimension: hitExtent,
            child: Material(
              type: MaterialType.transparency,
              child: InkResponse(
                onTap: _enabled ? _activate : null,
                onHighlightChanged: _enabled ? _setPressed : null,
                onHover: _enabled ? _setHovered : null,
                onFocusChange: _setFocused,
                canRequestFocus: _enabled,
                excludeFromSemantics: true,
                containedInkWell: true,
                highlightShape: BoxShape.circle,
                radius: hitExtent / 2,
                splashFactory: NoSplash.splashFactory,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                child: Center(
                  child: AnimatedScale(
                    scale: scale,
                    duration: motionDuration,
                    curve: CinearaMotion.pressCurve,
                    child: SizedBox.square(
                      dimension: avatarExtent,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          CinearaAvatar(
                            size: avatarExtent,
                            imageProvider: widget.imageProvider,
                            fallbackInitials: widget.fallbackInitials,
                            fallbackIconSize: fallbackIconSize,
                            initialsFontSize: initialsFontSize,
                          ),
                          ClipOval(
                            child: IgnorePointer(
                              child: AnimatedContainer(
                                duration: motionDuration,
                                curve: CinearaMotion.pressCurve,
                                color: overlayColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
