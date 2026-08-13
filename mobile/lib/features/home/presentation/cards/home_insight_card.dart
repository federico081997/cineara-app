import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One statistic displayed inside a [HomeInsightCard].
///
/// The item contains presentation-ready values only.
///
/// Calculating statistics, deciding which insights are relevant, formatting
/// values, and localising strings should happen before the item reaches this
/// component.
///
/// Example:
///
/// ```dart
/// HomeInsightItem(
///   value: '42 h',
///   label: context.l10n.watchedThisMonth,
///   supportingText: context.l10n.eightHoursMoreThanLastMonth,
///   icon: Icons.schedule_rounded,
/// )
/// ```
///
/// The Home/controller layer can therefore replace or reorder statistics
/// without requiring any changes to [HomeInsightCard].
@immutable
class HomeInsightItem {
  /// Creates one Home insight.
  const HomeInsightItem({
    required this.value,
    required this.label,
    this.icon,
    this.supportingText,
    this.semanticLabel,
  });

  /// Already formatted value displayed prominently.
  ///
  /// Examples:
  ///
  /// - `42 h`
  /// - `18`
  /// - `11`
  /// - `63%`
  ///
  /// Locale-sensitive formatting belongs outside this component.
  final String value;

  /// Localised description of [value].
  ///
  /// Examples:
  ///
  /// - `Watched this month`
  /// - `Films this year`
  /// - `Countries explored`
  final String label;

  /// Optional visual icon representing the statistic.
  final IconData? icon;

  /// Optional lower-priority contextual information.
  ///
  /// Examples:
  ///
  /// - `8 h more than last month`
  /// - `3 new this month`
  /// - `Across 6 series`
  final String? supportingText;

  /// Optional fully localised accessibility description.
  ///
  /// This is useful when the spoken representation should be more descriptive
  /// than the compact visual [value] and [label].
  final String? semanticLabel;

  /// Accessibility description used when [semanticLabel] is not supplied.
  String get resolvedSemanticLabel {
    if (semanticLabel case final String semantic
        when semantic.trim().isNotEmpty) {
      return semantic;
    }

    final List<String> parts = <String>[label, value];

    if (supportingText case final String supporting
        when supporting.trim().isNotEmpty) {
      parts.add(supporting);
    }

    return parts.join(', ');
  }

  /// Stable signature used for visual transitions when an insight changes.
  Object get transitionKey {
    return Object.hash(value, label, icon, supportingText);
  }
}

/// Paged Cineara Home panel displaying a concise selection of user statistics.
///
/// The card accepts between one and nine ordered insights.
///
/// The Home card is intentionally capped at three visual pages. The number of
/// insights shown on each page adapts to available width and accessibility text
/// scaling:
///
/// ```text
/// normal phone text       -> up to 3 insights/page -> up to 9 visible
/// enlarged phone text     -> up to 2 insights/page -> up to 6 visible
/// very large phone text   -> 1 insight/page        -> up to 3 visible
/// ```
///
/// Wider layouts retain more insights per page where there is enough physical
/// room. Because the input order is meaningful, reducing the visible capacity
/// keeps the highest-priority insights at the front of the list.
///
/// Horizontal swipes use [PageView] so movement always snaps to complete pages.
///
/// The Home/controller layer remains responsible for:
///
/// - calculating statistics;
/// - ranking their relevance;
/// - deciding which statistics should appear;
/// - ordering them;
/// - formatting values;
/// - localising all displayed strings.
///
/// This widget is presentation-only.
///
/// Example:
///
/// ```dart
/// HomeInsightCard(
///   title: context.l10n.yourCineara,
///   insights: <HomeInsightItem>[
///     HomeInsightItem(
///       value: '42 h',
///       label: context.l10n.watchedThisMonth,
///       icon: Icons.schedule_rounded,
///     ),
///     HomeInsightItem(
///       value: '18',
///       label: context.l10n.filmsThisYear,
///       icon: Icons.movie_rounded,
///     ),
///     HomeInsightItem(
///       value: '11',
///       label: context.l10n.countriesExplored,
///       icon: Icons.public_rounded,
///     ),
///     HomeInsightItem(
///       value: '27',
///       label: context.l10n.episodesThisMonth,
///       icon: Icons.live_tv_rounded,
///     ),
///   ],
///   pageSemanticLabelBuilder: (int page, int pageCount) {
///     return context.l10n.insightPage(page, pageCount);
///   },
///   onTap: () {
///     // Open the complete Statistics screen.
///   },
/// )
/// ```
class HomeInsightCard extends StatefulWidget {
  /// Creates a paged Cineara Home insight panel.
  const HomeInsightCard({
    required this.insights,
    this.title,
    this.semanticLabel,
    this.pageSemanticLabelBuilder,
    this.onTap,
    this.enableHaptics = false,
    super.key,
  });

