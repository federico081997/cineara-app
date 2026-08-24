import 'package:flutter/material.dart';

import '../../tokens/content_widths.dart';
import '../../tokens/spacing.dart';

/// A scrollable, width-constrained content layout used throughout Cineara.
///
/// The content is horizontally centered, respects system safe areas, and
/// remains vertically centered while it fits within the available viewport.
///
/// When the content becomes taller than the viewport, such as with large
/// accessibility text or in landscape orientation, the layout scrolls
/// naturally instead of overflowing.
final class CinearaCenteredContent extends StatelessWidget {
  const CinearaCenteredContent({
    required this.child,
    this.maxWidth = CinearaContentWidths.medium,
    this.padding = const EdgeInsets.all(CinearaSpacing.lg),
    this.centerVertically = true,
    this.useSafeArea = true,
    this.controller,
    this.physics,
    super.key,
  });

  /// Content displayed by the layout.
  final Widget child;

  /// Maximum logical width available to [child].
  final double maxWidth;

  /// Padding applied around the content.
  final EdgeInsetsGeometry padding;

  /// Whether the content is vertically centered when enough space is
  /// available.
  ///
  /// When false, the content is aligned to the top of the available area.
  final bool centerVertically;

  /// Whether the layout respects the system safe areas.
  final bool useSafeArea;

  /// Optional controller for the scrollable content.
  final ScrollController? controller;

  /// Optional scroll physics for the scrollable content.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding.resolve(Directionality.of(context));

    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final minContentHeight = constraints.hasBoundedHeight
            ? (constraints.maxHeight - resolvedPadding.vertical)
                  .clamp(0.0, double.infinity)
                  .toDouble()
            : 0.0;

        return SingleChildScrollView(
          controller: controller,
          physics: physics,
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: centerVertically ? minContentHeight : 0,
            ),
            child: Align(
              alignment: centerVertically
                  ? Alignment.center
                  : Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          ),
        );
      },
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }
}
