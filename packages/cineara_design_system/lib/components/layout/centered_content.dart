import 'package:flutter/material.dart';

import '../../tokens/content_widths.dart';
import '../../tokens/spacing.dart';

/// Scrollable, width-constrained layout for focused Cineara content.
///
/// [CinearaCenteredContent] is intended for content that benefits from a
/// narrow, visually focused presentation rather than Cineara's normal
/// page/section hierarchy.
///
/// Appropriate uses include:
///
/// - error pages;
/// - empty states;
/// - authentication or account forms;
/// - setup flows;
/// - focused settings forms;
/// - confirmation content;
/// - other small standalone compositions.
///
/// The content:
///
/// - remains horizontally centred;
/// - may remain vertically centred while it fits in the viewport;
/// - respects system safe areas when requested;
/// - becomes naturally scrollable when accessibility text, the keyboard, or a
///   small viewport makes the content too tall;
/// - is constrained to a configurable maximum width.
///
/// This component deliberately remains separate from `CinearaContentPage`.
///
/// `CinearaContentPage` is intended for normal application pages containing
/// headers, sections, lists, grids, and persistent-navigation clearance.
///
/// [CinearaCenteredContent] is intended for focused content where a centred
/// composition is preferable.
final class CinearaCenteredContent extends StatelessWidget {
  const CinearaCenteredContent({
    required this.child,
    this.maxWidth = CinearaContentWidths.medium,
    this.padding = const EdgeInsets.all(CinearaSpacing.lg),
    this.centerVertically = true,
    this.useSafeArea = true,
    this.controller,
    this.physics,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.onDrag,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    super.key,
  }) : assert(maxWidth > 0, 'maxWidth must be greater than zero.');

  /// Content displayed by the layout.
  final Widget child;

  /// Maximum logical width available to [child].
  ///
  /// The surrounding [padding] is not included in this width.
  final double maxWidth;

  /// Padding applied around the focused content.
  ///
  /// This intentionally remains independently configurable rather than using
  /// normal responsive page padding. Focused layouts often need different
  /// proportions from content-heavy application pages.
  final EdgeInsetsGeometry padding;

  /// Whether [child] should remain vertically centred while it fits within the
  /// available viewport.
  ///
  /// If the content becomes taller than the viewport, scrolling takes
  /// precedence and the content starts naturally from the top of the
  /// scrollable extent.
  ///
  /// When `false`, the content is always aligned toward the top.
  final bool centerVertically;

  /// Whether the layout should avoid operating-system safe areas.
  final bool useSafeArea;

  /// Optional scroll controller.
  final ScrollController? controller;

  /// Optional scroll physics.
  final ScrollPhysics? physics;

  /// Behaviour used to dismiss the software keyboard while scrolling.
  ///
  /// Drag-to-dismiss is useful for focused forms without requiring individual
  /// form pages to configure their scroll view independently.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Clipping behaviour of the internal scroll view.
  final Clip clipBehavior;

  /// Optional restoration identifier for the scroll position.
  final String? restorationId;

  @override
  Widget build(BuildContext context) {
    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        return _buildScrollableContent(context, constraints);
      },
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }

  Widget _buildScrollableContent(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final resolvedPadding = padding.resolve(Directionality.of(context));

    final minimumContentHeight = _minimumContentHeight(
      constraints,
      verticalPadding: resolvedPadding.vertical,
    );

    return SingleChildScrollView(
      controller: controller,
      physics: physics,
      padding: padding,
      keyboardDismissBehavior: keyboardDismissBehavior,
      clipBehavior: clipBehavior,
      restorationId: restorationId,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minimumContentHeight),
        child: Align(
          alignment: centerVertically ? Alignment.center : Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        ),
      ),
    );
  }

  double _minimumContentHeight(
    BoxConstraints constraints, {
    required double verticalPadding,
  }) {
    if (!centerVertically || !constraints.hasBoundedHeight) {
      return 0;
    }

    return (constraints.maxHeight - verticalPadding)
        .clamp(0.0, double.infinity)
        .toDouble();
  }
}