  /// Ordered statistics selected for the Home insight panel.
  ///
  /// Between one and nine items should be supplied.
  ///
  /// The ordering is meaningful because accessibility layouts may deliberately
  /// show fewer Home insights while keeping the card capped at three pages.
  ///
  /// The controller should therefore place the most useful insights first.
  final List<HomeInsightItem> insights;

  /// Optional localised heading displayed above the pages.
  ///
  /// Examples might conceptually represent:
  ///
  /// - the user's Cineara activity;
  /// - their current month;
  /// - their cinema journey.
  ///
  /// No heading is generated internally.
  final String? title;

  /// Optional fully localised accessibility description for the whole card.
  ///
  /// When supplied, this becomes the primary semantic description of the
  /// container.
  final String? semanticLabel;

  /// Optional builder for a localised page accessibility description.
  ///
  /// Both arguments are one-based from the user's perspective.
  ///
  /// For example, when the second of three pages is visible:
  ///
  /// ```text
  /// currentPage = 2
  /// pageCount   = 3
  /// ```
  ///
  /// No built-in page text is used so the widget remains localization-ready.
  final String Function(int currentPage, int pageCount)?
  pageSemanticLabelBuilder;

  /// Opens the related destination, normally the complete Statistics screen.
  ///
  /// When null, the card remains informational and does not show the navigation
  /// affordance or press interaction.
  final VoidCallback? onTap;

  /// Whether supported card interactions should produce haptic feedback.
  final bool enableHaptics;

  @override
  State<HomeInsightCard> createState() => _HomeInsightCardState();
}

class _HomeInsightCardState extends State<HomeInsightCard> {
  static const int _maximumInsights = 9;
  static const int _maximumPages = 3;

  static const Duration _minimumPressDuration = Duration(milliseconds: 90);

  late final PageController _pageController;

  int _currentPage = 0;

  bool _isPressed = false;

  bool _pageClampScheduled = false;

  DateTime? _pressStartedAt;

  bool get _isInteractive => widget.onTap != null;

  bool get _hasTitle => widget.title != null && widget.title!.trim().isNotEmpty;

  bool get _hasCustomSemanticLabel =>
      widget.semanticLabel != null && widget.semanticLabel!.trim().isNotEmpty;

  List<HomeInsightItem> _visibleInsightsFor(int insightsPerPage) {
    final int capacity = insightsPerPage * _maximumPages;

    return widget.insights
        .take(capacity < _maximumInsights ? capacity : _maximumInsights)
        .toList(growable: false);
  }

  static int _calculatePageCount(int itemCount, int insightsPerPage) {
    if (itemCount <= 0) {
      return 0;
    }

    return (itemCount + insightsPerPage - 1) ~/ insightsPerPage;
  }

  List<HomeInsightItem> _insightsForPage(
    List<HomeInsightItem> insights,
    int page,
    int insightsPerPage,
  ) {
    final int start = page * insightsPerPage;

    if (start >= insights.length) {
      return const <HomeInsightItem>[];
    }

    final int proposedEnd = start + insightsPerPage;

    final int end = proposedEnd < insights.length
        ? proposedEnd
        : insights.length;

    return insights.sublist(start, end);
  }

