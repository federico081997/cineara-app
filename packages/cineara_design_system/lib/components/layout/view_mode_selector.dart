import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../shapes/cineara_shapes.dart';
import '../../../tokens/accessibility.dart';
import '../../../tokens/motion.dart';
import 'view_mode.dart';

/// Compact selector for switching between Cineara's grid and list layouts.
///
/// Selection is represented by a single animated capsule that stretches toward
/// the newly selected destination, travels through the outer track, and then
/// settles back to its resting size.
///
/// This gives the selector a subtle flowing motion while keeping it visually
/// restrained enough for secondary page actions.
final class CinearaViewModeSelector extends StatefulWidget {
  const CinearaViewModeSelector({
    required this.value,
    required this.onChanged,
    required this.gridLabel,
    required this.listLabel,
    this.enabled = true,
    super.key,
  });

  final CinearaViewMode value;

  final ValueChanged<CinearaViewMode> onChanged;

  final String gridLabel;
  final String listLabel;

  final bool enabled;

  @override
  State<CinearaViewModeSelector> createState() =>
      _CinearaViewModeSelectorState();
}

final class _CinearaViewModeSelectorState extends State<CinearaViewModeSelector>
    with SingleTickerProviderStateMixin {
  static const double _width = 82;
  static const double _height = 34;

  static const double _outerPadding = 3;

  static const double _indicatorWidth = 35;
  static const double _indicatorHeight = 28;

  /// Maximum additional width reached around the middle of the transition.
  ///
  /// Keeping this restrained avoids making the motion look elastic or playful.
  static const double _indicatorStretch = 13;

  static const double _iconSize = 18;

  late final AnimationController _controller;

  late CinearaViewMode _fromMode;
  late CinearaViewMode _toMode;

  @override
  void initState() {
    super.initState();

    _fromMode = widget.value;
    _toMode = widget.value;

    _controller = AnimationController(vsync: this, value: 1);
  }

  @override
  void didUpdateWidget(CinearaViewModeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value == widget.value) {
      return;
    }

    _fromMode = oldWidget.value;
    _toMode = widget.value;

    final duration = CinearaAccessibility.adaptiveDuration(
      context,
      CinearaMotion.slow,
    );

    if (duration == Duration.zero) {
      _controller.value = 1;
      return;
    }

    _controller
      ..duration = duration
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      enabled: widget.enabled,
      child: SizedBox(
        // The visible selector remains compact while the surrounding region
        // preserves a comfortable touch target.
        height: 48,
        child: Center(
          child: SizedBox(
            width: _width,
            height: _height,
            child: Material(
              color: colors.surfaceContainerHigh.withValues(
                alpha: widget.enabled ? .68 : .42,
              ),
              shape: CinearaShapes.capsule(side: _outerBorder(context)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildAnimatedIndicator(context),
                  _buildDestinations(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIndicator(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final rawProgress = _controller.value;

        final positionProgress = CurvedAnimation(
          parent: _controller,
          curve: CinearaMotion.standardCurve,
        ).value;

        final stretchProgress = math.sin(math.pi * rawProgress);

        final indicatorWidth =
            _indicatorWidth + (_indicatorStretch * stretchProgress);

        final availableWidth = _width - (_outerPadding * 2) - indicatorWidth;

        final fromPosition = _positionFor(_fromMode, availableWidth);

        final toPosition = _positionFor(_toMode, availableWidth);

        final left =
            fromPosition + ((toPosition - fromPosition) * positionProgress);

        return PositionedDirectional(
          start: _outerPadding + left,
          top: (_height - _indicatorHeight) / 2,
          width: indicatorWidth,
          height: _indicatorHeight,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: widget.enabled
                  ? colors.primaryContainer
                  : colors.surfaceContainerHighest,
              shape: CinearaShapes.capsule(side: _indicatorBorder(context)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDestinations(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CinearaViewModeButton(
            mode: CinearaViewMode.grid,
            selected: widget.value == CinearaViewMode.grid,
            enabled: widget.enabled,
            icon: Icons.grid_view_rounded,
            iconSize: _iconSize,
            label: widget.gridLabel,
            onPressed: _select,
          ),
        ),
        Expanded(
          child: _CinearaViewModeButton(
            mode: CinearaViewMode.list,
            selected: widget.value == CinearaViewMode.list,
            enabled: widget.enabled,
            icon: Icons.view_list_rounded,
            iconSize: _iconSize,
            label: widget.listLabel,
            onPressed: _select,
          ),
        ),
      ],
    );
  }

  double _positionFor(CinearaViewMode mode, double availableWidth) {
    return switch (mode) {
      CinearaViewMode.grid => 0,
      CinearaViewMode.list => availableWidth,
    };
  }

  void _select(CinearaViewMode mode) {
    if (!widget.enabled || mode == widget.value) {
      return;
    }

    widget.onChanged(mode);
  }

  BorderSide _outerBorder(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final highContrast = MediaQuery.highContrastOf(context);

    return BorderSide(
      color: highContrast
          ? colors.outline
          : colors.outlineVariant.withValues(alpha: .22),
      width: highContrast ? 1.5 : .75,
    );
  }

  BorderSide _indicatorBorder(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final highContrast = MediaQuery.highContrastOf(context);

    if (!highContrast) {
      return BorderSide.none;
    }

    return BorderSide(color: colors.primary, width: 1.5);
  }
}

/// One interaction destination inside [CinearaViewModeSelector].
///
/// The moving selection surface is owned entirely by the parent. This widget
/// handles only interaction, semantics, tooltip presentation, and icon state.
final class _CinearaViewModeButton extends StatelessWidget {
  const _CinearaViewModeButton({
    required this.mode,
    required this.selected,
    required this.enabled,
    required this.icon,
    required this.iconSize,
    required this.label,
    required this.onPressed,
  });

  final CinearaViewMode mode;

  final bool selected;
  final bool enabled;

  final IconData icon;
  final double iconSize;

  final String label;

  final ValueChanged<CinearaViewMode> onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final foregroundColor = !enabled
        ? colors.onSurface.withValues(alpha: .38)
        : selected
        ? colors.onPrimaryContainer
        : colors.onSurfaceVariant.withValues(alpha: .78);

    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        selected: selected,
        enabled: enabled,
        label: label,
        onTap: enabled
            ? () {
                onPressed(mode);
              }
            : null,
        child: ExcludeSemantics(
          child: InkWell(
            onTap: enabled
                ? () {
                    onPressed(mode);
                  }
                : null,
            customBorder: CinearaShapes.capsule(),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (!enabled) {
                return Colors.transparent;
              }

              if (states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.focused)) {
                return colors.onSurface.withValues(alpha: .055);
              }

              if (states.contains(WidgetState.hovered)) {
                return colors.onSurface.withValues(alpha: .03);
              }

              return Colors.transparent;
            }),
            child: Center(
              child: Icon(icon, size: iconSize, color: foregroundColor),
            ),
          ),
        ),
      ),
    );
  }
}
