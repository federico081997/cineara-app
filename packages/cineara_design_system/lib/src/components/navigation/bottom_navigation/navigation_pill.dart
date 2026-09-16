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
/// The navigation is visually icon-only. Localized destination labels remain
/// available through accessibility semantics and tooltips.
///
/// Its geometry is composed from two closely related visual layers:
///
/// - a softly rounded outer navigation surface;
/// - one inset capsule that moves continuously between destinations.
///
/// The active capsule uses a uniform inset from its destination cell so its
/// distance from the surrounding navigation surface remains visually balanced
/// horizontally and vertically.
///
/// The component owns presentation and interaction only. Navigation state,
/// routing, branch restoration, and repeated-destination behaviour remain the
/// responsibility of the application shell.
///
/// The navigation is designed to remain visible throughout normal application
/// flows, including nested and cinematic pages. Page layouts should reserve
/// their bottom content area using
/// [CinearaNavigationPillMetrics.contentClearanceFor].
final class CinearaNavigationPill extends StatelessWidget {
  const CinearaNavigationPill({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  }) : assert(
         destinations.length >= 2,
         'At least two navigation destinations are required.',
       ),
       assert(
         destinations.length <= 5,
         'Use no more than five destinations in bottom navigation.',
       ),
       assert(
         selectedIndex >= 0 && selectedIndex < destinations.length,
         'selectedIndex must refer to an existing destination.',
       );

  /// Destinations displayed by the navigation control.
  ///
  /// Bottom navigation should contain between two and five root destinations.
  final List<CinearaNavigationDestination> destinations;

  /// Index of the currently active root destination.
  final int selectedIndex;

  /// Called when a destination is selected.
  ///
  /// Selecting the currently active destination is intentionally reported as
  /// well. The application shell may use that event to return the branch to its
  /// root or provide another conventional repeated-tab behaviour.
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final movementDuration = CinearaAccessibility.adaptiveDuration(
      context,
      CinearaMotion.slow,
    );

    final maxWidth = CinearaNavigationPillMetrics.maxWidthFor(context);
    final height = CinearaNavigationPillMetrics.heightFor(context);

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

                // Interaction overlays and internal content remain clipped to
                // the visible outer navigation shape.
                clipBehavior: Clip.antiAlias,

                child: LayoutBuilder(
                  builder: (context, constraints) {
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

/// Internal layout of [CinearaNavigationPill].
///
/// The outer navigation surface is divided into equally sized destination
/// cells. The active indicator fills its current destination cell while
/// maintaining the same inset on every side.
final class _NavigationPillLayout extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final itemWidth = availableWidth / destinations.length;

    final indicatorInset = CinearaNavigationPillMetrics.indicatorInset;

    final indicatorWidth = math.max(0.0, itemWidth - (indicatorInset * 2));

    final indicatorHeight = math.max(
      0.0,
      availableHeight - (indicatorInset * 2),
    );

    final indicatorStart = (itemWidth * selectedIndex) + indicatorInset;

    final indicatorTop = indicatorInset;

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildSelectionIndicator(
          context,
          start: indicatorStart,
          top: indicatorTop,
          width: indicatorWidth,
          height: indicatorHeight,
        ),
        _buildDestinations(),
      ],
    );
  }

  Widget _buildSelectionIndicator(
    BuildContext context, {
    required double start,
    required double top,
    required double width,
    required double height,
  }) {
    return AnimatedPositionedDirectional(
      duration: movementDuration,
      curve: CinearaMotion.standardCurve,
      start: start,
      top: top,
      width: width,
      height: height,

      // The moving capsule is decorative. Destination items own interaction
      // and accessibility semantics.
      child: IgnorePointer(
        ignoring: true,
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
      children: [
        for (var index = 0; index < destinations.length; index++)
          Expanded(
            child: CinearaNavigationPillItem(
              destination: destinations[index],
              selected: index == selectedIndex,
              onPressed: () {
                onDestinationSelected(index);
              },
            ),
          ),
      ],
    );
  }
}
