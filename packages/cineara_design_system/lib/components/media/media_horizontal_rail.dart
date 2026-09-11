import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// =============================================================================
// Horizontal media rail
// =============================================================================

/// Horizontally scrollable Cineara rail for arbitrary media presentation
/// widgets.
///
/// The rail is deliberately data-agnostic. It can host
/// [CinearaMediaGridItem] or another feature-specific tile without knowing
/// anything about the underlying media/domain model.
///
/// When [snapToCenter] is enabled, interior items settle onto the viewport's
/// horizontal center after scrolling stops. By default the first and last items
/// do not center-snap:
///
/// - the first item keeps the natural leading-edge composition;
/// - the last item can finish flush with the trailing viewport edge without
///   requiring synthetic trailing blank space.
///
/// Center targets are calculated through Flutter's [RenderAbstractViewport],
/// so the final offset is based on the actual rendered item and viewport rather
/// than hand-written index arithmetic.
final class CinearaMediaHorizontalRail extends StatefulWidget {
  const CinearaMediaHorizontalRail({
    required this.children,
    required this.itemWidth,
    super.key,
    this.spacing = 18,
    this.padding = EdgeInsets.zero,
    this.controller,
    this.physics,
    this.clipBehavior = Clip.hardEdge,
    this.snapToCenter = false,
    this.snapFirstItem = false,
    this.snapLastItem = false,
    this.snapDuration = const Duration(milliseconds: 320),
    this.snapCurve = Curves.easeInOutSine,
  }) : assert(itemWidth > 0, 'itemWidth must be greater than zero.'),
       assert(spacing >= 0, 'spacing must not be negative.'),
       assert(
         snapDuration >= Duration.zero,
         'snapDuration must not be negative.',
       );

  final List<Widget> children;

  /// Fixed width assigned to every child.
  final double itemWidth;

  /// Logical gap between adjacent children.
  final double spacing;

  final EdgeInsetsGeometry padding;

  /// Optional externally owned controller.
  ///
  /// If omitted, the rail owns an internal controller.
  final ScrollController? controller;

  final ScrollPhysics? physics;
  final Clip clipBehavior;

  /// Whether the nearest eligible item should settle onto the horizontal
  /// viewport center when user scrolling ends.
  final bool snapToCenter;

  /// Whether item 0 is allowed to center-snap.
  ///
  /// Cineara rails normally leave this false so the initial composition starts
  /// cleanly on the section's leading edge.
  final bool snapFirstItem;

  /// Whether the final item is allowed to center-snap.
  ///
  /// Cineara rails normally leave this false. This removes the need for a large
  /// trailing spacer and lets the last card finish naturally at the viewport
  /// edge.
  final bool snapLastItem;

  final Duration snapDuration;
  final Curve snapCurve;

  @override
  State<CinearaMediaHorizontalRail> createState() =>
      _CinearaMediaHorizontalRailState();
}

