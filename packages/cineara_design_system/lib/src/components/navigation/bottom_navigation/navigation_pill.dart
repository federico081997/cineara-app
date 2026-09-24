import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../foundations/tokens/accessibility.dart';
import '../../../foundations/tokens/motion.dart';
import 'navigation_destination.dart';
import 'navigation_pill_item.dart';
import 'navigation_pill_metrics.dart';
import 'navigation_pill_style.dart';

/// Cineara's persistent floating bottom-navigation control.
///
/// A shared selection surface flows continuously between destinations. The outer
/// surface and active indicator use the same navigation corner radius so the
/// selected state does not become a more rounded capsule inside the bar.
final class CinearaNavigationPill extends StatelessWidget {
  const CinearaNavigationPill({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  }) : assert(destinations.length >= 2),
       assert(destinations.length <= 5),
       assert(selectedIndex >= 0 && selectedIndex < destinations.length);

  final List<CinearaNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final Duration movementDuration = CinearaAccessibility.adaptiveDuration(
      context,
      CinearaMotion.selectionTransition,
    );

    final double maxWidth = CinearaNavigationPillMetrics.maxWidthFor(context);
    final double height = CinearaNavigationPillMetrics.heightFor(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: CinearaNavigationPillMetrics.horizontalMargin,
          end: CinearaNavigationPillMetrics.horizontalMargin,
          bottom: CinearaNavigationPillMetrics.bottomMargin,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SizedBox(
              width: double.infinity,
              height: height,
              child: Material(
                color: CinearaNavigationPillStyle.surfaceColor(context),
                elevation: CinearaNavigationPillStyle.elevation,
                shadowColor: CinearaNavigationPillStyle.shadowColor(context),
                shape: CinearaNavigationPillStyle.shape(context),
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return _NavigationPillLayout(
                      destinations: destinations,
                      selectedIndex: selectedIndex,
                      onDestinationSelected: onDestinationSelected,
                      movementDuration: movementDuration,
                      availableWidth: constraints.maxWidth,
                      availableHeight: constraints.maxHeight,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _NavigationPillLayout extends StatefulWidget {
  const _NavigationPillLayout({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.movementDuration,
    required this.availableWidth,
    required this.availableHeight,
  });

  final List<CinearaNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Duration movementDuration;
  final double availableWidth;
  final double availableHeight;

  @override
  State<_NavigationPillLayout> createState() => _NavigationPillLayoutState();
}

final class _NavigationPillLayoutState extends State<_NavigationPillLayout>
    with SingleTickerProviderStateMixin {
  static const double _maximumStretch = 14;

  late final AnimationController _controller;
  late double _fromSelection;
  late double _toSelection;

  @override
  void initState() {
    super.initState();

    final double selection = widget.selectedIndex.toDouble();
    _fromSelection = selection;
    _toSelection = selection;

    _controller = AnimationController(
      vsync: this,
      value: 1,
      duration: widget.movementDuration,
    );
  }

  @override
  void didUpdateWidget(_NavigationPillLayout oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.movementDuration != widget.movementDuration) {
      _controller.duration = widget.movementDuration;
    }

    if (oldWidget.selectedIndex == widget.selectedIndex) {
      return;
    }

    _fromSelection = _currentSelection();
    _toSelection = widget.selectedIndex.toDouble();

    if (widget.movementDuration == Duration.zero) {
      _controller.value = 1;
      return;
    }

    _controller
      ..duration = widget.movementDuration
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[_buildIndicator(context), _buildDestinations()],
        );
      },
    );
  }

  Widget _buildIndicator(BuildContext context) {
    final double itemWidth = widget.availableWidth / widget.destinations.length;
    final double inset = CinearaNavigationPillMetrics.indicatorInset;

    final double restingWidth = math.max(0, itemWidth - (inset * 2));
    final double height = math.max(0, widget.availableHeight - (inset * 2));

    final double stretchProgress = _stretchProgress(_controller.value);
    final double stretch = math.min(_maximumStretch, itemWidth * 0.18);
    final double width = restingWidth + (stretch * stretchProgress);

    final double centre = (itemWidth * _currentSelection()) + (itemWidth / 2);
    final double start = centre - (width / 2);

    return PositionedDirectional(
      start: start,
      top: inset,
      width: width,
      height: height,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: RepaintBoundary(
            child: DecoratedBox(
              decoration: CinearaNavigationPillStyle.indicatorDecoration(
                context,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestinations() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int index = 0; index < widget.destinations.length; index++)
          Expanded(
            child: CinearaNavigationPillItem(
              destination: widget.destinations[index],
              selected: index == widget.selectedIndex,
              onPressed: () {
                widget.onDestinationSelected(index);
              },
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

  double _stretchProgress(double progress) {
    if (_fromSelection == _toSelection) {
      return 0;
    }

    return math.sin(math.pi * progress).clamp(0.0, 1.0).toDouble();
  }
}
