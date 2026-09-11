import 'package:flutter/material.dart';

// =============================================================================
// Responsive media Grid
// =============================================================================

/// Responsive layout primitive for Cineara media tiles.
///
/// The Grid deliberately accepts arbitrary widgets rather than media-domain
/// objects. Search can use [CinearaMediaGridItem], while another feature can
/// provide a different card without changing the layout primitive.
///
/// Column logic is preserved from the approved preview:
///
/// ```text
/// width >= 1120 -> 6
/// width >=  900 -> 5
/// width >=  680 -> 4
/// width >=  460 -> 3
/// otherwise     -> 2
/// ```
///
/// Spacing is 18 dp horizontally and 28 dp vertically.
final class CinearaMediaGrid extends StatelessWidget {
  const CinearaMediaGrid({
    required this.children,
    super.key,
    this.spacing = 18,
    this.runSpacing = 28,
  }) : assert(spacing >= 0, 'spacing must not be negative.'),
       assert(runSpacing >= 0, 'runSpacing must not be negative.');

  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;

        final int columns = columnsForWidth(width);

        final double itemWidth = (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children
              .map((Widget child) => SizedBox(width: itemWidth, child: child))
              .toList(growable: false),
        );
      },
    );
  }

  static int columnsForWidth(double width) {
    return switch (width) {
      >= 1120 => 6,
      >= 900 => 5,
      >= 680 => 4,
      >= 460 => 3,
      _ => 2,
    };
  }
}
