import 'dart:async';

import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CinearaStatusDockPreviewApp());
}

// =============================================================================
// App
// =============================================================================

final class CinearaStatusDockPreviewApp extends StatefulWidget {
  const CinearaStatusDockPreviewApp({super.key});

  @override
  State<CinearaStatusDockPreviewApp> createState() =>
      _CinearaStatusDockPreviewAppState();
}

final class _CinearaStatusDockPreviewAppState
    extends State<CinearaStatusDockPreviewApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  bool _highContrast = false;
  bool _reducedMotion = false;
  bool _rtl = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cineara Status Dock Preview',
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQuery.copyWith(
            highContrast: _highContrast,
            disableAnimations: _reducedMotion,
            accessibleNavigation: _reducedMotion,
          ),
          child: Directionality(
            textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: _PreviewPage(
        themeMode: _themeMode,
        highContrast: _highContrast,
        reducedMotion: _reducedMotion,
        rtl: _rtl,
        onThemeModeChanged: (ThemeMode value) {
          setState(() {
            _themeMode = value;
          });
        },
        onHighContrastChanged: (bool value) {
          setState(() {
            _highContrast = value;
          });
        },
        onReducedMotionChanged: (bool value) {
          setState(() {
            _reducedMotion = value;
          });
        },
        onRtlChanged: (bool value) {
          setState(() {
            _rtl = value;
          });
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final ColorScheme colors = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7657E8),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? const Color(0xFF0D0A10)
          : const Color(0xFFFFF8FF),
    );
  }
}

// =============================================================================
// Preview page
// =============================================================================

final class _PreviewPage extends StatefulWidget {
  const _PreviewPage({
    required this.themeMode,
    required this.highContrast,
    required this.reducedMotion,
    required this.rtl,
    required this.onThemeModeChanged,
    required this.onHighContrastChanged,
    required this.onReducedMotionChanged,
    required this.onRtlChanged,
  });

  final ThemeMode themeMode;

  final bool highContrast;
  final bool reducedMotion;
  final bool rtl;

  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<bool> onHighContrastChanged;
  final ValueChanged<bool> onReducedMotionChanged;
  final ValueChanged<bool> onRtlChanged;

  @override
  State<_PreviewPage> createState() => _PreviewPageState();
}

final class _PreviewPageState extends State<_PreviewPage> {
  // ===========================================================================
  // Interactive example state
  // ===========================================================================

  final CinearaStatusDockController _dockController =
      CinearaStatusDockController();

  bool _favorite = true;
  bool _collection = true;
  bool _watchlist = false;

  double? _personalRating = 8.5;

  Set<CinearaStatusDockIndicator> _visibleIndicators =
      <CinearaStatusDockIndicator>{
        CinearaStatusDockIndicator.favorite,
        CinearaStatusDockIndicator.collection,
        CinearaStatusDockIndicator.watchlist,
        CinearaStatusDockIndicator.rating,
      };

  CinearaStatusDockMode _mode = CinearaStatusDockMode.compact;

  CinearaStatusDockDensity _density = CinearaStatusDockDensity.compact;

  CinearaStatusDockVariant _variant = CinearaStatusDockVariant.artwork;

  CinearaStatusDockSide _side = CinearaStatusDockSide.end;

  bool _tapToExpand = true;
  bool _autoCollapse = true;

