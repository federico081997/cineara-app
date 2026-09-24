import 'dart:async';
import 'dart:math' as math;

import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/search/presentation/pages/search_page.dart';
import '../../l10n/app_localizations.dart';
import '../routing/app_routes.dart';
import 'app_root_destination.dart';

/// Persistent application shell for Cineara's primary navigation branches.
///
/// Root destinations and Search share one top-bar surface. Search expands from
/// the existing Search action while the active branch supplies the page content
/// below it.
final class CinearaAppShell extends StatelessWidget {
  const CinearaAppShell({
    required this.navigationShell,
    required this.location,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final String location;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final AppRootDestination currentDestination =
        AppRootDestination.values[navigationShell.currentIndex];

    final List<CinearaNavigationDestination> destinations =
        <CinearaNavigationDestination>[
          for (final AppRootDestination destination
              in AppRootDestination.values)
            destination.navigationDestination(l10n),
        ];

    final bool isRootLocation = AppRoutes.isRootLocation(location);
    final bool isSearchLocation =
        location == AppRoutes.searchFor(currentDestination);
    final bool showShellTopBar = isRootLocation || isSearchLocation;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      appBar: showShellTopBar
          ? _ShellTopBar(
              searchMode: isSearchLocation,
              currentDestination: currentDestination,
              l10n: l10n,
            )
          : null,
      // The StatefulShellRoute is the single owner of branch page content.
      // SearchPage is mounted by the Search route itself, so the shell never
      // substitutes feature pages outside the active branch Navigator.
      body: navigationShell,
      bottomNavigationBar: CinearaNavigationPill(
        destinations: destinations,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) {
          _selectDestination(
            index,
            isSearchLocation: isSearchLocation,
            searchController: CinearaSearchDependenciesScope.of(
              context,
            ).chromeController,
          );
        },
      ),
    );
  }

  void _selectDestination(
    int index, {
    required bool isSearchLocation,
    required CinearaSearchChromeController searchController,
  }) {
    final int currentIndex = navigationShell.currentIndex;

    if (isSearchLocation) {
      searchController.resetForNavigation();

      // Remove Search from the current branch before leaving it.
      navigationShell.goBranch(currentIndex, initialLocation: true);

      if (index != currentIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigationShell.goBranch(index);
        });
      }

      return;
    }

    navigationShell.goBranch(index, initialLocation: index == currentIndex);
  }
}

/// Shell-level top bar shared by root destinations and Search.
///
/// The AppBar uses the same background as the page so the complete Search
/// experience reads as one continuous light or dark surface.
final class _ShellTopBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ShellTopBar({
    required this.searchMode,
    required this.currentDestination,
    required this.l10n,
  });

  static const double _toolbarHeight = 64;

  final bool searchMode;
  final AppRootDestination currentDestination;
  final AppLocalizations l10n;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CinearaSearchDependencies searchDependencies =
        CinearaSearchDependenciesScope.of(context);

    final ThemeData topBarTheme = theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );

    return Theme(
      data: topBarTheme,
      child: CinearaTopAppBar(
        showBrand: true,
        toolbarHeight: _toolbarHeight,
        brandSemanticLabel: searchMode ? l10n.searchFieldLabel : 'Cineara',
        brand: _ShellTopBarContent(
          searchMode: searchMode,
          currentDestination: currentDestination,
          l10n: l10n,
          searchController: searchDependencies.chromeController,
        ),
      ),
    );
  }
}

/// Full-width animated content inside Cineara's top bar.
///
/// Search is represented by one continuous surface. The same circular Search
/// action that receives the press highlight expands into the query field, which
/// removes cross-fades between duplicate Search controls.
final class _ShellTopBarContent extends StatefulWidget {
  const _ShellTopBarContent({
    required this.searchMode,
    required this.currentDestination,
    required this.l10n,
    required this.searchController,
  });

  static const double _searchFieldHeight = 44;

  final bool searchMode;
  final AppRootDestination currentDestination;
  final AppLocalizations l10n;
  final CinearaSearchChromeController searchController;

  @override
  State<_ShellTopBarContent> createState() => _ShellTopBarContentState();
}

