import 'package:flutter/material.dart';

import '../../../tokens/spacing.dart';
import '../badges/media_badge.dart';

/// Builds a localized accessibility description for hidden poster flags.
///
/// [hiddenCount] is the number of flags collapsed behind the `+N` badge.
///
/// Example:
///
/// ```dart
/// flagOverflowSemanticLabelBuilder: (hiddenCount) =>
///     '$hiddenCount more media flags',
/// ```
typedef CinearaBadgeOverflowSemanticLabelBuilder =
    String Function(int hiddenCount);

/// Centralised overlay layout for badges displayed over Cineara poster artwork.
///
/// [CinearaMediaBadgeStack] owns the spatial relationship between:
///
/// - one primary viewing-status badge at the logical top-start;
/// - independent media flags at the logical top-end;
/// - flag overflow using `+N`;
/// - an external rating at the logical bottom-start;
/// - a personal rating at the logical bottom-end.
///
/// Example:
///
/// ```text
/// ╭────────────────────────────╮
/// │ ▶                      ♥   │
/// │                        🔖   │
/// │                            │
/// │                            │
/// │ ★ 8.4               ★ 9.0 │
/// ╰────────────────────────────╯
/// ```
///
/// If more independent flags exist than should remain visible:
///
/// ```text
/// ╭────────────────────────────╮
/// │ ▶                      ♥   │
/// │                        🔖   │
/// │                        +1  │
/// │                            │
/// │ ★ 8.4               ★ 9.0 │
/// ╰────────────────────────────╯
/// ```
///
/// Feature components should not reproduce these coordinates manually.
///
/// In particular, `CinearaPosterMediaCard`, Search results, Discover cards,
/// Library cards, and recommendation cards should all delegate poster badge
/// positioning to this component.
///
/// This widget does not define the semantic meaning or appearance of individual
/// badges. Those responsibilities belong to:
///
/// - `CinearaStatusBadge`;
/// - `CinearaFlagBadge`;
/// - `CinearaRatingBadge`.
///
/// The stack may be placed directly over [CinearaPosterImage] inside a parent
/// [Stack].
final class CinearaMediaBadgeStack extends StatelessWidget {
  const CinearaMediaBadgeStack({
    this.primaryStatus,
    this.flags = const <Widget>[],
    this.externalRating,
    this.personalRating,
    this.maxVisibleFlags = defaultMaxVisibleFlags,
    this.flagOverflowSemanticLabelBuilder,
    this.edgeInset = defaultEdgeInset,
    this.badgeGap = defaultBadgeGap,
    super.key,
  }) : assert(maxVisibleFlags >= 0, 'maxVisibleFlags must not be negative.'),
       assert(edgeInset >= 0, 'edgeInset must not be negative.'),
       assert(badgeGap >= 0, 'badgeGap must not be negative.');

  // ---------------------------------------------------------------------------
  // Standard overlay metrics
  // ---------------------------------------------------------------------------

  /// Maximum number of ordinary independent flags shown before overflow.
  ///
  /// The overflow badge is additional to this count.
  ///
  /// For example, three flags with the default value produce:
  ///
  /// ```text
  /// flag
  /// flag
  /// +1
  /// ```
  static const int defaultMaxVisibleFlags = 2;

  /// Standard distance between badges and poster edges.
  static const double defaultEdgeInset = CinearaSpacing.xs;

  /// Standard distance between adjacent badges.
  static const double defaultBadgeGap = CinearaSpacing.xxs;

  // ---------------------------------------------------------------------------
  // Top-start status
  // ---------------------------------------------------------------------------

  /// Primary mutually-exclusive viewing status.
  ///
  /// Only one widget is accepted by design, preventing poster cards from
  /// accidentally displaying conflicting states such as Watching and
  /// Completed simultaneously.
  ///
  /// This is positioned at the logical top-start.
  final Widget? primaryStatus;

  // ---------------------------------------------------------------------------
  // Top-end flags
  // ---------------------------------------------------------------------------

