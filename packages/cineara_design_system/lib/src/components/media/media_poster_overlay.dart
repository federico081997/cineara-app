import 'package:flutter/material.dart';

import '../../foundations/shapes/cineara_shapes.dart';
import '../badges/external_rating_badge.dart';
import '../badges/status_badge.dart';
import 'media_progress_indicator.dart';
import 'media_status_dock.dart';

// =============================================================================
// Media poster overlay
// =============================================================================

/// Composes Cineara's state and metadata overlays over poster artwork.
///
/// [CinearaMediaPosterOverlay] is the single layout authority for media UI
/// rendered above a poster.
///
/// Standard composition:
///
/// ```text
/// ┌──────────────────────────────┐
/// │ Status                  8.7 │
/// │                              │
/// │                              │
/// │                              │
/// │                         Dock │
/// │━━━━━━━━ progress ━━━━━━━━━━━│
/// └──────────────────────────────┘
/// ```
///
/// ## Stable overlay slots
///
/// The overlay always keeps four stable children in its [Stack]:
///
/// ```text
/// progress slot
/// external-rating slot
/// status slot
/// dock slot
/// ```
///
/// The slots are keyed and remain in the same order even when their visual
/// content appears or disappears.
///
/// This is important for [CinearaStatusDock], because the dock may own a
/// [CinearaStatusDockController]. Conditional insertion/removal of sibling
/// `Positioned` widgets must not cause Flutter to remount the dock while its
/// previous state is still detaching.
///
/// The dock itself also remains mounted whenever [statusDock] is non-null,
/// including when it currently has zero active indicators. An empty
/// [CinearaStatusDock] is responsible for rendering itself as empty.
///
/// ## Poster interaction
///
/// A surrounding `CinearaMediaPoster` normally provides:
///
/// ```text
/// tap
/// → open media details
///
/// long press
/// → open media quick actions
/// ```
///
/// This overlay blocks that interaction only where an overlay component has a
/// meaningful pointer action of its own.
///
/// ```text
/// collapsible status + expandOnTap
/// → protected
///
/// persistent/non-tappable status
/// → passive
///
/// compact dock + tapToExpand + 2+ active visible indicators
/// → protected
///
/// permanent dock
/// → passive
///
/// compact dock with 0–1 active visible indicators
/// → passive
///
/// external rating
/// → passive
///
/// progress
/// → passive
/// ```
///
/// Passive controls are wrapped in [IgnorePointer], so touching their visual
/// bounds still behaves like touching the poster.
///
/// ## Protected acquisition regions
///
/// Interactive status/dock controls receive a modest 48 dp protected region by
/// default. This is deliberately smaller than the older 72 dp corner
/// reservation so the poster does not lose a large amount of actionable
/// artwork.
///
/// ## Poster clipping
///
/// The complete overlay is intentionally not clipped. Expandable status and
/// dock animations therefore have room to paint.
///
/// Only artwork-bound content, currently [progressIndicator], is clipped using
/// [CinearaShapes.poster].
final class CinearaMediaPosterOverlay extends StatelessWidget {
  const CinearaMediaPosterOverlay({
    super.key,
    this.statusBadge,
    this.externalRatingBadge,
    this.statusDock,
    this.progressIndicator,
    this.edgeInset = 8,
    this.bottomControlInset = 8,
    this.statusHitTargetExtent = 48,
    this.dockHitTargetExtent = 48,
    this.minimumWidthForDualTopIndicators = 116,
    this.hideExternalRatingWhenCrowded = true,
  }) : assert(edgeInset >= 0, 'edgeInset must not be negative.'),
       assert(
         bottomControlInset >= 0,
         'bottomControlInset must not be negative.',
       ),
       assert(
         statusHitTargetExtent >= 48,
         'statusHitTargetExtent must be at least 48.',
       ),
       assert(
         dockHitTargetExtent >= 48,
         'dockHitTargetExtent must be at least 48.',
       ),
       assert(
         minimumWidthForDualTopIndicators >= 0,
         'minimumWidthForDualTopIndicators must not be negative.',
       );

  // ===========================================================================
  // Stable slot keys
  // ===========================================================================

  static const Key _progressSlotKey = ValueKey<String>(
    'cineara-media-poster-overlay-progress',
  );