  void _ensureCurrentPageIsValid(int pageCount) {
    if (pageCount <= 0 || _currentPage < pageCount || _pageClampScheduled) {
      return;
    }

    final int targetPage = pageCount - 1;
    _pageClampScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      _pageClampScheduled = false;

      if (!mounted) {
        return;
      }

      if (_currentPage != targetPage) {
        setState(() {
          _currentPage = targetPage;
        });
      }

      if (_pageController.hasClients) {
        _pageController.jumpToPage(targetPage);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (!_isInteractive || _isPressed) {
      return;
    }

    _pressStartedAt = DateTime.now();

    setState(() {
      _isPressed = true;
    });
  }

  void _handleTap() {
    final VoidCallback? callback = widget.onTap;

    if (callback == null) {
      return;
    }

    _scheduleRelease();

    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    callback();
  }

  void _handleTapCancel() {
    _scheduleRelease();
  }

  void _handlePageChanged(int page) {
    if (_currentPage == page) {
      return;
    }

    setState(() {
      _currentPage = page;
    });

    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
  }

  void _scheduleRelease() {
    if (!_isPressed) {
      return;
    }

    final DateTime startedAt = _pressStartedAt ?? DateTime.now();

    final Duration elapsed = DateTime.now().difference(startedAt);

    final Duration remaining = elapsed >= _minimumPressDuration
        ? Duration.zero
        : _minimumPressDuration - elapsed;

    if (remaining == Duration.zero) {
      _releasePressedState();
      return;
    }

    Future<void>.delayed(remaining, () {
      if (!mounted) {
        return;
      }

      _releasePressedState();
    });
  }

  void _releasePressedState() {
    if (!_isPressed) {
      return;
    }

    setState(() {
      _isPressed = false;
    });

    _pressStartedAt = null;
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.insights.isNotEmpty,
      'HomeInsightCard requires at least one insight.',
    );

    assert(
      widget.insights.length <= _maximumInsights,
      'HomeInsightCard supports at most nine insights.',
    );

    if (widget.insights.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);

    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final Duration interactionDuration = reduceMotion
        ? Duration.zero
        : CinearaMotion.fast;

    final Duration contentTransitionDuration = reduceMotion
        ? Duration.zero
        : CinearaMotion.standard;

    final Duration scaleDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 90);

    final BorderRadius borderRadius = BorderRadius.circular(CinearaRadii.lg);

    //
    // Theme-derived surfaces keep the component independent from a specific
    // light or dark Cineara theme.
    //
    final Color surfaceStart = theme.colorScheme.surfaceContainerHigh;

    final Color surfaceMiddle = Color.alphaBlend(
      theme.colorScheme.primary.withValues(alpha: 0.055),
      theme.colorScheme.surfaceContainer,
    );

    final Color surfaceEnd = Color.alphaBlend(
      theme.colorScheme.secondary.withValues(alpha: 0.035),
      theme.colorScheme.surfaceContainer,
    );

