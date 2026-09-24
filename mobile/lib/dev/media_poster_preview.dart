import 'dart:async';

import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CinearaMediaPosterPreviewApp());
}

// =============================================================================
// App
// =============================================================================

final class CinearaMediaPosterPreviewApp extends StatefulWidget {
  const CinearaMediaPosterPreviewApp({super.key});

  @override
  State<CinearaMediaPosterPreviewApp> createState() =>
      _CinearaMediaPosterPreviewAppState();
}

final class _CinearaMediaPosterPreviewAppState
    extends State<CinearaMediaPosterPreviewApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  bool _highContrast = false;
  bool _reducedMotion = false;
  bool _rtl = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cineara Search Result Preview',
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

enum _PreviewLayout { grid, list, rail }

/// Mirrors Cineara's user-facing personal-indicator density preference.
///
/// - off: no personal-state dock;
/// - compact: anchor + real-state satellite, expandable;
/// - permanent: the complete chain remains visible.
enum _DockPreviewMode { off, compact, permanent }

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
  static const Duration _postPopupReactionDelay = Duration(milliseconds: 360);

  static const CinearaStatusDockLabels _dockLabels = CinearaStatusDockLabels(
    dock: 'Personal media status',
    favorite: 'Favorite',
    collection: 'In collection',
    watchlist: 'In watchlist',
    personalRating: 'Personal rating',
  );

  static const CinearaStatusDockLabels _personDockLabels =
      CinearaStatusDockLabels(
        dock: 'Personal person status',
        favorite: 'Favorite',
        collection: 'In collection',
        watchlist: 'In watchlist',
        personalRating: 'Personal rating',
      );

  static const CinearaStatusDockLabels _entityDockLabels =
      CinearaStatusDockLabels(
        dock: 'Personal entity status',
        favorite: 'Favorite',
        collection: 'In collection',
        watchlist: 'In watchlist',
        personalRating: 'Personal rating',
      );

  _PreviewLayout _layout = _PreviewLayout.grid;
  _DockPreviewMode _dockMode = _DockPreviewMode.compact;

  late List<_PreviewMedia> _media;
  late List<_PreviewPerson> _people;
  late List<_PreviewEntity> _entities;
  late String _selectedMediaId;

  int _dockReactionSerial = 0;
  _DockReaction? _dockReaction;
  _DockReaction? _railDockReaction;

  @override
  void initState() {
    super.initState();

    _media = _initialMedia
        .map((_PreviewMedia item) => item.copyWith())
        .toList(growable: false);

    _people = _initialPeople
        .map((_PreviewPerson person) => person.copyWith())
        .toList(growable: false);

    _entities = _initialEntities
        .map((_PreviewEntity entity) => entity.copyWith())
        .toList(growable: false);

    _selectedMediaId = _media.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final _PreviewMedia selected = _selectedMedia;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            // -----------------------------------------------------------------
            // Standard page content uses the normal 24 dp content gutter.
            // -----------------------------------------------------------------
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverList.list(
                children: <Widget>[
                  _PreviewHeader(
                    themeMode: widget.themeMode,
                    highContrast: widget.highContrast,
                    reducedMotion: widget.reducedMotion,
                    rtl: widget.rtl,
                    layout: _layout,
                    onThemeModeChanged: widget.onThemeModeChanged,
                    onHighContrastChanged: widget.onHighContrastChanged,
                    onReducedMotionChanged: widget.onReducedMotionChanged,
                    onRtlChanged: widget.onRtlChanged,
                    onLayoutChanged: (_PreviewLayout value) {
                      setState(() {
                        _layout = value;
                      });
                    },
                  ),

                  const SizedBox(height: 44),

                  const _SectionHeader(
                    title: 'Interactive state workbench',
                    description:
                        'Pick any title and directly add/remove viewing status, '
                        'Favorite, Watchlist, Collection, personal rating, '
                        'external rating, and progress. Direct changes are '
                        'useful for repeatedly testing badge and dock motion.',
                  ),

                  const SizedBox(height: 20),

                  _StateWorkbench(
                    media: selected,
                    allMedia: _media,
                    dockMode: _dockMode,
                    onDockModeChanged: (_DockPreviewMode value) {
                      setState(() {
                        _dockMode = value;
                      });
                    },
                    onSelectedMediaChanged: (String id) {
                      setState(() {
                        _selectedMediaId = id;
                      });
                    },
                    onStatusChanged: (CinearaStatusBadgeType? status) {
                      _updateSelected(
                        selected.copyWith(
                          status: status,
                          clearStatus: status == null,
                        ),
                      );
                    },
                    onFavoriteChanged: (bool value) {
                      _updateSelected(selected.copyWith(favorite: value));
                    },
                    onWatchlistChanged: (bool value) {
                      _updateSelected(selected.copyWith(watchlist: value));
                    },
                    onCollectionChanged: (bool value) {
                      _updateSelected(selected.copyWith(collection: value));
                    },
                    onPersonalRatingEnabledChanged: (bool enabled) {
                      _updateSelected(
                        selected.copyWith(
                          personalRating: enabled
                              ? (selected.personalRating ?? 8.0)
                              : null,
                          clearPersonalRating: !enabled,
                        ),
                      );
                    },
                    onPersonalRatingChanged: (double value) {
                      _updateSelected(selected.copyWith(personalRating: value));
                    },
                    onExternalRatingVisibleChanged: (bool visible) {
                      _updateSelected(
                        selected.copyWith(showExternalRating: visible),
                        animateDock: false,
                      );
                    },
                    onExternalRatingChanged: (double value) {
                      _updateSelected(
                        selected.copyWith(externalRating: value),
                        animateDock: false,
                      );
                    },
                    onProgressVisibleChanged: (bool visible) {
                      _updateSelected(
                        selected.copyWith(showProgress: visible),
                        animateDock: false,
                      );
                    },
                    onProgressChanged: (double value) {
                      _updateSelected(
                        selected.copyWith(progress: value),
                        animateDock: false,
                      );
                    },
                    onReset: _resetSelected,
                  ),

                  const SizedBox(height: 44),

                  _SectionHeader(
                    title: _layout == _PreviewLayout.grid
                        ? 'Grid posters'
                        : 'List rows',
                    description: _layout == _PreviewLayout.grid
                        ? 'Status stays top-start, external rating top-end, '
                              'personal state bottom-end, and progress on the '
                              'bottom edge. The poster now rests slightly above '
                              'the page through the shared Cineara artwork '
                              'shadow + rim. Pressing contracts that elevation '
                              'while the existing compression feedback plays. '
                              'Only the poster is clickable; title and metadata '
                              'remain passive with no interaction highlight. '
                              'Long press opens editable Quick Actions.'
                        : 'Search List mode uses a clean editorial row rather '
                              'than a card: external rating on poster top-start, '
                              'progress on the poster edge, title + type/year + '
                              'one primary genre, and optional Cineara state. '
                              'The fixed List poster uses the same shared '
                              'artwork elevation as Grid, but only the raw '
                              'artwork zooms. Missing or failed poster artwork '
                              'uses the canonical neutral Cineara media fallback. '
                              'Pressing contracts the shadow while frame, rim, '
                              'rating and progress stay fixed. One parent-owned '
                              'separator defines the rhythm between rows.',
                  ),

                  const SizedBox(height: 24),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder:
                        (Widget? currentChild, List<Widget> previousChildren) {
                          return Stack(
                            alignment: Alignment.topCenter,
                            children: <Widget>[
                              ...previousChildren,
                              ?currentChild,
                            ],
                          );
                        },
                    child: _layout == _PreviewLayout.grid
                        ? _GridPreview(
                            key: const ValueKey<String>('grid'),
                            media: _media,
                            dockLabels: _dockLabels,
                            dockReaction: _dockReaction,
                            dockMode: _dockMode,
                            onPosterTap: _showPosterTap,
                            onPosterLongPress: _showQuickActions,
                          )
                        : _ListPreview(
                            key: const ValueKey<String>('list'),
                            media: _media,
                            dockLabels: _dockLabels,
                            dockReaction: _dockReaction,
                            dockMode: _dockMode,
                            onPosterTap: _showListTap,
                            onPosterLongPress: _showQuickActions,
                          ),
                  ),

                  const SizedBox(height: 52),

                  // Keep the rail title aligned with the rest of the page.
                  // The actual rail is the next sliver and receives the full
                  // viewport width.
                  const _SectionHeader(
                    title: 'Horizontal rail',
                    description:
                        'The production media item is reused inside a '
                        'full-width cinematic rail. Rail posters inherit the '
                        'same Cineara artwork rim and detached shadow as Grid, '
                        'with the shadow contracting during poster interaction. '
                        'The first and last posters keep equal breathing room, '
                        'scrolling remains continuous with no automatic snap, '
                        'and the continuation fade grows gradually as content '
                        'moves beyond a physical edge. Rail posters are '
                        'intentionally a little '
                        'smaller than before and remain clearly more compact '
                        'than Grid posters so more titles stay visible. Titles '
                        'and metadata remain passive here too.',
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // -----------------------------------------------------------------
            // Full-width rail.
            //
            // This is intentionally outside the 24 dp SliverPadding above.
            // CinearaMediaHorizontalRail therefore receives the complete
            // viewport width and can fade directly at the physical page edge.
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _RailPreview(
                media: _media,
                dockLabels: _dockLabels,
                dockReaction: _railDockReaction,
                dockMode: _dockMode,
                onPosterTap: _showPosterTap,
                onPosterLongPress: _showQuickActions,
              ),
            ),

            // -----------------------------------------------------------------
            // People header remains aligned with the normal page gutter.
            // The compact people rail itself is full width below.
            // -----------------------------------------------------------------
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 52, 24, 0),
              sliver: SliverList.list(
                children: const <Widget>[
                  _SectionHeader(
                    title: 'People · compact rail',
                    description:
                        'Search All uses CinearaPersonGridItem. Circular '
                        'portraits now have a slightly stronger optical lift '
                        'than posters so the smaller photo still reads as '
                        'detached from the background. The portrait rises '
                        'subtly at rest, its shadow contracts on press, and only '
                        'the raw photo zooms to 1.030. Favorite remains the real '
                        'CinearaStatusDock, so its heart and mutation motion are '
                        'identical to media posters.',
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: _PeopleRailPreview(
                people: _people,
                statusDockLabels: _personDockLabels,
                onTap: _showPersonTap,
                onLongPress: _showPersonQuickActions,
              ),
            ),

            // -----------------------------------------------------------------
            // Focused People results return to the regular content gutter.
            // -----------------------------------------------------------------
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 52, 24, 0),
              sliver: SliverList.list(
                children: <Widget>[
                  const _SectionHeader(
                    title: 'People · focused results',
                    description:
                        'Focused People results use CinearaPersonListItem. '
                        'Their circular photos keep the same portrait '
                        'interaction language as People Grid, while the List '
                        'chevron moves toward the destination on tap.',
                  ),

                  const SizedBox(height: 24),

                  _PeopleListPreview(
                    people: _people,
                    statusDockLabels: _personDockLabels,
                    onTap: _showPersonTap,
                    onLongPress: _showPersonQuickActions,
                  ),
                ],
              ),
            ),

            // -----------------------------------------------------------------
            // Search All entity rail. Collections and studios are the two
            // entity families with meaningful visual treatments. Collections
            // keep native 2:3 poster geometry; studios keep contained logo
            // geometry. Topics intentionally stay out of the visual rail.
            // -----------------------------------------------------------------
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 52, 24, 0),
              sliver: SliverList.list(
                children: const <Widget>[
                  _SectionHeader(
                    title: 'Entities · Search All rail',
                    description:
                        'Collections and studios reuse CinearaEntityGridItem '
                        'inside CinearaHorizontalRail while preserving their '
                        'native visual language. Collections use real 2:3 TMDB '
                        'poster artwork; studios use contained TMDB logos with '
                        'dedicated breathing room. A missing or failed Studio logo '
                        'uses one shared company icon on the neutral fallback '
                        'surface rather than the light real-logo plate. Topics '
                        'stay out of this visual rail rather than receiving '
                        'fabricated artwork.',
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: _EntityRailPreview(
                entities: _entities,
                statusDockLabels: _entityDockLabels,
                onTap: _showEntityTap,
                onLongPress: _showEntityQuickActions,
              ),
            ),

            // -----------------------------------------------------------------
            // Focused entity results. The page-level Grid/List control is
            // reused here to exercise both entity presentation components.
            // Topics remain List-only and are therefore omitted from Grid.
            // -----------------------------------------------------------------
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 52, 24, 72),
              sliver: SliverList.list(
                children: <Widget>[
                  _SectionHeader(
                    title: _layout == _PreviewLayout.grid
                        ? 'Entities · focused Grid'
                        : 'Entities · focused List',
                    description: _layout == _PreviewLayout.grid
                        ? 'Collections and studios use CinearaEntityGridItem '
                              'with variant-aware geometry. Collection artwork '
                              'retains a true 2:3 poster presentation while '
                              'studio logos use a contained logo surface with '
                              'intentional breathing room; only the visual zooms.'
                        : 'Collections, studios and topics use '
                              'CinearaEntityListItem with media-List interaction. '
                              'Collections keep poster artwork and Studios keep '
                              'contained logos; missing Studio artwork uses the '
                              'shared company fallback. Topics stay text-only '
                              'because the API supplies only their names. Favorite '
                              'stays on Collection/Studio artwork and sits inline '
                              'beside a Topic title.',
                  ),

                  const SizedBox(height: 24),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _EntityFocusedPreview(
                      key: ValueKey<_PreviewLayout>(_layout),
                      layout: _layout,
                      entities: _entities,
                      statusDockLabels: _entityDockLabels,
                      onTap: _showEntityTap,
                      onLongPress: _showEntityQuickActions,
                    ),
                  ),

                  const SizedBox(height: 52),

                  const _InteractionExplanation(),

                  const SizedBox(height: 52),

                  const _PlacementReference(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _PreviewMedia get _selectedMedia {
    return _media.firstWhere(
      (_PreviewMedia item) => item.id == _selectedMediaId,
    );
  }

  int _indexFor(String id) {
    return _media.indexWhere((_PreviewMedia item) => item.id == id);
  }

  void _selectMedia(_PreviewMedia media) {
    if (_selectedMediaId == media.id) {
      return;
    }

    setState(() {
      _selectedMediaId = media.id;
    });
  }

  Future<void> _updateSelected(_PreviewMedia next, {bool animateDock = true}) {
    return _applyMediaState(next, animateDock: animateDock);
  }

  Future<void> _applyMediaState(
    _PreviewMedia next, {
    required bool animateDock,
  }) {
    final int index = _indexFor(next.id);

    if (index < 0) {
      return Future<void>.value();
    }

    final _PreviewMedia previous = _media[index];

    final Set<CinearaStatusDockIndicator> dockChanges = _dockChanges(
      previous,
      next,
    );

    _DockReaction? reaction;
    _DockReaction? railReaction;

    if (animateDock && dockChanges.isNotEmpty) {
      final Set<CinearaStatusDockIndicator> immutableChanges =
          Set<CinearaStatusDockIndicator>.unmodifiable(dockChanges);

      reaction = _DockReaction(
        serial: ++_dockReactionSerial,
        layout: _layout,
        mediaId: next.id,
        changedIndicators: immutableChanges,
      );

      railReaction = _DockReaction(
        serial: ++_dockReactionSerial,
        layout: _PreviewLayout.rail,
        mediaId: next.id,
        changedIndicators: immutableChanges,
      );
    }

    setState(() {
      _media = List<_PreviewMedia>.of(_media)..[index] = next;

      if (reaction != null) {
        _dockReaction = reaction;
      }

      if (railReaction != null) {
        _railDockReaction = railReaction;
      }
    });

    return Future<void>.value();
  }

  Set<CinearaStatusDockIndicator> _dockChanges(
    _PreviewMedia oldValue,
    _PreviewMedia newValue,
  ) {
    final Set<CinearaStatusDockIndicator> changed =
        <CinearaStatusDockIndicator>{};

    if (oldValue.favorite != newValue.favorite) {
      changed.add(CinearaStatusDockIndicator.favorite);
    }

    if (oldValue.watchlist != newValue.watchlist) {
      changed.add(CinearaStatusDockIndicator.watchlist);
    }

    if (oldValue.collection != newValue.collection) {
      changed.add(CinearaStatusDockIndicator.collection);
    }

    if (oldValue.personalRating != newValue.personalRating) {
      changed.add(CinearaStatusDockIndicator.rating);
    }

    return changed;
  }

  int _personIndexFor(int id) {
    return _people.indexWhere((_PreviewPerson person) => person.id == id);
  }

  Future<void> _applyPersonState(_PreviewPerson next) async {
    final int index = _personIndexFor(next.id);

    if (index < 0) {
      return;
    }

    setState(() {
      _people = List<_PreviewPerson>.of(_people)..[index] = next;
    });
  }

  Future<void> _showPersonQuickActions(_PreviewPerson person) async {
    final _PersonEditResult? result =
        await showModalBottomSheet<_PersonEditResult>(
          context: context,
          showDragHandle: true,
          builder: (BuildContext context) {
            return _PersonQuickActionsSheet(person: person);
          },
        );

    if (result == null || !mounted) {
      return;
    }

    await _waitForQuickActionsDismissal();

    if (!mounted) {
      return;
    }

    await _applyPersonState(result.person);
  }

  void _showPersonTap(_PreviewPerson person) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('${person.name} → open person details'),
          duration: const Duration(milliseconds: 900),
        ),
      );
  }

  void _showEntityTap(_PreviewEntity entity) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            '${entity.title} → open ${entity.descriptor.toLowerCase()}',
          ),
          duration: const Duration(milliseconds: 900),
        ),
      );
  }

  int _entityIndexFor(String id) {
    return _entities.indexWhere((_PreviewEntity entity) => entity.id == id);
  }

  Future<void> _applyEntityState(_PreviewEntity next) async {
    final int index = _entityIndexFor(next.id);

    if (index < 0) {
      return;
    }

    setState(() {
      _entities = List<_PreviewEntity>.of(_entities)..[index] = next;
    });
  }

  Future<void> _showEntityQuickActions(_PreviewEntity entity) async {
    final _EntityEditResult? result =
        await showModalBottomSheet<_EntityEditResult>(
          context: context,
          showDragHandle: true,
          builder: (BuildContext context) {
            return _EntityQuickActionsSheet(entity: entity);
          },
        );

    if (result == null || !mounted) {
      return;
    }

    // Match media/person choreography: let the modal finish disappearing before
    // updating the underlying Favorite dock so its mutation animation remains
    // fully visible.
    await _waitForQuickActionsDismissal();

    if (!mounted) {
      return;
    }

    await _applyEntityState(result.entity);
  }

  void _showPosterTap(_PreviewMedia media) {
    _selectMedia(media);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('${media.title} → open media details'),
          duration: const Duration(milliseconds: 900),
        ),
      );
  }

  void _showListTap(_PreviewMedia media) {
    // Search List would navigate directly to the media-details route.
    //
    // The preview updates the workbench selection silently instead of showing
    // a SnackBar. Navigation feedback belongs to the pressed row itself.
    _selectMedia(media);
  }

  Future<void> _showQuickActions(_PreviewMedia media) async {
    _selectMedia(media);

    final _MediaEditResult? result =
        await showModalBottomSheet<_MediaEditResult>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (BuildContext context) {
            return _QuickActionsSheet(media: media);
          },
        );

    if (result == null || !mounted) {
      return;
    }

    // Do not apply the changed media state while the modal route may still be
    // visually reversing away.
    //
    // The dock mutation animation is intentionally a separate beat:
    //
    // Quick Actions closes
    //      ↓
    // poster is fully visible
    //      ↓
    // short breathing pause
    //      ↓
    // state updates
    //      ↓
    // dock mutation animation plays unobstructed
    //
    // This timing belongs to the preview/feature choreography, not to
    // CinearaStatusDock itself.
    await _waitForQuickActionsDismissal();

    if (!mounted) {
      return;
    }

    await _applyMediaState(result.media, animateDock: true);
  }

  Future<void> _waitForQuickActionsDismissal() async {
    if (widget.reducedMotion) {
      // Reduced-motion mode should not introduce an artificial pause, but one
      // frame still gives Navigator/Overlay a chance to settle before the
      // underlying preview state changes.
      await WidgetsBinding.instance.endOfFrame;
      return;
    }

    await Future<void>.delayed(_postPopupReactionDelay);

    if (!mounted) {
      return;
    }

    // Apply on a clean frame after the dismissal pause rather than in the same
    // scheduling turn as the modal-route teardown.
    await WidgetsBinding.instance.endOfFrame;
  }

  Future<void> _resetSelected() async {
    final _PreviewMedia original = _initialMedia.firstWhere(
      (_PreviewMedia item) => item.id == _selectedMediaId,
    );

    await _applyMediaState(original.copyWith(), animateDock: true);
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
    required this.layout,
    required this.onThemeModeChanged,
    required this.onHighContrastChanged,
    required this.onReducedMotionChanged,
    required this.onRtlChanged,
    required this.onLayoutChanged,
  });

  final ThemeMode themeMode;

  final bool highContrast;
  final bool reducedMotion;
  final bool rtl;

  final _PreviewLayout layout;

  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<bool> onHighContrastChanged;
  final ValueChanged<bool> onReducedMotionChanged;
  final ValueChanged<bool> onRtlChanged;
  final ValueChanged<_PreviewLayout> onLayoutChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'CINEARA',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Search Results',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Media posters, people portraits, entity tiles, horizontal '
          'rails, focused rows, interactive state editing, and production '
          'interaction feedback.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            SegmentedButton<_PreviewLayout>(
              segments: const <ButtonSegment<_PreviewLayout>>[
                ButtonSegment<_PreviewLayout>(
                  value: _PreviewLayout.grid,
                  icon: Icon(Icons.grid_view_rounded),
                  label: Text('Grid'),
                ),
                ButtonSegment<_PreviewLayout>(
                  value: _PreviewLayout.list,
                  icon: Icon(Icons.view_agenda_outlined),
                  label: Text('List'),
                ),
              ],
              selected: <_PreviewLayout>{layout},
              onSelectionChanged: (Set<_PreviewLayout> values) {
                onLayoutChanged(values.first);
              },
            ),
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
// State workbench
// =============================================================================

