import 'package:cineara_design_system/cards/episode_card.dart';
import 'package:cineara_design_system/cards/poster_media_card.dart';
import 'package:flutter/material.dart';

/// Development preview for [EpisodeCard].
///
/// This preview is written against the current EpisodeCard API:
///
/// - [EpisodeCardLayout.home]
/// - [EpisodeCardLayout.seasonList]
/// - [EpisodeCardLayout.upNext]
/// - [EpisodeCardLayout.calendar]
///
/// It demonstrates:
///
/// - Up Next on a Series page;
/// - Continue Watching on Home;
/// - New Episodes on Home;
/// - Upcoming Episodes on Home with reminder quick actions;
/// - independent series-title navigation on Home and Calendar cards;
/// - watched / unwatched / updating episode states;
/// - the Season-page "mark previous episodes watched" quality-of-life flow;
/// - Calendar day grouping;
/// - future-episode reminder actions;
/// - released Calendar episodes falling back to the watched action;
/// - watched Calendar episodes remaining in their original day group;
/// - Calendar suppressing the redundant NEW artwork treatment;
/// - upcoming/unavailable episodes;
/// - missing artwork;
/// - specials / Episode 0;
/// - whole-card tap and long-press interaction.
///
/// The preview deliberately owns all mock business/progress logic.
/// [EpisodeCard] remains presentation-only.
class EpisodeCardPreview extends StatefulWidget {
  const EpisodeCardPreview({super.key});

  @override
  State<EpisodeCardPreview> createState() => _EpisodeCardPreviewState();
}

class _EpisodeCardPreviewState extends State<EpisodeCardPreview> {
  static const Duration _mockWriteDelay = Duration(milliseconds: 420);
  static const Duration _confirmationDelay = Duration(milliseconds: 620);

  final Set<String> _watchedEpisodeIds = <String>{
    'season-1-episode-1',
    'season-1-episode-2',
    'calendar-kaiju-12',
  };

  final Set<String> _updatingEpisodeIds = <String>{};

  /// Reminder state is separate from watched state because both Home Upcoming
  /// and Calendar can use a generic [EpisodeCardQuickAction] before release.
  final Set<String> _reminderEpisodeIds = <String>{
    'upcoming-home-pokemon-145',
    'calendar-pokemon-145',
  };

  final Set<String> _updatingReminderIds = <String>{};

  int _upNextIndex = 0;

  final List<int> _continueIndexes = <int>[0, 0, 0];

  final Set<int> _finishedContinueSlots = <int>{};

  static const List<_PreviewEpisode> _upNextEpisodes = <_PreviewEpisode>[
    _PreviewEpisode(
      id: 'up-next-4',
      seriesTitle: 'TASUKETSU -Fate of the Majority-',
      seasonNumber: 1,
      episodeNumber: 4,
      title: 'Transition',
      imageUrl: 'https://picsum.photos/seed/cineara-up-next-4/640/360',
      airDateLabel: '24 Jul 2024',
      runtimeLabel: '24 min',
      isNew: true,
    ),
    _PreviewEpisode(
      id: 'up-next-5',
      seriesTitle: 'TASUKETSU -Fate of the Majority-',
      seasonNumber: 1,
      episodeNumber: 5,
      title: 'Crimson Invitation',
      imageUrl: 'https://picsum.photos/seed/cineara-up-next-5/640/360',
      airDateLabel: '31 Jul 2024',
      runtimeLabel: '24 min',
    ),
    _PreviewEpisode(
      id: 'up-next-6',
      seriesTitle: 'TASUKETSU -Fate of the Majority-',
      seasonNumber: 1,
      episodeNumber: 6,
      title: 'The Choice Ahead',
      imageUrl: 'https://picsum.photos/seed/cineara-up-next-6/640/360',
      airDateLabel: '7 Aug 2024',
      runtimeLabel: '24 min',
    ),
  ];

  /// Each inner list represents one series in Continue Watching.
  ///
  /// There is intentionally no playback percentage: Cineara tracks which
  /// episode should be watched next rather than where playback stopped inside
  /// a video.
  static const List<List<_PreviewEpisode>>
  _continueQueues = <List<_PreviewEpisode>>[
    <_PreviewEpisode>[
      _PreviewEpisode(
        id: 'continue-conan-1156',
        seriesTitle: 'Detective Conan',
        seasonNumber: 1,
        episodeNumber: 1156,
        title:
            'The Ishikawa Mystery that cannot fit in one line and it is not possible to continue',
        imageUrl: 'https://picsum.photos/seed/cineara-conan-1156/640/360',
        runtimeLabel: '24 min',
      ),
      _PreviewEpisode(
        id: 'continue-conan-1157',
        seriesTitle: 'Detective Conan',
        seasonNumber: 1,
        episodeNumber: 1157,
        title: 'A Message in the Rain',
        imageUrl: 'https://picsum.photos/seed/cineara-conan-1157/640/360',
        runtimeLabel: '24 min',
      ),
    ],
    <_PreviewEpisode>[
      _PreviewEpisode(
        id: 'continue-pokemon-59',
        seriesTitle: 'Pokémon Horizons',
        seasonNumber: 1,
        episodeNumber: 59,
        title: 'Dance, Quaxly! Blue Medali Step',
        imageUrl: 'https://picsum.photos/seed/cineara-pokemon-59/640/360',
        runtimeLabel: '24 min',
      ),
      _PreviewEpisode(
        id: 'continue-pokemon-60',
        seriesTitle: 'Pokémon Horizons',
        seasonNumber: 1,
        episodeNumber: 60,
        title: 'The Next Adventure',
        imageUrl: 'https://picsum.photos/seed/cineara-pokemon-60/640/360',
        runtimeLabel: '24 min',
      ),
    ],
    <_PreviewEpisode>[
      _PreviewEpisode(
        id: 'continue-pachinko-3',
        seriesTitle: 'Pachinko',
        seasonNumber: 2,
        episodeNumber: 3,
        title: 'Chapter Eleven',
        imageUrl: 'https://picsum.photos/seed/cineara-pachinko-3/640/360',
        runtimeLabel: '58 min',
      ),
      _PreviewEpisode(
        id: 'continue-pachinko-4',
        seriesTitle: 'Pachinko',
        seasonNumber: 2,
        episodeNumber: 4,
        title: 'Chapter Twelve',
        imageUrl: 'https://picsum.photos/seed/cineara-pachinko-4/640/360',
        runtimeLabel: '61 min',
      ),
    ],
  ];