    final Widget cardContent = AnimatedScale(
      scale: _isPressed && !reduceMotion ? 0.985 : 1.0,
      duration: scaleDuration,
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: interactionDuration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.55,
                  ),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[surfaceStart, surfaceMiddle, surfaceEnd],
                  stops: const <double>[0.0, 0.58, 1.0],
                ),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _isInteractive ? _handleTap : null,
                onTapDown: _isInteractive ? _handleTapDown : null,
                onTapCancel: _isInteractive ? _handleTapCancel : null,
                child: Stack(
                  children: <Widget>[
                    //
                    // MAIN CONTENT
                    //
                    Padding(
                      padding: const EdgeInsets.all(CinearaSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          //
                          // HEADER
                          //
                          if (_hasTitle || _isInteractive) ...<Widget>[
                            _InsightHeader(
                              title: _hasTitle ? widget.title : null,
                              showNavigationIndicator: _isInteractive,
                              isPressed: _isPressed,
                              animationDuration: interactionDuration,
                            ),
                            const SizedBox(height: CinearaSpacing.md),
                          ],

                          //
                          // RESPONSIVE PAGED STATISTICS
                          //
                          LayoutBuilder(
                            builder:
                                (
                                  BuildContext context,
                                  BoxConstraints constraints,
                                ) {
                                  final double width =
                                      constraints.hasBoundedWidth
                                      ? constraints.maxWidth
                                      : 360;

                                  final double textScale = _effectiveTextScale(
                                    context,
                                  );

                                  final int insightsPerPage =
                                      _resolveInsightsPerPage(
                                        width: width,
                                        textScale: textScale,
                                      );

                                  final List<HomeInsightItem> visibleInsights =
                                      _visibleInsightsFor(insightsPerPage);

                                  final int pageCount = _calculatePageCount(
                                    visibleInsights.length,
                                    insightsPerPage,
                                  );

                                  _ensureCurrentPageIsValid(pageCount);

                                  final int displayedPage = pageCount <= 0
                                      ? 0
                                      : _currentPage.clamp(0, pageCount - 1);

                                  final _HomeInsightDensity density =
                                      _resolveInsightDensity(width);

                                  final _InsightGeometry geometry =
                                      _InsightGeometry.resolve(
                                        context,
                                        density,
                                        insightsPerPage: insightsPerPage,
                                        textScale: textScale,
                                      );

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      SizedBox(
                                        height: geometry.pageHeight,
                                        child: PageView.builder(
                                          key: ValueKey<int>(insightsPerPage),
                                          controller: _pageController,
                                          itemCount: pageCount,
                                          pageSnapping: true,
                                          padEnds: false,
                                          allowImplicitScrolling: false,
                                          physics: pageCount > 1
                                              ? const PageScrollPhysics(
                                                  parent:
                                                      ClampingScrollPhysics(),
                                                )
                                              : const NeverScrollableScrollPhysics(),
                                          onPageChanged: _handlePageChanged,
                                          itemBuilder:
                                              (
                                                BuildContext context,
                                                int pageIndex,
                                              ) {
                                                final List<HomeInsightItem>
                                                pageInsights = _insightsForPage(
                                                  visibleInsights,
                                                  pageIndex,
                                                  insightsPerPage,
                                                );

                                                final String?
                                                pageSemanticLabel = widget
                                                    .pageSemanticLabelBuilder
                                                    ?.call(
                                                      pageIndex + 1,
                                                      pageCount,
                                                    );

                                                return _InsightPage(
                                                  key: ValueKey<String>(
                                                    '$insightsPerPage-'
                                                    '$pageIndex',
                                                  ),
                                                  insights: pageInsights,
                                                  insightsPerPage:
                                                      insightsPerPage,
                                                  geometry: geometry,
                                                  pageSemanticLabel:
                                                      pageSemanticLabel,
                                                  transitionDuration:
                                                      contentTransitionDuration,
                                                );
                                              },
                                        ),
                                      ),
                                      if (pageCount > 1) ...<Widget>[
                                        const SizedBox(
                                          height: CinearaSpacing.md,
                                        ),
                                        _InsightPageIndicator(
                                          currentPage: displayedPage,
                                          pageCount: pageCount,
                                          animationDuration:
                                              interactionDuration,
                                        ),
                                      ],
                                    ],
                                  );
                                },
                          ),
                        ],
                      ),
                    ),

                    //
                    // SUBTLE PRESS TINT
                    //
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: _isPressed && !reduceMotion ? 1.0 : 0.0,
                          duration: scaleDuration,
                          curve: Curves.easeOutCubic,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: borderRadius,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  theme.colorScheme.primary.withValues(
                                    alpha: 0.055,
                                  ),
                                  Colors.transparent,
                                  theme.colorScheme.secondary.withValues(
                                    alpha: 0.04,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (_hasCustomSemanticLabel) {
      return Semantics(
        container: true,
        button: _isInteractive,
        enabled: _isInteractive,
        label: widget.semanticLabel,
        onTap: widget.onTap,
        child: ExcludeSemantics(child: cardContent),
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      button: _isInteractive,
      enabled: _isInteractive,
      onTap: widget.onTap,
      child: cardContent,
    );
  }
}

/// Responsive density for the paged Home insight layout.
enum _HomeInsightDensity {
  /// Narrow phone or constrained card.
  compact,

  /// Standard phone layout.
  regular,

  /// Tablet or otherwise wide layout.
  expanded,
}

_HomeInsightDensity _resolveInsightDensity(double width) {
  if (width < 320) {
    return _HomeInsightDensity.compact;
  }

  if (width < 600) {
    return _HomeInsightDensity.regular;
  }

  return _HomeInsightDensity.expanded;
}

double _effectiveTextScale(BuildContext context) {
  final TextScaler scaler = MediaQuery.textScalerOf(context);

  // Measuring a representative font size works for both linear and future
  // nonlinear TextScaler implementations without relying on deprecated APIs.
  return scaler.scale(16) / 16;
}