  static const Key _externalRatingSlotKey = ValueKey<String>(
    'cineara-media-poster-overlay-external-rating',
  );

  static const Key _statusSlotKey = ValueKey<String>(
    'cineara-media-poster-overlay-status',
  );

  static const Key _dockSlotKey = ValueKey<String>(
    'cineara-media-poster-overlay-dock',
  );

  // ===========================================================================
  // Content
  // ===========================================================================

  /// Optional viewing-lifecycle badge at logical top-start.
  final CinearaStatusBadge? statusBadge;

  /// Optional passive external/community rating at logical top-end.
  final CinearaExternalRatingBadge? externalRatingBadge;

  /// Optional personal-state dock at logical bottom-start/end.
  ///
  /// When supplied, this dock stays mounted even if it currently has zero
  /// active indicators. This keeps optional controller ownership stable.
  final CinearaStatusDock? statusDock;

  /// Optional passive poster-edge progress indicator.
  final CinearaMediaProgressIndicator? progressIndicator;

  // ===========================================================================
  // Geometry
  // ===========================================================================

  /// Visible inset of corner controls from the poster edge.
  final double edgeInset;

  /// Bottom inset applied to the personal-state dock.
  final double bottomControlInset;

  /// Protected extent used only when [statusBadge] is meaningfully interactive.
  final double statusHitTargetExtent;

  /// Protected extent used only when [statusDock] is meaningfully interactive.
  final double dockHitTargetExtent;

  // ===========================================================================
  // Crowding
  // ===========================================================================

  /// Minimum bounded poster width at which both top indicators may be shown.
  final double minimumWidthForDualTopIndicators;

  /// Whether external rating may be omitted when the top edge is crowded.
  final bool hideExternalRatingWhenCrowded;

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool showExternalRating = _shouldShowExternalRating(constraints);

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,