  static const List<_PreviewEpisode> _newEpisodes = <_PreviewEpisode>[
    _PreviewEpisode(
      id: 'new-rezero',
      seriesTitle: 'Re:ZERO -Starting Life in Another World-',
      seasonNumber: 1,
      episodeNumber: 78,
      title: 'A Name Written in Snow',
      imageUrl: 'https://picsum.photos/seed/cineara-new-rezero/640/360',
      airDateLabel: 'Today',
      runtimeLabel: '25 min',
      isNew: true,
    ),
    _PreviewEpisode(
      id: 'new-link-click',
      seriesTitle: 'LINK CLICK',
      seasonNumber: 4,
      episodeNumber: 1,
      title: 'Return to the Beginning',
      imageUrl: 'https://picsum.photos/seed/cineara-new-link-click/640/360',
      airDateLabel: 'Yesterday',
      runtimeLabel: '28 min',
      isNew: true,
    ),
    _PreviewEpisode(
      id: 'new-kingdom',
      seriesTitle: 'Kingdom',
      seasonNumber: 4,
      episodeNumber: 8,
      title: 'The Gathering Storm',
      imageUrl: 'https://picsum.photos/seed/cineara-new-kingdom/640/360',
      airDateLabel: '2 days ago',
      runtimeLabel: '51 min',
      isNew: true,
    ),
  ];

  /// Future episodes shown in the Home "Upcoming Episodes" carousel.
  ///
  /// These intentionally reuse [EpisodeCardLayout.home]. The generic quick
  /// action supplies the reminder affordance, while the compact Home metadata
  /// becomes `Episode N • release date`.
  static const List<_PreviewEpisode> _upcomingHomeEpisodes = <_PreviewEpisode>[
    _PreviewEpisode(
      id: 'upcoming-home-link-click-1',
      seriesTitle: 'LINK CLICK',
      seasonNumber: 4,
      episodeNumber: 1,
      title: 'Return to the Beginning',
      imageUrl:
          'https://picsum.photos/seed/cineara-home-upcoming-link-click/640/360',
      airDateLabel: 'Fri, 14 Aug',
      isAvailable: false,
    ),
    _PreviewEpisode(
      id: 'upcoming-home-pokemon-145',
      seriesTitle: 'Pokémon Horizons',
      seasonNumber: 1,
      episodeNumber: 145,
      title: 'Shocking! A New Challenge',
      imageUrl:
          'https://picsum.photos/seed/cineara-home-upcoming-pokemon/640/360',
      airDateLabel: 'Fri, 14 Aug',
      isAvailable: false,
    ),
    _PreviewEpisode(
      id: 'upcoming-home-one-piece-1174',
      seriesTitle: 'One Piece',
      seasonNumber: 23,
      episodeNumber: 1174,
      title: 'Save the Future',
      imageUrl:
          'https://picsum.photos/seed/cineara-home-upcoming-one-piece/640/360',
      airDateLabel: 'Sun, 16 Aug',
      isAvailable: false,
    ),
  ];

  static const List<_PreviewEpisode> _seasonEpisodes = <_PreviewEpisode>[
    _PreviewEpisode(
      id: 'season-1-episode-1',
      seasonNumber: 1,
      episodeNumber: 1,
      title: 'Tomorrow',
      imageUrl: 'https://picsum.photos/seed/cineara-season-1/640/360',
      airDateLabel: '3 Jul 2024',
      runtimeLabel: '24 min',
    ),
    _PreviewEpisode(
      id: 'season-1-episode-2',
      seasonNumber: 1,
      episodeNumber: 2,
      title: 'Good Intentions',
      imageUrl: 'https://picsum.photos/seed/cineara-season-2/640/360',
      airDateLabel: '10 Jul 2024',
      runtimeLabel: '24 min',
    ),
    _PreviewEpisode(
      id: 'season-1-episode-3',
      seasonNumber: 1,
      episodeNumber: 3,
      title: 'Motion',
      imageUrl: 'https://picsum.photos/seed/cineara-season-3/640/360',
      airDateLabel: '17 Jul 2024',
      runtimeLabel: '24 min',
    ),
    _PreviewEpisode(
      id: 'season-1-episode-4',
      seasonNumber: 1,
      episodeNumber: 4,
      title: 'Transition',
      imageUrl: 'https://picsum.photos/seed/cineara-season-4/640/360',
      airDateLabel: '24 Jul 2024',
      runtimeLabel: '24 min',
    ),
    _PreviewEpisode(
      id: 'season-1-episode-5',
      seasonNumber: 1,
      episodeNumber: 5,
      title: 'Crimson Invitation',
      imageUrl: 'https://picsum.photos/seed/cineara-season-5/640/360',
      airDateLabel: '31 Jul 2024',
      runtimeLabel: '24 min',
    ),
    _PreviewEpisode(
      id: 'season-1-episode-6',
      seasonNumber: 1,
      episodeNumber: 6,
      title: 'The Choice Ahead',
      imageUrl: 'https://picsum.photos/seed/cineara-season-6/640/360',
      airDateLabel: '7 Aug 2024',
      runtimeLabel: '24 min',
      isNew: true,
    ),
    _PreviewEpisode(
      id: 'season-1-episode-7',
      seasonNumber: 1,
      episodeNumber: 7,
      title: 'After the Vote',
      imageUrl: 'https://picsum.photos/seed/cineara-season-7/640/360',
      airDateLabel: '19 Aug 2026',
      runtimeLabel: '24 min',
      isAvailable: false,
    ),
  ];

