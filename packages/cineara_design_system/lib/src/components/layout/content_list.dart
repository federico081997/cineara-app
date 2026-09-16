import 'package:flutter/material.dart';

/// Builds a separator after the item at [index].
typedef CinearaMediaListSeparatorBuilder =
    Widget Function(BuildContext context, int index);

// =============================================================================
// Generic editorial List
// =============================================================================

/// Centered Cineara List layout for arbitrary tile widgets.
///
/// Despite the media-oriented name, this container deliberately knows nothing
/// about a tile's fields or concrete widget type.
///
/// Search may provide:
///
/// ```dart
/// CinearaMediaListItem(...)
/// ```
///
/// while another page may provide a completely different tile:
///
/// ```dart
/// EpisodeListTile(...)
/// SeasonListTile(...)
/// CreditListTile(...)
/// ```
///
/// The container owns only:
///
/// - centered maximum width;
/// - inter-item separator placement;
/// - separator spacing.
///
/// It does **not** own media metadata, poster geometry, gestures, or row state.
///
/// To reproduce the approved Search media layout, use:
///
/// ```dart
/// CinearaMediaList(
///   separatorStartInset:
///       CinearaMediaListItem.defaultMetadataRailInset,
///   children: mediaRows,
/// )
/// ```
///
/// The default separator end inset is zero, so the hairline ends at the same
/// logical edge as the row / temporary pressed tile.
final class CinearaContentList extends StatelessWidget {
  const CinearaContentList({
    required this.children,
    super.key,
    this.maximumWidth = 840,
    this.separatorStartInset = 0,
    this.separatorEndInset = 0,
    this.separatorSpacing = 8,
    this.showSeparators = true,
    this.separatorBuilder,
  }) : assert(maximumWidth > 0, 'maximumWidth must be greater than zero.'),
       assert(
         separatorStartInset >= 0,
         'separatorStartInset must not be negative.',
       ),
       assert(
         separatorEndInset >= 0,
         'separatorEndInset must not be negative.',
       ),
       assert(separatorSpacing >= 0, 'separatorSpacing must not be negative.');

  /// Any tile widgets.
  final List<Widget> children;

  /// Maximum centered List width.
  ///
  /// The approved Search preview uses 840 dp.
  final double maximumWidth;

  /// Logical separator start inset.
  ///
  /// Search media rows use
  /// `CinearaMediaListItem.defaultMetadataRailInset`. Other tile families can
  /// use a different inset or zero.
  final double separatorStartInset;

  /// Logical separator end inset.
  ///
  /// Search uses zero so the separator ends at the row edge.
  final double separatorEndInset;

  /// Space placed both before and after the separator.
  ///
  /// The preview uses 8 dp.
  final double separatorSpacing;

  final bool showSeparators;

  /// Optional complete replacement for the default hairline separator.
  ///
  /// This is the escape hatch that lets another page keep the same List
  /// container while using entirely different tile/separator semantics.
  final CinearaMediaListSeparatorBuilder? separatorBuilder;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maximumWidth),
        child: Column(
          children: <Widget>[
            for (int index = 0; index < children.length; index++) ...<Widget>[
              children[index],
              if (showSeparators && index < children.length - 1) ...<Widget>[
                SizedBox(height: separatorSpacing),
                separatorBuilder?.call(context, index) ??
                    _CinearaMediaListSeparator(
                      startInset: separatorStartInset,
                      endInset: separatorEndInset,
                    ),
                SizedBox(height: separatorSpacing),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Default hairline separator
// =============================================================================

final class _CinearaMediaListSeparator extends StatelessWidget {
  const _CinearaMediaListSeparator({
    required this.startInset,
    required this.endInset,
  });

  final double startInset;
  final double endInset;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(start: startInset, end: endInset),
      child: Container(
        height: highContrast ? 1 : 0.75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: colors.outlineVariant.withValues(
            alpha: highContrast ? 0.72 : 0.34,
          ),
        ),
      ),
    );
  }
}
