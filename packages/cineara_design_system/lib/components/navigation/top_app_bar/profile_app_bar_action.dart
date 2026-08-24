import 'package:flutter/material.dart';

import '../../../tokens/motion.dart';
import '../../identity/avatar.dart';
import 'top_app_bar_metrics.dart';
import 'top_app_bar_style.dart';

/// Profile action used in Cineara's top application bar.
///
/// The control uses the same accessible hit-target sizing as other top-bar
/// actions while restricting its visual interaction feedback to the avatar
/// itself.
///
/// Avatar image and fallback presentation are delegated to [CinearaAvatar].
final class CinearaProfileAppBarAction extends StatefulWidget {
  const CinearaProfileAppBarAction({
    required this.semanticLabel,
    required this.onPressed,
    this.imageProvider,
    this.fallbackInitials,
    super.key,
  });

  /// Localized tooltip and accessibility label.
  final String semanticLabel;

  /// Opens the profile experience.
  ///
  /// When null, the action is disabled.
  final VoidCallback? onPressed;

  /// Optional profile image.
  final ImageProvider<Object>? imageProvider;

  /// Optional profile initials used when no usable image is available.
  final String? fallbackInitials;

  @override
  State<CinearaProfileAppBarAction> createState() =>
      _CinearaProfileAppBarActionState();
}

final class _CinearaProfileAppBarActionState
    extends State<CinearaProfileAppBarAction> {
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final enabled = widget.onPressed != null;

    final reduceMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;

    final hitExtent = CinearaTopAppBarMetrics.actionExtentFor(context);

    final avatarExtent = CinearaTopAppBarMetrics.avatarExtentFor(context);

    final fallbackIconSize = CinearaTopAppBarMetrics.avatarFallbackIconSizeFor(
      context,
    );

    final initialsFontSize =
        CinearaTopAppBarMetrics.avatarInitialsFontSize *
        CinearaTopAppBarMetrics.initialsScale(context);

    final overlayColor = CinearaTopAppBarStyle.profileOverlay(
      context,
      pressed: _pressed,
      hovered: _hovered,
      focused: _focused,
      enabled: enabled,
    );

    return Tooltip(
      message: widget.semanticLabel,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: widget.semanticLabel,
        onTap: widget.onPressed,
        child: ExcludeSemantics(
          child: SizedBox.square(
            dimension: hitExtent,
            child: Material(
              type: MaterialType.transparency,
              child: InkResponse(
                onTap: widget.onPressed,
                onHighlightChanged: enabled ? _setPressed : null,
                onHover: enabled ? _setHovered : null,
                onFocusChange: _setFocused,
                canRequestFocus: enabled,
                excludeFromSemantics: true,
                containedInkWell: true,
                highlightShape: BoxShape.circle,
                radius: hitExtent / 2,

                // Profile feedback is rendered inside the avatar
                // instead of as a large surrounding circle.
                splashFactory: NoSplash.splashFactory,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,

                child: Center(
                  child: SizedBox.square(
                    dimension: avatarExtent,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
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
                              duration: reduceMotion
                                  ? Duration.zero
                                  : CinearaMotion.press,
                              curve: Curves.easeOutCubic,
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
    );
  }
}