  /// Calendar grouping lives outside EpisodeCard. Each card therefore receives
  /// only the episode-specific information it needs.
  static const List<_PreviewCalendarDay> _calendarDays = <_PreviewCalendarDay>[
    _PreviewCalendarDay(
      heading: 'Today',
      dateLabel: '12 Aug',
      episodes: <_PreviewEpisode>[
        _PreviewEpisode(
          id: 'calendar-kaiju-12',
          seriesTitle: 'Kaiju No. 8',
          seasonNumber: 2,
          episodeNumber: 12,
          title: 'The Final Line',
          imageUrl: 'https://picsum.photos/seed/cineara-calendar-kaiju/640/360',
          airTimeLabel: '09:00',
          runtimeLabel: '24 min',
        ),
        _PreviewEpisode(
          id: 'calendar-dandadan-8',
          seriesTitle: 'Dandadan',
          seasonNumber: 2,
          episodeNumber: 8,
          title: 'A Strange Signal',
          imageUrl:
              'https://picsum.photos/seed/cineara-calendar-dandadan/640/360',
          airTimeLabel: '12:30',
          runtimeLabel: '24 min',
          isNew: true,
        ),
        _PreviewEpisode(
          id: 'calendar-rezero-78',
          seriesTitle: 'Re:ZERO -Starting Life in Another World-',
          seasonNumber: 1,
          episodeNumber: 78,
          title: 'A Name Written in Snow',
          imageUrl:
              'https://picsum.photos/seed/cineara-calendar-rezero/640/360',
          airTimeLabel: '15:00',
          isAvailable: false,
        ),
      ],
    ),
    _PreviewCalendarDay(
      heading: 'Fri, 14 Aug',
      episodes: <_PreviewEpisode>[
        _PreviewEpisode(
          id: 'calendar-link-click-1',
          seriesTitle: 'LINK CLICK',
          seasonNumber: 4,
          episodeNumber: 1,
          title: 'Return to the Beginning',
          imageUrl:
              'https://picsum.photos/seed/cineara-calendar-link-click/640/360',
          airTimeLabel: '05:00',
          isAvailable: false,
        ),
        _PreviewEpisode(
          id: 'calendar-pokemon-145',
          seriesTitle: 'Pokémon Horizons',
          seasonNumber: 1,
          episodeNumber: 145,
          title: 'Shocking! A New Challenge',
          imageUrl:
              'https://picsum.photos/seed/cineara-calendar-pokemon/640/360',
          airTimeLabel: '11:55',
          isAvailable: false,
        ),
      ],
    ),
    _PreviewCalendarDay(
      heading: 'Sun, 16 Aug',
      episodes: <_PreviewEpisode>[
        _PreviewEpisode(
          id: 'calendar-one-piece-1174',
          seriesTitle: 'One Piece',
          seasonNumber: 23,
          episodeNumber: 1174,
          title: 'Save the Future',
          imageUrl:
              'https://picsum.photos/seed/cineara-calendar-one-piece/640/360',
          airTimeLabel: '16:15',
          isAvailable: false,
        ),
        _PreviewEpisode(
          id: 'calendar-yamishibai-6',
          seriesTitle: 'Theatre of Darkness: Yamishibai',
          seasonNumber: 17,
          episodeNumber: 6,
          title: 'Episode 6',
          imageUrl:
              'https://picsum.photos/seed/cineara-calendar-yamishibai/640/360',
          airTimeLabel: '19:50',
          isAvailable: false,
        ),
      ],
    ),
  ];

  PosterMediaCardLabels get _posterLabels {
    return PosterMediaCardLabels(
      notStarted: 'Not started',
      watching: 'Watching',
      caughtUp: 'Caught up',
      completed: 'Completed',
      rewatching: 'Rewatching',
      onHold: 'On hold',
      dropped: 'Dropped',
      favourite: 'Favourite',
      watchlist: 'In watchlist',

      userRating: (String rating) {
        return 'Your rating $rating';
      },

      collectionCount: (int count) {
        return count == 1 ? 'In one collection' : 'In $count collections';
      },

      progress: (int percentage) {
        return '$percentage% watched';
      },

      newContent: 'NEW',

      newContentBadge: (PosterNewContentType type, int? count) {
        return switch (type) {
          PosterNewContentType.release => 'NEW',
          PosterNewContentType.episodes =>
            count == 1 ? '1 NEW' : '${count ?? 0} NEW',
        };
      },

      newContentDescription: (PosterNewContentType type, int? count) {
        return switch (type) {
          PosterNewContentType.release => 'Newly available',
          PosterNewContentType.episodes =>
            count == 1
                ? 'One new episode available'
                : '${count ?? 0} new episodes available',
        };
      },

      quickAction:
          (PosterQuickActionType type, bool isActive, String mediaTitle) {
            return switch (type) {
              PosterQuickActionType.watchlist =>
                isActive
                    ? 'Remove $mediaTitle from watchlist'
                    : 'Add $mediaTitle to watchlist',

              PosterQuickActionType.favourite =>
                isActive
                    ? 'Remove $mediaTitle from favourites'
                    : 'Add $mediaTitle to favourites',

              PosterQuickActionType.watched =>
                isActive
                    ? 'Mark $mediaTitle unwatched'
                    : 'Mark $mediaTitle watched',
            };
          },
    );
  }