final class _StateWorkbench extends StatelessWidget {
  const _StateWorkbench({
    required this.media,
    required this.allMedia,
    required this.dockMode,
    required this.onDockModeChanged,
    required this.onSelectedMediaChanged,
    required this.onStatusChanged,
    required this.onFavoriteChanged,
    required this.onWatchlistChanged,
    required this.onCollectionChanged,
    required this.onPersonalRatingEnabledChanged,
    required this.onPersonalRatingChanged,
    required this.onExternalRatingVisibleChanged,
    required this.onExternalRatingChanged,
    required this.onProgressVisibleChanged,
    required this.onProgressChanged,
    required this.onReset,
  });

  final _PreviewMedia media;
  final List<_PreviewMedia> allMedia;

  final _DockPreviewMode dockMode;
  final ValueChanged<_DockPreviewMode> onDockModeChanged;

  final ValueChanged<String> onSelectedMediaChanged;
  final ValueChanged<CinearaStatusBadgeType?> onStatusChanged;

  final ValueChanged<bool> onFavoriteChanged;
  final ValueChanged<bool> onWatchlistChanged;
  final ValueChanged<bool> onCollectionChanged;

  final ValueChanged<bool> onPersonalRatingEnabledChanged;
  final ValueChanged<double> onPersonalRatingChanged;

