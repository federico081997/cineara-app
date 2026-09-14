import 'package:flutter/material.dart';

// =============================================================================
// Horizontal media rail
// =============================================================================

/// Edge-to-edge cinematic horizontal rail for Cineara.
///
/// The rail is deliberately data-agnostic. It can host
/// [CinearaMediaGridItem], people tiles, collection tiles, or any other widget
/// without knowing anything about the underlying feature/domain model.
///
/// ## Cineara edge behavior
///
/// The rail viewport itself should be allowed to reach the physical screen
/// edges by the page layout. Inside that viewport:
///
/// - the first and last posters receive the same small 12 dp logical inset;
/// - only an edge with hidden scrollable content beyond it receives a fade;
/// - that fade grows gradually with the amount of content hidden beyond it;
/// - the physical beginning never fades on its outside edge;
/// - the physical end never fades on its outside edge;
/// - the fade is a background-colored opacity veil, not a ShaderMask or
///   BackdropFilter, so there is no hard vertical filter boundary;
/// - scrolling is deliberately free and continuous;
/// - releasing a gesture never triggers an automatic position correction.
///
/// At the initial scroll position in LTR:
///
/// ```text
/// [ first ] [ ... ] [ partially visible ... fade ]
/// ^ clean                                     ^ fade
/// ```
///
/// In the middle:
///
/// ```text
/// [ fade ... ] [ cards ] [ ... fade ]
/// ```
///
/// At the natural end:
///
/// ```text
/// [ fade ... ] [ ... ] [ last ]
///                              ^ clean
/// ```
///
/// RTL is handled using the scroll position's physical [AxisDirection].
///
/// ## Full-width requirement
///
/// `padding` belongs to the scroll content, not the outer rail viewport. This
/// widget cannot escape horizontal padding imposed by its parent. If the rail
/// must reach the actual device edges, place it outside the page's normal
/// horizontal content gutter and pad the section title/header separately.
final class CinearaMediaHorizontalRail extends StatefulWidget {
  const CinearaMediaHorizontalRail({
    required this.children,
    required this.itemWidth,
    super.key,
    this.spacing = 16,
    this.padding = const EdgeInsetsDirectional.only(start: 12, end: 12),
    this.controller,
    this.physics,
    this.clipBehavior = Clip.hardEdge,
    this.edgeFadeWidth = 36,
    this.edgeFadeRevealDistance = 72,
    this.edgeFadeColor,
    this.showOverscrollIndicator = false,
    this.showScrollbar = false,
  }) : assert(itemWidth > 0, 'itemWidth must be greater than zero.'),
       assert(spacing >= 0, 'spacing must not be negative.'),
       assert(edgeFadeWidth >= 0, 'edgeFadeWidth must not be negative.'),
       assert(
         edgeFadeRevealDistance > 0,
         'edgeFadeRevealDistance must be greater than zero.',
       );

  /// Widgets displayed by the rail.
  final List<Widget> children;

  /// Fixed width assigned to every child.
  final double itemWidth;

  /// Logical gap between adjacent children.
  final double spacing;

  /// Logical start/end padding inside the scroll content.
  ///
  /// The default is symmetrical so the first and final poster have the same
  /// breathing room.
  final EdgeInsetsGeometry padding;

  /// Optional externally owned controller.
  ///
  /// If omitted, the rail creates and owns an internal controller.
  final ScrollController? controller;

  final ScrollPhysics? physics;
  final Clip clipBehavior;

  /// Width of the physical-edge continuation fade.
  ///
  /// The fade is only visible when scrollable content exists beyond that
  /// physical edge.
  final double edgeFadeWidth;

  /// Scroll distance over which an edge fade grows from fully absent to
  /// fully visible.
  ///
  /// This makes the continuation treatment follow the user's gesture instead
  /// of suddenly appearing after a binary threshold.
  final double edgeFadeRevealDistance;

  /// Optional color the rail fades into.
  ///
  /// Defaults to [ThemeData.scaffoldBackgroundColor].
  final Color? edgeFadeColor;

  /// Whether platform overscroll chrome should remain visible.
  final bool showOverscrollIndicator;

  /// Whether platform scrollbars should remain visible.
  final bool showScrollbar;

  @override
  State<CinearaMediaHorizontalRail> createState() =>
      _CinearaMediaHorizontalRailState();
}