  /// Exact [EpisodeCardLabels] API currently used by EpisodeCard.
  EpisodeCardLabels get _labels {
    return EpisodeCardLabels(
      poster: _posterLabels,
      episode: 'Episode',

      episodeNumber: (int number) {
        return 'Episode $number';
      },

      seasonNumber: (int number) {
        return 'Season $number';
      },

      newEpisode: 'New episode',
      watched: 'Watched',
      markWatched: 'Mark watched',
      markUnwatched: 'Mark unwatched',
      updating: 'Saving',
      notYetAvailable: 'Not yet available',

      // EpisodeCard still requires this localization callback even though this
      // preview intentionally does not pass playback progress to Continue
      // Watching cards.
      progress: (int percentage) {
        return '$percentage% watched';
      },
    );
  }

  bool _isWatched(String episodeId) {
    return _watchedEpisodeIds.contains(episodeId);
  }

  bool _isUpdating(String episodeId) {
    return _updatingEpisodeIds.contains(episodeId);
  }

  bool _hasReminder(String episodeId) {
    return _reminderEpisodeIds.contains(episodeId);
  }

  bool _isReminderUpdating(String episodeId) {
    return _updatingReminderIds.contains(episodeId);
  }

  Future<void> _toggleReminder(_PreviewEpisode episode) async {
    if (_isReminderUpdating(episode.id)) {
      return;
    }

    final bool shouldEnable = !_hasReminder(episode.id);

    setState(() {
      _updatingReminderIds.add(episode.id);
    });

    await Future<void>.delayed(_mockWriteDelay);

    if (!mounted) {
      return;
    }

    setState(() {
      _updatingReminderIds.remove(episode.id);

      if (shouldEnable) {
        _reminderEpisodeIds.add(episode.id);
      } else {
        _reminderEpisodeIds.remove(episode.id);
      }
    });

    _showMessage(
      shouldEnable
          ? 'Reminder added for ${episode.seriesTitle}'
          : 'Reminder removed for ${episode.seriesTitle}',
    );
  }

  Future<void> _writeWatchedState(
    String episodeId, {
    required bool watched,
  }) async {
    if (_isUpdating(episodeId)) {
      return;
    }

    setState(() {
      _updatingEpisodeIds.add(episodeId);
    });

    await Future<void>.delayed(_mockWriteDelay);

    if (!mounted) {
      return;
    }

    setState(() {
      _updatingEpisodeIds.remove(episodeId);

      if (watched) {
        _watchedEpisodeIds.add(episodeId);
      } else {
        _watchedEpisodeIds.remove(episodeId);
      }
    });
  }

  Future<void> _markUpNextWatched() async {
    if (_upNextIndex >= _upNextEpisodes.length) {
      return;
    }

    final _PreviewEpisode episode = _upNextEpisodes[_upNextIndex];

    await _writeWatchedState(episode.id, watched: true);

    if (!mounted) {
      return;
    }

    // Give EpisodeCard time to show its committed watched-state confirmation
    // before replacing it with the next episode.
    await Future<void>.delayed(_confirmationDelay);

    if (!mounted) {
      return;
    }

    setState(() {
      _upNextIndex++;
    });
  }

  Future<void> _markContinueWatched(int slot) async {
    if (_finishedContinueSlots.contains(slot)) {
      return;
    }

    final List<_PreviewEpisode> queue = _continueQueues[slot];
    final int currentIndex = _continueIndexes[slot];
    final _PreviewEpisode episode = queue[currentIndex];

    await _writeWatchedState(episode.id, watched: true);

    if (!mounted) {
      return;
    }

    await Future<void>.delayed(_confirmationDelay);

    if (!mounted) {
      return;
    }

    setState(() {
      if (currentIndex < queue.length - 1) {
        _continueIndexes[slot] = currentIndex + 1;
      } else {
        _finishedContinueSlots.add(slot);
      }
    });
  }

  Future<void> _markSeasonEpisodeWatched(_PreviewEpisode episode) async {
    await _writeWatchedState(episode.id, watched: true);

    if (!mounted || !_isWatched(episode.id)) {
      return;
    }

    // The selected episode is committed first. The optional catch-up prompt
    // comes afterwards so the primary action never feels blocked.
    await Future<void>.delayed(_confirmationDelay);

    if (!mounted) {
      return;
    }

    final List<_PreviewEpisode> previousUnwatched = _seasonEpisodes
        .where(
          (_PreviewEpisode candidate) =>
              candidate.episodeNumber < episode.episodeNumber &&
              candidate.isAvailable &&
              !_isWatched(candidate.id),
        )
        .toList(growable: false);

    if (previousUnwatched.isEmpty) {
      return;
    }

    final bool markPrevious =
        await _showMarkPreviousEpisodesDialog(
          selectedEpisode: episode,
          previousUnwatched: previousUnwatched,
        ) ??
        false;

    if (!mounted || !markPrevious) {
      return;
    }

    setState(() {
      _watchedEpisodeIds.addAll(
        previousUnwatched.map(
          (_PreviewEpisode previousEpisode) => previousEpisode.id,
        ),
      );
    });

    _showMessage(
      previousUnwatched.length == 1
          ? 'Marked the previous episode watched'
          : 'Marked ${previousUnwatched.length} previous episodes watched',
    );
  }

