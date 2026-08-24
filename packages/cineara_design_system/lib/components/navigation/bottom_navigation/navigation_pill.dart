import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../tokens/accessibility.dart';
import '../../../tokens/motion.dart';
import '../../../tokens/spacing.dart';
import 'navigation_destination.dart';
import 'navigation_pill_item.dart';
import 'navigation_pill_metrics.dart';
import 'navigation_pill_style.dart';

/// Cineara's floating bottom-navigation control.
///
/// The navigation is visually icon-only. Localized destination labels remain
/// available through accessibility semantics and tooltips.
///
/// A single shared capsule moves continuously between destinations so the
/// currently active root destination remains visually unambiguous.
///
/// The component owns presentation and interaction only. Routing remains the
/// responsibility of the application shell.
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

  /// Destinations displayed by the navigation pill.
  final List<CinearaNavigationDestination> destinations;

  /// Index of the currently active destination.
  final int selectedIndex;

  /// Called when a destination is selected.
  ///
  /// Selecting the current destination is also reported so the application
  /// shell can optionally return that navigation branch to its root.
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
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth =
                        constraints.maxWidth / destinations.length;

                    final desiredIndicatorWidth =
                        CinearaNavigationPillMetrics.indicatorWidthFor(context);

                    final indicatorWidth = math.min(
                      desiredIndicatorWidth,
                      math.max(0.0, itemWidth - (CinearaSpacing.xs * 2)),
                    );

                    final indicatorHeight =
                        CinearaNavigationPillMetrics.indicatorHeightFor(
                          context,
                        );

                    final indicatorStart =
                        (itemWidth * selectedIndex) +
                        ((itemWidth - indicatorWidth) / 2);

                    final indicatorTop =
                        (constraints.maxHeight - indicatorHeight) / 2;

                    return Stack(
                      children: [
                        AnimatedPositionedDirectional(
                          duration: movementDuration,
                          curve: CinearaMotion.standardCurve,
                          start: indicatorStart,
                          top: indicatorTop,
                          width: indicatorWidth,
                          height: indicatorHeight,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration:
                                  CinearaNavigationPillStyle.indicatorDecoration(
                                    context,
                                  ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (
                                var index = 0;
                                index < destinations.length;
                                index++
                              )
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
                          ),
                        ),
                      ],
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