final class _ShellTopBarContentState extends State<_ShellTopBarContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _closing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      value: widget.searchMode ? 1 : 0,
      duration: CinearaMotion.searchTransition,
      reverseDuration: CinearaMotion.searchTransition,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool reduceMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;

    final Duration duration = CinearaMotion.resolve(
      CinearaMotion.searchTransition,
      reduceMotion: reduceMotion,
    );

    _controller
      ..duration = duration
      ..reverseDuration = duration;

    if (duration == Duration.zero) {
      _controller.value = widget.searchMode ? 1 : 0;
    }
  }

  @override
  void didUpdateWidget(_ShellTopBarContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.searchMode == widget.searchMode) {
      return;
    }

    if (widget.searchMode) {
      _closing = false;

      if (_controller.value < 1) {
        if (_controller.duration == Duration.zero) {
          _controller.value = 1;
        } else {
          _controller.forward();
        }
      }
      return;
    }

    _closing = false;
    widget.searchController.focusNode.unfocus();

    if (_controller.value > 0) {
      if (_controller.reverseDuration == Duration.zero) {
        _controller.value = 0;
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openSearch() {
    if (_closing || widget.searchMode) {
      return;
    }

    // Route state owns the expanded Search state. The pressed icon provides
    // immediate feedback, then the route change mounts SearchPage and the
    // shell morph starts from didUpdateWidget. This prevents the field from
    // opening over an unchanged root page when navigation has not completed.
    unawaited(context.push(AppRoutes.searchFor(widget.currentDestination)));
  }

  Future<void> _closeSearch() async {
    if (_closing || !widget.searchMode) {
      return;
    }

    setState(() {
      _closing = true;
    });

    widget.searchController.focusNode.unfocus();

    if (_controller.reverseDuration == Duration.zero) {
      _controller.value = 0;
    } else if (_controller.value > 0) {
      await _controller.reverse();
    }

    if (!mounted) {
      return;
    }

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.locationFor(widget.currentDestination));
  }

  @override
  Widget build(BuildContext context) {
    const double actionExtent = 48;
    final double actionGap = CinearaSpacing.xxs;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableWidth = constraints.maxWidth;
        final double rootActionsWidth = (actionExtent * 3) + (actionGap * 2);

        final double rootSearchStart = math.max(
          0,
          availableWidth - rootActionsWidth,
        );

        final double expandedSearchStart = math.min(
          actionExtent + actionGap,
          math.max(0, availableWidth - actionExtent),
        );

        final double expandedEndInset = actionGap;
        final double expandedSearchWidth = math.max(
          actionExtent,
          availableWidth - expandedSearchStart - expandedEndInset,
        );

        return SizedBox(
          width: double.infinity,
          height: actionExtent,
          child: AnimatedBuilder(
            animation: Listenable.merge(<Listenable>[
              _controller,
              widget.searchController.focusNode,
            ]),
            builder: (BuildContext context, Widget? child) {
              final double rawProgress = _controller.value;
              final double progress = CinearaMotion.bubbleCurve.transform(
                rawProgress,
              );
              final double fadeProgress = CinearaMotion.fadeCurve.transform(
                rawProgress,
              );

              final double trailingOpacity =
                  1 - _interval(fadeProgress, 0.05, 0.42);
              final double brandOpacity =
                  1 - _interval(fadeProgress, 0.03, 0.38);
              final double backOpacity = _interval(fadeProgress, 0.42, 0.84);

              final double searchStart = _lerp(
                rootSearchStart,
                expandedSearchStart,
                progress,
              );

              final double searchWidth = _lerp(
                actionExtent,
                expandedSearchWidth,
                progress,
              );

              final double searchHeight = _lerp(
                actionExtent,
                _ShellTopBarContent._searchFieldHeight,
                progress,
              );

              final double searchTop = (actionExtent - searchHeight) / 2;

              return Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.hardEdge,
                children: <Widget>[
                  PositionedDirectional(
                    start: 0,
                    end: rootActionsWidth + actionGap,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      ignoring: progress > 0.12,
                      child: Opacity(
                        opacity: brandOpacity,
                        child: Transform.scale(
                          scale: _lerp(1, 0.982, progress),
                          alignment: AlignmentDirectional.centerStart.resolve(
                            Directionality.of(context),
                          ),
                          child: const Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: CinearaBrandMark(
                              size: CinearaBrandMarkSize.compact,
                              semanticLabel: 'Cineara',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: rootSearchStart + actionExtent + actionGap,
                    top: 0,
                    width: actionExtent,
                    height: actionExtent,
                    child: _TrailingTopBarAction(
                      progress: progress,
                      opacity: trailingOpacity,
                      child: CinearaNotificationAppBarAction(
                        semanticLabel: widget.l10n.topBarNotifications,
                        onPressed: () {},
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: rootSearchStart + ((actionExtent + actionGap) * 2),
                    top: 0,
                    width: actionExtent,
                    height: actionExtent,
                    child: _TrailingTopBarAction(
                      progress: progress,
                      opacity: trailingOpacity,
                      child: CinearaProfileAppBarAction(
                        semanticLabel: widget.l10n.topBarOpenProfileMenu,
                        onPressed: () {},
                        imageProvider: null,
                        fallbackInitials: null,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: 0,
                    top: 0,
                    width: actionExtent,
                    height: actionExtent,
                    child: IgnorePointer(
                      ignoring: backOpacity < 0.96 || _closing,
                      child: Opacity(
                        opacity: backOpacity,
                        child: Transform.translate(
                          offset: Offset(
                            _directionalOffset(context, 7 * (1 - backOpacity)),
                            0,
                          ),
                          child: CinearaTopAppBarIconAction(
                            icon: Icons.arrow_back_rounded,
                            semanticLabel: MaterialLocalizations.of(
                              context,
                            ).backButtonTooltip,
                            isSelected: _closing,
                            onPressed: () {
                              _closeSearch();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: searchStart,
                    top: searchTop,
                    width: searchWidth,
                    height: searchHeight,
                    child: _SearchMorphSurface(
                      progress: progress,
                      engaged: widget.searchMode || _closing,
                      controller: widget.searchController,
                      l10n: widget.l10n,
                      onOpen: _openSearch,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// Root action that yields its top-bar space to Search.
final class _TrailingTopBarAction extends StatelessWidget {
  const _TrailingTopBarAction({
    required this.progress,
    required this.opacity,
    required this.child,
  });

  final double progress;
  final double opacity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: progress > 0.10,
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(_directionalOffset(context, 7 * progress), 0),
          child: Transform.scale(scale: _lerp(1, 0.97, progress), child: child),
        ),
      ),
    );
  }
}

/// Search surface that grows from the root Search action into the query field.
///
/// The collapsed layer is the real shared top-bar action, so Search and
/// Notifications receive identical circular feedback before Search begins to
/// expand.
final class _SearchMorphSurface extends StatelessWidget {
  const _SearchMorphSurface({
    required this.progress,
    required this.engaged,
    required this.controller,
    required this.l10n,
    required this.onOpen,
  });

  final double progress;
  final bool engaged;
  final CinearaSearchChromeController controller;
  final AppLocalizations l10n;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool focused = controller.focusNode.hasFocus;
    final bool highContrast = MediaQuery.highContrastOf(context);

    final double fieldProgress = _interval(progress, 0.10, 0.86);
    final double contentProgress = _interval(progress, 0.30, 0.82);
    final double collapsedActionOpacity = 1 - _interval(progress, 0.10, 0.24);
    final double movingIconOpacity = 1 - collapsedActionOpacity;

    final Color actionHighlight = colors.primary.withValues(
      alpha: highContrast ? 0.18 : 0.10,
    );

    final double fieldTintOpacity = highContrast
        ? 0.14
        : focused
        ? (theme.brightness == Brightness.dark ? 0.11 : 0.065)
        : (theme.brightness == Brightness.dark ? 0.075 : 0.035);

    final Color fieldBackground = Color.alphaBlend(
      colors.primary.withValues(alpha: fieldTintOpacity),
      colors.surfaceContainerHighest,
    );

    final Color targetBackground =
        Color.lerp(actionHighlight, fieldBackground, fieldProgress) ??
        fieldBackground;

    // The morph background takes over exactly as the real collapsed action
    // fades away. This prevents two translucent highlight circles from being
    // painted on top of each other during the hand-off.
    final Color background =
        Color.lerp(Colors.transparent, targetBackground, movingIconOpacity) ??
        targetBackground;

    final Color borderColor =
        Color.lerp(
          Colors.transparent,
          colors.primary.withValues(
            alpha: highContrast
                ? 1
                : focused
                ? 0.62
                : 0.30,
          ),
          fieldProgress,
        ) ??
        Colors.transparent;

    final double borderWidth = _lerp(
      0,
      highContrast
          ? 2
          : focused
          ? 1.25
          : 0.9,
      fieldProgress,
    );

    final Color movingIconColor =
        Color.lerp(
          colors.primary,
          focused ? colors.primary : colors.onSurfaceVariant,
          fieldProgress,
        ) ??
        colors.primary;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double radius = constraints.maxHeight / 2;
        final double iconStart = _lerp(
          math.max(0, (constraints.maxWidth - 22) / 2),
          14,
          fieldProgress,
        );

        final List<BoxShadow> shadows = fieldProgress < 0.35
            ? const <BoxShadow>[]
            : <BoxShadow>[
                BoxShadow(
                  color: colors.primary.withValues(
                    alpha: focused ? 0.085 : 0.035,
                  ),
                  blurRadius: focused ? 16 : 10,
                  spreadRadius: focused ? 0.5 : 0,
                  offset: const Offset(0, 2),
                ),
              ];

        return DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(radius),
            border: borderWidth <= 0
                ? null
                : Border.all(color: borderColor, width: borderWidth),
            boxShadow: shadows,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (progress > 0.20)
                  IgnorePointer(
                    ignoring: progress < 0.78,
                    child: Opacity(
                      opacity: contentProgress,
                      child: _ShellSearchField(
                        controller: controller,
                        l10n: l10n,
                      ),
                    ),
                  ),
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  width: 48,
                  height: 48,
                  child: IgnorePointer(
                    ignoring: engaged || progress > 0.02,
                    child: Opacity(
                      opacity: collapsedActionOpacity,
                      child: CinearaTopAppBarIconAction(
                        icon: Icons.search_rounded,
                        semanticLabel: l10n.topBarSearch,
                        isSelected: engaged,
                        onPressed: onOpen,
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: iconStart,
                  top: (constraints.maxHeight - 22) / 2,
                  width: 22,
                  height: 22,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: movingIconOpacity,
                      child: Icon(
                        Icons.search_rounded,
                        size: 22,
                        color: movingIconColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Query field displayed inside the expanded Search bubble.
///
/// [_SearchMorphSurface] owns the background, border, radius, shadow and moving
/// Search icon. This widget supplies only the query text and trailing clear
/// action so the expanded control remains one continuous visual surface.
final class _ShellSearchField extends StatelessWidget {
  const _ShellSearchField({required this.controller, required this.l10n});

  static const double _height = 44;
  static const double _actionWidth = 48;

  final CinearaSearchChromeController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        controller,
        controller.queryController,
        controller.focusNode,
      ]),
      builder: (BuildContext context, Widget? child) {
        final bool focused = controller.focusNode.hasFocus;
        final bool hasText = controller.queryController.text.isNotEmpty;

        return SizedBox(
          height: _height,
          child: Row(
            children: <Widget>[
              // The animated Search glyph is painted by _SearchMorphSurface.
              // Reserving the same width as the clear action keeps the query
              // mathematically centered throughout the interaction.
              const SizedBox(width: _actionWidth, height: _height),
              Expanded(
                child: TextField(
                  controller: controller.queryController,
                  focusNode: controller.focusNode,
                  maxLines: 1,
                  textInputAction: TextInputAction.search,
                  keyboardType: TextInputType.text,
                  enableSuggestions: true,
                  autocorrect: true,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: colors.primary,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                  onChanged: controller.handleChanged,
                  onSubmitted: controller.handleSubmitted,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    hintMaxLines: 1,
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w500,
                    ),
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              SizedBox(
                width: _actionWidth,
                height: _height,
                child: AnimatedSwitcher(
                  duration: CinearaMotion.fast,
                  switchInCurve: CinearaMotion.enterCurve,
                  switchOutCurve: CinearaMotion.exitCurve,
                  child: hasText
                      ? IconButton(
                          key: const ValueKey<String>('clear'),
                          tooltip: l10n.searchClearSearch,
                          onPressed: controller.clearSearch,
                          icon: Icon(
                            Icons.close_rounded,
                            size: 22,
                            color: focused
                                ? colors.onSurface
                                : colors.onSurfaceVariant,
                          ),
                        )
                      : const SizedBox(key: ValueKey<String>('empty')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

double _interval(double value, double begin, double end) {
  if (end <= begin) {
    return value >= end ? 1 : 0;
  }

  return ((value - begin) / (end - begin)).clamp(0.0, 1.0).toDouble();
}

double _lerp(double begin, double end, double progress) {
  return begin + ((end - begin) * progress);
}

double _directionalOffset(BuildContext context, double logicalOffset) {
  return Directionality.of(context) == TextDirection.ltr
      ? logicalOffset
      : -logicalOffset;
}