  Future<bool?> _showMarkPreviousEpisodesDialog({
    required _PreviewEpisode selectedEpisode,
    required List<_PreviewEpisode> previousUnwatched,
  }) {
    final int count = previousUnwatched.length;

    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.done_all_rounded),
          title: const Text('Catch up your progress?'),
          content: Text(
            count == 1
                ? 'You marked Episode ${selectedEpisode.episodeNumber} as '
                      'watched, but one earlier episode is still unwatched. '
                      'Mark it watched too?'
                : 'You marked Episode ${selectedEpisode.episodeNumber} as '
                      'watched, but $count earlier episodes are still '
                      'unwatched. Mark them watched too?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Keep as is'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              icon: const Icon(Icons.done_all_rounded),
              label: Text(
                count == 1 ? 'Mark previous watched' : 'Mark $count watched',
              ),
            ),
          ],
        );
      },
    );
  }

  void _markUnwatched(String episodeId) {
    if (_isUpdating(episodeId)) {
      return;
    }

    _writeWatchedState(episodeId, watched: false);
  }

  void _openEpisode(_PreviewEpisode episode) {
    final String owner = episode.seriesTitle?.trim().isNotEmpty == true
        ? '${episode.seriesTitle} — '
        : '';

    _showMessage('EPISODE: $owner${episode.title}');
  }

  void _openSeries(_PreviewEpisode episode) {
    _showMessage('SERIES: ${episode.seriesTitle ?? 'Unknown series'}');
  }

  String _seriesSemanticLabel(_PreviewEpisode episode) {
    return 'Open ${episode.seriesTitle ?? 'series'}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1100),
        ),
      );
  }

  void _resetPreview() {
    setState(() {
      _watchedEpisodeIds
        ..clear()
        ..addAll(<String>{
          'season-1-episode-1',
          'season-1-episode-2',
          'calendar-kaiju-12',
        });

      _updatingEpisodeIds.clear();

      _reminderEpisodeIds
        ..clear()
        ..addAll(<String>{'upcoming-home-pokemon-145', 'calendar-pokemon-145'});

      _updatingReminderIds.clear();

      _upNextIndex = 0;

      for (int index = 0; index < _continueIndexes.length; index++) {
        _continueIndexes[index] = 0;
      }

      _finishedContinueSlots.clear();
    });

    _showMessage('Preview state reset');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EpisodeCard Preview'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reset preview',
            onPressed: _resetPreview,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20, bottom: 56),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _PreviewSectionHeader(
                title: 'Up Next',
                description:
                    'Series-page layout. Marking the episode watched advances '
                    'to the next available episode.',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildUpNextPreview(),
              ),

              const SizedBox(height: 38),

              const _PreviewSectionHeader(
                title: 'Continue Watching',
                description:
                    'Tap the series name + chevron to open the series; tap the '
                    'rest of the card for the episode. No playback percentage '
                    'or streaming-style progress bar.',
              ),
              _buildContinueWatchingPreview(),

              const SizedBox(height: 38),

              const _PreviewSectionHeader(
                title: 'New Episodes',
                description:
                    'Release-focused Home cards with independent series links. '
                    'The watched action is hidden so NEW remains the primary '
                    'signal.',
              ),
              _buildNewEpisodesPreview(),

              const SizedBox(height: 38),

              const _PreviewSectionHeader(
                title: 'Upcoming Episodes',
                description:
                    'Future releases reuse the Home layout. The series name '
                    'opens the series, the rest of the card opens the episode, '
                    'and the trailing bell toggles a reminder.',
              ),
              _buildUpcomingEpisodesPreview(),

              const SizedBox(height: 38),

              _buildSeasonHeader(),
              _buildSeasonPreview(),

              const SizedBox(height: 38),

              const _PreviewSectionHeader(
                title: 'Calendar',
                description:
                    'The Calendar owns day/date grouping. Series names are '
                    'independent links, future episodes use reminders, released '
                    'episodes use the watched check, and watched rows stay in '
                    'place. NEW is intentionally suppressed here.',
              ),
              _buildCalendarPreview(),

              const SizedBox(height: 38),

              const _PreviewSectionHeader(
                title: 'Interaction States',
                description:
                    'Non-interactive and long-press examples complement the '
                    'nested series-link tests above. Series-link presses should '
                    'not trigger the outer card highlight.',
              ),
              _buildInteractionStatesPreview(),

              const SizedBox(height: 38),

              const _PreviewSectionHeader(
                title: 'Edge Cases',
                description: 'Missing artwork, specials and long titles.',
              ),
              _buildEdgeCasesPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpNextPreview() {
    final bool caughtUp = _upNextIndex >= _upNextEpisodes.length;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final Animation<Offset> slide =
            Tween<Offset>(
              begin: const Offset(0.045, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: caughtUp
          ? _CaughtUpPreview(
              key: const ValueKey<String>('caught-up'),
              onReset: () {
                setState(() {
                  _upNextIndex = 0;
                });
              },
            )
          : _buildCurrentUpNextCard(),
    );
  }

  Widget _buildCurrentUpNextCard() {
    final _PreviewEpisode episode = _upNextEpisodes[_upNextIndex];

    return EpisodeCard(
      key: ValueKey<String>(episode.id),
      layout: EpisodeCardLayout.upNext,
      seasonNumber: episode.seasonNumber,
      episodeNumber: episode.episodeNumber,
      title: episode.title,
      imageUrl: episode.imageUrl,
      airDateLabel: episode.airDateLabel,
      runtimeLabel: episode.runtimeLabel,
      isNew: episode.isNew,
      isWatched: _isWatched(episode.id),
      isWatchedUpdating: _isUpdating(episode.id),
      labels: _labels,
      heroTag: 'up-next-${episode.id}',
      onTap: () {
        _showMessage('Opened ${episode.title}');
      },
      onLongPress: () {
        _showMessage('Episode actions for ${episode.title}');
      },
      onMarkWatched: _markUpNextWatched,
      onMarkUnwatched: () {
        _markUnwatched(episode.id);
      },
    );
  }

  Widget _buildContinueWatchingPreview() {
    final List<int> activeSlots = <int>[
      for (int slot = 0; slot < _continueQueues.length; slot++)
        if (!_finishedContinueSlots.contains(slot)) slot,
    ];

    if (activeSlots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: _InlineEmptyState(
          icon: Icons.done_all_rounded,
          title: 'Nothing left to continue',
          description: 'All Continue Watching preview queues are complete.',
        ),
      );
    }

    return SizedBox(
      height: 320,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: activeSlots.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final int slot = activeSlots[index];
          final List<_PreviewEpisode> queue = _continueQueues[slot];
          final _PreviewEpisode episode = queue[_continueIndexes[slot]];

          return SizedBox(
            width: 276,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: EpisodeCard(
                key: ValueKey<String>(episode.id),
                layout: EpisodeCardLayout.home,
                seriesTitle: episode.seriesTitle,
                seasonNumber: episode.seasonNumber,
                episodeNumber: episode.episodeNumber,
                title: episode.title,
                imageUrl: episode.imageUrl,
                runtimeLabel: episode.runtimeLabel,

                // Deliberately no `progress:` value here. Cineara is a media
                // tracker, not the video playback provider.
                isWatched: _isWatched(episode.id),
                isWatchedUpdating: _isUpdating(episode.id),
                labels: _labels,
                heroTag: 'continue-${episode.id}',
                onTap: () {
                  _openEpisode(episode);
                },
                onSeriesTap: () {
                  _openSeries(episode);
                },
                seriesSemanticLabel: _seriesSemanticLabel(episode),
                onLongPress: () {
                  _showMessage('Actions for ${episode.seriesTitle}');
                },
                onMarkWatched: () {
                  _markContinueWatched(slot);
                },
                onMarkUnwatched: () {
                  _markUnwatched(episode.id);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewEpisodesPreview() {
    return SizedBox(
      height: 292,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _newEpisodes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final _PreviewEpisode episode = _newEpisodes[index];

          return SizedBox(
            width: 276,
            child: EpisodeCard(
              layout: EpisodeCardLayout.home,
              seriesTitle: episode.seriesTitle,
              seasonNumber: episode.seasonNumber,
              episodeNumber: episode.episodeNumber,
              title: episode.title,
              imageUrl: episode.imageUrl,
              airDateLabel: episode.airDateLabel,
              runtimeLabel: episode.runtimeLabel,
              isNew: episode.isNew,
              showWatchedAction: false,
              labels: _labels,
              heroTag: 'new-${episode.id}',
              onTap: () {
                _openEpisode(episode);
              },
              onSeriesTap: () {
                _openSeries(episode);
              },
              seriesSemanticLabel: _seriesSemanticLabel(episode),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingEpisodesPreview() {
    return SizedBox(
      height: 320,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _upcomingHomeEpisodes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final _PreviewEpisode episode = _upcomingHomeEpisodes[index];

          return SizedBox(
            width: 250,
            child: EpisodeCard(
              key: ValueKey<String>('home-upcoming-${episode.id}'),
              layout: EpisodeCardLayout.home,
              seriesTitle: episode.seriesTitle,
              seasonNumber: episode.seasonNumber,
              episodeNumber: episode.episodeNumber,
              title: episode.title,
              imageUrl: episode.imageUrl,
              airDateLabel: episode.airDateLabel,
              isAvailable: false,
              showWatchedAction: false,
              labels: _labels,
              heroTag: 'home-upcoming-${episode.id}',

              // Home Upcoming uses the same generic action contract as
              // Calendar. EpisodeCard itself does not need to understand
              // reminders.
              quickAction: EpisodeCardQuickAction(
                icon: Icons.notifications_none_rounded,
                activeIcon: Icons.notifications_rounded,
                isActive: _hasReminder(episode.id),
                isUpdating: _isReminderUpdating(episode.id),
                semanticLabel:
                    'Add reminder for ${episode.seriesTitle ?? episode.title}',
                activeSemanticLabel:
                    'Remove reminder for ${episode.seriesTitle ?? episode.title}',
                onPressed: () {
                  _toggleReminder(episode);
                },
              ),

              // Two independent navigation targets:
              // - rest of the card -> episode;
              // - series title + chevron -> series.
              onTap: () {
                _openEpisode(episode);
              },
              onSeriesTap: () {
                _openSeries(episode);
              },
              seriesSemanticLabel: _seriesSemanticLabel(episode),
              onLongPress: () {
                _showMessage(
                  'Upcoming episode actions for '
                  '${episode.seriesTitle ?? episode.title}',
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeasonHeader() {
    final ThemeData theme = Theme.of(context);

    final int watchedCount = _seasonEpisodes
        .where(
          (_PreviewEpisode episode) =>
              episode.isAvailable && _isWatched(episode.id),
        )
        .length;

    final int availableCount = _seasonEpisodes
        .where((_PreviewEpisode episode) => episode.isAvailable)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Season 1',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Episodes 1–2 start watched. Mark Episode 6 watched first '
                  'to test the optional previous-episode catch-up flow.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _SeasonProgressPill(
            watchedCount: watchedCount,
            availableCount: availableCount,
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          for (int index = 0; index < _seasonEpisodes.length; index++) ...[
            _buildSeasonEpisode(_seasonEpisodes[index]),
            if (index != _seasonEpisodes.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildSeasonEpisode(_PreviewEpisode episode) {
    return EpisodeCard(
      layout: EpisodeCardLayout.seasonList,
      seasonNumber: episode.seasonNumber,
      episodeNumber: episode.episodeNumber,
      title: episode.title,
      imageUrl: episode.imageUrl,
      airDateLabel: episode.airDateLabel,
      runtimeLabel: episode.runtimeLabel,
      isNew: episode.isNew,
      isWatched: _isWatched(episode.id),
      isAvailable: episode.isAvailable,
      isWatchedUpdating: _isUpdating(episode.id),
      labels: _labels,
      heroTag: 'season-${episode.id}',
      onTap: () {
        _showMessage(
          'Opened Episode ${episode.episodeNumber}: ${episode.title}',
        );
      },
      onLongPress: () {
        _showMessage('Episode ${episode.episodeNumber} actions');
      },
      onMarkWatched: episode.isAvailable
          ? () {
              _markSeasonEpisodeWatched(episode);
            }
          : null,
      onMarkUnwatched: episode.isAvailable
          ? () {
              _markUnwatched(episode.id);
            }
          : null,
    );
  }

  Widget _buildCalendarPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (
            int dayIndex = 0;
            dayIndex < _calendarDays.length;
            dayIndex++
          ) ...<Widget>[
            _CalendarDayHeading(day: _calendarDays[dayIndex]),
            const SizedBox(height: 10),

            for (
              int episodeIndex = 0;
              episodeIndex < _calendarDays[dayIndex].episodes.length;
              episodeIndex++
            ) ...<Widget>[
              _buildCalendarEpisode(
                _calendarDays[dayIndex].episodes[episodeIndex],
              ),

              if (episodeIndex != _calendarDays[dayIndex].episodes.length - 1)
                const SizedBox(height: 8),
            ],

            if (dayIndex != _calendarDays.length - 1)
              const SizedBox(height: 26),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendarEpisode(_PreviewEpisode episode) {
    final bool hasReleased = episode.isAvailable;

    return EpisodeCard(
      key: ValueKey<String>('calendar-${episode.id}'),
      layout: EpisodeCardLayout.calendar,
      seriesTitle: episode.seriesTitle,
      seasonNumber: episode.seasonNumber,
      episodeNumber: episode.episodeNumber,
      title: episode.title,
      imageUrl: episode.imageUrl,
      airTimeLabel: episode.airTimeLabel,
      runtimeLabel: episode.runtimeLabel,
      isNew: episode.isNew,
      isAvailable: episode.isAvailable,
      isWatched: _isWatched(episode.id),
      isWatchedUpdating: _isUpdating(episode.id),
      labels: _labels,
      heroTag: 'calendar-${episode.id}',

      // Before release the Calendar uses a context-specific reminder action.
      // Once released, quickAction is null and EpisodeCard falls back to its
      // normal watched check automatically.
      quickAction: hasReleased
          ? null
          : EpisodeCardQuickAction(
              icon: Icons.notifications_none_rounded,
              activeIcon: Icons.notifications_rounded,
              isActive: _hasReminder(episode.id),
              isUpdating: _isReminderUpdating(episode.id),
              semanticLabel:
                  'Add reminder for ${episode.seriesTitle ?? episode.title}',
              activeSemanticLabel:
                  'Remove reminder for ${episode.seriesTitle ?? episode.title}',
              onPressed: () {
                _toggleReminder(episode);
              },
            ),

      // Calendar deliberately keeps isNew in the mock data for one released
      // item so the preview proves that EpisodeCardLayout.calendar suppresses
      // the redundant NEW badge/tint internally.
      onTap: () {
        _openEpisode(episode);
      },

      onSeriesTap: () {
        _openSeries(episode);
      },
      seriesSemanticLabel: _seriesSemanticLabel(episode),

      onLongPress: () {
        _showMessage(
          'Calendar actions for ${episode.seriesTitle ?? episode.title}',
        );
      },

      // Marking a released Calendar episode watched only changes presentation
      // state. The parent keeps the row in the same day group.
      onMarkWatched: hasReleased
          ? () {
              _writeWatchedState(episode.id, watched: true);
            }
          : null,

      onMarkUnwatched: hasReleased
          ? () {
              _markUnwatched(episode.id);
            }
          : null,
    );
  }

  Widget _buildInteractionStatesPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          EpisodeCard(
            layout: EpisodeCardLayout.upNext,
            seasonNumber: 2,
            episodeNumber: 8,
            title: 'An Upcoming Episode',
            imageUrl:
                'https://picsum.photos/seed/cineara-upcoming-state/640/360',
            airDateLabel: '20 Aug 2026',
            runtimeLabel: '47 min',
            isAvailable: false,
            labels: _labels,
            onTap: () {
              _showMessage('Opened upcoming episode details');
            },
          ),
          const SizedBox(height: 10),
          EpisodeCard(
            layout: EpisodeCardLayout.seasonList,
            seasonNumber: 1,
            episodeNumber: 9,
            title: 'Long-press for episode actions',
            imageUrl: 'https://picsum.photos/seed/cineara-long-press/640/360',
            airDateLabel: '14 Aug 2026',
            runtimeLabel: '44 min',
            labels: _labels,
            onTap: () {
              _showMessage('Normal card tap');
            },
            onLongPress: () {
              _showMessage('Long-press action sheet requested');
            },
            onMarkWatched: () {
              _showMessage('Mark watched requested');
            },
          ),
          const SizedBox(height: 10),

          // No onTap/onLongPress: useful for confirming that the component
          // does not fake card-level interaction when the surrounding screen
          // intentionally wants a passive presentation.
          EpisodeCard(
            layout: EpisodeCardLayout.seasonList,
            seasonNumber: 1,
            episodeNumber: 10,
            title: 'Passive card — watched control only',
            imageUrl: 'https://picsum.photos/seed/cineara-passive-card/640/360',
            airDateLabel: '21 Aug 2026',
            runtimeLabel: '46 min',
            labels: _labels,
            onMarkWatched: () {
              _showMessage('Only the watched action is interactive');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEdgeCasesPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          EpisodeCard(
            layout: EpisodeCardLayout.seasonList,
            episodeNumber: 11,
            title: 'Episode Without Artwork',
            airDateLabel: '28 Aug 2026',
            runtimeLabel: '46 min',
            labels: _labels,
            onTap: () {
              _showMessage('Opened Episode 11');
            },
            onMarkWatched: () {
              _showMessage('Mark watched requested');
            },
          ),
          const SizedBox(height: 10),
          EpisodeCard(
            layout: EpisodeCardLayout.seasonList,
            episodeNumber: 0,
            episodeLabel: 'Special',
            title: 'A Winter Interlude',
            imageUrl: 'https://picsum.photos/seed/cineara-special/640/360',
            runtimeLabel: '32 min',
            labels: _labels,
            onTap: () {
              _showMessage('Opened special episode');
            },
            onMarkWatched: () {
              _showMessage('Mark special watched requested');
            },
          ),
          const SizedBox(height: 10),
          EpisodeCard(
            layout: EpisodeCardLayout.seasonList,
            episodeNumber: 12,
            title:
                'A Very Long Episode Title Designed to Check Ellipsis and '
                'Narrow Phone Behaviour',
            imageUrl: 'https://picsum.photos/seed/cineara-long-title/640/360',
            airDateLabel: '4 Sep 2026',
            runtimeLabel: '54 min',
            labels: _labels,
            onTap: () {
              _showMessage('Opened long-title episode');
            },
            onMarkWatched: () {
              _showMessage('Mark watched requested');
            },
          ),
        ],
      ),
    );
  }
}

/// Lightweight mock episode used only by [EpisodeCardPreview].
@immutable
class _PreviewEpisode {
  const _PreviewEpisode({
    required this.id,
    required this.episodeNumber,
    required this.title,
    this.seriesTitle,
    this.seasonNumber,
    this.imageUrl,
    this.airDateLabel,
    this.airTimeLabel,
    this.runtimeLabel,
    this.isNew = false,
    this.isAvailable = true,
  });

  final String id;
  final String? seriesTitle;
  final int? seasonNumber;
  final int episodeNumber;
  final String title;
  final String? imageUrl;
  final String? airDateLabel;
  final String? airTimeLabel;
  final String? runtimeLabel;
  final bool isNew;
  final bool isAvailable;
}

/// Calendar grouping owned by the preview page rather than by EpisodeCard.
@immutable
class _PreviewCalendarDay {
  const _PreviewCalendarDay({
    required this.heading,
    required this.episodes,
    this.dateLabel,
  });

  final String heading;
  final String? dateLabel;
  final List<_PreviewEpisode> episodes;
}

/// Date heading shown once for a group of Calendar episode cards.
class _CalendarDayHeading extends StatelessWidget {
  const _CalendarDayHeading({required this.day});

  final _PreviewCalendarDay day;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(
          day.heading,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),

        if (day.dateLabel case final String dateLabel
            when dateLabel.trim().isNotEmpty) ...<Widget>[
          const SizedBox(width: 10),
          Text(
            dateLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Consistent heading used to separate preview scenarios.
class _PreviewSectionHeader extends StatelessWidget {
  const _PreviewSectionHeader({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeasonProgressPill extends StatelessWidget {
  const _SeasonProgressPill({
    required this.watchedCount,
    required this.availableCount,
  });

  final int watchedCount;
  final int availableCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$watchedCount / $availableCount',
        style: theme.textTheme.labelMedium?.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CaughtUpPreview extends StatelessWidget {
  const _CaughtUpPreview({required this.onReset, super.key});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.done_all_rounded,
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'You\'re caught up',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Every currently available Up Next preview episode is '
                  'watched.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Replay preview',
            onPressed: onReset,
            icon: const Icon(Icons.replay_rounded),
          ),
        ],
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