  final ValueChanged<bool> onExternalRatingVisibleChanged;
  final ValueChanged<double> onExternalRatingChanged;

  final ValueChanged<bool> onProgressVisibleChanged;
  final ValueChanged<double> onProgressChanged;

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Material(
      color: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.40)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButtonFormField<String>(
              initialValue: media.id,
              decoration: const InputDecoration(
                labelText: 'Poster to edit',
                border: OutlineInputBorder(),
              ),
              items: allMedia
                  .map((_PreviewMedia item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(item.title),
                    );
                  })
                  .toList(growable: false),
              onChanged: (String? value) {
                if (value != null) {
                  onSelectedMediaChanged(value);
                }
              },
            ),

            const SizedBox(height: 24),

            Text(
              'Viewing status',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ChoiceChip(
                  selected: media.status == null,
                  label: const Text('None'),
                  onSelected: (_) {
                    onStatusChanged(null);
                  },
                ),
                for (final CinearaStatusBadgeType status
                    in CinearaStatusBadgeType.values)
                  ChoiceChip(
                    selected: media.status == status,
                    label: Text(_statusLabel(status)),
                    onSelected: (_) {
                      onStatusChanged(status);
                    },
                  ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Personal state',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilterChip(
                  selected: media.favorite,
                  avatar: const Icon(Icons.favorite_rounded, size: 18),
                  label: const Text('Favorite'),
                  onSelected: onFavoriteChanged,
                ),
                FilterChip(
                  selected: media.watchlist,
                  avatar: const Icon(Icons.bookmark_rounded, size: 18),
                  label: const Text('Watchlist'),
                  onSelected: onWatchlistChanged,
                ),
                FilterChip(
                  selected: media.collection,
                  avatar: const Icon(Icons.inventory_2_rounded, size: 18),
                  label: const Text('Collection'),
                  onSelected: onCollectionChanged,
                ),
                FilterChip(
                  selected: media.personalRating != null,
                  avatar: const Icon(Icons.star_rounded, size: 18),
                  label: const Text('Personal rating'),
                  onSelected: onPersonalRatingEnabledChanged,
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              'Personal indicator presentation',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            SegmentedButton<_DockPreviewMode>(
              segments: const <ButtonSegment<_DockPreviewMode>>[
                ButtonSegment<_DockPreviewMode>(
                  value: _DockPreviewMode.off,
                  icon: Icon(Icons.visibility_off_outlined),
                  label: Text('Off'),
                ),
                ButtonSegment<_DockPreviewMode>(
                  value: _DockPreviewMode.compact,
                  icon: Icon(Icons.hub_outlined),
                  label: Text('Compact'),
                ),
                ButtonSegment<_DockPreviewMode>(
                  value: _DockPreviewMode.permanent,
                  icon: Icon(Icons.linear_scale_rounded),
                  label: Text('Permanent'),
                ),
              ],
              selected: <_DockPreviewMode>{dockMode},
              onSelectionChanged: (Set<_DockPreviewMode> values) {
                onDockModeChanged(values.first);
              },
            ),

            const SizedBox(height: 8),

            Text(
              dockMode == _DockPreviewMode.compact
                  ? 'Compact keeps one anchor + the real second-state satellite '
                        'at rest, then reveals the full chain.'
                  : dockMode == _DockPreviewMode.permanent
                  ? 'Permanent keeps every active personal-state indicator '
                        'visible.'
                  : 'Personal-state indicators are hidden; lifecycle status '
                        'remains independent.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 18),

            _LabeledSlider(
              label: 'Personal rating',
              valueLabel: media.personalRating == null
                  ? 'Off'
                  : media.personalRating!.toStringAsFixed(1),
              value: media.personalRating ?? 8.0,
              min: 0,
              max: 10,
              divisions: 100,
              onChanged: media.personalRating == null
                  ? null
                  : onPersonalRatingChanged,
            ),

            const SizedBox(height: 24),

            Text(
              'External metadata',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show external rating'),
              subtitle: const Text(
                'Artwork badge in both grid and Search list presentations',
              ),
              value: media.showExternalRating,
              onChanged: onExternalRatingVisibleChanged,
            ),

            _LabeledSlider(
              label: 'External rating',
              valueLabel: media.showExternalRating
                  ? media.externalRating.toStringAsFixed(1)
                  : 'Off',
              value: media.externalRating,
              min: 0,
              max: 10,
              divisions: 100,
              onChanged: media.showExternalRating
                  ? onExternalRatingChanged
                  : null,
            ),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show viewing progress'),
              subtitle: const Text(
                'Poster-edge progress in both grid and list',
              ),
              value: media.showProgress,
              onChanged: onProgressVisibleChanged,
            ),

            _LabeledSlider(
              label: 'Progress',
              valueLabel: media.showProgress
                  ? '${(media.progress * 100).round()}%'
                  : 'Off',
              value: media.progress,
              min: 0,
              max: 1,
              divisions: 100,
              onChanged: media.showProgress ? onProgressChanged : null,
            ),

            const SizedBox(height: 18),

            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset selected'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;

  final double value;
  final double min;
  final double max;
  final int divisions;

  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              valueLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// =============================================================================
// Dock reaction request
// =============================================================================

@immutable
final class _DockReaction {
  const _DockReaction({
    required this.serial,
    required this.layout,
    required this.mediaId,
    required this.changedIndicators,
  });

  final int serial;
  final _PreviewLayout layout;
  final String mediaId;
  final Set<CinearaStatusDockIndicator> changedIndicators;
}

// =============================================================================
// Grid
// =============================================================================

/// Preview adapter around the production [CinearaMediaGrid].
///
/// Grid geometry and artwork treatment live entirely in the design-system
/// components. Only the poster is interactive; title and metadata are passive
/// and never receive a tap/hover highlight.
///
/// This preview only maps mutable workbench data into reusable media items.
final class _GridPreview extends StatelessWidget {
  const _GridPreview({
    super.key,
    required this.media,
    required this.dockLabels,
    required this.dockReaction,
    required this.dockMode,
    required this.onPosterTap,
    required this.onPosterLongPress,
  });

  final List<_PreviewMedia> media;
  final CinearaStatusDockLabels dockLabels;
  final _DockReaction? dockReaction;
  final _DockPreviewMode dockMode;

  final ValueChanged<_PreviewMedia> onPosterTap;
  final ValueChanged<_PreviewMedia> onPosterLongPress;

  @override
  Widget build(BuildContext context) {
    return CinearaResponsiveGrid(
      children: media
          .map((_PreviewMedia item) {
            return _GridMediaItemAdapter(
              key: ValueKey<String>('grid-card-${item.id}'),
              media: item,
              dockLabels: dockLabels,
              dockReaction: dockReaction,
              dockMode: dockMode,
              onTap: () {
                onPosterTap(item);
              },
              onLongPress: () {
                onPosterLongPress(item);
              },
            );
          })
          .toList(growable: false),
    );
  }
}

/// Preview-only state adapter.
///
/// [CinearaMediaGridItem] deliberately does not own application state or a
/// status-dock controller. The adapter keeps the preview's existing mutation
/// reaction choreography while the reusable component owns the actual card
/// presentation.
final class _GridMediaItemAdapter extends StatefulWidget {
  const _GridMediaItemAdapter({
    super.key,
    required this.media,
    required this.dockLabels,
    required this.dockReaction,
    required this.dockMode,
    required this.onTap,
    required this.onLongPress,
  });

  final _PreviewMedia media;
  final CinearaStatusDockLabels dockLabels;
  final _DockReaction? dockReaction;
  final _DockPreviewMode dockMode;

  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  State<_GridMediaItemAdapter> createState() => _GridMediaItemAdapterState();
}

final class _GridMediaItemAdapterState extends State<_GridMediaItemAdapter> {
  late final CinearaStatusDockController _dockController;

  int _lastHandledReactionSerial = -1;

  @override
  void initState() {
    super.initState();

    // Presentation-local ownership is intentional. AnimatedSwitcher can keep
    // an outgoing Grid mounted while another presentation enters; no two docks
    // should ever share one controller.
    _dockController = CinearaStatusDockController();
  }

  @override
  void didUpdateWidget(_GridMediaItemAdapter oldWidget) {
    super.didUpdateWidget(oldWidget);

    _scheduleDockReactionIfNeeded();
  }

  void _scheduleDockReactionIfNeeded() {
    final _DockReaction? reaction = widget.dockReaction;

    if (reaction == null ||
        reaction.layout != _PreviewLayout.grid ||
        reaction.mediaId != widget.media.id ||
        reaction.serial == _lastHandledReactionSerial) {
      return;
    }

    _lastHandledReactionSerial = reaction.serial;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(_runDockReaction(reaction));
    });
  }

  Future<void> _runDockReaction(_DockReaction reaction) async {
    if (!_dockController.attached) {
      return;
    }

    await _dockController.revealChanges(
      changedIndicators: reaction.changedIndicators,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _PreviewMedia media = widget.media;

    return CinearaMediaGridItem(
      artwork: _NetworkPoster(url: media.imageUrl, title: media.title),
      title: media.title,
      descriptor: media.descriptor,
      year: media.year,
      semanticHint: 'Open media details',
      onPosterTap: widget.onTap,
      onPosterLongPress: widget.onLongPress,
      statusBadge: media.status == null
          ? null
          : CinearaStatusBadge(
              key: ValueKey<String>('status-${media.id}'),
              type: media.status!,
              label: _statusLabel(media.status!),
              variant: CinearaStatusBadgeVariant.artwork,
              density: CinearaStatusBadgeDensity.compact,
              behavior: CinearaStatusBadgeBehavior.collapsible,
              revealOnMount: true,
              revealOnStatusChange: true,
              expandOnTap: true,
              autoCollapse: true,
            ),
      externalRatingBadge: !media.showExternalRating
          ? null
          : CinearaExternalRatingBadge(
              value: media.externalRating.toStringAsFixed(1),
              semanticLabel:
                  'External rating '
                  '${media.externalRating.toStringAsFixed(1)} '
                  'out of 10',
              variant: CinearaExternalRatingBadgeVariant.artwork,
              density: CinearaExternalRatingBadgeDensity.compact,
            ),
      statusDock: widget.dockMode == _DockPreviewMode.off
          ? null
          : CinearaStatusDock(
              controller: _dockController,
              labels: widget.dockLabels,
              favorite: media.favorite,
              collection: media.collection,
              watchlist: media.watchlist,
              personalRating: media.personalRating,
              mode: widget.dockMode == _DockPreviewMode.permanent
                  ? CinearaStatusDockMode.permanent
                  : CinearaStatusDockMode.compact,
              variant: CinearaStatusDockVariant.artwork,
              density: CinearaStatusDockDensity.compact,
              side: CinearaStatusDockSide.end,
              tapToExpand: widget.dockMode == _DockPreviewMode.compact,
              autoCollapse: widget.dockMode == _DockPreviewMode.compact,
            ),
      progressIndicator: !media.showProgress
          ? null
          : CinearaMediaProgressIndicator(
              value: media.progress,
              variant: CinearaMediaProgressVariant.posterEdge,
              semanticLabel: 'Viewing progress',
            ),
    );
  }
}

// =============================================================================
// Horizontal rail
// =============================================================================

/// Preview adapter around [CinearaMediaHorizontalRail].
///
/// The rail intentionally reuses [CinearaMediaGridItem] rather than introducing
/// another poster-card implementation. Grid and rails therefore share the same
/// poster-only interaction contract: poster tap/hold remain interactive while
/// title and metadata stay passive with no highlight.
///
/// Scrolling is deliberately free and continuous. Releasing a drag or fling
/// never triggers an automatic centering correction.
final class _RailPreview extends StatelessWidget {
  const _RailPreview({
    required this.media,
    required this.dockLabels,
    required this.dockReaction,
    required this.dockMode,
    required this.onPosterTap,
    required this.onPosterLongPress,
  });

  final List<_PreviewMedia> media;
  final CinearaStatusDockLabels dockLabels;
  final _DockReaction? dockReaction;
  final _DockPreviewMode dockMode;

  final ValueChanged<_PreviewMedia> onPosterTap;
  final ValueChanged<_PreviewMedia> onPosterLongPress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // ---------------------------------------------------------------------
        // Rail geometry
        // ---------------------------------------------------------------------
        //
        // The viewport itself is full width because _RailPreview is mounted as
        // its own SliverToBoxAdapter outside the page's 24 dp content gutter.
        //
        // Rail posters are intentionally smaller than Grid posters. On compact
        // screens this now aims for roughly 2.3 cards plus a clearer
        // continuation slice, keeping the rail more browseable and visibly
        // distinct from the larger Search Grid.
        const double contentInset = 12;
        const double spacing = 16;
        const double desiredNextItemPeek = 30;
        const double compactVisibleCards = 2.30;

        final double railWidth = constraints.maxWidth;

        final double compactItemWidth =
            (railWidth -
                (contentInset * 2) -
                (spacing * 2) -
                desiredNextItemPeek) /
            compactVisibleCards;

        // Keep rail cards compact even on medium/wide layouts. Additional
        // horizontal space should reveal more titles, not inflate the posters.
        //
        // 136 dp is intentionally below the previous 146 dp cap so the rail
        // reads as a denser browsing surface without making overlays cramped.
        final double itemWidth = compactItemWidth.clamp(110, 136).toDouble();

        // Rail lifecycle labels need enough room to remain legible while still
        // respecting the external-rating zone.
        final double statusBadgeMaxWidth = (itemWidth - 50)
            .clamp(64, 86)
            .toDouble();

        return CinearaHorizontalRail(
          itemWidth: itemWidth,
          spacing: spacing,

          // Equal first/last breathing room lives inside the scroll content.
          // The rail viewport itself remains full width.
          padding: const EdgeInsetsDirectional.only(
            start: contentInset,
            end: contentInset,
          ),

          // The continuation fade is dynamic in the production rail:
          //
          // beginning -> trailing edge only
          // middle    -> both physical edges
          // end       -> leading edge only
          //
          // Therefore the final poster has no trailing fade/line.
          edgeFadeWidth: 36,
          edgeFadeRevealDistance: 72,
          edgeFadeColor: Theme.of(context).scaffoldBackgroundColor,

          showOverscrollIndicator: false,
          showScrollbar: false,

          children: media
              .map((_PreviewMedia item) {
                return _RailMediaItemAdapter(
                  key: ValueKey<String>('rail-card-${item.id}'),
                  media: item,
                  dockLabels: dockLabels,
                  dockReaction: dockReaction,
                  dockMode: dockMode,
                  statusBadgeMaxWidth: statusBadgeMaxWidth,
                  onTap: () {
                    onPosterTap(item);
                  },
                  onLongPress: () {
                    onPosterLongPress(item);
                  },
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}

/// Preview-only state adapter for one rail item.
///
/// The reusable rail remains data-agnostic; this adapter only supplies the
/// preview's mutable state and owns the mounted status-dock controller.
final class _RailMediaItemAdapter extends StatefulWidget {
  const _RailMediaItemAdapter({
    super.key,
    required this.media,
    required this.dockLabels,
    required this.dockReaction,
    required this.dockMode,
    required this.statusBadgeMaxWidth,
    required this.onTap,
    required this.onLongPress,
  });

  final _PreviewMedia media;
  final CinearaStatusDockLabels dockLabels;
  final _DockReaction? dockReaction;
  final _DockPreviewMode dockMode;

  /// Rail-specific lifecycle expansion cap.
  final double statusBadgeMaxWidth;

  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  State<_RailMediaItemAdapter> createState() => _RailMediaItemAdapterState();
}

final class _RailMediaItemAdapterState extends State<_RailMediaItemAdapter> {
  late final CinearaStatusDockController _dockController;

  int _lastHandledReactionSerial = -1;

  @override
  void initState() {
    super.initState();

    _dockController = CinearaStatusDockController();
  }

  @override
  void didUpdateWidget(_RailMediaItemAdapter oldWidget) {
    super.didUpdateWidget(oldWidget);

    _scheduleDockReactionIfNeeded();
  }

  void _scheduleDockReactionIfNeeded() {
    final _DockReaction? reaction = widget.dockReaction;

    if (reaction == null ||
        reaction.layout != _PreviewLayout.rail ||
        reaction.mediaId != widget.media.id ||
        reaction.serial == _lastHandledReactionSerial) {
      return;
    }

    _lastHandledReactionSerial = reaction.serial;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(_runDockReaction(reaction));
    });
  }

  Future<void> _runDockReaction(_DockReaction reaction) async {
    if (!_dockController.attached) {
      return;
    }

    await _dockController.revealChanges(
      changedIndicators: reaction.changedIndicators,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _PreviewMedia media = widget.media;

    return CinearaMediaGridItem(
      artwork: _NetworkPoster(url: media.imageUrl, title: media.title),
      title: media.title,
      descriptor: media.descriptor,
      year: media.year,
      semanticHint: 'Open media details',
      onPosterTap: widget.onTap,
      onPosterLongPress: widget.onLongPress,
      statusBadge: media.status == null
          ? null
          : CinearaStatusBadge(
              key: ValueKey<String>('rail-status-${media.id}'),
              type: media.status!,
              label: _statusLabel(media.status!),
              variant: CinearaStatusBadgeVariant.artwork,
              density: CinearaStatusBadgeDensity.compact,
              behavior: CinearaStatusBadgeBehavior.collapsible,
              revealOnMount: false,
              revealOnStatusChange: false,
              expandOnTap: false,
              autoCollapse: false,
              maxWidth: widget.statusBadgeMaxWidth,
            ),
      externalRatingBadge: !media.showExternalRating
          ? null
          : CinearaExternalRatingBadge(
              value: media.externalRating.toStringAsFixed(1),
              semanticLabel:
                  'External rating '
                  '${media.externalRating.toStringAsFixed(1)} '
                  'out of 10',
              variant: CinearaExternalRatingBadgeVariant.artwork,
              density: CinearaExternalRatingBadgeDensity.compact,
            ),
      statusDock: widget.dockMode == _DockPreviewMode.off
          ? null
          : CinearaStatusDock(
              controller: _dockController,
              labels: widget.dockLabels,
              favorite: media.favorite,
              collection: media.collection,
              watchlist: media.watchlist,
              personalRating: media.personalRating,
              mode: widget.dockMode == _DockPreviewMode.permanent
                  ? CinearaStatusDockMode.permanent
                  : CinearaStatusDockMode.compact,
              variant: CinearaStatusDockVariant.artwork,
              density: CinearaStatusDockDensity.compact,
              side: CinearaStatusDockSide.end,
              tapToExpand: widget.dockMode == _DockPreviewMode.compact,
              autoCollapse: widget.dockMode == _DockPreviewMode.compact,
            ),
      progressIndicator: !media.showProgress
          ? null
          : CinearaMediaProgressIndicator(
              value: media.progress,
              variant: CinearaMediaProgressVariant.posterEdge,
              semanticLabel: 'Viewing progress',
            ),
    );
  }
}

// =============================================================================
// People
// =============================================================================

/// Search All People presentation.
///
/// The generic horizontal rail owns free scrolling and the continuation fade.
/// It does not apply any automatic item snapping. Each item is the dedicated
/// [CinearaPersonGridItem], so portrait
/// rim, stronger local shadow, resting lift and press-depth contraction are all
/// inherited from the production design-system component.
///
/// Favorite is not preview-painted. The production Grid item embeds the same
/// [CinearaStatusDock] used by media artwork and owns its Favorite mutation
/// controller, so toggling Favorite through Person Quick Actions demonstrates
/// the real media-style magnetic add/remove animation.
final class _PeopleRailPreview extends StatelessWidget {
  const _PeopleRailPreview({
    required this.people,
    required this.statusDockLabels,
    required this.onTap,
    required this.onLongPress,
  });

  final List<_PreviewPerson> people;
  final CinearaStatusDockLabels statusDockLabels;

  final ValueChanged<_PreviewPerson> onTap;
  final ValueChanged<_PreviewPerson> onLongPress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double contentInset = 12;
        const double spacing = 16;
        const double desiredNextItemPeek = 24;
        const double compactVisibleItems = 2.65;

        final double railWidth = constraints.maxWidth;

        final double compactItemWidth =
            (railWidth -
                (contentInset * 2) -
                (spacing * 2) -
                desiredNextItemPeek) /
            compactVisibleItems;

        final double itemWidth = compactItemWidth.clamp(108, 134).toDouble();

        final double portraitSize = (itemWidth * 0.72).clamp(76, 88).toDouble();

        return CinearaHorizontalRail(
          itemWidth: itemWidth,
          spacing: spacing,
          padding: const EdgeInsetsDirectional.only(
            start: contentInset,
            end: contentInset,
          ),
          edgeFadeWidth: 36,
          edgeFadeRevealDistance: 72,
          edgeFadeColor: Theme.of(context).scaffoldBackgroundColor,
          showOverscrollIndicator: false,
          showScrollbar: false,
          children: people
              .map((_PreviewPerson person) {
                return CinearaPersonGridItem(
                  key: ValueKey<String>('person-grid-${person.id}'),
                  name: person.name,
                  image: person.imageUrl == null
                      ? null
                      : NetworkImage(person.imageUrl!),
                  knownForDepartment: person.knownForDepartment,
                  knownFor: person.knownFor,
                  favorite: person.favorite,
                  statusDockLabels: statusDockLabels,
                  portraitSize: portraitSize,
                  semanticLabel: person.semanticLabel,
                  semanticHint:
                      'Open person details. Long press for person quick actions.',
                  onTap: () {
                    onTap(person);
                  },
                  onLongPress: () {
                    onLongPress(person);
                  },
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}

/// Focused People category presentation.
///
/// [CinearaMediaList] remains the generic list container while each row is a
/// dedicated [CinearaPersonListItem]. The production row owns portrait depth,
/// pressure animation, raw-photo zoom, Favorite-dock mutation animation,
/// accessibility and the RTL-aware moving chevron.
final class _PeopleListPreview extends StatelessWidget {
  const _PeopleListPreview({
    required this.people,
    required this.statusDockLabels,
    required this.onTap,
    required this.onLongPress,
  });

  final List<_PreviewPerson> people;
  final CinearaStatusDockLabels statusDockLabels;

  final ValueChanged<_PreviewPerson> onTap;
  final ValueChanged<_PreviewPerson> onLongPress;

  @override
  Widget build(BuildContext context) {
    return CinearaContentList(
      maximumWidth: double.infinity,

      // The preview lets the parent page own tablet width/alignment instead of
      // centering the complete List inside a fixed 840 dp island. Row geometry
      // still comes from the production People List component.
      separatorStartInset: CinearaPersonListItem.defaultMetadataRailInset,
      separatorEndInset: 0,
      separatorSpacing: 8,
      children: people
          .map((_PreviewPerson person) {
            return CinearaPersonListItem(
              key: ValueKey<String>('person-list-${person.id}'),
              name: person.name,
              image: person.imageUrl == null
                  ? null
                  : NetworkImage(person.imageUrl!),
              knownForDepartment: person.knownForDepartment,
              knownFor: person.knownFor,
              favorite: person.favorite,
              statusDockLabels: statusDockLabels,
              portraitSize: CinearaPersonListItem.defaultPortraitSize,
              semanticLabel: person.semanticLabel,
              semanticHint:
                  'Open person details. Long press for person quick actions.',
              onTap: () {
                onTap(person);
              },
              onLongPress: () {
                onLongPress(person);
              },
            );
          })
          .toList(growable: false),
    );
  }
}

// =============================================================================
// Entities
// =============================================================================

/// Search All presentation for entity types with meaningful visual assets.
///
/// The preview delegates all entity geometry to the production
/// [CinearaEntityGridItem]. Collections use the poster variant, studios use the
/// logo variant, and the component itself owns aspect ratio, fit, logo padding,
/// rim, elevation, interaction depth and artwork Favorite placement.
///
/// Topics intentionally stay out of Search All's visual rail. They remain
/// available in focused List results as text-only rows because the API provides
/// a name but no visual identity.
final class _EntityRailPreview extends StatelessWidget {
  const _EntityRailPreview({
    required this.entities,
    required this.statusDockLabels,
    required this.onTap,
    required this.onLongPress,
  });

  final List<_PreviewEntity> entities;
  final CinearaStatusDockLabels statusDockLabels;
  final ValueChanged<_PreviewEntity> onTap;
  final ValueChanged<_PreviewEntity> onLongPress;

  @override
  Widget build(BuildContext context) {
    final List<_PreviewEntity> railEntities = entities
        .where((_PreviewEntity entity) => entity.supportsGrid)
        .toList(growable: false);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double contentInset = 12;
        const double spacing = 16;
        const double desiredNextItemPeek = 30;
        const double compactVisibleCards = 2.30;

        final double railWidth = constraints.maxWidth;

        final double compactItemWidth =
            (railWidth -
                (contentInset * 2) -
                (spacing * 2) -
                desiredNextItemPeek) /
            compactVisibleCards;

        final double itemWidth = compactItemWidth.clamp(110, 136).toDouble();

        return CinearaHorizontalRail(
          itemWidth: itemWidth,
          spacing: spacing,
          padding: const EdgeInsetsDirectional.only(
            start: contentInset,
            end: contentInset,
          ),
          edgeFadeWidth: 36,
          edgeFadeRevealDistance: 72,
          edgeFadeColor: Theme.of(context).scaffoldBackgroundColor,
          showOverscrollIndicator: false,
          showScrollbar: false,
          children: railEntities
              .map((_PreviewEntity entity) {
                return CinearaEntityGridItem(
                  key: ValueKey<String>('entity-rail-${entity.id}'),
                  title: entity.title,
                  variant: entity.gridVisualVariant,
                  image: entity.imageProvider,
                  favorite: entity.favorite,
                  showFavorite: true,
                  statusDockLabels: statusDockLabels,
                  fallbackIcon: entity.kind == _PreviewEntityKind.studio
                      ? null
                      : entity.fallbackIcon,
                  semanticLabel: entity.semanticLabel,
                  semanticHint:
                      'Open ${entity.descriptor.toLowerCase()}. '
                      'Long press for ${entity.descriptor.toLowerCase()} quick actions.',
                  onTap: () {
                    onTap(entity);
                  },
                  onLongPress: () {
                    onLongPress(entity);
                  },
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}

/// Focused entity category preview.
///
/// Collections and studios support Grid and List. Topics remain List-only so
/// Search never invents artwork merely to make every scope visually identical.
///
/// Both branches use the production entity components directly:
///
/// - [CinearaEntityGridItem] owns responsive poster/logo geometry in Grid.
/// - [CinearaEntityListItem] owns the media-List-style row interaction. Its
///   leading visual is optional, so Topics can remain genuinely text-only.
final class _EntityFocusedPreview extends StatelessWidget {
  const _EntityFocusedPreview({
    super.key,
    required this.layout,
    required this.entities,
    required this.statusDockLabels,
    required this.onTap,
    required this.onLongPress,
  });

  final _PreviewLayout layout;
  final List<_PreviewEntity> entities;
  final CinearaStatusDockLabels statusDockLabels;
  final ValueChanged<_PreviewEntity> onTap;
  final ValueChanged<_PreviewEntity> onLongPress;

  @override
  Widget build(BuildContext context) {
    if (layout == _PreviewLayout.grid) {
      final List<_PreviewEntity> gridEntities = entities
          .where((_PreviewEntity entity) => entity.supportsGrid)
          .toList(growable: false);

      return CinearaResponsiveGrid(
        children: gridEntities
            .map((_PreviewEntity entity) {
              return CinearaEntityGridItem(
                key: ValueKey<String>('entity-grid-${entity.id}'),
                title: entity.title,
                variant: entity.gridVisualVariant,
                image: entity.imageProvider,
                favorite: entity.favorite,
                showFavorite: true,
                statusDockLabels: statusDockLabels,
                fallbackIcon: entity.kind == _PreviewEntityKind.studio
                    ? null
                    : entity.fallbackIcon,
                semanticLabel: entity.semanticLabel,
                semanticHint:
                    'Open ${entity.descriptor.toLowerCase()}. '
                    'Long press for ${entity.descriptor.toLowerCase()} quick actions.',
                onTap: () {
                  onTap(entity);
                },
                onLongPress: () {
                  onLongPress(entity);
                },
              );
            })
            .toList(growable: false),
      );
    }

    return CinearaContentList(
      // Entity rows themselves own no width cap and no separator. The parent
      // list fills the available content region and draws exactly one separator
      // between siblings, avoiding doubled lines on tablet/desktop.
      maximumWidth: double.infinity,
      separatorStartInset: CinearaEntityListItem.defaultMetadataRailInset,
      separatorEndInset: 0,
      separatorSpacing: 8,
      children: entities
          .map((_PreviewEntity entity) {
            return CinearaEntityListItem(
              key: ValueKey<String>('entity-list-${entity.id}'),
              title: entity.title,
              variant: entity.listVisualVariant,
              image: entity.imageProvider,
              favorite: entity.favorite,
              showFavorite: true,
              statusDockLabels: statusDockLabels,
              fallbackIcon: entity.kind == _PreviewEntityKind.studio
                  ? null
                  : entity.fallbackIcon,
              semanticLabel: entity.semanticLabel,
              semanticHint:
                  'Open ${entity.descriptor.toLowerCase()}. '
                  'Long press for ${entity.descriptor.toLowerCase()} quick actions.',
              onTap: () {
                onTap(entity);
              },
              onLongPress: () {
                onLongPress(entity);
              },
            );
          })
          .toList(growable: false),
    );
  }
}

// =============================================================================
// List
// =============================================================================

/// Preview adapter around the generic production [CinearaMediaList].
///
/// The List container accepts arbitrary widget tiles. Search happens to provide
/// [CinearaMediaListItem] here, but another page can reuse the same container
/// with episode, season, credit, or other tile families.
final class _ListPreview extends StatelessWidget {
  const _ListPreview({
    super.key,
    required this.media,
    required this.dockLabels,
    required this.dockReaction,
    required this.dockMode,
    required this.onPosterTap,
    required this.onPosterLongPress,
  });

  final List<_PreviewMedia> media;

  final CinearaStatusDockLabels dockLabels;
  final _DockReaction? dockReaction;
  final _DockPreviewMode dockMode;

  final ValueChanged<_PreviewMedia> onPosterTap;
  final ValueChanged<_PreviewMedia> onPosterLongPress;

  @override
  Widget build(BuildContext context) {
    return CinearaContentList(
      maximumWidth: double.infinity,

      // Search media rows fill the parent content region. CinearaContentList is
      // the single separator authority: metadata rail -> same logical edge as the
      // row / pressed tile.
      separatorStartInset: CinearaMediaListItem.defaultMetadataRailInset,
      separatorEndInset: 0,
      separatorSpacing: 8,

      children: media
          .map((_PreviewMedia item) {
            return _ListMediaItemAdapter(
              key: ValueKey<String>('list-row-${item.id}'),
              media: item,
              dockLabels: dockLabels,
              dockReaction: dockReaction,
              dockMode: dockMode,
              onTap: () {
                onPosterTap(item);
              },
              onLongPress: () {
                onPosterLongPress(item);
              },
            );
          })
          .toList(growable: false),
    );
  }
}

/// Preview-only state adapter for [CinearaMediaListItem].
///
/// The reusable List item owns all approved row geometry, centralized artwork
/// elevation, accessibility, scroll-safe press handling, raw-artwork zoom,
/// full-tile pressure treatment, lifecycle choreography and RTL navigation
/// feedback. This wrapper owns only the mutable preview dock
/// controller/reaction request.
final class _ListMediaItemAdapter extends StatefulWidget {
  const _ListMediaItemAdapter({
    super.key,
    required this.media,
    required this.dockLabels,
    required this.dockReaction,
    required this.dockMode,
    required this.onTap,
    required this.onLongPress,
  });

  final _PreviewMedia media;
  final CinearaStatusDockLabels dockLabels;
  final _DockReaction? dockReaction;
  final _DockPreviewMode dockMode;

  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  State<_ListMediaItemAdapter> createState() => _ListMediaItemAdapterState();
}

final class _ListMediaItemAdapterState extends State<_ListMediaItemAdapter> {
  late final CinearaStatusDockController _dockController;

  int _lastHandledReactionSerial = -1;

  @override
  void initState() {
    super.initState();

    _dockController = CinearaStatusDockController();
  }

  @override
  void didUpdateWidget(_ListMediaItemAdapter oldWidget) {
    super.didUpdateWidget(oldWidget);

    _scheduleDockReactionIfNeeded();
  }

  void _scheduleDockReactionIfNeeded() {
    final _DockReaction? reaction = widget.dockReaction;

    if (reaction == null ||
        reaction.layout != _PreviewLayout.list ||
        reaction.mediaId != widget.media.id ||
        reaction.serial == _lastHandledReactionSerial) {
      return;
    }

    _lastHandledReactionSerial = reaction.serial;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(_runDockReaction(reaction));
    });
  }

  Future<void> _runDockReaction(_DockReaction reaction) async {
    if (!_dockController.attached) {
      return;
    }

    await _dockController.revealChanges(
      changedIndicators: reaction.changedIndicators,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _PreviewMedia media = widget.media;

    return CinearaMediaListItem(
      artwork: _NetworkPoster(url: media.imageUrl, title: media.title),
      title: media.title,
      descriptor: media.descriptor,
      year: media.year,
      primaryGenre: media.primaryGenre,
      semanticHint: 'Open media details. Long press for quick actions.',
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      externalRatingBadge: !media.showExternalRating
          ? null
          : CinearaExternalRatingBadge(
              value: media.externalRating.toStringAsFixed(1),
              semanticLabel:
                  'External rating '
                  '${media.externalRating.toStringAsFixed(1)} out of 10',
              variant: CinearaExternalRatingBadgeVariant.artwork,
              density: CinearaExternalRatingBadgeDensity.compact,
              showTooltip: false,
            ),
      progressIndicator: !media.showProgress
          ? null
          : CinearaMediaProgressIndicator(
              value: media.progress,
              variant: CinearaMediaProgressVariant.posterEdge,
              semanticLabel: 'Viewing progress',
            ),
      lifecycleStatus: media.status == null
          ? null
          : CinearaStatusBadge(
              key: ValueKey<String>('list-status-${media.status!.name}'),
              type: media.status!,
              label: _statusLabel(media.status!),
              semanticLabel: _statusLabel(media.status!),
              variant: CinearaStatusBadgeVariant.surface,
              density: CinearaStatusBadgeDensity.compact,
              behavior: CinearaStatusBadgeBehavior.collapsible,
              revealOnMount: false,
              revealOnStatusChange: false,
              expandOnTap: false,
              autoCollapse: false,
            ),
      personalDock: widget.dockMode == _DockPreviewMode.off
          ? null
          : CinearaStatusDock(
              controller: _dockController,
              labels: widget.dockLabels,
              favorite: media.favorite,
              collection: media.collection,
              watchlist: media.watchlist,
              personalRating: media.personalRating,
              mode: widget.dockMode == _DockPreviewMode.permanent
                  ? CinearaStatusDockMode.permanent
                  : CinearaStatusDockMode.compact,
              layout: CinearaStatusDockLayout.horizontal,
              variant: CinearaStatusDockVariant.surface,
              density: CinearaStatusDockDensity.compact,
              side: CinearaStatusDockSide.start,
              tapToExpand: widget.dockMode == _DockPreviewMode.compact,
              autoCollapse: widget.dockMode == _DockPreviewMode.compact,
            ),
    );
  }
}

// =============================================================================
// Person Quick Actions
// =============================================================================

final class _PersonQuickActionsSheet extends StatefulWidget {
  const _PersonQuickActionsSheet({required this.person});

  final _PreviewPerson person;

  @override
  State<_PersonQuickActionsSheet> createState() =>
      _PersonQuickActionsSheetState();
}

final class _PersonQuickActionsSheetState
    extends State<_PersonQuickActionsSheet> {
  late bool _favorite;

  @override
  void initState() {
    super.initState();

    _favorite = widget.person.favorite;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.person.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Person Quick Actions',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.favorite_rounded),
              title: const Text('Favorite person'),
              subtitle: const Text(
                'Uses the same Favorite status-dock node and add/remove '
                'animation as media posters.',
              ),
              value: _favorite,
              onChanged: (bool value) {
                setState(() {
                  _favorite = value;
                });
              },
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      _PersonEditResult(
                        person: widget.person.copyWith(favorite: _favorite),
                      ),
                    );
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
final class _PersonEditResult {
  const _PersonEditResult({required this.person});

  final _PreviewPerson person;
}

// =============================================================================
// Entity Quick Actions
// =============================================================================

final class _EntityQuickActionsSheet extends StatefulWidget {
  const _EntityQuickActionsSheet({required this.entity});

  final _PreviewEntity entity;

  @override
  State<_EntityQuickActionsSheet> createState() =>
      _EntityQuickActionsSheetState();
}

final class _EntityQuickActionsSheetState
    extends State<_EntityQuickActionsSheet> {
  late bool _favorite;

  @override
  void initState() {
    super.initState();

    _favorite = widget.entity.favorite;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String descriptor = widget.entity.descriptor;
    final String descriptorLower = descriptor.toLowerCase();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.entity.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$descriptor Quick Actions',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.favorite_rounded),
              title: Text('Favorite $descriptorLower'),
              subtitle: Text(
                'Updates the real Favorite status-dock treatment used by '
                '${widget.entity.kind == _PreviewEntityKind.topic ? 'the text-only Topic row' : 'this $descriptorLower result'}.',
              ),
              value: _favorite,
              onChanged: (bool value) {
                setState(() {
                  _favorite = value;
                });
              },
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      _EntityEditResult(
                        entity: widget.entity.copyWith(favorite: _favorite),
                      ),
                    );
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
final class _EntityEditResult {
  const _EntityEditResult({required this.entity});

  final _PreviewEntity entity;
}

// =============================================================================
// Editable Quick Actions
// =============================================================================

final class _QuickActionsSheet extends StatefulWidget {
  const _QuickActionsSheet({required this.media});

  final _PreviewMedia media;

  @override
  State<_QuickActionsSheet> createState() => _QuickActionsSheetState();
}

final class _QuickActionsSheetState extends State<_QuickActionsSheet> {
  late CinearaStatusBadgeType? _status;

  late bool _favorite;
  late bool _watchlist;
  late bool _collection;

  late double? _personalRating;

  late bool _showExternalRating;
  late double _externalRating;

  late bool _showProgress;
  late double _progress;

  @override
  void initState() {
    super.initState();

    final _PreviewMedia media = widget.media;

    _status = media.status;

    _favorite = media.favorite;
    _watchlist = media.watchlist;
    _collection = media.collection;

    _personalRating = media.personalRating;

    _showExternalRating = media.showExternalRating;
    _externalRating = media.externalRating;

    _showProgress = media.showProgress;
    _progress = media.progress;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          28 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.media.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Edit the state, then press Apply. The poster/dock reacts after '
              'the sheet closes.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Viewing status',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ChoiceChip(
                  selected: _status == null,
                  label: const Text('None'),
                  onSelected: (_) {
                    setState(() {
                      _status = null;
                    });
                  },
                ),
                for (final CinearaStatusBadgeType status
                    in CinearaStatusBadgeType.values)
                  ChoiceChip(
                    selected: _status == status,
                    label: Text(_statusLabel(status)),
                    onSelected: (_) {
                      setState(() {
                        _status = status;
                      });
                    },
                  ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Personal state',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.favorite_rounded),
              title: const Text('Favorite'),
              value: _favorite,
              onChanged: (bool value) {
                setState(() {
                  _favorite = value;
                });
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.bookmark_rounded),
              title: const Text('Watchlist'),
              value: _watchlist,
              onChanged: (bool value) {
                setState(() {
                  _watchlist = value;
                });
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.inventory_2_rounded),
              title: const Text('Collection'),
              value: _collection,
              onChanged: (bool value) {
                setState(() {
                  _collection = value;
                });
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.star_rounded),
              title: const Text('Personal rating'),
              value: _personalRating != null,
              onChanged: (bool enabled) {
                setState(() {
                  _personalRating = enabled ? (_personalRating ?? 8.0) : null;
                });
              },
            ),

            if (_personalRating != null)
              _LabeledSlider(
                label: 'Your rating',
                valueLabel: _personalRating!.toStringAsFixed(1),
                value: _personalRating!,
                min: 0,
                max: 10,
                divisions: 100,
                onChanged: (double value) {
                  setState(() {
                    _personalRating = value;
                  });
                },
              ),

            const SizedBox(height: 18),

            Text(
              'External metadata',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('External rating'),
              value: _showExternalRating,
              onChanged: (bool value) {
                setState(() {
                  _showExternalRating = value;
                });
              },
            ),

            if (_showExternalRating)
              _LabeledSlider(
                label: 'External rating',
                valueLabel: _externalRating.toStringAsFixed(1),
                value: _externalRating,
                min: 0,
                max: 10,
                divisions: 100,
                onChanged: (double value) {
                  setState(() {
                    _externalRating = value;
                  });
                },
              ),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Viewing progress'),
              value: _showProgress,
              onChanged: (bool value) {
                setState(() {
                  _showProgress = value;
                });
              },
            ),

            if (_showProgress)
              _LabeledSlider(
                label: 'Progress',
                valueLabel: '${(_progress * 100).round()}%',
                value: _progress,
                min: 0,
                max: 1,
                divisions: 100,
                onChanged: (double value) {
                  setState(() {
                    _progress = value;
                  });
                },
              ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      _MediaEditResult(
                        media: widget.media.copyWith(
                          status: _status,
                          clearStatus: _status == null,
                          favorite: _favorite,
                          watchlist: _watchlist,
                          collection: _collection,
                          personalRating: _personalRating,
                          clearPersonalRating: _personalRating == null,
                          showExternalRating: _showExternalRating,
                          externalRating: _externalRating,
                          showProgress: _showProgress,
                          progress: _progress,
                        ),
                      ),
                    );
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
final class _MediaEditResult {
  const _MediaEditResult({required this.media});

  final _PreviewMedia media;
}

// =============================================================================
// Network poster
// =============================================================================

final class _NetworkPoster extends StatelessWidget {
  const _NetworkPoster({required this.url, required this.title});

  final String? url;
  final String title;

  @override
  Widget build(BuildContext context) {
    final String? resolvedUrl = url?.trim();

    return CinearaPosterImage(
      image: resolvedUrl == null || resolvedUrl.isEmpty
          ? null
          : NetworkImage(resolvedUrl),

      // CinearaMediaPoster already supplies the 2:3 geometry.
      constrainToPosterAspectRatio: false,

      // The media poster owns the accessible media label.
      semanticLabel: title,
      excludeFromSemantics: true,

      // No custom placeholder/error builders here. The production poster image
      // is intentionally previewed as-is:
      //
      // loading       -> quiet neutral surface
      // missing/fail  -> neutral surface + canonical primary movie icon
    );
  }
}

// =============================================================================
// Explanations
// =============================================================================

final class _InteractionExplanation extends StatelessWidget {
  const _InteractionExplanation();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.38),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Interaction test',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Grid and horizontal media rails share the complete '
            'poster-overlay treatment and the central Cineara artwork depth '
            'language: a subtle rim plus contact/ambient shadow at rest, with '
            'the shadow contracting as the existing press interaction deepens. '
            'Search List uses the same optical elevation without moving the '
            'poster frame: only raw artwork zooms while frame, rim, external '
            'rating and progress remain fixed. People remain split into '
            'CinearaPersonGridItem and CinearaPersonListItem. Their smaller '
            'circular portraits use stronger local optical separation so the '
            'photos still read as detached from the background, with a subtle '
            'resting lift and contracting shadow. Both People components keep '
            'the same 1.030 raw-photo zoom, scroll-safe press arming, '
            'confirmed-hold depth and haptic. Favorite remains the real '
            'CinearaStatusDock outside the portrait depth treatment, so the '
            'heart styling and magnetic add/remove animation stay identical to '
            'media. Entity Grid/List items use the same restrained full-item '
            'pressure language while keeping only the visual zoomed. '
            'Entity geometry is owned entirely by the production components: '
            'Collections preserve true 2:3 TMDB poster geometry, Studios use '
            'real transparent TMDB logos inside dedicated 3:2 contained-logo '
            'surfaces with breathing room, while Topics are text-only in '
            'List mode because the API supplies no topic artwork or icon. '
            'Entity List Favorite moves into the metadata/state rail, matching '
            'media List placement. Long press opens Entity Quick Actions so '
            'Favorite changes can be tested on collections, studios and topics. '
            'List chevrons move toward details on tap confirmation. '
            'Reduced-motion mode keeps the interaction static instead of '
            'animating depth or zoom.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

final class _PlacementReference extends StatelessWidget {
  const _PlacementReference();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.38),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Mode-specific placement',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          const _PlacementRow(
            label: 'Grid / rails',
            value:
                'Shared artwork rim + detached shadow · status top-start · '
                'external rating top-end · personal dock bottom-end · progress '
                'owns bottom edge · shadow contracts on press · rail '
                'free-scrolls with no automatic snap · continuation fade '
                'appears only where more content exists',
          ),
          const _PlacementRow(
            label: 'People Grid',
            value:
                'Circular portrait · stronger local shadow + shared rim · '
                'slight resting lift · real Favorite status dock at portrait '
                'bottom-end · 1.030 raw-photo zoom · shadow contracts on press '
                '· long press opens person Quick Actions',
          ),
          const _PlacementRow(
            label: 'People List',
            value:
                'Circular portrait · same stronger portrait depth + shared rim '
                '· Favorite remains outside the portrait shadow · editorial '
                'metadata · same pressure/zoom/hold language · directional '
                'chevron moves on tap confirmation',
          ),
          const _PlacementRow(
            label: 'Entity Grid',
            value:
                'Variant-owned visual geometry · Collection posters keep true '
                '2:3 artwork · Studio logos use dedicated contained-logo '
                'surfaces with breathing room · complete tile interaction · '
                'visual-only 1.030 zoom · shared rim · title only · '
                'real Favorite dock',
          ),
          const _PlacementRow(
            label: 'Entity List',
            value:
                'Collection poster / Studio logo / text-only Topic · complete '
                'media-List-style row pressure · visual-only 1.030 zoom when a '
                'visual exists · Favorite in metadata/state rail · RTL-aware '
                'moving chevron · long press opens Entity Quick Actions',
          ),
          const _PlacementRow(
            label: 'Search list',
            value:
                'Fixed poster frame + shared artwork elevation · external '
                'rating top-start · progress visually replaces bottom rim · '
                'title + descriptor/year + one primary genre · optional '
                'lifecycle + horizontal personal dock · row-driven press '
                'chevron · separator runs from metadata rail to row edge',
          ),
          const SizedBox(height: 10),
          Text(
            'Long press media to edit media state. Long press a person, '
            'collection, studio or topic to edit Favorite in the corresponding '
            'Quick Actions sheet. The workbench above remains the faster route '
            'for repeatedly testing media transitions.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

final class _PlacementRow extends StatelessWidget {
  const _PlacementRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 94,
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Preview data
// =============================================================================

enum _PreviewEntityKind { collection, studio, topic }

@immutable
final class _PreviewEntity {
  const _PreviewEntity({
    required this.id,
    required this.title,
    required this.kind,
    this.fallbackIcon,
    this.subtitle,
    this.imageUrl,
    this.favorite = false,
  });

  final String id;
  final String title;
  final _PreviewEntityKind kind;
  final String? subtitle;
  final String? imageUrl;

  /// Optional fallback only for entity families that genuinely own a visual.
  /// Topics intentionally keep this null because the API supplies only a name.
  final IconData? fallbackIcon;

  final bool favorite;

  String get descriptor {
    return switch (kind) {
      _PreviewEntityKind.collection => 'Collection',
      _PreviewEntityKind.studio => 'Studio',
      _PreviewEntityKind.topic => 'Topic',
    };
  }

  /// Only entity types with genuine visual assets participate in Grid/rail.
  bool get supportsGrid => kind != _PreviewEntityKind.topic;

  /// Non-null because this is used only after [supportsGrid] has been checked.
  CinearaEntityVisualVariant get gridVisualVariant {
    return switch (kind) {
      _PreviewEntityKind.collection => CinearaEntityVisualVariant.poster,
      _PreviewEntityKind.studio => CinearaEntityVisualVariant.logo,
      _PreviewEntityKind.topic => throw StateError(
        'Topics are text-only and do not support Grid/rail visuals.',
      ),
    };
  }

  /// List may omit the leading visual entirely. This is the intended Topic
  /// representation because TMDB keywords/topics provide no artwork identity.
  CinearaEntityVisualVariant? get listVisualVariant {
    return switch (kind) {
      _PreviewEntityKind.collection => CinearaEntityVisualVariant.poster,
      _PreviewEntityKind.studio => CinearaEntityVisualVariant.logo,
      _PreviewEntityKind.topic => null,
    };
  }

  ImageProvider<Object>? get imageProvider {
    final String? url = imageUrl;

    if (url == null || url.trim().isEmpty) {
      return null;
    }

    return NetworkImage(url);
  }

  String get semanticLabel {
    final List<String> parts = <String>[title, descriptor];

    final String? supportingText = subtitle?.trim();

    if (supportingText != null && supportingText.isNotEmpty) {
      parts.add(supportingText);
    }

    if (favorite) {
      parts.add('Favorite');
    }

    return parts.join('. ');
  }

  _PreviewEntity copyWith({
    String? id,
    String? title,
    _PreviewEntityKind? kind,
    String? subtitle,
    bool clearSubtitle = false,
    String? imageUrl,
    bool clearImageUrl = false,
    IconData? fallbackIcon,
    bool clearFallbackIcon = false,
    bool? favorite,
  }) {
    return _PreviewEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      fallbackIcon: clearFallbackIcon
          ? null
          : (fallbackIcon ?? this.fallbackIcon),
      favorite: favorite ?? this.favorite,
    );
  }
}

const List<_PreviewEntity> _initialEntities = <_PreviewEntity>[
  _PreviewEntity(
    id: 'collection-dune',
    title: 'Dune Collection',
    kind: _PreviewEntityKind.collection,
    subtitle: 'Film collection',
    imageUrl: 'https://image.tmdb.org/t/p/w500/lxIGYkpvYjLtYtZH684AQft0FhD.jpg',
    fallbackIcon: Icons.video_library_rounded,
    favorite: true,
  ),
  _PreviewEntity(
    id: 'collection-star-wars',
    title: 'Star Wars Collection',
    kind: _PreviewEntityKind.collection,
    subtitle: 'Film collection',
    imageUrl: 'https://image.tmdb.org/t/p/w500/22dj38IckjzEEUZwN1tPU5VJ1qq.jpg',
    fallbackIcon: Icons.video_library_rounded,
  ),
  _PreviewEntity(
    id: 'studio-ghibli',
    title: 'Studio Ghibli',
    kind: _PreviewEntityKind.studio,
    subtitle: 'Animation studio',
    imageUrl: 'https://image.tmdb.org/t/p/w300/uFuxPEZRUcBTEiYIxjHJq62Vr77.png',
    favorite: true,
  ),
  _PreviewEntity(
    id: 'studio-lucasfilm',
    title: 'Lucasfilm Ltd.',
    kind: _PreviewEntityKind.studio,
    subtitle: 'Film and television studio · missing artwork demo',
    imageUrl: null,
  ),
  _PreviewEntity(
    id: 'topic-time-travel',
    title: 'Time travel',
    kind: _PreviewEntityKind.topic,
    subtitle: 'Keyword',
  ),
  _PreviewEntity(
    id: 'topic-artificial-intelligence',
    title: 'Artificial intelligence',
    kind: _PreviewEntityKind.topic,
    subtitle: 'Keyword',
  ),
  _PreviewEntity(
    id: 'topic-space-exploration',
    title: 'Space exploration',
    kind: _PreviewEntityKind.topic,
    subtitle: 'Keyword',
  ),
];

@immutable
final class _PreviewPerson {
  const _PreviewPerson({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.knownForDepartment,
    required this.knownFor,
    required this.favorite,
  });

  final int id;
  final String name;
  final String? imageUrl;
  final String? knownForDepartment;
  final List<CinearaPersonKnownForItem> knownFor;

  final bool favorite;

  String get semanticLabel {
    final List<String> parts = <String>[name];

    final String? department = knownForDepartment;

    if (department != null && department.trim().isNotEmpty) {
      parts.add(department.trim());
    }

    if (knownFor.isNotEmpty) {
      parts.add(
        knownFor
            .take(3)
            .map((CinearaPersonKnownForItem item) => item.label)
            .join(', '),
      );
    }

    if (favorite) {
      parts.add('Favorite');
    }

    return parts.join('. ');
  }

  _PreviewPerson copyWith({
    int? id,
    String? name,
    String? imageUrl,
    bool clearImageUrl = false,
    String? knownForDepartment,
    bool clearKnownForDepartment = false,
    List<CinearaPersonKnownForItem>? knownFor,
    bool? favorite,
  }) {
    return _PreviewPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      knownForDepartment: clearKnownForDepartment
          ? null
          : (knownForDepartment ?? this.knownForDepartment),
      knownFor: knownFor ?? this.knownFor,
      favorite: favorite ?? this.favorite,
    );
  }
}

const List<_PreviewPerson> _initialPeople = <_PreviewPerson>[
  _PreviewPerson(
    id: 31,
    name: 'Tom Hanks',
    imageUrl: 'https://image.tmdb.org/t/p/w185/oFvZoKI6lvU03n4YoNGAll9rkas.jpg',
    knownForDepartment: 'Acting',
    knownFor: <CinearaPersonKnownForItem>[
      CinearaPersonKnownForItem(title: 'Forrest Gump', year: 1994),
      CinearaPersonKnownForItem(title: 'Toy Story', year: 1995),
      CinearaPersonKnownForItem(title: 'The Green Mile', year: 1999),
    ],
    favorite: true,
  ),
  _PreviewPerson(
    id: 115440,
    name: 'Zendaya',
    imageUrl: 'https://image.tmdb.org/t/p/w185/3WdOloHpjtjL96uVOhFRRCcYSwq.jpg',
    knownForDepartment: 'Acting',
    knownFor: <CinearaPersonKnownForItem>[
      CinearaPersonKnownForItem(title: 'Dune: Part Two', year: 2024),
      CinearaPersonKnownForItem(title: 'Euphoria', year: 2019),
      CinearaPersonKnownForItem(title: 'Spider-Man: No Way Home', year: 2021),
    ],
    favorite: true,
  ),
  _PreviewPerson(
    id: 2037,
    name: 'Cillian Murphy',
    imageUrl: 'https://image.tmdb.org/t/p/w185/llkbyWKwpfowZ6C8peBjIV9jj99.jpg',
    knownForDepartment: 'Acting',
    knownFor: <CinearaPersonKnownForItem>[
      CinearaPersonKnownForItem(title: 'Oppenheimer', year: 2023),
      CinearaPersonKnownForItem(title: 'Peaky Blinders', year: 2013),
      CinearaPersonKnownForItem(title: 'Inception', year: 2010),
    ],
    favorite: false,
  ),
  _PreviewPerson(
    id: 1253360,
    name: 'Pedro Pascal',
    imageUrl: 'https://image.tmdb.org/t/p/w185/dBOrm29cr7NUrjiDQMTtrTyDpfy.jpg',
    knownForDepartment: 'Acting',
    knownFor: <CinearaPersonKnownForItem>[
      CinearaPersonKnownForItem(title: 'The Last of Us', year: 2023),
      CinearaPersonKnownForItem(title: 'The Mandalorian', year: 2019),
      CinearaPersonKnownForItem(title: 'Gladiator II', year: 2024),
    ],
    favorite: true,
  ),
  _PreviewPerson(
    id: 1783265,
    name: 'Ayo Edebiri',
    imageUrl: null,
    knownForDepartment: 'Acting',
    knownFor: <CinearaPersonKnownForItem>[
      CinearaPersonKnownForItem(title: 'The Bear', year: 2022),
      CinearaPersonKnownForItem(title: 'Bottoms', year: 2023),
      CinearaPersonKnownForItem(title: 'Inside Out 2', year: 2024),
    ],
    favorite: false,
  ),
  _PreviewPerson(
    id: 608,
    name: 'Hayao Miyazaki',
    imageUrl: null,
    knownForDepartment: 'Directing',
    knownFor: <CinearaPersonKnownForItem>[
      CinearaPersonKnownForItem(title: 'Spirited Away', year: 2001),
      CinearaPersonKnownForItem(title: 'Howl’s Moving Castle', year: 2004),
      CinearaPersonKnownForItem(title: 'The Boy and the Heron', year: 2023),
    ],
    favorite: true,
  ),
];

@immutable
final class _PreviewMedia {
  const _PreviewMedia({
    required this.id,
    required this.title,
    required this.descriptor,
    required this.year,
    required this.primaryGenre,
    required this.imageUrl,
    required this.externalRating,
    required this.showExternalRating,
    required this.status,
    required this.favorite,
    required this.collection,
    required this.watchlist,
    required this.personalRating,
    required this.progress,
    required this.showProgress,
  });

  final String id;
  final String title;

  /// Search-facing media descriptor.
  ///
  /// Examples:
  ///
  /// ```text
  /// Movie
  /// TV series
  /// Animation
  /// Anime
  /// K-drama
  /// ```
  final String descriptor;

  /// Release/first-air year when available.
  final int? year;

  /// One representative Search/List genre.
  ///
  /// Grid deliberately stays more artwork-led. List may use this single genre
  /// as a third information line; multiple genres are intentionally not shown.
  final String? primaryGenre;

  /// Null deliberately exercises CinearaPosterImage's canonical missing-artwork
  /// fallback in this preview.
  final String? imageUrl;

  final double externalRating;
  final bool showExternalRating;

  final CinearaStatusBadgeType? status;

  final bool favorite;
  final bool collection;
  final bool watchlist;

  final double? personalRating;

  final double progress;
  final bool showProgress;

  /// Compact metadata grammar shared by Movie and TV search results.
  ///
  /// Search deliberately does not fabricate country data for movies. The
  /// descriptor/year grammar remains separate from the optional single
  /// [primaryGenre] used by List mode.
  String get searchMetadata {
    final int? resolvedYear = year;

    if (resolvedYear == null) {
      return descriptor;
    }

    return '$descriptor · $resolvedYear';
  }

  _PreviewMedia copyWith({
    String? id,
    String? title,
    String? descriptor,
    int? year,
    bool clearYear = false,
    String? primaryGenre,
    bool clearPrimaryGenre = false,
    String? imageUrl,
    bool clearImageUrl = false,
    double? externalRating,
    bool? showExternalRating,
    CinearaStatusBadgeType? status,
    bool clearStatus = false,
    bool? favorite,
    bool? collection,
    bool? watchlist,
    double? personalRating,
    bool clearPersonalRating = false,
    double? progress,
    bool? showProgress,
  }) {
    return _PreviewMedia(
      id: id ?? this.id,
      title: title ?? this.title,
      descriptor: descriptor ?? this.descriptor,
      year: clearYear ? null : (year ?? this.year),
      primaryGenre: clearPrimaryGenre
          ? null
          : (primaryGenre ?? this.primaryGenre),
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      externalRating: externalRating ?? this.externalRating,
      showExternalRating: showExternalRating ?? this.showExternalRating,
      status: clearStatus ? null : (status ?? this.status),
      favorite: favorite ?? this.favorite,
      collection: collection ?? this.collection,
      watchlist: watchlist ?? this.watchlist,
      personalRating: clearPersonalRating
          ? null
          : (personalRating ?? this.personalRating),
      progress: progress ?? this.progress,
      showProgress: showProgress ?? this.showProgress,
    );
  }
}

const List<_PreviewMedia> _initialMedia = <_PreviewMedia>[
  _PreviewMedia(
    id: 'movie-693134',
    title: 'Dune: Part Two',
    descriptor: 'Movie',
    year: 2024,
    primaryGenre: 'Science fiction',
    imageUrl: 'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg',
    externalRating: 8.3,
    showExternalRating: true,
    status: CinearaStatusBadgeType.completed,
    favorite: true,
    collection: true,
    watchlist: false,
    personalRating: 9.2,
    progress: 1,
    showProgress: true,
  ),
  _PreviewMedia(
    id: 'movie-346698',
    title: 'Barbie',
    descriptor: 'Movie',
    year: 2023,
    primaryGenre: 'Comedy',
    imageUrl: 'https://image.tmdb.org/t/p/w500/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg',
    externalRating: 7.0,
    showExternalRating: true,
    status: CinearaStatusBadgeType.rewatching,
    favorite: true,
    collection: false,
    watchlist: true,
    personalRating: 8.4,
    progress: 0.36,
    showProgress: true,
  ),
  _PreviewMedia(
    id: 'movie-872585',
    title: 'Oppenheimer',
    descriptor: 'Movie',
    year: 2023,
    primaryGenre: 'Drama',
    imageUrl: 'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
    externalRating: 8.0,
    showExternalRating: true,
    status: CinearaStatusBadgeType.completed,
    favorite: true,
    collection: true,
    watchlist: false,
    personalRating: 9.4,
    progress: 1,
    showProgress: true,
  ),
  _PreviewMedia(
    id: 'tv-136315',
    title: 'The Bear',
    descriptor: 'TV series',
    year: 2022,
    primaryGenre: 'Drama',
    imageUrl: 'https://image.tmdb.org/t/p/w500/eKfVzzEazSIjJMrw9ADa2x8ksLz.jpg',
    externalRating: 8.2,
    showExternalRating: true,
    status: CinearaStatusBadgeType.watching,
    favorite: true,
    collection: false,
    watchlist: false,
    personalRating: 8.8,
    progress: 0.72,
    showProgress: true,
  ),
  _PreviewMedia(
    id: 'tv-225180',
    title: 'Blue Eye Samurai',
    descriptor: 'Animation',
    year: 2023,
    primaryGenre: 'Action & adventure',
    imageUrl: 'https://image.tmdb.org/t/p/w500/fXm3JT4WLQVnwukdvghtAblc1wc.jpg',
    externalRating: 8.5,
    showExternalRating: true,
    status: CinearaStatusBadgeType.caughtUp,
    favorite: true,
    collection: true,
    watchlist: false,
    personalRating: 9.1,
    progress: 1,
    showProgress: true,
  ),
  _PreviewMedia(
    id: 'movie-1011985',
    title: 'Kung Fu Panda 4',
    descriptor: 'Movie',
    year: 2024,
    primaryGenre: 'Adventure',
    imageUrl: null,
    externalRating: 7.1,
    showExternalRating: true,
    status: null,
    favorite: false,
    collection: false,
    watchlist: false,
    personalRating: null,
    progress: 0,
    showProgress: false,
  ),
];

// =============================================================================
// Labels
// =============================================================================

String _statusLabel(CinearaStatusBadgeType type) {
  return switch (type) {
    CinearaStatusBadgeType.watching => 'Watching',
    CinearaStatusBadgeType.caughtUp => 'Caught up',
    CinearaStatusBadgeType.completed => 'Completed',
    CinearaStatusBadgeType.rewatching => 'Rewatching',
    CinearaStatusBadgeType.onHold => 'On hold',
    CinearaStatusBadgeType.dropped => 'Dropped',
  };
}