int _resolveInsightsPerPage({
  required double width,
  required double textScale,
}) {
  // Very large accessibility text needs a dedicated reading width on phones.
  if (textScale >= 1.80) {
    return width >= 600 ? 2 : 1;
  }

  // Moderately enlarged text keeps a useful comparison while avoiding three
  // cramped columns on phone-sized cards.
  if (textScale >= 1.30) {
    return width >= 600 ? 3 : 2;
  }

  // Very narrow cards use two columns even at normal text size.
  if (width < 320) {
    return 2;
  }

  return 3;
}

/// Calculated metric geometry for one responsive density.
///
/// Fixed content slots keep values, labels and supporting information aligned
/// between adjacent statistics and between different pages.
///
/// Text-dependent heights respect the current [TextScaler], preventing a page
/// from changing height when the user swipes while still accommodating larger
/// accessibility text.
@immutable
class _InsightGeometry {
  const _InsightGeometry({
    required this.iconContainerSize,
    required this.iconSize,
    required this.valueFontSize,
    required this.labelFontSize,
    required this.supportingFontSize,
    required this.valueSlotHeight,
    required this.labelSlotHeight,
    required this.supportingSlotHeight,
    required this.labelMaxLines,
    required this.supportingMaxLines,
    required this.iconToValueSpacing,
    required this.valueToLabelSpacing,
    required this.labelToSupportingSpacing,
    required this.horizontalMetricPadding,
  });

  final double iconContainerSize;

  final double iconSize;

  final double valueFontSize;

  final double labelFontSize;

  final double supportingFontSize;

  final double valueSlotHeight;

  final double labelSlotHeight;

  final double supportingSlotHeight;

  final int labelMaxLines;

  final int supportingMaxLines;

  final double iconToValueSpacing;

  final double valueToLabelSpacing;

  final double labelToSupportingSpacing;

  final double horizontalMetricPadding;

  double get pageHeight {
    return iconContainerSize +
        iconToValueSpacing +
        valueSlotHeight +
        valueToLabelSpacing +
        labelSlotHeight +
        labelToSupportingSpacing +
        supportingSlotHeight;
  }

  static _InsightGeometry resolve(
    BuildContext context,
    _HomeInsightDensity density, {
    required int insightsPerPage,
    required double textScale,
  }) {
    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    final double iconContainerSize = switch (density) {
      _HomeInsightDensity.compact => 28,
      _HomeInsightDensity.regular => 30,
      _HomeInsightDensity.expanded => 32,
    };

    final double iconSize = switch (density) {
      _HomeInsightDensity.compact => 15,
      _HomeInsightDensity.regular => 16,
      _HomeInsightDensity.expanded => 17,
    };

    final double valueFontSize = switch (density) {
      _HomeInsightDensity.compact => 21,
      _HomeInsightDensity.regular => 24,
      _HomeInsightDensity.expanded => 26,
    };

    final double labelFontSize = switch (density) {
      _HomeInsightDensity.compact => 10.5,
      _HomeInsightDensity.regular => 11.5,
      _HomeInsightDensity.expanded => 12,
    };

    final double supportingFontSize = switch (density) {
      _HomeInsightDensity.compact => 9.5,
      _HomeInsightDensity.regular => 10,
      _HomeInsightDensity.expanded => 10.5,
    };

    final int labelMaxLines = 2;

    final int supportingMaxLines = insightsPerPage == 1 || textScale >= 1.30
        ? 3
        : 2;

    final double scaledValueSize = textScaler.scale(valueFontSize);

    final double scaledLabelSize = textScaler.scale(labelFontSize);

    final double scaledSupportingSize = textScaler.scale(supportingFontSize);

    // Slightly more generous line boxes are intentional. CJK, Arabic,
    // Devanagari and other fallback fonts can have taller ascent/descent
    // metrics than the primary Latin font.
    const double valueLineHeight = 1.20;
    const double labelLineHeight = 1.30;
    const double supportingLineHeight = 1.30;

    return _InsightGeometry(
      iconContainerSize: iconContainerSize,
      iconSize: iconSize,
      valueFontSize: valueFontSize,
      labelFontSize: labelFontSize,
      supportingFontSize: supportingFontSize,
      valueSlotHeight: scaledValueSize * valueLineHeight + 2,
      labelSlotHeight: scaledLabelSize * labelLineHeight * labelMaxLines + 2,
      supportingSlotHeight:
          scaledSupportingSize * supportingLineHeight * supportingMaxLines + 2,
      labelMaxLines: labelMaxLines,
      supportingMaxLines: supportingMaxLines,
      iconToValueSpacing: CinearaSpacing.sm,
      valueToLabelSpacing: CinearaSpacing.xs,
      labelToSupportingSpacing: CinearaSpacing.xxs,
      horizontalMetricPadding: switch (density) {
        _HomeInsightDensity.compact => CinearaSpacing.xxs,
        _HomeInsightDensity.regular => CinearaSpacing.xs,
        _HomeInsightDensity.expanded => CinearaSpacing.sm,
      },
    );
  }
}