          // Keep these four slots present, keyed and in a fixed order.
          //
          // Do not convert them back to conditionally inserted Stack children.
          // A stateful dock with a controller must not be remounted merely
          // because status/rating/progress visibility changed.
          children: <Widget>[
            _buildProgressSlot(),
            _buildExternalRatingSlot(showExternalRating),
            _buildStatusSlot(),
            _buildDockSlot(),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // Progress slot
  // ===========================================================================

  Widget _buildProgressSlot() {
    final CinearaMediaProgressIndicator? progress = progressIndicator;

    return Positioned.fill(
      key: _progressSlotKey,
      child: progress == null
          ? const SizedBox.shrink()
          : IgnorePointer(
              child: ClipPath(
                clipper: ShapeBorderClipper(shape: CinearaShapes.poster()),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    PositionedDirectional(
                      start: 0,
                      end: 0,
                      bottom: 0,
                      child: progress,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ===========================================================================
  // External-rating slot
  // ===========================================================================

  Widget _buildExternalRatingSlot(bool showExternalRating) {
    final CinearaExternalRatingBadge? rating = externalRatingBadge;

    return PositionedDirectional(
      key: _externalRatingSlotKey,
      top: edgeInset,
      end: edgeInset,
      child: showExternalRating && rating != null
          ? IgnorePointer(child: rating)
          : const SizedBox.shrink(),
    );
  }

  bool _shouldShowExternalRating(BoxConstraints constraints) {
    if (externalRatingBadge == null) {
      return false;
    }

    if (statusBadge == null ||
        !hideExternalRatingWhenCrowded ||
        !constraints.hasBoundedWidth) {
      return true;
    }

    return constraints.maxWidth >= minimumWidthForDualTopIndicators;
  }

  // ===========================================================================
  // Status slot
  // ===========================================================================

  Widget _buildStatusSlot() {
    final CinearaStatusBadge? badge = statusBadge;

    return PositionedDirectional(
      key: _statusSlotKey,
      start: 0,
      top: 0,
      child: badge == null
          ? const SizedBox.shrink()
          : _ConditionalCornerInteractionRegion(
              interactive: _statusNeedsProtection(badge),
              protectedExtent: statusHitTargetExtent,
              alignment: AlignmentDirectional.topStart,
              visualPadding: EdgeInsetsDirectional.only(
                start: edgeInset,
                top: edgeInset,
              ),
              child: badge,
            ),
    );
  }

  bool _statusNeedsProtection(CinearaStatusBadge badge) {
    return badge.behavior == CinearaStatusBadgeBehavior.collapsible &&
        badge.expandOnTap;
  }

  // ===========================================================================
  // Dock slot
  // ===========================================================================

  Widget _buildDockSlot() {
    final CinearaStatusDock? dock = statusDock;

    // Keep the slot itself stable even when no dock was supplied.
    if (dock == null) {
      return const PositionedDirectional(
        key: _dockSlotKey,
        end: 0,
        bottom: 0,
        child: SizedBox.shrink(),
      );
    }

    final bool dockAtEnd = dock.side == CinearaStatusDockSide.end;

    final AlignmentGeometry alignment = dockAtEnd
        ? AlignmentDirectional.bottomEnd
        : AlignmentDirectional.bottomStart;

    final EdgeInsetsGeometry visualPadding = dockAtEnd
        ? EdgeInsetsDirectional.only(end: edgeInset, bottom: bottomControlInset)
        : EdgeInsetsDirectional.only(
            start: edgeInset,
            bottom: bottomControlInset,
          );

    return PositionedDirectional(
      key: _dockSlotKey,
      start: dockAtEnd ? null : 0,
      end: dockAtEnd ? 0 : null,
      bottom: 0,
      child: _ConditionalCornerInteractionRegion(
        interactive: _dockNeedsProtection(dock),
        protectedExtent: dockHitTargetExtent,
        alignment: alignment,
        visualPadding: visualPadding,
        child: dock,
      ),
    );
  }

  /// Returns the number of active personal indicators that are also eligible
  /// for this dock presentation.
  int _activeVisibleDockIndicatorCount(CinearaStatusDock dock) {
    final Set<CinearaStatusDockIndicator> visible = dock.visibleIndicators;

    int count = 0;

    if (visible.contains(CinearaStatusDockIndicator.rating) &&
        dock.personalRating != null) {
      count++;
    }

    if (visible.contains(CinearaStatusDockIndicator.watchlist) &&
        dock.watchlist) {
      count++;
    }

    if (visible.contains(CinearaStatusDockIndicator.favorite) &&
        dock.favorite) {
      count++;
    }

    if (visible.contains(CinearaStatusDockIndicator.collection) &&
        dock.collection) {
      count++;
    }

    return count;
  }

  bool _dockNeedsProtection(CinearaStatusDock dock) {
    if (dock.mode != CinearaStatusDockMode.compact || !dock.tapToExpand) {
      return false;
    }

    // One visible state has no chain to reveal.
    //
    // Zero states render empty, so there is likewise nothing useful to tap.
    return _activeVisibleDockIndicatorCount(dock) > 1;
  }
}

// =============================================================================
// Conditional corner interaction region
// =============================================================================

/// Stable pointer-isolation wrapper for an overlay control.
///
/// The widget hierarchy does not change when [interactive] changes.
///
/// When interactive:
///
/// - the control receives pointer events normally;
/// - the acquisition region has at least [protectedExtent] width/height;
/// - empty protected padding consumes poster tap/hold gestures.
///
/// When passive:
///
/// - [IgnorePointer] makes the complete visual transparent to hit testing;
/// - the minimum protected extent collapses to zero;
/// - the underlying poster remains fully interactive.
///
/// The actual child remains mounted in both states.
final class _ConditionalCornerInteractionRegion extends StatelessWidget {
  const _ConditionalCornerInteractionRegion({
    required this.interactive,
    required this.protectedExtent,
    required this.alignment,
    required this.visualPadding,
    required this.child,
  });

  final bool interactive;
  final double protectedExtent;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry visualPadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !interactive,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        // The acquisition wrapper must not duplicate the child's accessibility
        // semantics.
        excludeFromSemantics: true,

        onTap: interactive ? _consumeGesture : null,

        onLongPress: interactive ? _consumeGesture : null,

        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: interactive ? protectedExtent : 0,
            minHeight: interactive ? protectedExtent : 0,
          ),
          child: Align(
            alignment: alignment,
            widthFactor: 1,
            heightFactor: 1,
            child: Padding(padding: visualPadding, child: child),
          ),
        ),
      ),
    );
  }

  static void _consumeGesture() {}
}