  /// Independent media flags.
  ///
  /// These are displayed vertically from the logical top-end of the poster.
  ///
  /// Typical values are:
  ///
  /// ```text
  /// Watchlist
  /// Favourite
  /// Collection
  /// ```
  ///
  /// Unlike [primaryStatus], several may coexist.
  final List<Widget> flags;

  /// Maximum number of ordinary [flags] displayed before remaining flags are
  /// represented by a `+N` overflow badge.
  ///
  /// The overflow badge itself does not count toward this number.
  final int maxVisibleFlags;

  /// Optional localized accessibility description for the overflow badge.
  ///
  /// The visible `+N` notation is intentionally compact and language-neutral,
  /// but assistive technology should receive a complete localized description.
  ///
  /// When omitted, the visible `+N` value is also used as its semantic label.
  final CinearaBadgeOverflowSemanticLabelBuilder?
  flagOverflowSemanticLabelBuilder;

  // ---------------------------------------------------------------------------
  // Ratings
  // ---------------------------------------------------------------------------

  /// Rating supplied by an external source.
  ///
  /// Positioned at the logical bottom-start of the poster.
  final Widget? externalRating;

  /// User's personal rating.
  ///
  /// Positioned at the logical bottom-end of the poster.
  final Widget? personalRating;

  // ---------------------------------------------------------------------------
  // Geometry
  // ---------------------------------------------------------------------------

  /// Distance maintained between badge groups and the poster edge.
  final double edgeInset;

  /// Gap maintained between vertically stacked independent flags.
  final double badgeGap;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      return const SizedBox.expand();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (primaryStatus case final status?)
          PositionedDirectional(
            top: edgeInset,
            start: edgeInset,
            child: status,
          ),

        if (flags.isNotEmpty)
          PositionedDirectional(
            top: edgeInset,
            end: edgeInset,
            child: _buildFlagStack(),
          ),

        if (externalRating case final rating?)
          PositionedDirectional(
            start: edgeInset,
            bottom: edgeInset,
            child: rating,
          ),

        if (personalRating case final rating?)
          PositionedDirectional(
            end: edgeInset,
            bottom: edgeInset,
            child: rating,
          ),
      ],
    );
  }

  bool get _isEmpty {
    return primaryStatus == null &&
        flags.isEmpty &&
        externalRating == null &&
        personalRating == null;
  }

  Widget _buildFlagStack() {
    final visibleCount = flags.length.clamp(0, maxVisibleFlags);

    final hiddenCount = flags.length - visibleCount;

    final visibleFlags = flags.take(visibleCount);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final flag in visibleFlags) ...[
          flag,
          if (flag != visibleFlags.last || hiddenCount > 0)
            SizedBox(height: badgeGap),
        ],
        if (hiddenCount > 0)
          _CinearaFlagOverflowBadge(
            hiddenCount: hiddenCount,
            semanticLabel:
                flagOverflowSemanticLabelBuilder?.call(hiddenCount) ??
                '+$hiddenCount',
          ),
      ],
    );
  }
}

/// Compact `+N` badge used when poster flags exceed their visible limit.
///
/// Geometry and high-contrast behaviour are inherited from
/// [CinearaMediaBadge] so overflow remains visually consistent with every
/// other poster badge.
final class _CinearaFlagOverflowBadge extends StatelessWidget {
  const _CinearaFlagOverflowBadge({
    required this.hiddenCount,
    required this.semanticLabel,
  });

  final int hiddenCount;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final badge = CinearaMediaBadge(
      foregroundColor: colors.onSurface,
      backgroundColor: colors.surfaceContainerHighest,
      borderColor: colors.outlineVariant.withValues(alpha: .55),
      child: Text(
        '+$hiddenCount',
        maxLines: 1,
        softWrap: false,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return Tooltip(
      message: semanticLabel,
      excludeFromSemantics: true,
      child: Semantics(
        container: true,
        label: semanticLabel,
        child: ExcludeSemantics(child: badge),
      ),
    );
  }
}
