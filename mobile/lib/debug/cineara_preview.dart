import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CinearaDesignSystemPreviewApp());
}

// =============================================================================
// Application
// =============================================================================

final class CinearaDesignSystemPreviewApp extends StatefulWidget {
  const CinearaDesignSystemPreviewApp({super.key});

  @override
  State<CinearaDesignSystemPreviewApp> createState() =>
      _CinearaDesignSystemPreviewAppState();
}

final class _CinearaDesignSystemPreviewAppState
    extends State<CinearaDesignSystemPreviewApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cineara Design System Preview',
      theme: CinearaLightTheme.theme,
      darkTheme: CinearaDarkTheme.theme,
      themeMode: _themeMode,
      home: CinearaDesignSystemPreviewPage(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

// =============================================================================
// Main preview shell
// =============================================================================

final class CinearaDesignSystemPreviewPage extends StatefulWidget {
  const CinearaDesignSystemPreviewPage({
    required this.isDark,
    required this.onToggleTheme,
    super.key,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<CinearaDesignSystemPreviewPage> createState() =>
      _CinearaDesignSystemPreviewPageState();
}

final class _CinearaDesignSystemPreviewPageState
    extends State<CinearaDesignSystemPreviewPage> {
  int _selectedRootIndex = 1;

  bool _showSearch = false;

  CinearaViewMode _discoverViewMode = CinearaViewMode.grid;
  CinearaViewMode _libraryViewMode = CinearaViewMode.grid;
  CinearaViewMode _searchViewMode = CinearaViewMode.list;

  final TextEditingController _searchController = TextEditingController();

  static const List<_PreviewMedia> _media = <_PreviewMedia>[
    _PreviewMedia(
      title: 'Frieren: Beyond Journey\'s End',
      metadata: '2023 • Anime',
      rating: '8.8',
      status: 'Watching',
      progress: '18 / 28',
    ),
    _PreviewMedia(
      title: 'Memories of Murder',
      metadata: '2003 • South Korea',
      rating: '8.1',
      status: 'Watchlist',
    ),
    _PreviewMedia(
      title: 'Perfect Days',
      metadata: '2023 • Japan',
      rating: '7.8',
      status: 'Favourite',
    ),
    _PreviewMedia(
      title: 'The Last of Us',
      metadata: '2023 • TV Series',
      rating: '8.7',
      status: 'Caught up',
      progress: '16 / 16',
    ),
    _PreviewMedia(
      title: 'Decision to Leave',
      metadata: '2022 • South Korea',
      rating: '7.3',
      status: 'Collection',
    ),
    _PreviewMedia(
      title: 'Monster',
      metadata: '2004 • Anime',
      rating: '8.7',
      status: 'Completed',
      progress: '74 / 74',
    ),
    _PreviewMedia(
      title: 'In the Mood for Love',
      metadata: '2000 • Hong Kong',
      rating: '8.1',
      status: 'Favourite',
    ),
    _PreviewMedia(
      title: 'The Handmaiden',
      metadata: '2016 • South Korea',
      rating: '8.1',
      status: 'Watchlist',
    ),
    _PreviewMedia(
      title: 'Drive My Car',
      metadata: '2021 • Japan',
      rating: '7.5',
      status: 'Collection',
    ),
    _PreviewMedia(
      title: 'Dark',
      metadata: '2017 • TV Series',
      rating: '8.7',
      status: 'Completed',
      progress: '26 / 26',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = <CinearaNavigationDestination>[
      CinearaNavigationDestination(
        label: 'Home',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
      ),
      CinearaNavigationDestination(
        label: 'Discover',
        icon: Icons.explore_outlined,
        selectedIcon: Icons.explore_rounded,
      ),
      CinearaNavigationDestination(
        label: 'Library',
        icon: Icons.video_library_outlined,
        selectedIcon: Icons.video_library_rounded,
      ),
      CinearaNavigationDestination(
        label: 'Profile',
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
      ),
    ];

    return Scaffold(
      extendBody: true,

      // Search represents a nested route. It intentionally does not receive
      // Cineara's root top app bar.
      appBar: _showSearch ? null : _buildRootTopBar(context),

      body: _showSearch
          ? _buildSearchPage(context)
          : switch (_selectedRootIndex) {
              0 => _buildHomePage(context),
              1 => _buildDiscoverPage(context),
              2 => _buildLibraryPage(context),
              3 => _buildProfilePage(context),
              _ => const SizedBox.shrink(),
            },

      bottomNavigationBar: CinearaNavigationPill(
        destinations: destinations,
        selectedIndex: _selectedRootIndex,
        onDestinationSelected: _selectRootDestination,
      ),
    );
  }

  // ===========================================================================
  // Top app bar
  // ===========================================================================

  PreferredSizeWidget _buildRootTopBar(BuildContext context) {
    return CinearaTopAppBar(
      showBrand: true,
      actions: <Widget>[
        CinearaTopAppBarIconAction(
          icon: Icons.search_rounded,
          semanticLabel: 'Search Cineara',
          onPressed: _openSearch,
        ),
        CinearaNotificationAppBarAction(
          semanticLabel: 'Open notifications',
          onPressed: () {
            _openNotifications(context);
          },
        ),
        CinearaProfileAppBarAction(
          semanticLabel: 'Open profile',
          onPressed: () {
            _selectRootDestination(3);
          },
          imageProvider: null,
          fallbackInitials: 'FM',
        ),
      ],
    );
  }

  // ===========================================================================
  // Root navigation
  // ===========================================================================

  void _selectRootDestination(int index) {
    setState(() {
      _selectedRootIndex = index;
      _showSearch = false;
    });
  }

  void _openSearch() {
    setState(() {
      _showSearch = true;
    });
  }

  void _closeSearch() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _showSearch = false;
    });
  }

  // ===========================================================================
  // Home
  // ===========================================================================

  Widget _buildHomePage(BuildContext context) {
    return CinearaContentPage(
      header: const CinearaPageHeader(
        title: 'Good afternoon',
        subtitle: 'Here is what is happening in your Cineara world.',
      ),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: CinearaSection(
            title: 'Continue watching',
            subtitle: 'Pick up where you left off',
            trailing: TextButton(
              onPressed: () {
                _showMessage(context, 'Open Continue watching');
              },
              child: const Text('See all'),
            ),
            child: SizedBox(
              height: 238,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, _) {
                  return const SizedBox(width: CinearaSpacing.sm);
                },
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 142,
                    child: _PreviewCompactMediaCard(
                      media: _media[index],
                      index: index,
                      onTap: () {
                        _openMedia(context, _media[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        _sectionGap(context),
        SliverToBoxAdapter(
          child: CinearaSection(
            title: 'Today for you',
            subtitle: 'One recommendation matched to your recent activity',
            child: _DailyPickCard(
              media: _media[1],
              onOpen: () {
                _openMedia(context, _media[1]);
              },
              onAnother: () {
                _showMessage(context, 'Choosing another recommendation…');
              },
            ),
          ),
        ),
        _sectionGap(context),
        SliverToBoxAdapter(
          child: CinearaSection(title: 'This week', child: _HomeStatistics()),
        ),
      ],
    );
  }

  // ===========================================================================
  // Discover
  // ===========================================================================

  Widget _buildDiscoverPage(BuildContext context) {
    return CinearaContentPage(
      header: const CinearaPageHeader(
        title: 'Discover',
        subtitle: 'Explore stories from around the world.',
      ),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: CinearaSection(
            title: 'Cineara bridge',
            subtitle: 'Because you enjoy Korean thrillers',
            child: _DiscoveryBridge(
              onPressed: () {
                _showMessage(context, 'Opening Hong Kong crime cinema');
              },
            ),
          ),
        ),
        _sectionGap(context),
        SliverToBoxAdapter(
          child: CinearaSectionHeader(
            title: 'Trending around the world',
            subtitle: 'Movies and series people are discovering now',
            trailing: CinearaViewModeSelector(
              value: _discoverViewMode,
              gridLabel: 'Grid view',
              listLabel: 'List view',
              onChanged: (mode) {
                setState(() {
                  _discoverViewMode = mode;
                });
              },
            ),
          ),
        ),
        _headerGap(context),
        CinearaMediaCollection(
          viewMode: _discoverViewMode,
          itemCount: _media.length,
          gridItemBuilder: (context, index) {
            return _PreviewGridMediaCard(
              media: _media[index],
              index: index,
              onTap: () {
                _openMedia(context, _media[index]);
              },
            );
          },
          listItemBuilder: (context, index) {
            return _PreviewListMediaTile(
              media: _media[index],
              index: index,
              onTap: () {
                _openMedia(context, _media[index]);
              },
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // Library
  // ===========================================================================

  Widget _buildLibraryPage(BuildContext context) {
    return CinearaContentPage(
      header: CinearaPageHeader(
        title: 'Library',
        subtitle: 'Everything you are tracking in one place.',
        actions: <Widget>[
          IconButton(
            tooltip: 'Filter library',
            onPressed: () {
              _showMessage(context, 'Library filters');
            },
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      slivers: <Widget>[
        SliverToBoxAdapter(child: _LibrarySummary()),
        _sectionGap(context),
        SliverToBoxAdapter(
          child: CinearaSectionHeader(
            title: 'Your media',
            subtitle: '${_media.length} titles in this preview',
            trailing: CinearaViewModeSelector(
              value: _libraryViewMode,
              gridLabel: 'Grid view',
              listLabel: 'List view',
              onChanged: (mode) {
                setState(() {
                  _libraryViewMode = mode;
                });
              },
            ),
          ),
        ),
        _headerGap(context),
        CinearaMediaCollection(
          viewMode: _libraryViewMode,
          itemCount: _media.length,
          gridItemBuilder: (context, index) {
            return _PreviewGridMediaCard(
              media: _media[index],
              index: index,
              onTap: () {
                _openMedia(context, _media[index]);
              },
            );
          },
          listItemBuilder: (context, index) {
            return _PreviewListMediaTile(
              media: _media[index],
              index: index,
              onTap: () {
                _openMedia(context, _media[index]);
              },
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // Profile
  // ===========================================================================

  Widget _buildProfilePage(BuildContext context) {
    return CinearaContentPage(
      header: const CinearaPageHeader(
        title: 'Profile',
        subtitle: 'Your viewing journey across Cineara.',
      ),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: CinearaSection(title: 'Overview', child: _ProfileOverview()),
        ),
        _sectionGap(context),
        SliverToBoxAdapter(
          child: CinearaSection(
            title: 'Statistics',
            trailing: TextButton(
              onPressed: () {
                _showMessage(context, 'Open full statistics');
              },
              child: const Text('See all'),
            ),
            child: const _ProfileStatistics(),
          ),
        ),
        _sectionGap(context),
        SliverToBoxAdapter(
          child: CinearaSection(
            title: 'Preferences',
            child: CinearaSurface(
              variant: CinearaSurfaceVariant.standard,
              child: Column(
                children: <Widget>[
                  SwitchListTile.adaptive(
                    secondary: Icon(
                      widget.isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                    ),
                    title: const Text('Dark theme'),
                    subtitle: const Text(
                      'Switch themes to inspect the real design system.',
                    ),
                    value: widget.isDark,
                    onChanged: (_) {
                      widget.onToggleTheme();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Edit profile'),
                    subtitle: const Text('Preview a focused centred form'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      _openEditProfile(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Search
  // ===========================================================================

  Widget _buildSearchPage(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final results = query.isEmpty
        ? _media
        : _media
              .where(
                (item) =>
                    item.title.toLowerCase().contains(query) ||
                    item.metadata.toLowerCase().contains(query),
              )
              .toList(growable: false);

    return CinearaContentPage(
      header: CinearaPageHeader(
        showBackButton: true,
        onBackPressed: _closeSearch,
        title: 'Search',
        subtitle: 'Find movies, TV series, anime, people and more.',
      ),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: TextField(
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Search Cineara',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),
        _sectionGap(context),
        SliverToBoxAdapter(
          child: CinearaSectionHeader(
            title: query.isEmpty ? 'Suggested for you' : 'Results',
            subtitle: query.isEmpty
                ? 'Popular titles across Cineara'
                : '${results.length} matching titles',
            trailing: CinearaViewModeSelector(
              value: _searchViewMode,
              gridLabel: 'Grid view',
              listLabel: 'List view',
              onChanged: (mode) {
                setState(() {
                  _searchViewMode = mode;
                });
              },
            ),
          ),
        ),
        _headerGap(context),
        if (results.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: CinearaCenteredContent(
              useSafeArea: false,
              padding: const EdgeInsetsDirectional.only(
                top: CinearaSpacing.lg,
                bottom: CinearaSpacing.xxl,
              ),
              physics: const NeverScrollableScrollPhysics(),
              child: _SearchEmptyState(
                query: _searchController.text.trim(),
                onClear: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
            ),
          )
        else
          CinearaMediaCollection(
            viewMode: _searchViewMode,
            itemCount: results.length,
            gridItemBuilder: (context, index) {
              final media = results[index];

              return _PreviewGridMediaCard(
                media: media,
                index: _media.indexOf(media),
                onTap: () {
                  _openMedia(context, media);
                },
              );
            },
            listItemBuilder: (context, index) {
              final media = results[index];

              return _PreviewListMediaTile(
                media: media,
                index: _media.indexOf(media),
                onTap: () {
                  _openMedia(context, media);
                },
              );
            },
          ),
      ],
    );
  }

  // ===========================================================================
  // Navigation helpers
  // ===========================================================================

  SliverToBoxAdapter _sectionGap(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(height: CinearaPageMetrics.sectionGapFor(context)),
    );
  }

  SliverToBoxAdapter _headerGap(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(height: CinearaPageMetrics.headerGapFor(context)),
    );
  }

  // ===========================================================================
  // Interactions
  // ===========================================================================

  void _openMedia(BuildContext context, _PreviewMedia media) {
    _showMessage(context, 'Opening ${media.title}');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              CinearaSpacing.md,
              0,
              CinearaSpacing.md,
              CinearaSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const CinearaSectionHeader(
                  title: 'Notifications',
                  subtitle: '3 unread',
                ),
                const SizedBox(height: CinearaSpacing.md),
                CinearaSurface(
                  variant: CinearaSurfaceVariant.standard,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _NotificationTile(
                        icon: Icons.live_tv_rounded,
                        title: 'New episode available',
                        subtitle: 'Frieren: Beyond Journey\'s End • Episode 12',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(height: 1),
                      _NotificationTile(
                        icon: Icons.emoji_events_rounded,
                        title: 'Achievement unlocked',
                        subtitle: 'World Traveller',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(height: 1),
                      _NotificationTile(
                        icon: Icons.public_rounded,
                        title: 'Cinema Passport updated',
                        subtitle: 'Japan reached Level 4',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openEditProfile(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) {
          return const _FocusedEditProfilePage();
        },
      ),
    );
  }
}

// =============================================================================
// Home components
// =============================================================================

final class _DailyPickCard extends StatelessWidget {
  const _DailyPickCard({
    required this.media,
    required this.onOpen,
    required this.onAnother,
  });

  final _PreviewMedia media;
  final VoidCallback onOpen;
  final VoidCallback onAnother;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CinearaSurface(
      variant: CinearaSurfaceVariant.prominent,
      padding: const EdgeInsets.all(CinearaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.auto_awesome_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: CinearaSpacing.xs),
              Text(
                'TODAY\'S PICK',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: CinearaSpacing.md),
          Text(
            media.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: CinearaSpacing.xs),
          Text(
            'You often finish Korean crime thrillers, and this is already '
            'on your watchlist.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: CinearaSpacing.lg),
          Wrap(
            spacing: CinearaSpacing.sm,
            runSpacing: CinearaSpacing.sm,
            children: <Widget>[
              FilledButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('View details'),
              ),
              OutlinedButton(
                onPressed: onAnother,
                child: const Text('Choose another'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _HomeStatistics extends StatelessWidget {
  const _HomeStatistics();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Expanded(
          child: _StatisticCard(
            value: '7',
            label: 'Episodes',
            icon: Icons.tv_rounded,
          ),
        ),
        SizedBox(width: CinearaSpacing.sm),
        Expanded(
          child: _StatisticCard(
            value: '3',
            label: 'Movies',
            icon: Icons.movie_rounded,
          ),
        ),
        SizedBox(width: CinearaSpacing.sm),
        Expanded(
          child: _StatisticCard(
            value: '12h',
            label: 'Watched',
            icon: Icons.schedule_rounded,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Discover components
// =============================================================================

final class _DiscoveryBridge extends StatelessWidget {
  const _DiscoveryBridge({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CinearaSurface(
      variant: CinearaSurfaceVariant.elevated,
      padding: const EdgeInsets.all(CinearaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: CinearaSpacing.xs,
            runSpacing: CinearaSpacing.xs,
            children: <Widget>[
              const Chip(
                avatar: Icon(Icons.public_rounded, size: 18),
                label: Text('South Korea'),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const Chip(
                avatar: Icon(Icons.public_rounded, size: 18),
                label: Text('Hong Kong'),
              ),
            ],
          ),
          const SizedBox(height: CinearaSpacing.md),
          Text(
            'Try Hong Kong crime cinema',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: CinearaSpacing.xs),
          Text(
            'Neon noir, moral tension and propulsive urban crime stories.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: CinearaSpacing.md),
          FilledButton.tonalIcon(
            onPressed: onPressed,
            icon: const Icon(Icons.travel_explore_rounded),
            label: const Text('Explore the bridge'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Library components
// =============================================================================

final class _LibrarySummary extends StatelessWidget {
  const _LibrarySummary();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Expanded(
          child: _StatisticCard(
            value: '148',
            label: 'Tracked',
            icon: Icons.video_library_rounded,
          ),
        ),
        SizedBox(width: CinearaSpacing.sm),
        Expanded(
          child: _StatisticCard(
            value: '31',
            label: 'Watchlist',
            icon: Icons.bookmark_rounded,
          ),
        ),
        SizedBox(width: CinearaSpacing.sm),
        Expanded(
          child: _StatisticCard(
            value: '22',
            label: 'Favourites',
            icon: Icons.favorite_rounded,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Profile components
// =============================================================================

final class _ProfileOverview extends StatelessWidget {
  const _ProfileOverview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CinearaSurface(
      variant: CinearaSurfaceVariant.prominent,
      padding: const EdgeInsets.all(CinearaSpacing.lg),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            child: Text(
              'FM',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: CinearaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Federico',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: CinearaSpacing.xxs),
                Text(
                  'Level 27 • World Explorer',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: CinearaSpacing.sm),
                const LinearProgressIndicator(value: .68),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _ProfileStatistics extends StatelessWidget {
  const _ProfileStatistics();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Expanded(
          child: _StatisticCard(
            value: '482',
            label: 'Hours',
            icon: Icons.schedule_rounded,
          ),
        ),
        SizedBox(width: CinearaSpacing.sm),
        Expanded(
          child: _StatisticCard(
            value: '17',
            label: 'Countries',
            icon: Icons.public_rounded,
          ),
        ),
        SizedBox(width: CinearaSpacing.sm),
        Expanded(
          child: _StatisticCard(
            value: '38',
            label: 'Anime',
            icon: Icons.animation_rounded,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Search states
// =============================================================================

final class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: CinearaContentWidths.narrow),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.search_off_rounded,
            size: 52,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: CinearaSpacing.md),
          Text(
            'No results',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: CinearaSpacing.xs),
          Text(
            'We couldn\'t find anything matching “$query”.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: CinearaSpacing.lg),
          FilledButton(onPressed: onClear, child: const Text('Clear search')),
        ],
      ),
    );
  }
}

// =============================================================================
// Media cards
// =============================================================================

final class _PreviewGridMediaCard extends StatelessWidget {
  const _PreviewGridMediaCard({
    required this.media,
    required this.index,
    required this.onTap,
  });

  final _PreviewMedia media;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CinearaGeometry.surfaceRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _PreviewPoster(index: index, title: media.title),
            ),
            const SizedBox(height: CinearaSpacing.xs),
            Text(
              media.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: CinearaSpacing.xxs),
            Text(
              media.metadata,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

final class _PreviewCompactMediaCard extends StatelessWidget {
  const _PreviewCompactMediaCard({
    required this.media,
    required this.index,
    required this.onTap,
  });

  final _PreviewMedia media;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CinearaGeometry.posterRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: _PreviewPoster(index: index, title: media.title),
          ),
          const SizedBox(height: CinearaSpacing.xs),
          Text(
            media.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: CinearaSpacing.xxs),
          Text(
            media.progress ?? media.metadata,
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

final class _PreviewListMediaTile extends StatelessWidget {
  const _PreviewListMediaTile({
    required this.media,
    required this.index,
    required this.onTap,
  });

  final _PreviewMedia media;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CinearaSurface(
      variant: CinearaSurfaceVariant.subtle,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(CinearaSpacing.sm),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 68,
                height: 102,
                child: _PreviewPoster(index: index, title: media.title),
              ),
              const SizedBox(width: CinearaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      media.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: CinearaSpacing.xs),
                    Text(
                      media.metadata,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: CinearaSpacing.sm),
                    Wrap(
                      spacing: CinearaSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        _MetadataLabel(
                          icon: Icons.star_rounded,
                          label: media.rating,
                        ),
                        _MetadataLabel(
                          icon: Icons.check_circle_outline_rounded,
                          label: media.status,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CinearaSpacing.xs),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

final class _PreviewPoster extends StatelessWidget {
  const _PreviewPoster({required this.index, required this.title});

  final int index;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final baseColors = <Color>[
      colors.primaryContainer,
      colors.secondaryContainer,
      colors.tertiaryContainer,
      colors.surfaceContainerHighest,
    ];

    final first = baseColors[index.abs() % baseColors.length];

    final second = Color.alphaBlend(
      colors.primary.withValues(alpha: .16),
      colors.surfaceContainer,
    );

    return Material(
      shape: CinearaShapes.poster(),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: <Color>[first, second],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Center(
              child: Icon(
                Icons.movie_filter_rounded,
                size: 44,
                color: colors.onSurfaceVariant.withValues(alpha: .48),
              ),
            ),
            PositionedDirectional(
              start: CinearaSpacing.xs,
              end: CinearaSpacing.xs,
              bottom: CinearaSpacing.xs,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
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
// Shared small components
// =============================================================================

final class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CinearaSurface(
      variant: CinearaSurfaceVariant.standard,
      padding: const EdgeInsets.all(CinearaSpacing.md),
      child: Column(
        children: <Widget>[
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: CinearaSpacing.xs),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: CinearaSpacing.xxs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

final class _MetadataLabel extends StatelessWidget {
  const _MetadataLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: CinearaSpacing.xxs),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}

// =============================================================================
// Notification preview
// =============================================================================

final class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

// =============================================================================
// Focused centred-content preview
// =============================================================================

final class _FocusedEditProfilePage extends StatelessWidget {
  const _FocusedEditProfilePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: CinearaCenteredContent(
        maxWidth: CinearaContentWidths.narrow,
        child: CinearaSurface(
          variant: CinearaSurfaceVariant.standard,
          padding: const EdgeInsets.all(CinearaSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Profile details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: CinearaSpacing.lg),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Display name',
                  hintText: 'Federico',
                ),
              ),
              const SizedBox(height: CinearaSpacing.md),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell people about your taste in media',
                ),
              ),
              const SizedBox(height: CinearaSpacing.lg),
              FilledButton(onPressed: null, child: Text('Save changes')),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Preview data
// =============================================================================

@immutable
final class _PreviewMedia {
  const _PreviewMedia({
    required this.title,
    required this.metadata,
    required this.rating,
    required this.status,
    this.progress,
  });

  final String title;
  final String metadata;
  final String rating;
  final String status;
  final String? progress;
}