/// One complete horizontally swipeable page of insights.
///
/// Every insight occupies one slot of the current responsive page capacity.
///
/// Incomplete final pages remain centred rather than stretching their remaining
/// metrics to fill the whole card. This keeps a statistic visually stable when
/// the final page contains fewer items than the previous pages.
class _InsightPage extends StatelessWidget {
  const _InsightPage({
    required this.insights,
    required this.insightsPerPage,
    required this.geometry,
    required this.pageSemanticLabel,
    required this.transitionDuration,
    super.key,
  });

  final List<HomeInsightItem> insights;

  final int insightsPerPage;

  final _InsightGeometry geometry;

  final String? pageSemanticLabel;

  final Duration transitionDuration;

  @override
  Widget build(BuildContext context) {
    final double widthFactor = insights.length / insightsPerPage;

    final Widget content = Align(
      alignment: Alignment.topCenter,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: SizedBox(
          height: geometry.pageHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int index = 0; index < insights.length; index++) ...<Widget>[
                Expanded(
                  child: _InsightMetricSlot(
                    item: insights[index],
                    geometry: geometry,
                    transitionDuration: transitionDuration,
                  ),
                ),

                if (index != insights.length - 1)
                  const _InsightVerticalDivider(),
              ],
            ],
          ),
        ),
      ),
    );

    if (pageSemanticLabel case final String label
        when label.trim().isNotEmpty) {
      return Semantics(
        container: true,
        explicitChildNodes: true,
        label: label,
        child: content,
      );
    }

    return content;
  }
}

/// Stable page slot that softly transitions when the Home algorithm replaces
/// one statistic with another at the same position.
class _InsightMetricSlot extends StatelessWidget {
  const _InsightMetricSlot({
    required this.item,
    required this.geometry,
    required this.transitionDuration,
  });

  final HomeInsightItem item;

  final _InsightGeometry geometry;

  final Duration transitionDuration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: transitionDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[...previousChildren, ?currentChild],
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        final Animation<Offset> position =
            Tween<Offset>(
              begin: const Offset(0, 0.025),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: position, child: child),
        );
      },
      child: _InsightMetric(
        key: ValueKey<Object>(item.transitionKey),
        item: item,
        geometry: geometry,
      ),
    );
  }
}

/// Heading and optional navigation affordance.
class _InsightHeader extends StatelessWidget {
  const _InsightHeader({
    required this.title,
    required this.showNavigationIndicator,
    required this.isPressed,
    required this.animationDuration,
  });

  final String? title;
  final bool showNavigationIndicator;
  final bool isPressed;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextDirection direction = Directionality.of(context);

    final double arrowShift = direction == TextDirection.rtl ? -0.15 : 0.15;

    final bool hasTitle = title != null && title!.trim().isNotEmpty;

    return Row(
      children: <Widget>[
        if (hasTitle)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: true,
                  applyHeightToLastDescent: true,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  height: 1.30,
                  letterSpacing: 0.10,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
            ),
          )
        else
          const Spacer(),

