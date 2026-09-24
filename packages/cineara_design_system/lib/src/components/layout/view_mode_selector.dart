import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../foundations/shapes/cineara_shapes.dart';
import '../../foundations/tokens/accessibility.dart';
import '../../foundations/tokens/motion.dart';
import 'view_mode.dart';

/// Compact selector for switching between Cineara's grid and list layouts.
///
/// A shared capsule flows between destinations and briefly expands while
/// travelling. Icon emphasis follows the capsule position so the entire control
/// reads as one continuous state transition.
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
  static const double _indicatorStretch = 13;

  static const double _iconSize = 18;

  late final AnimationController _controller;

  late double _fromSelection;
  late double _toSelection;

  @override
  void initState() {
    super.initState();

    final double initialSelection = _selectionFor(widget.value);

    _fromSelection = initialSelection;
    _toSelection = initialSelection;

    _controller = AnimationController(
      vsync: this,
      value: 1,
      duration: CinearaMotion.selectionTransition,
    );
  }

  @override
  void didUpdateWidget(CinearaViewModeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value == widget.value) {
      return;
    }

    _fromSelection = _currentSelection();
    _toSelection = _selectionFor(widget.value);

    final Duration duration = CinearaAccessibility.adaptiveDuration(
      context,
      CinearaMotion.selectionTransition,
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
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      enabled: widget.enabled,
      child: SizedBox(
        height: 48,
        child: Center(
          child: SizedBox(
            width: _width,
            height: _height,
            child: Material(
              color: colors.surfaceContainerHigh.withValues(
                alpha: widget.enabled ? 0.68 : 0.42,
              ),
              shape: CinearaShapes.capsule(side: _outerBorder(context)),
              clipBehavior: Clip.antiAlias,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  final double rawProgress = _controller.value;
                  final double selection = _currentSelection();

                  return Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      _buildIndicator(
                        context,
                        selection: selection,
                        transitionProgress: rawProgress,
                      ),
                      _buildDestinations(context, selection: selection),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(
    BuildContext context, {
    required double selection,
    required double transitionProgress,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final double stretchProgress = _stretchProgress(transitionProgress);

    final double indicatorWidth =
        _indicatorWidth + (_indicatorStretch * stretchProgress);

    final double availableWidth = _width - (_outerPadding * 2) - indicatorWidth;

    final double logicalPosition = availableWidth * selection;

    final double liftScale = _indicatorLiftScale(stretchProgress);

    return PositionedDirectional(
      start: _outerPadding + logicalPosition,
      top: (_height - _indicatorHeight) / 2,
      width: indicatorWidth,
      height: _indicatorHeight,
      child: Transform.scale(
        scale: liftScale,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: widget.enabled
                ? colors.primaryContainer
                : colors.surfaceContainerHighest,
            shape: CinearaShapes.capsule(side: _indicatorBorder(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildDestinations(BuildContext context, {required double selection}) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _CinearaViewModeButton(
            mode: CinearaViewMode.grid,
            selected: widget.value == CinearaViewMode.grid,
            selectionProgress: 1 - selection,
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
            selectionProgress: selection,
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

  double _currentSelection() {
    if (_controller.value >= 1) {
      return _toSelection;
    }

    final double progress = CinearaMotion.bubbleCurve.transform(
      _controller.value,
    );

    return _fromSelection + ((_toSelection - _fromSelection) * progress);
  }

  double _stretchProgress(double transitionProgress) {
    if (_fromSelection == _toSelection) {
      return 0;
    }

    return math.sin(math.pi * transitionProgress).clamp(0.0, 1.0);
  }

  double _indicatorLiftScale(double stretchProgress) {
    final double lift = CinearaMotion.bubbleLiftScale - 1;

    return 1 + (lift * stretchProgress);
  }

  double _selectionFor(CinearaViewMode mode) {
    return switch (mode) {
      CinearaViewMode.grid => 0,
      CinearaViewMode.list => 1,
    };
  }

  void _select(CinearaViewMode mode) {
    if (!widget.enabled || mode == widget.value) {
      return;
    }

    widget.onChanged(mode);
  }

  BorderSide _outerBorder(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);

    return BorderSide(
      color: highContrast
          ? colors.outline
          : colors.outlineVariant.withValues(alpha: 0.22),
      width: highContrast ? 1.5 : 0.75,
    );
  }

  BorderSide _indicatorBorder(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);

    if (!highContrast) {
      return BorderSide.none;
    }

    return BorderSide(color: colors.primary, width: 1.5);
  }
}

/// Interaction destination inside [CinearaViewModeSelector].
///
/// Selection emphasis is derived from the position of the shared capsule so
/// icon feedback remains synchronized with the surrounding surface motion.
final class _CinearaViewModeButton extends StatelessWidget {
  const _CinearaViewModeButton({
    required this.mode,
    required this.selected,
    required this.selectionProgress,
    required this.enabled,
    required this.icon,
    required this.iconSize,
    required this.label,
    required this.onPressed,
  });

  final CinearaViewMode mode;

  final bool selected;
  final double selectionProgress;
  final bool enabled;

  final IconData icon;
  final double iconSize;

  final String label;

  final ValueChanged<CinearaViewMode> onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final double emphasis = selectionProgress.clamp(0.0, 1.0);

    final Color foregroundColor = _foregroundColor(colors, emphasis: emphasis);

    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        selected: selected,
        enabled: enabled,
        label: label,
        onTap: enabled ? _handlePressed : null,
        child: ExcludeSemantics(
          child: InkWell(
            onTap: enabled ? _handlePressed : null,
            customBorder: CinearaShapes.capsule(),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (!enabled) {
                return Colors.transparent;
              }

              if (states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.focused)) {
                return colors.onSurface.withValues(alpha: 0.055);
              }

              if (states.contains(WidgetState.hovered)) {
                return colors.onSurface.withValues(alpha: 0.03);
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

  Color _foregroundColor(ColorScheme colors, {required double emphasis}) {
    if (!enabled) {
      return colors.onSurface.withValues(alpha: 0.38);
    }

    final Color inactive = colors.onSurfaceVariant.withValues(alpha: 0.78);
    final Color active = colors.onPrimaryContainer;

    return Color.lerp(inactive, active, emphasis)!;
  }

  void _handlePressed() {
    onPressed(mode);
  }
}