final class _CinearaMediaHorizontalRailState
    extends State<CinearaMediaHorizontalRail> {
  final GlobalKey _viewportKey = GlobalKey();

  late ScrollController _controller;
  late bool _ownsController;

  List<GlobalKey> _itemKeys = <GlobalKey>[];

  bool _snapping = false;
  bool _snapScheduled = false;

  static const double _edgeTolerance = 2;
  static const double _minimumSnapDistance = 3;

  @override
  void initState() {
    super.initState();

    _configureController();
    _synchronizeItemKeys();
  }

  @override
  void didUpdateWidget(CinearaMediaHorizontalRail oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      if (_ownsController) {
        _controller.dispose();
      }

      _configureController();
    }

    if (oldWidget.children.length != widget.children.length) {
      _synchronizeItemKeys();
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }

    super.dispose();
  }

  void _configureController() {
    final ScrollController? external = widget.controller;

    if (external != null) {
      _controller = external;
      _ownsController = false;
      return;
    }

    _controller = ScrollController();
    _ownsController = true;
  }

  void _synchronizeItemKeys() {
    final int targetLength = widget.children.length;

    if (_itemKeys.length == targetLength) {
      return;
    }

    final List<GlobalKey> previous = _itemKeys;

    _itemKeys = List<GlobalKey>.generate(
      targetLength,
      (int index) => index < previous.length
          ? previous[index]
          : GlobalKey(debugLabel: 'cineara-media-rail-item-$index'),
      growable: false,
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.snapToCenter ||
        _snapping ||
        notification.metrics.axis != Axis.horizontal) {
      return false;
    }

    if (notification is ScrollEndNotification) {
      _scheduleSnap();
    }

    return false;
  }

  void _scheduleSnap() {
    if (_snapScheduled || _snapping || !mounted) {
      return;
    }

    _snapScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _snapScheduled = false;

      if (!mounted) {
        return;
      }

      unawaited(_snapNearestEligibleItemToCenter());
    });
  }

  Future<void> _snapNearestEligibleItemToCenter() async {
    if (!mounted ||
        _snapping ||
        !_controller.hasClients ||
        widget.children.length < 2) {
      return;
    }

    final BuildContext? viewportContext = _viewportKey.currentContext;

    if (viewportContext == null) {
      return;
    }

    final RenderObject? viewportObject = viewportContext.findRenderObject();

    if (viewportObject is! RenderBox ||
        !viewportObject.attached ||
        !viewportObject.hasSize) {
      return;
    }

    final ScrollPosition position = _controller.position;

    // Keep the rail completely natural at its physical beginning/end.
    if (!widget.snapFirstItem &&
        position.pixels <= position.minScrollExtent + _edgeTolerance) {
      return;
    }

    if (!widget.snapLastItem &&
        position.pixels >= position.maxScrollExtent - _edgeTolerance) {
      return;
    }

    final Offset viewportCenter = viewportObject.localToGlobal(
      Offset(viewportObject.size.width / 2, viewportObject.size.height / 2),
    );

    int? nearestIndex;
    RenderBox? nearestItem;
    double nearestDistance = double.infinity;

    for (int index = 0; index < _itemKeys.length; index++) {
      final BuildContext? itemContext = _itemKeys[index].currentContext;

      if (itemContext == null) {
        continue;
      }

      final RenderObject? itemObject = itemContext.findRenderObject();

      if (itemObject is! RenderBox ||
          !itemObject.attached ||
          !itemObject.hasSize) {
        continue;
      }

      final Offset itemCenter = itemObject.localToGlobal(
        Offset(itemObject.size.width / 2, itemObject.size.height / 2),
      );

      final double distance = (itemCenter.dx - viewportCenter.dx).abs();

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = index;
        nearestItem = itemObject;
      }
    }

    if (nearestIndex == null || nearestItem == null) {
      return;
    }

    if (nearestIndex == 0 && !widget.snapFirstItem) {
      return;
    }

    final int lastIndex = widget.children.length - 1;

    if (nearestIndex == lastIndex && !widget.snapLastItem) {
      return;
    }

    // If the user deliberately reached the natural trailing end, do not pull
    // the rail back to the penultimate item. The last card should remain flush
    // at the edge rather than creating an empty end-cap.
    if (!widget.snapLastItem &&
        (position.maxScrollExtent - position.pixels).abs() < _edgeTolerance) {
      return;
    }

    final RenderAbstractViewport viewport = RenderAbstractViewport.of(
      nearestItem,
    );

    final RevealedOffset revealed = viewport.getOffsetToReveal(
      nearestItem,
      0.5,
    );

    final double target = revealed.offset
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();

    final double snapDistance = (target - position.pixels).abs();

    if (snapDistance < _minimumSnapDistance) {
      return;
    }

    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final bool reduceMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;

    _snapping = true;

    try {
      if (reduceMotion || widget.snapDuration == Duration.zero) {
        _controller.jumpTo(target);
      } else {
        // Small corrections finish sooner; larger ones use the full soft
        // settle. This reads more like magnetic alignment than a second scroll.
        final double stride = widget.itemWidth + widget.spacing;
        final double distanceFraction = stride <= 0
            ? 1
            : (snapDistance / stride).clamp(0.0, 1.0).toDouble();

        final int durationMs =
            (210 +
                    ((widget.snapDuration.inMilliseconds - 210) *
                        distanceFraction))
                .round();

        await _controller.animateTo(
          target,
          duration: Duration(milliseconds: durationMs),
          curve: widget.snapCurve,
        );
      }
    } finally {
      if (mounted) {
        _snapping = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      key: _viewportKey,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: widget.physics,
          clipBehavior: widget.clipBehavior,
          padding: widget.padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (
                int index = 0;
                index < widget.children.length;
                index++
              ) ...<Widget>[
                KeyedSubtree(
                  key: _itemKeys[index],
                  child: SizedBox(
                    width: widget.itemWidth,
                    child: widget.children[index],
                  ),
                ),
                if (index < widget.children.length - 1)
                  SizedBox(width: widget.spacing),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