final class _CinearaMediaHorizontalRailState
    extends State<CinearaMediaHorizontalRail> {
  late ScrollController _controller;
  late bool _ownsController;

  double _leftFadeStrength = 0;
  double _rightFadeStrength = 0;

  static const double _edgeTolerance = 2;

  // ===========================================================================
  // Lifecycle
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _configureController();
    _scheduleEdgeStateUpdate();
  }

  @override
  void didUpdateWidget(CinearaMediaHorizontalRail oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      _detachController();

      if (_ownsController) {
        _controller.dispose();
      }

      _configureController();
    }

    if (oldWidget.children.length != widget.children.length ||
        oldWidget.itemWidth != widget.itemWidth ||
        oldWidget.spacing != widget.spacing ||
        oldWidget.padding != widget.padding ||
        oldWidget.edgeFadeWidth != widget.edgeFadeWidth) {
      _scheduleEdgeStateUpdate();
    }
  }

  @override
  void dispose() {
    _detachController();

    if (_ownsController) {
      _controller.dispose();
    }

    super.dispose();
  }

  // ===========================================================================
  // Controller ownership
  // ===========================================================================

  void _configureController() {
    final ScrollController? external = widget.controller;

    if (external != null) {
      _controller = external;
      _ownsController = false;
    } else {
      _controller = ScrollController();
      _ownsController = true;
    }

    _controller.addListener(_handleControllerScroll);
  }

  void _detachController() {
    _controller.removeListener(_handleControllerScroll);
  }

  // ===========================================================================
  // Dynamic continuation fade
  // ===========================================================================

  void _handleControllerScroll() {
    _updateEdgeFadeState();
  }

  void _scheduleEdgeStateUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateEdgeFadeState();
      }
    });
  }

  void _updateEdgeFadeState() {
    if (!mounted || !_controller.hasClients || widget.edgeFadeWidth <= 0) {
      _setEdgeFadeStrength(left: 0, right: 0);
      return;
    }

    final ScrollPosition position = _controller.position;

    final double beforeStrength = _fadeStrengthForExtent(position.extentBefore);

    final double afterStrength = _fadeStrengthForExtent(position.extentAfter);

    final double leftStrength;
    final double rightStrength;

    // extentBefore / extentAfter are logical along the scroll axis.
    // Convert them to physical left/right edges so RTL behaves correctly.
    switch (position.axisDirection) {
      case AxisDirection.right:
        leftStrength = beforeStrength;
        rightStrength = afterStrength;
        break;

      case AxisDirection.left:
        leftStrength = afterStrength;
        rightStrength = beforeStrength;
        break;

      case AxisDirection.up:
      case AxisDirection.down:
        leftStrength = 0;
        rightStrength = 0;
        break;
    }

    _setEdgeFadeStrength(left: leftStrength, right: rightStrength);
  }

  double _fadeStrengthForExtent(double extent) {
    if (extent <= _edgeTolerance) {
      return 0;
    }

    final double normalized = (extent / widget.edgeFadeRevealDistance)
        .clamp(0.0, 1.0)
        .toDouble();

    // Smoothstep: gradual at both ends, with no abrupt "on" moment.
    return normalized * normalized * (3 - (2 * normalized));
  }

  void _setEdgeFadeStrength({required double left, required double right}) {
    if ((_leftFadeStrength - left).abs() < 0.001 &&
        (_rightFadeStrength - right).abs() < 0.001) {
      return;
    }

    setState(() {
      _leftFadeStrength = left;
      _rightFadeStrength = right;
    });
  }

  Widget _buildEdgeFade({
    required BuildContext context,
    required bool left,
    required double strength,
  }) {
    if (strength <= 0) {
      return const SizedBox.shrink();
    }

    final Color color =
        widget.edgeFadeColor ?? Theme.of(context).scaffoldBackgroundColor;

    final Alignment begin = left ? Alignment.centerLeft : Alignment.centerRight;

    final Alignment end = left ? Alignment.centerRight : Alignment.centerLeft;

    return IgnorePointer(
      child: Opacity(
        opacity: strength.clamp(0.0, 1.0).toDouble(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: <Color>[
                color,
                color.withAlpha(244),
                color.withAlpha(212),
                color.withAlpha(156),
                color.withAlpha(88),
                color.withAlpha(32),
                color.withAlpha(0),
              ],
              stops: const <double>[0, 0.12, 0.28, 0.48, 0.68, 0.86, 1],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCinematicViewport({
    required BuildContext context,
    required Widget child,
  }) {
    if (widget.edgeFadeWidth <= 0) {
      return child;
    }

    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.hardEdge,
      children: <Widget>[
        child,

        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: widget.edgeFadeWidth,
          child: _buildEdgeFade(
            context: context,
            left: true,
            strength: _leftFadeStrength,
          ),
        ),

        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: widget.edgeFadeWidth,
          child: _buildEdgeFade(
            context: context,
            left: false,
            strength: _rightFadeStrength,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Scroll notifications
  // ===========================================================================

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.horizontal) {
      return false;
    }

    // A metrics change can happen after layout, viewport resizing, content
    // changes, or a physics update. Re-evaluate the continuation fades on the
    // next frame once the new scroll extents are stable.
    if (notification is ScrollMetricsNotification) {
      _scheduleEdgeStateUpdate();
    }

    // Cineara rails intentionally free-scroll. ScrollEndNotification does not
    // trigger any automatic correction or centering.
    return false;
  }

  // ===========================================================================
  // Scroll chrome
  // ===========================================================================

  bool _handleOverscrollIndicator(
    OverscrollIndicatorNotification notification,
  ) {
    if (!widget.showOverscrollIndicator) {
      notification.disallowIndicator();
    }

    return false;
  }

  ScrollBehavior _scrollBehavior(BuildContext context) {
    return ScrollConfiguration.of(context).copyWith(
      scrollbars: widget.showScrollbar,
      overscroll: widget.showOverscrollIndicator,
    );
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }

    final Widget scrollView = ScrollConfiguration(
      behavior: _scrollBehavior(context),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleOverscrollIndicator,
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
                  SizedBox(
                    width: widget.itemWidth,
                    child: widget.children[index],
                  ),
                  if (index < widget.children.length - 1)
                    SizedBox(width: widget.spacing),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return _buildCinematicViewport(context: context, child: scrollView);
  }
}