  static const CinearaStatusDockLabels _dockLabels = CinearaStatusDockLabels(
    dock: 'Personal media status',
    favorite: 'Favorite',
    collection: 'In collection',
    watchlist: 'In watchlist',
    personalRating: 'Personal rating',
  );

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 72),
              sliver: SliverList.list(
                children: <Widget>[
                  _PreviewHeader(
                    themeMode: widget.themeMode,
                    highContrast: widget.highContrast,
                    reducedMotion: widget.reducedMotion,
                    rtl: widget.rtl,
                    onThemeModeChanged: widget.onThemeModeChanged,
                    onHighContrastChanged: widget.onHighContrastChanged,
                    onReducedMotionChanged: widget.onReducedMotionChanged,
                    onRtlChanged: widget.onRtlChanged,
                  ),

                  const SizedBox(height: 48),

                  // ===========================================================
                  // Interactive card
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Interactive card',
                    description:
                        'Compact mode normally shows only the first active '
                        'visible indicator. Tap the dock to unfold it, or '
                        'long-press the card to edit personal state. The full '
                        'change animation starts only after the actions surface '
                        'has closed.',
                  ),

                  const SizedBox(height: 24),

                  _InteractivePosterCard(
                    controller: _dockController,
                    favorite: _favorite,
                    collection: _collection,
                    watchlist: _watchlist,
                    personalRating: _personalRating,
                    visibleIndicators: _visibleIndicators,
                    mode: _mode,
                    density: _density,
                    variant: _variant,
                    side: _side,
                    tapToExpand: _tapToExpand,
                    autoCollapse: _autoCollapse,
                    labels: _dockLabels,
                    onTap: _showDetailsFeedback,
                    onLongPress: _showQuickActions,
                  ),

                  const SizedBox(height: 24),

                  _WorkbenchControls(
                    favorite: _favorite,
                    collection: _collection,
                    watchlist: _watchlist,
                    personalRating: _personalRating,
                    visibleIndicators: _visibleIndicators,
                    mode: _mode,
                    density: _density,
                    variant: _variant,
                    side: _side,
                    tapToExpand: _tapToExpand,
                    autoCollapse: _autoCollapse,
                    onFavoriteChanged: (bool value) {
                      unawaited(
                        _applyPersonalState(
                          favorite: value,
                          collection: _collection,
                          watchlist: _watchlist,
                          personalRating: _personalRating,
                        ),
                      );
                    },
                    onCollectionChanged: (bool value) {
                      unawaited(
                        _applyPersonalState(
                          favorite: _favorite,
                          collection: value,
                          watchlist: _watchlist,
                          personalRating: _personalRating,
                        ),
                      );
                    },
                    onWatchlistChanged: (bool value) {
                      unawaited(
                        _applyPersonalState(
                          favorite: _favorite,
                          collection: _collection,
                          watchlist: value,
                          personalRating: _personalRating,
                        ),
                      );
                    },
                    onRatingPressed: _showRatingEditor,
                    onRatingCleared: () {
                      unawaited(
                        _applyPersonalState(
                          favorite: _favorite,
                          collection: _collection,
                          watchlist: _watchlist,
                          personalRating: null,
                        ),
                      );
                    },
                    onVisibilityChanged: _setIndicatorVisibility,
                    onModeChanged: (CinearaStatusDockMode value) {
                      setState(() {
                        _mode = value;
                      });
                    },
                    onDensityChanged: (CinearaStatusDockDensity value) {
                      setState(() {
                        _density = value;
                      });
                    },
                    onVariantChanged: (CinearaStatusDockVariant value) {
                      setState(() {
                        _variant = value;
                      });
                    },
                    onSideChanged: (CinearaStatusDockSide value) {
                      setState(() {
                        _side = value;
                      });
                    },
                    onTapToExpandChanged: (bool value) {
                      setState(() {
                        _tapToExpand = value;
                      });
                    },
                    onAutoCollapseChanged: (bool value) {
                      setState(() {
                        _autoCollapse = value;
                      });
                    },
                    onReveal: () {
                      unawaited(_dockController.reveal());
                    },
                    onCollapse: () {
                      unawaited(_dockController.collapse());
                    },
                    onReset: () {
                      unawaited(_resetInteractiveState());
                    },
                  ),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Compact / permanent comparison
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Compact vs permanent',
                    description:
                        'Both examples contain the same personal state. The '
                        'compact dock collapses into its first visible active '
                        'indicator; the permanent dock keeps the complete chain.',
                  ),

                  const SizedBox(height: 24),

                  const _ModeComparisonPreview(labels: _dockLabels),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Anchor rules
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Compact anchor priority',
                    description:
                        'The first active visible indicator is always the '
                        'anchor. Rating is not treated specially.',
                  ),

                  const SizedBox(height: 24),

                  const _AnchorPriorityPreview(labels: _dockLabels),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Empty state
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Empty state',
                    description:
                        'With no active visible indicator, absolutely nothing '
                        'should remain on the artwork.',
                  ),

                  const SizedBox(height: 24),

                  const _EmptyStatePreview(labels: _dockLabels),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Grid
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Grid posters',
                    description:
                        'The personal dock stays inside the artwork in grid '
                        'mode. Compact mode is useful here because poster space '
                        'is scarce.',
                  ),

                  const SizedBox(height: 24),

                  const _GridPreview(labels: _dockLabels),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // List
                  // ===========================================================
                  const _SectionHeader(
                    title: 'List rows',
                    description:
                        'In list mode the dock moves outside the poster but '
                        'remains inside the media row. Rows live directly on '
                        'the page background and use subtle separators rather '
                        'than large rounded cards.',
                  ),

                  const SizedBox(height: 24),

                  const _ListPreview(labels: _dockLabels),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Status badge relationship
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Status-badge relationship',
                    description:
                        'Viewing state and personal state remain separate, but '
                        'their nested dark-shell / semantic-core construction '
                        'should read as one Cineara visual language.',
                  ),

                  const SizedBox(height: 24),

                  const _CombinedPosterPreview(labels: _dockLabels),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // RTL
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Logical attachment',
                    description:
                        'Test logical start and end, then enable RTL above to '
                        'verify that attachment mirrors correctly.',
                  ),

                  const SizedBox(height: 24),

                  const _DirectionPreview(labels: _dockLabels),

                  const SizedBox(height: 56),

                  const _InspectionChecklist(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // State application
  // ===========================================================================

  Future<void> _applyPersonalState({
    required bool favorite,
    required bool collection,
    required bool watchlist,
    required double? personalRating,
  }) async {
    final Set<CinearaStatusDockIndicator> changed = _changedIndicators(
      oldFavorite: _favorite,
      newFavorite: favorite,
      oldCollection: _collection,
      newCollection: collection,
      oldWatchlist: _watchlist,
      newWatchlist: watchlist,
      oldRating: _personalRating,
      newRating: personalRating,
    );

    if (changed.isEmpty) {
      return;
    }

    setState(() {
      _favorite = favorite;
      _collection = collection;
      _watchlist = watchlist;
      _personalRating = personalRating;
    });

    // The updated dock must first be painted with its new application state.
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) {
      return;
    }

    await _dockController.revealChanges(changedIndicators: changed);
  }

  Set<CinearaStatusDockIndicator> _changedIndicators({
    required bool oldFavorite,
    required bool newFavorite,
    required bool oldCollection,
    required bool newCollection,
    required bool oldWatchlist,
    required bool newWatchlist,
    required double? oldRating,
    required double? newRating,
  }) {
    final Set<CinearaStatusDockIndicator> changed =
        <CinearaStatusDockIndicator>{};

    if (oldFavorite != newFavorite) {
      changed.add(CinearaStatusDockIndicator.favorite);
    }

    if (oldCollection != newCollection) {
      changed.add(CinearaStatusDockIndicator.collection);
    }

    if (oldWatchlist != newWatchlist) {
      changed.add(CinearaStatusDockIndicator.watchlist);
    }

    if (oldRating != newRating) {
      changed.add(CinearaStatusDockIndicator.rating);
    }

    return changed;
  }

  void _setIndicatorVisibility(
    CinearaStatusDockIndicator indicator,
    bool visible,
  ) {
    final Set<CinearaStatusDockIndicator> next =
        Set<CinearaStatusDockIndicator>.of(_visibleIndicators);

    if (visible) {
      next.add(indicator);
    } else {
      next.remove(indicator);
    }

    setState(() {
      _visibleIndicators = next;
    });
  }

  Future<void> _resetInteractiveState() async {
    setState(() {
      _favorite = true;
      _collection = true;
      _watchlist = false;
      _personalRating = 8.5;

      _visibleIndicators = <CinearaStatusDockIndicator>{
        CinearaStatusDockIndicator.favorite,
        CinearaStatusDockIndicator.collection,
        CinearaStatusDockIndicator.watchlist,
        CinearaStatusDockIndicator.rating,
      };

      _mode = CinearaStatusDockMode.compact;
      _density = CinearaStatusDockDensity.compact;
      _variant = CinearaStatusDockVariant.artwork;
      _side = CinearaStatusDockSide.end;
      _tapToExpand = true;
      _autoCollapse = true;
    });

    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) {
      return;
    }

    await _dockController.collapse();
  }

  // ===========================================================================
  // Card interactions
  // ===========================================================================

  void _showDetailsFeedback() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Card tap → open media details'),
          duration: Duration(milliseconds: 1000),
        ),
      );
  }

  Future<void> _showQuickActions() async {
    final bool previousFavorite = _favorite;

    final bool previousCollection = _collection;

    final bool previousWatchlist = _watchlist;

    final double? previousRating = _personalRating;

    bool draftFavorite = previousFavorite;

    bool draftCollection = previousCollection;

    bool draftWatchlist = previousWatchlist;

    double? draftRating = previousRating;

    final _QuickActionResult? result =
        await showModalBottomSheet<_QuickActionResult>(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setSheetState) {
                return _QuickActionsSheet(
                  favorite: draftFavorite,
                  collection: draftCollection,
                  watchlist: draftWatchlist,
                  personalRating: draftRating,
                  onFavoriteChanged: (bool value) {
                    setSheetState(() {
                      draftFavorite = value;
                    });
                  },
                  onCollectionChanged: (bool value) {
                    setSheetState(() {
                      draftCollection = value;
                    });
                  },
                  onWatchlistChanged: (bool value) {
                    setSheetState(() {
                      draftWatchlist = value;
                    });
                  },
                  onRatingChanged: (double? value) {
                    setSheetState(() {
                      draftRating = value;
                    });
                  },
                  onApply: () {
                    Navigator.of(context).pop(
                      _QuickActionResult(
                        favorite: draftFavorite,
                        collection: draftCollection,
                        watchlist: draftWatchlist,
                        personalRating: draftRating,
                      ),
                    );
                  },
                );
              },
            );
          },
        );

    if (!mounted || result == null) {
      return;
    }

    final Set<CinearaStatusDockIndicator> changed = _changedIndicators(
      oldFavorite: previousFavorite,
      newFavorite: result.favorite,
      oldCollection: previousCollection,
      newCollection: result.collection,
      oldWatchlist: previousWatchlist,
      newWatchlist: result.watchlist,
      oldRating: previousRating,
      newRating: result.personalRating,
    );

    if (changed.isEmpty) {
      return;
    }

    // The popup has now fully returned a result. Update application state.
    setState(() {
      _favorite = result.favorite;
      _collection = result.collection;
      _watchlist = result.watchlist;
      _personalRating = result.personalRating;
    });

    // Wait until the card has rebuilt and the popup route is no longer
    // obscuring the poster.
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) {
      return;
    }

    // Only now does the full dock animation run.
    await _dockController.revealChanges(changedIndicators: changed);
  }

  Future<void> _showRatingEditor() async {
    double draft = _personalRating ?? 8;

    final double? result = await showModalBottomSheet<double>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Personal rating',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          draft.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Slider(
                      value: draft,
                      min: 0,
                      max: 10,
                      divisions: 100,
                      label: draft.toStringAsFixed(1),
                      onChanged: (double value) {
                        setSheetState(() {
                          draft = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(double.nan);
                          },
                          child: const Text('Clear'),
                        ),

                        const Spacer(),

                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),

                        const SizedBox(width: 8),

                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop(draft);
                          },
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    final double? nextRating = result.isNaN ? null : result;

    await _applyPersonalState(
      favorite: _favorite,
      collection: _collection,
      watchlist: _watchlist,
      personalRating: nextRating,
    );
  }
}