        if (showNavigationIndicator) ...<Widget>[
          const SizedBox(width: CinearaSpacing.sm),
          ExcludeSemantics(
            child: AnimatedSlide(
              offset: isPressed ? Offset(arrowShift, 0) : Offset.zero,
              duration: animationDuration,
              curve: Curves.easeOutCubic,
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  end: isPressed
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.70,
                        ),
                ),
                duration: animationDuration,
                curve: Curves.easeOutCubic,
                builder: (BuildContext context, Color? color, Widget? child) {
                  return Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: color,
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// One aligned statistic inside an insight page.
///
/// Every instance reserves identical vertical slots for:
///
/// - icon;
/// - value;
/// - a responsive label slot;
/// - a responsive supporting-text slot.
///
/// This keeps neighbouring statistics aligned even when text length differs
/// between languages.
class _InsightMetric extends StatelessWidget {
  const _InsightMetric({required this.item, required this.geometry, super.key});

  final HomeInsightItem item;

  final _InsightGeometry geometry;

  bool get _hasSupportingText =>
      item.supportingText != null && item.supportingText!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Semantics(
      container: true,
      label: item.resolvedSemanticLabel,
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: geometry.horizontalMetricPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              //
              // FIXED ICON SLOT
              //
              SizedBox(
                height: geometry.iconContainerSize,
                child: switch (item.icon) {
                  final IconData icon => Align(
                    alignment: Alignment.topCenter,
                    child: _InsightIcon(
                      icon: icon,
                      containerSize: geometry.iconContainerSize,
                      iconSize: geometry.iconSize,
                    ),
                  ),
                  null => null,
                },
              ),

              SizedBox(height: geometry.iconToValueSpacing),

              //
              // FIXED VALUE SLOT
              //
              SizedBox(
                height: geometry.valueSlotHeight,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: Text(
                      item.value,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: true,
                        applyHeightToLastDescent: true,
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontSize: geometry.valueFontSize,
                        height: 1.20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                        leadingDistribution: TextLeadingDistribution.even,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: geometry.valueToLabelSpacing),

              //
              // RESPONSIVE LABEL SLOT
              //
              SizedBox(
                height: geometry.labelSlotHeight,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    item.label,
                    maxLines: geometry.labelMaxLines,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: true,
                      applyHeightToLastDescent: true,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: geometry.labelFontSize,
                      height: 1.30,
                      fontWeight: FontWeight.w600,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                  ),
                ),
              ),

              SizedBox(height: geometry.labelToSupportingSpacing),

              //
              // RESPONSIVE SUPPORTING-TEXT SLOT
              //
              SizedBox(
                height: geometry.supportingSlotHeight,
                child: _hasSupportingText
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          item.supportingText!,
                          maxLines: geometry.supportingMaxLines,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: true,
                            applyHeightToLastDescent: true,
                            leadingDistribution: TextLeadingDistribution.even,
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.72),
                            fontSize: geometry.supportingFontSize,
                            height: 1.30,
                            fontWeight: FontWeight.w500,
                            leadingDistribution: TextLeadingDistribution.even,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small theme-aware icon surface used by each statistic.
class _InsightIcon extends StatelessWidget {
  const _InsightIcon({
    required this.icon,
    required this.containerSize,
    required this.iconSize,
  });

  final IconData icon;

  final double containerSize;

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color background = Color.alphaBlend(
      theme.colorScheme.primary.withValues(alpha: 0.12),
      theme.colorScheme.surfaceContainerHighest,
    );

    return Container(
      width: containerSize,
      height: containerSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(CinearaRadii.sm),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.19),
        ),
      ),
      child: Icon(icon, size: iconSize, color: theme.colorScheme.primary),
    );
  }
}

/// Vertical separator between neighbouring statistics.
class _InsightVerticalDivider extends StatelessWidget {
  const _InsightVerticalDivider();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: CinearaSpacing.xxs),
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.52),
    );
  }
}

/// Compact progress indicator shown underneath paged insights.
///
/// The active page expands into a longer segment while inactive pages remain
/// small. Because the indicator uses the active [ColorScheme], it works with
/// light, dark and future Cineara themes without theme-specific constants.
class _InsightPageIndicator extends StatelessWidget {
  const _InsightPageIndicator({
    required this.currentPage,
    required this.pageCount,
    required this.animationDuration,
  });

  final int currentPage;

  final int pageCount;

  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ExcludeSemantics(
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int index = 0; index < pageCount; index++) ...<Widget>[
              AnimatedContainer(
                duration: animationDuration,
                curve: Curves.easeOutCubic,
                width: index == currentPage ? 22 : 6,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(CinearaRadii.pill),
                  color: index == currentPage
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.72,
                        ),
                ),
              ),

              if (index != pageCount - 1)
                const SizedBox(width: CinearaSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }
}