// =============================================================================
// Header
// =============================================================================

final class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({
    required this.themeMode,
    required this.highContrast,
    required this.reducedMotion,
    required this.rtl,
    required this.onThemeModeChanged,
    required this.onHighContrastChanged,
    required this.onReducedMotionChanged,
    required this.onRtlChanged,
  });

  final ThemeMode themeMode;

  final bool highContrast;
  final bool reducedMotion;
  final bool rtl;

  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<bool> onHighContrastChanged;
  final ValueChanged<bool> onReducedMotionChanged;
  final ValueChanged<bool> onRtlChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'CINEARA',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Status Dock',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Compact/permanent personal-state dock development preview.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 24),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            SegmentedButton<ThemeMode>(
              segments: const <ButtonSegment<ThemeMode>>[
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
              ],
              selected: <ThemeMode>{
                themeMode == ThemeMode.light ? ThemeMode.light : ThemeMode.dark,
              },
              onSelectionChanged: (Set<ThemeMode> values) {
                onThemeModeChanged(values.first);
              },
            ),

            FilterChip(
              selected: highContrast,
              avatar: const Icon(Icons.contrast_rounded, size: 18),
              label: const Text('High contrast'),
              onSelected: onHighContrastChanged,
            ),

            FilterChip(
              selected: reducedMotion,
              avatar: const Icon(Icons.motion_photos_off_outlined, size: 18),
              label: const Text('Reduced motion'),
              onSelected: onReducedMotionChanged,
            ),

            FilterChip(
              selected: rtl,
              avatar: const Icon(
                Icons.format_textdirection_r_to_l_rounded,
                size: 18,
              ),
              label: const Text('RTL'),
              onSelected: onRtlChanged,
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// Section header
// =============================================================================

final class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Interactive poster
// =============================================================================

final class _InteractivePosterCard extends StatelessWidget {
  const _InteractivePosterCard({
    required this.controller,
    required this.favorite,
    required this.collection,
    required this.watchlist,
    required this.personalRating,
    required this.visibleIndicators,
    required this.mode,
    required this.density,
    required this.variant,
    required this.side,
    required this.tapToExpand,
    required this.autoCollapse,
    required this.labels,
    required this.onTap,
    required this.onLongPress,
  });

  final CinearaStatusDockController controller;

  final bool favorite;
  final bool collection;
  final bool watchlist;

  final double? personalRating;

  final Set<CinearaStatusDockIndicator> visibleIndicators;

  final CinearaStatusDockMode mode;
  final CinearaStatusDockDensity density;
  final CinearaStatusDockVariant variant;
  final CinearaStatusDockSide side;

  final bool tapToExpand;
  final bool autoCollapse;

  final CinearaStatusDockLabels labels;

  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              onLongPress: onLongPress,
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Stack(
                  children: <Widget>[
                    const Positioned.fill(child: _FakePoster(index: 0)),

                    PositionedDirectional(
                      end: side == CinearaStatusDockSide.end ? 7 : null,
                      start: side == CinearaStatusDockSide.start ? 7 : null,
                      bottom: 8,
                      child: CinearaStatusDock(
                        controller: controller,
                        labels: labels,
                        favorite: favorite,
                        collection: collection,
                        watchlist: watchlist,
                        personalRating: personalRating,
                        visibleIndicators: visibleIndicators,
                        mode: mode,
                        density: density,
                        variant: variant,
                        side: side,
                        tapToExpand: tapToExpand,
                        autoCollapse: autoCollapse,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Interactive example',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              'Tap card → details · Tap dock → reveal · '
              'Long press → edit',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Workbench controls
// =============================================================================

final class _WorkbenchControls extends StatelessWidget {
  const _WorkbenchControls({
    required this.favorite,
    required this.collection,
    required this.watchlist,
    required this.personalRating,
    required this.visibleIndicators,
    required this.mode,
    required this.density,
    required this.variant,
    required this.side,
    required this.tapToExpand,
    required this.autoCollapse,
    required this.onFavoriteChanged,
    required this.onCollectionChanged,
    required this.onWatchlistChanged,
    required this.onRatingPressed,
    required this.onRatingCleared,
    required this.onVisibilityChanged,
    required this.onModeChanged,
    required this.onDensityChanged,
    required this.onVariantChanged,
    required this.onSideChanged,
    required this.onTapToExpandChanged,
    required this.onAutoCollapseChanged,
    required this.onReveal,
    required this.onCollapse,
    required this.onReset,
  });

  final bool favorite;
  final bool collection;
  final bool watchlist;

  final double? personalRating;

  final Set<CinearaStatusDockIndicator> visibleIndicators;

  final CinearaStatusDockMode mode;
  final CinearaStatusDockDensity density;
  final CinearaStatusDockVariant variant;
  final CinearaStatusDockSide side;

  final bool tapToExpand;
  final bool autoCollapse;

  final ValueChanged<bool> onFavoriteChanged;
  final ValueChanged<bool> onCollectionChanged;
  final ValueChanged<bool> onWatchlistChanged;

  final VoidCallback onRatingPressed;
  final VoidCallback onRatingCleared;

  final void Function(CinearaStatusDockIndicator indicator, bool visible)
  onVisibilityChanged;

  final ValueChanged<CinearaStatusDockMode> onModeChanged;

  final ValueChanged<CinearaStatusDockDensity> onDensityChanged;

  final ValueChanged<CinearaStatusDockVariant> onVariantChanged;

  final ValueChanged<CinearaStatusDockSide> onSideChanged;

  final ValueChanged<bool> onTapToExpandChanged;

  final ValueChanged<bool> onAutoCollapseChanged;

  final VoidCallback onReveal;
  final VoidCallback onCollapse;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // -------------------------------------------------------------------
          // Actual media state
          // -------------------------------------------------------------------
          Text(
            'Application state',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'These values describe the media itself.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilterChip(
                selected: favorite,
                avatar: const Icon(Icons.favorite_rounded, size: 17),
                label: const Text('Favorite'),
                onSelected: onFavoriteChanged,
              ),

              FilterChip(
                selected: collection,
                avatar: const Icon(Icons.layers_rounded, size: 17),
                label: const Text('Collection'),
                onSelected: onCollectionChanged,
              ),

              FilterChip(
                selected: watchlist,
                avatar: const Icon(Icons.bookmark_rounded, size: 17),
                label: const Text('Watchlist'),
                onSelected: onWatchlistChanged,
              ),

              ActionChip(
                avatar: const Icon(Icons.star_rounded, size: 17),
                label: Text(
                  personalRating == null
                      ? 'Set rating'
                      : 'Rating ${personalRating!.toStringAsFixed(1)}',
                ),
                onPressed: onRatingPressed,
              ),

              if (personalRating != null)
                ActionChip(
                  avatar: const Icon(Icons.close_rounded, size: 17),
                  label: const Text('Clear rating'),
                  onPressed: onRatingCleared,
                ),
            ],
          ),

          const SizedBox(height: 28),

          // -------------------------------------------------------------------
          // User visibility preference
          // -------------------------------------------------------------------
          Text(
            'Visible indicators',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Hiding an indicator does not change the media state.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _VisibilityChip(
                indicator: CinearaStatusDockIndicator.favorite,
                label: 'Favorite',
                selected: visibleIndicators.contains(
                  CinearaStatusDockIndicator.favorite,
                ),
                onChanged: onVisibilityChanged,
              ),
              _VisibilityChip(
                indicator: CinearaStatusDockIndicator.collection,
                label: 'Collection',
                selected: visibleIndicators.contains(
                  CinearaStatusDockIndicator.collection,
                ),
                onChanged: onVisibilityChanged,
              ),
              _VisibilityChip(
                indicator: CinearaStatusDockIndicator.watchlist,
                label: 'Watchlist',
                selected: visibleIndicators.contains(
                  CinearaStatusDockIndicator.watchlist,
                ),
                onChanged: onVisibilityChanged,
              ),
              _VisibilityChip(
                indicator: CinearaStatusDockIndicator.rating,
                label: 'Rating',
                selected: visibleIndicators.contains(
                  CinearaStatusDockIndicator.rating,
                ),
                onChanged: onVisibilityChanged,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // -------------------------------------------------------------------
          // Mode
          // -------------------------------------------------------------------
          Text(
            'Dock mode',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          SegmentedButton<CinearaStatusDockMode>(
            segments: const <ButtonSegment<CinearaStatusDockMode>>[
              ButtonSegment<CinearaStatusDockMode>(
                value: CinearaStatusDockMode.compact,
                icon: Icon(Icons.compress_rounded),
                label: Text('Compact'),
              ),
              ButtonSegment<CinearaStatusDockMode>(
                value: CinearaStatusDockMode.permanent,
                icon: Icon(Icons.unfold_more_rounded),
                label: Text('Permanent'),
              ),
            ],
            selected: <CinearaStatusDockMode>{mode},
            onSelectionChanged: (Set<CinearaStatusDockMode> values) {
              onModeChanged(values.first);
            },
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilterChip(
                selected: tapToExpand,
                label: const Text('Tap to expand'),
                onSelected: onTapToExpandChanged,
              ),
              FilterChip(
                selected: autoCollapse,
                label: const Text('Auto collapse'),
                onSelected: onAutoCollapseChanged,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // -------------------------------------------------------------------
          // Presentation
          // -------------------------------------------------------------------
          Text(
            'Presentation',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              SegmentedButton<CinearaStatusDockDensity>(
                segments: const <ButtonSegment<CinearaStatusDockDensity>>[
                  ButtonSegment<CinearaStatusDockDensity>(
                    value: CinearaStatusDockDensity.compact,
                    label: Text('Compact size'),
                  ),
                  ButtonSegment<CinearaStatusDockDensity>(
                    value: CinearaStatusDockDensity.standard,
                    label: Text('Standard size'),
                  ),
                ],
                selected: <CinearaStatusDockDensity>{density},
                onSelectionChanged: (Set<CinearaStatusDockDensity> values) {
                  onDensityChanged(values.first);
                },
              ),

              SegmentedButton<CinearaStatusDockVariant>(
                segments: const <ButtonSegment<CinearaStatusDockVariant>>[
                  ButtonSegment<CinearaStatusDockVariant>(
                    value: CinearaStatusDockVariant.artwork,
                    label: Text('Artwork'),
                  ),
                  ButtonSegment<CinearaStatusDockVariant>(
                    value: CinearaStatusDockVariant.surface,
                    label: Text('Surface'),
                  ),
                ],
                selected: <CinearaStatusDockVariant>{variant},
                onSelectionChanged: (Set<CinearaStatusDockVariant> values) {
                  onVariantChanged(values.first);
                },
              ),

              SegmentedButton<CinearaStatusDockSide>(
                segments: const <ButtonSegment<CinearaStatusDockSide>>[
                  ButtonSegment<CinearaStatusDockSide>(
                    value: CinearaStatusDockSide.start,
                    label: Text('Start'),
                  ),
                  ButtonSegment<CinearaStatusDockSide>(
                    value: CinearaStatusDockSide.end,
                    label: Text('End'),
                  ),
                ],
                selected: <CinearaStatusDockSide>{side},
                onSelectionChanged: (Set<CinearaStatusDockSide> values) {
                  onSideChanged(values.first);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // -------------------------------------------------------------------
          // Controller
          // -------------------------------------------------------------------
          Text(
            'Controller',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ActionChip(
                avatar: const Icon(Icons.unfold_more_rounded, size: 18),
                label: const Text('Reveal'),
                onPressed: onReveal,
              ),
              ActionChip(
                avatar: const Icon(Icons.unfold_less_rounded, size: 18),
                label: const Text('Collapse'),
                onPressed: onCollapse,
              ),
              ActionChip(
                avatar: const Icon(Icons.restart_alt_rounded, size: 18),
                label: const Text('Reset'),
                onPressed: onReset,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _VisibilityChip extends StatelessWidget {
  const _VisibilityChip({
    required this.indicator,
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final CinearaStatusDockIndicator indicator;
  final String label;
  final bool selected;

  final void Function(CinearaStatusDockIndicator indicator, bool visible)
  onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (bool value) {
        onChanged(indicator, value);
      },
    );
  }
}

// =============================================================================
// Compact / permanent comparison
// =============================================================================

final class _ModeComparisonPreview extends StatelessWidget {
  const _ModeComparisonPreview({required this.labels});

  final CinearaStatusDockLabels labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 28,
      runSpacing: 32,
      children: <Widget>[
        _DockSpecimen(
          title: 'Compact',
          subtitle: 'Tap the anchor',
          index: 0,
          dock: CinearaStatusDock(
            labels: labels,
            mode: CinearaStatusDockMode.compact,
            favorite: true,
            collection: true,
            watchlist: true,
            personalRating: 8.6,
          ),
        ),

        _DockSpecimen(
          title: 'Permanent',
          subtitle: 'Entire chain stays visible',
          index: 1,
          dock: CinearaStatusDock(
            labels: labels,
            mode: CinearaStatusDockMode.permanent,
            favorite: true,
            collection: true,
            watchlist: true,
            personalRating: 8.6,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Anchor priority
// =============================================================================

final class _AnchorPriorityPreview extends StatelessWidget {
  const _AnchorPriorityPreview({required this.labels});

  final CinearaStatusDockLabels labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 30,
      children: <Widget>[
        _DockSpecimen(
          title: 'Favorite anchor',
          subtitle: 'Favorite is first active',
          index: 0,
          dock: CinearaStatusDock(
            labels: labels,
            mode: CinearaStatusDockMode.compact,
            favorite: true,
            collection: true,
            watchlist: true,
            personalRating: 8.5,
          ),
        ),

        _DockSpecimen(
          title: 'Collection anchor',
          subtitle: 'Favorite inactive',
          index: 1,
          dock: CinearaStatusDock(
            labels: labels,
            mode: CinearaStatusDockMode.compact,
            collection: true,
            watchlist: true,
            personalRating: 8.5,
          ),
        ),

        _DockSpecimen(
          title: 'Watchlist anchor',
          subtitle: 'Only Watchlist + Rating',
          index: 2,
          dock: CinearaStatusDock(
            labels: labels,
            mode: CinearaStatusDockMode.compact,
            watchlist: true,
            personalRating: 8.5,
          ),
        ),

        _DockSpecimen(
          title: 'Rating anchor',
          subtitle: 'Only Rating active',
          index: 3,
          dock: CinearaStatusDock(
            labels: labels,
            mode: CinearaStatusDockMode.compact,
            personalRating: 8.5,
          ),
        ),

        _DockSpecimen(
          title: 'Hidden Favorite',
          subtitle: 'Collection becomes first visible',
          index: 0,
          dock: CinearaStatusDock(
            labels: labels,
            mode: CinearaStatusDockMode.compact,
            favorite: true,
            collection: true,
            watchlist: true,
            personalRating: 8.5,
            visibleIndicators: const <CinearaStatusDockIndicator>{
              CinearaStatusDockIndicator.collection,
              CinearaStatusDockIndicator.watchlist,
              CinearaStatusDockIndicator.rating,
            },
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Empty state
// =============================================================================

final class _EmptyStatePreview extends StatelessWidget {
  const _EmptyStatePreview({required this.labels});

  final CinearaStatusDockLabels labels;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                children: <Widget>[
                  const Positioned.fill(child: _FakePoster(index: 2)),

                  PositionedDirectional(
                    end: 7,
                    bottom: 8,
                    child: CinearaStatusDock(
                      labels: labels,
                      mode: CinearaStatusDockMode.compact,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'No personal state',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 3),

            Text(
              'There should be no line, node, or handle.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Dock specimen
// =============================================================================

final class _DockSpecimen extends StatelessWidget {
  const _DockSpecimen({
    required this.title,
    required this.subtitle,
    required this.index,
    required this.dock,
  });

  final String title;
  final String subtitle;

  final int index;

  final Widget dock;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: _FakePoster(index: index)),

                PositionedDirectional(end: 7, bottom: 8, child: dock),
              ],
            ),
          ),

          const SizedBox(height: 9),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            subtitle,
            maxLines: 2,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Grid
// =============================================================================

final class _GridPreview extends StatelessWidget {
  const _GridPreview({required this.labels});

  final CinearaStatusDockLabels labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 30,
      children: <Widget>[
        _GridCard(
          title: 'Compact tracking',
          subtitle: '2026 · Series',
          index: 0,
          dock: CinearaStatusDock(
            labels: labels,
            mode: CinearaStatusDockMode.compact,
            favorite: true,
            collection: true,
            personalRating: 8.5,
          ),
        ),

        _GridCard(
          title: 'Watchlist',
          subtitle: '2026 · Movie',
          index: 1,
          dock: CinearaStatusDock(
            labels: labels,
            mode: CinearaStatusDockMode.compact,
            watchlist: true,
          ),
        ),

        _GridCard(
          title: 'Clean',
          subtitle: '2024 · Series',
          index: 2,
          dock: CinearaStatusDock(
            labels: labels,
            mode: CinearaStatusDockMode.compact,
          ),
        ),

        _GridCard(
          title: 'Permanent',
          subtitle: '2025 · Anime',
          index: 3,
          dock: CinearaStatusDock(
            labels: labels,
            mode: CinearaStatusDockMode.permanent,
            favorite: true,
            collection: true,
            watchlist: true,
            personalRating: 9.4,
          ),
        ),
      ],
    );
  }
}

final class _GridCard extends StatelessWidget {
  const _GridCard({
    required this.title,
    required this.subtitle,
    required this.index,
    required this.dock,
  });

  final String title;
  final String subtitle;

  final int index;

  final Widget dock;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: _FakePoster(index: index)),

                PositionedDirectional(end: 6, bottom: 7, child: dock),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// List
// =============================================================================

final class _ListPreview extends StatelessWidget {
  const _ListPreview({required this.labels});

  final CinearaStatusDockLabels labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _ListRow(
          index: 0,
          title: 'Frieren: Beyond Journey\'s End',
          metadata: '2023 · Japan · Anime',
          description:
              'The dock occupies the trailing edge of the row rather than '
              'covering the small list poster.',
          hasPersonalState: true,
          dock: CinearaStatusDock(
            labels: labels,
            mode: CinearaStatusDockMode.permanent,
            variant: CinearaStatusDockVariant.surface,
            favorite: true,
            collection: true,
            personalRating: 8.8,
          ),
        ),

        const Divider(height: 1, indent: 104),

        _ListRow(
          index: 1,
          title: 'A title with no personal state',
          metadata: '2026 · Series',
          description:
              'No dock width is reserved when there is nothing to show.',
          hasPersonalState: false,
          dock: CinearaStatusDock(
            labels: labels,
            variant: CinearaStatusDockVariant.surface,
          ),
        ),

        const Divider(height: 1, indent: 104),

        _ListRow(
          index: 2,
          title: 'Compact list preference',
          metadata: '2025 · Movie',
          description:
              'The same compact behavior can also be used in list mode if '
              'the user prefers minimal persistent indicators.',
          hasPersonalState: true,
          dock: CinearaStatusDock(
            labels: labels,
            mode: CinearaStatusDockMode.compact,
            variant: CinearaStatusDockVariant.surface,
            favorite: true,
            collection: true,
            watchlist: true,
            personalRating: 9.1,
          ),
        ),
      ],
    );
  }
}

final class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.index,
    required this.title,
    required this.metadata,
    required this.description,
    required this.hasPersonalState,
    required this.dock,
  });

  final int index;

  final String title;
  final String metadata;
  final String description;

  final bool hasPersonalState;

  final Widget dock;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final ColorScheme colors = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {},
      onLongPress: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 88,
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: _FakePoster(index: index, radius: 10),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    metadata,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            if (hasPersonalState) ...<Widget>[const SizedBox(width: 10), dock],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Combined status + dock
// =============================================================================

final class _CombinedPosterPreview extends StatelessWidget {
  const _CombinedPosterPreview({required this.labels});

  final CinearaStatusDockLabels labels;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 190,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                children: <Widget>[
                  const Positioned.fill(child: _FakePoster(index: 3)),

                  const PositionedDirectional(
                    start: 7,
                    top: 7,
                    child: CinearaStatusBadge(
                      type: CinearaStatusBadgeType.rewatching,
                      label: 'Rewatching',
                    ),
                  ),

                  PositionedDirectional(
                    end: 7,
                    bottom: 8,
                    child: CinearaStatusDock(
                      labels: labels,
                      mode: CinearaStatusDockMode.permanent,
                      favorite: true,
                      collection: true,
                      watchlist: true,
                      personalRating: 9.1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Viewing status + personal dock',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Direction
// =============================================================================

final class _DirectionPreview extends StatelessWidget {
  const _DirectionPreview({required this.labels});

  final CinearaStatusDockLabels labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 30,
      children: <Widget>[
        _DirectionalPoster(
          title: 'Logical start',
          side: CinearaStatusDockSide.start,
          index: 0,
          labels: labels,
        ),
        _DirectionalPoster(
          title: 'Logical end',
          side: CinearaStatusDockSide.end,
          index: 1,
          labels: labels,
        ),
      ],
    );
  }
}

final class _DirectionalPoster extends StatelessWidget {
  const _DirectionalPoster({
    required this.title,
    required this.side,
    required this.index,
    required this.labels,
  });

  final String title;

  final CinearaStatusDockSide side;

  final int index;

  final CinearaStatusDockLabels labels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: _FakePoster(index: index)),

                PositionedDirectional(
                  start: side == CinearaStatusDockSide.start ? 6 : null,
                  end: side == CinearaStatusDockSide.end ? 6 : null,
                  bottom: 7,
                  child: CinearaStatusDock(
                    labels: labels,
                    mode: CinearaStatusDockMode.permanent,
                    side: side,
                    favorite: true,
                    collection: true,
                    watchlist: true,
                    personalRating: 8.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 9),

          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Quick actions
// =============================================================================

final class _QuickActionsSheet extends StatelessWidget {
  const _QuickActionsSheet({
    required this.favorite,
    required this.collection,
    required this.watchlist,
    required this.personalRating,
    required this.onFavoriteChanged,
    required this.onCollectionChanged,
    required this.onWatchlistChanged,
    required this.onRatingChanged,
    required this.onApply,
  });

  final bool favorite;
  final bool collection;
  final bool watchlist;

  final double? personalRating;

  final ValueChanged<bool> onFavoriteChanged;
  final ValueChanged<bool> onCollectionChanged;
  final ValueChanged<bool> onWatchlistChanged;
  final ValueChanged<double?> onRatingChanged;

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final ColorScheme colors = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Media actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Make several changes if you want. The poster animation will '
              'wait until this surface closes.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            _QuickActionToggle(
              icon: Icons.favorite_rounded,
              accent: const Color(0xFFE65D78),
              title: 'Favorite',
              selected: favorite,
              onChanged: onFavoriteChanged,
            ),

            _QuickActionToggle(
              icon: Icons.layers_rounded,
              accent: const Color(0xFF9569EB),
              title: 'Collection',
              selected: collection,
              onChanged: onCollectionChanged,
            ),

            _QuickActionToggle(
              icon: Icons.bookmark_rounded,
              accent: const Color(0xFF3EAFCB),
              title: 'Watchlist',
              selected: watchlist,
              onChanged: onWatchlistChanged,
            ),

            const SizedBox(height: 8),

            _QuickRatingControl(
              value: personalRating,
              onChanged: onRatingChanged,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onApply,
                child: const Text('Apply changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _QuickActionToggle extends StatelessWidget {
  const _QuickActionToggle({
    required this.icon,
    required this.accent,
    required this.title,
    required this.selected,
    required this.onChanged,
  });

  final IconData icon;
  final Color accent;

  final String title;

  final bool selected;

  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withValues(alpha: 0.16),
        ),
        child: Icon(icon, size: 20, color: accent),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      value: selected,
      onChanged: onChanged,
    );
  }
}

final class _QuickRatingControl extends StatelessWidget {
  const _QuickRatingControl({required this.value, required this.onChanged});

  final double? value;

  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final double effectiveValue = value ?? 8;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.star_rounded, color: Color(0xFFE2A638)),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Personal rating',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              Text(
                value == null ? 'Not rated' : value!.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Slider(
            value: effectiveValue,
            min: 0,
            max: 10,
            divisions: 100,
            onChanged: (double newValue) {
              onChanged(newValue);
            },
          ),

          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: value == null
                  ? null
                  : () {
                      onChanged(null);
                    },
              icon: const Icon(Icons.close_rounded),
              label: const Text('Remove rating'),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Quick-action result
// =============================================================================

final class _QuickActionResult {
  const _QuickActionResult({
    required this.favorite,
    required this.collection,
    required this.watchlist,
    required this.personalRating,
  });

  final bool favorite;
  final bool collection;
  final bool watchlist;

  final double? personalRating;
}

// =============================================================================
// Fake poster
// =============================================================================

final class _FakePoster extends StatelessWidget {
  const _FakePoster({required this.index, this.radius = 14});

  final int index;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final List<List<Color>> gradients = <List<Color>>[
      const <Color>[Color(0xFF182243), Color(0xFF6550C9), Color(0xFF17121F)],
      const <Color>[Color(0xFF143F3D), Color(0xFF47A99C), Color(0xFF101C1A)],
      const <Color>[Color(0xFF542C1F), Color(0xFFC8784D), Color(0xFF20120F)],
      const <Color>[Color(0xFF4D213E), Color(0xFFB14F88), Color(0xFF21101C)],
    ];

    final List<Color> colors = gradients[index % gradients.length];

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 30,
              right: -25,
              child: Transform.rotate(
                angle: 0.42,
                child: Container(
                  width: 145,
                  height: 42,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),

            Positioned(
              left: 18,
              bottom: 48,
              child: Icon(
                Icons.movie_creation_outlined,
                size: 52,
                color: Colors.white.withValues(alpha: 0.30),
              ),
            ),

            Positioned(
              left: -34,
              bottom: -22,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Checklist
// =============================================================================

final class _InspectionChecklist extends StatelessWidget {
  const _InspectionChecklist();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ChecklistTitle(),

          SizedBox(height: 14),

          _ChecklistItem(
            text: 'Compact mode rests on the first active visible indicator.',
          ),

          _ChecklistItem(text: 'Rating has no special anchor priority.'),

          _ChecklistItem(
            text:
                'Tapping a compact dock reveals the chain and it collapses automatically.',
          ),

          _ChecklistItem(
            text:
                'The anchor remains spatially fixed while the other nodes unfold away from it.',
          ),

          _ChecklistItem(
            text:
                'On collapse, non-anchor nodes return into the anchor rather than the whole dock shrinking generically.',
          ),

          _ChecklistItem(
            text: 'Long-press changes do not animate underneath the popup.',
          ),

          _ChecklistItem(
            text:
                'After Apply, the popup closes first and only then does revealChanges run.',
          ),

          _ChecklistItem(
            text:
                'Only changed active nodes receive the magnetic docking reaction.',
          ),

          _ChecklistItem(
            text:
                'Existing nodes do not replay an entrance animation when another state is added.',
          ),

          _ChecklistItem(
            text:
                'Multiple changes share one reveal sequence rather than replaying the whole dock repeatedly.',
          ),

          _ChecklistItem(
            text:
                'Hiding an indicator affects presentation only, not application state.',
          ),

          _ChecklistItem(
            text:
                'A completely empty visible state leaves no line, handle, or artifact.',
          ),

          _ChecklistItem(text: 'Grid mode keeps the dock inside the poster.'),

          _ChecklistItem(
            text:
                'List mode moves the dock to the trailing edge of the row and keeps the poster clean.',
          ),

          _ChecklistItem(
            text:
                'Reduced Motion disables decorative attachment, pulse, and spring behavior without changing functionality.',
          ),

          _ChecklistItem(
            text: 'RTL correctly mirrors logical start/end placement.',
          ),
        ],
      ),
    );
  }
}

final class _ChecklistTitle extends StatelessWidget {
  const _ChecklistTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'What to inspect',
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

final class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: theme.colorScheme.primary,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
