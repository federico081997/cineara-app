import 'package:cineara_design_system/cards/poster_media_card.dart';
import 'package:cineara_design_system/tokens/spacing_tokens.dart';
import 'package:flutter/material.dart';

import '../../app/localization/poster_media_card_localization.dart';
import '../../l10n/app_localizations.dart';

/// Large development-only simulation of the Cineara Home screen.
///
/// The purpose of this screen is not to test every low-level card state in
/// isolation. Instead, it shows how [PosterMediaCard] can be composed into a
/// believable, content-rich Home experience.
///
/// Important presentation rules demonstrated here:
///
/// - Every movie or series keeps its title visible.
/// - Episode cards show the series title, episode number, episode title and date.
/// - Release dates are shown where they are actionable, such as "Coming soon".
/// - Progress-heavy sections prioritise episode/progress information.
/// - World-cinema sections keep Cineara's cultural identity visible.
/// - Context-specific sections suppress redundant status icons where appropriate.
/// - External and personal ratings are both rendered inside poster artwork.
/// - Poster-card copy is supplied through [AppLocalizations] and
///   [PosterMediaCardLabels].
/// - Personal ratings are passive Cineara marks; they do not own a tap action.
/// - Tap and long-press interactions are enabled independently per use case.
/// - Embedded posters can be purely presentational when a parent surface owns input.
/// - Artwork-only cards are wrapped by a title/metadata treatment so the user
///   never has to identify a title from its poster alone.
///
/// All content below is preview data only.
class PosterMediaCardPreviewScreen extends StatefulWidget {
  const PosterMediaCardPreviewScreen({super.key});

  @override
  State<PosterMediaCardPreviewScreen> createState() =>
      _PosterMediaCardPreviewScreenState();
}

class _PosterMediaCardPreviewScreenState
    extends State<PosterMediaCardPreviewScreen> {
  int _selectedNavigationIndex = 0;

  // ---------------------------------------------------------------------------
  // STATUS DOCK ANIMATION TEST
  // ---------------------------------------------------------------------------

  PosterViewingStatus _testViewingStatus = PosterViewingStatus.notStarted;
  PosterQuickActionType _testQuickActionType = PosterQuickActionType.watchlist;

  bool _testShowQuickAction = true;

  bool _testWatchlist = false;
  bool _testFavourite = false;
  int _testCollectionCount = 0;

  bool _testShowUserRating = false;
  bool _testShowStatusDock = true;

  PosterNewContent? _testNewContent;

  // Preview-only personal-state overrides.
  //
  // The catalogue data below stays immutable, while these maps let quick actions
  // behave like real controls. The same title therefore keeps the same preview
  // state when it appears in more than one Home section.
  final Map<String, bool> _watchlistOverrides = <String, bool>{};
  final Map<String, bool> _favouriteOverrides = <String, bool>{};
  final Map<String, PosterViewingStatus> _viewingStatusOverrides =
      <String, PosterViewingStatus>{};

  // ---------------------------------------------------------------------------
  // WORLD IDENTITIES
  // ---------------------------------------------------------------------------
  static const PosterWorldIdentity _jpFilm = PosterWorldIdentity(
    label: 'JP · Film',
    compactLabel: 'JP',
    semanticLabel: 'Japan, Japanese cinema',
  );

  static const PosterWorldIdentity _jpAnime = PosterWorldIdentity(
    label: 'JP · Anime',
    compactLabel: 'JP',
    semanticLabel: 'Japan, Anime',
  );

  static const PosterWorldIdentity _krDrama = PosterWorldIdentity(
    label: 'KR · K-Drama',
    compactLabel: 'KR',
    semanticLabel: 'South Korea, K-Drama',
  );

  static const PosterWorldIdentity _krFilm = PosterWorldIdentity(
    label: 'KR · Film',
    compactLabel: 'KR',
    semanticLabel: 'South Korea, Korean cinema',
  );

  static const PosterWorldIdentity _cnDrama = PosterWorldIdentity(
    label: 'CN · C-Drama',
    compactLabel: 'CN',
    semanticLabel: 'China, C-Drama',
  );

  static const PosterWorldIdentity _cnFilm = PosterWorldIdentity(
    label: 'CN · Film',
    compactLabel: 'CN',
    semanticLabel: 'China, Chinese cinema',
  );

  static const PosterWorldIdentity _hkFilm = PosterWorldIdentity(
    label: 'HK · Film',
    compactLabel: 'HK',
    semanticLabel: 'Hong Kong, Cantonese cinema',
  );

  static const PosterWorldIdentity _inHindi = PosterWorldIdentity(
    label: 'IN · Hindi',
    compactLabel: 'IN',
    semanticLabel: 'India, Hindi cinema',
  );

  static const PosterWorldIdentity _inMalayalam = PosterWorldIdentity(
    label: 'IN · Malayalam',
    compactLabel: 'IN',
    semanticLabel: 'India, Malayalam cinema',
  );

  static const PosterWorldIdentity _inTamil = PosterWorldIdentity(
    label: 'IN · Tamil',
    compactLabel: 'IN',
    semanticLabel: 'India, Tamil cinema',
  );

  static const PosterWorldIdentity _thFilm = PosterWorldIdentity(
    label: 'TH · Film',
    compactLabel: 'TH',
    semanticLabel: 'Thailand, Thai cinema',
  );

  static const PosterWorldIdentity _twDrama = PosterWorldIdentity(
    label: 'TW · Drama',
    compactLabel: 'TW',
    semanticLabel: 'Taiwan, Taiwanese drama',
  );

  static const PosterWorldIdentity _frFilm = PosterWorldIdentity(
    label: 'FR · Film',
    compactLabel: 'FR',
    semanticLabel: 'France, French cinema',
  );

  static const PosterWorldIdentity _itFilm = PosterWorldIdentity(
    label: 'IT · Film',
    compactLabel: 'IT',
    semanticLabel: 'Italy, Italian cinema',
  );

  static const PosterWorldIdentity _usFilm = PosterWorldIdentity(
    label: 'US · Film',
    compactLabel: 'US',
    semanticLabel: 'United States, American cinema',
  );

  static const PosterWorldIdentity _ukFilm = PosterWorldIdentity(
    label: 'UK · Film',
    compactLabel: 'UK',
    semanticLabel: 'United Kingdom, British cinema',
  );

  static const PosterWorldIdentity _irFilm = PosterWorldIdentity(
    label: 'IR · Film',
    compactLabel: 'IR',
    semanticLabel: 'Iran, Iranian cinema',
  );

  // ---------------------------------------------------------------------------
  // CONTINUE WATCHING
  // ---------------------------------------------------------------------------

  static const List<_HomeMedia> _continueWatching = <_HomeMedia>[
    _HomeMedia(
      title: 'Frieren: Beyond Journey',
      subtitle: 'S1 E17 · 62% · 2023',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/home-frieren/500/750',
      worldIdentity: _jpAnime,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.9'),
      userRating: '9.5',
      viewingStatus: PosterViewingStatus.watching,
      progress: 0.62,
      newContent: const PosterNewContent(
        type: PosterNewContentType.episodes,
        count: 2,
      ),
      isFavourite: true,
      isInWatchlist: true,
      collectionCount: 2,
    ),
    _HomeMedia(
      title: 'Reset',
      subtitle: 'S1 E8 · 53% · 2022',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/home-reset/500/750',
      worldIdentity: _cnDrama,
      externalRating: PosterExternalRating(sourceLabel: 'TMDb', value: '8.2'),
      viewingStatus: PosterViewingStatus.watching,
      progress: 0.53,
      newContent: const PosterNewContent(
        type: PosterNewContentType.episodes,
        count: 1,
      ),
      isInWatchlist: true,
      collectionCount: 1,
    ),
    _HomeMedia(
      title: 'Kingdom',
      subtitle: 'S1 E3 · 38% · 2019',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/home-kingdom/500/750',
      worldIdentity: _krDrama,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.3'),
      viewingStatus: PosterViewingStatus.watching,
      progress: 0.38,
      isFavourite: true,
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'Steins;Gate',
      subtitle: 'Rewatch · S1 E8 · 33%',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/home-steins-gate/500/750',
      worldIdentity: _jpAnime,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.8'),
      userRating: '10',
      viewingStatus: PosterViewingStatus.rewatching,
      progress: 0.33,
      isFavourite: true,
      collectionCount: 4,
    ),
    _HomeMedia(
      title: 'Someday',
      subtitle: 'S1 E6 · 46% · 2019',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/home-someday/500/750',
      worldIdentity: _twDrama,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.6'),
      viewingStatus: PosterViewingStatus.watching,
      progress: 0.46,
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'The Long Season',
      subtitle: 'S1 E7 · 58% · 2023',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/home-long-season/500/750',
      worldIdentity: _cnDrama,
      externalRating: PosterExternalRating(sourceLabel: 'TMDb', value: '8.5'),
      viewingStatus: PosterViewingStatus.onHold,
      progress: 0.58,
      newContent: const PosterNewContent(
        type: PosterNewContentType.episodes,
        count: 3,
      ),
      isInWatchlist: true,
    ),
  ];

  // ---------------------------------------------------------------------------
  // NEW EPISODES
  //
  // Episode names here are preview content so that the layout can be evaluated
  // with realistic hierarchy: series -> episode title -> season/episode -> date.
  // ---------------------------------------------------------------------------

  static const List<_EpisodePreview> _newEpisodes = <_EpisodePreview>[
    _EpisodePreview(
      seriesTitle: 'Frieren: Beyond Journey\'s End',
      episodeTitle: 'A Quiet Morning in the Northern Lands',
      seasonEpisode: 'S2 E7',
      releaseLabel: 'Today · 21:00',
      imageUrl: 'https://picsum.photos/seed/episode-frieren-7/500/750',
      worldIdentity: _jpAnime,
      newContent: const PosterNewContent(
        type: PosterNewContentType.episodes,
        count: 1,
      ),
      progress: 0.72,
      isFavourite: true,
    ),
    _EpisodePreview(
      seriesTitle: 'Moving',
      episodeTitle: 'The Distance Between Us',
      seasonEpisode: 'S2 E4',
      releaseLabel: 'Today',
      imageUrl: 'https://picsum.photos/seed/episode-moving-4/500/750',
      worldIdentity: _krDrama,
      newContent: const PosterNewContent(
        type: PosterNewContentType.episodes,
        count: 1,
      ),
      progress: 0.64,
      isFavourite: true,
    ),
    _EpisodePreview(
      seriesTitle: 'The Long Season',
      episodeTitle: 'The River Remembers',
      seasonEpisode: 'S1 E9',
      releaseLabel: 'Yesterday',
      imageUrl: 'https://picsum.photos/seed/episode-long-season-9/500/750',
      worldIdentity: _cnDrama,
      newContent: const PosterNewContent(
        type: PosterNewContentType.episodes,
        count: 3,
      ),
      progress: 0.58,
    ),
    _EpisodePreview(
      seriesTitle: 'Someday',
      episodeTitle: 'The Song on the Cassette',
      seasonEpisode: 'S1 E10',
      releaseLabel: 'Aug 8',
      imageUrl: 'https://picsum.photos/seed/episode-someday-10/500/750',
      worldIdentity: _twDrama,
      newContent: const PosterNewContent(
        type: PosterNewContentType.episodes,
        count: 1,
      ),
      progress: 0.76,
    ),
    _EpisodePreview(
      seriesTitle: 'Kingdom',
      episodeTitle: 'The Gates at Dawn',
      seasonEpisode: 'S3 E2',
      releaseLabel: 'Aug 7',
      imageUrl: 'https://picsum.photos/seed/episode-kingdom-2/500/750',
      worldIdentity: _krDrama,
      newContent: const PosterNewContent(
        type: PosterNewContentType.episodes,
        count: 2,
      ),
      progress: 0.44,
      isFavourite: true,
    ),
  ];

  // ---------------------------------------------------------------------------
  // TRENDING WORLDWIDE
  // ---------------------------------------------------------------------------

  static const List<_HomeMedia> _trendingWorldwide = <_HomeMedia>[
    _HomeMedia(
      title: 'Decision to Leave',
      subtitle: '2022 · South Korea',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/trending-decision/500/750',
      worldIdentity: _krFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.3'),
      newContent: const PosterNewContent(type: PosterNewContentType.release),
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'Monster',
      subtitle: '2023 · Japan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/trending-monster/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.8'),
      newContent: const PosterNewContent(type: PosterNewContentType.release),
      isFavourite: true,
    ),
    _HomeMedia(
      title: 'Past Lives',
      subtitle: '2023 · United States',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/trending-past-lives/500/750',
      worldIdentity: _usFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.8'),
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'Anatomy of a Fall',
      subtitle: '2023 · France',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/trending-anatomy/500/750',
      worldIdentity: _frFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.7'),
    ),
    _HomeMedia(
      title: 'Perfect Days',
      subtitle: '2023 · Japan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/trending-perfect-days/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.9'),
      viewingStatus: PosterViewingStatus.completed,
      userRating: '9.0',
      isFavourite: true,
    ),
    _HomeMedia(
      title: 'The Lunchbox',
      subtitle: '2013 · India',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/trending-lunchbox/500/750',
      worldIdentity: _inHindi,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.8'),
    ),
  ];

  // ---------------------------------------------------------------------------
  // WORLD CINEMA PASSPORT
  // ---------------------------------------------------------------------------

  static const List<_HomeMedia> _worldCinema = <_HomeMedia>[
    _HomeMedia(
      title: 'In the Mood for Love',
      subtitle: '2000 · Hong Kong',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/world-in-the-mood/500/750',
      worldIdentity: _hkFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.1'),
      userRating: '10',
      viewingStatus: PosterViewingStatus.completed,
      isFavourite: true,
      collectionCount: 3,
    ),
    _HomeMedia(
      title: 'A Separation',
      subtitle: '2011 · Iran',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/world-separation/500/750',
      worldIdentity: _irFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.3'),
    ),
    _HomeMedia(
      title: 'Bad Genius',
      subtitle: '2017 · Thailand',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/world-bad-genius/500/750',
      worldIdentity: _thFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.6'),
      userRating: '8.5',
      viewingStatus: PosterViewingStatus.completed,
    ),
    _HomeMedia(
      title: 'Premalu',
      subtitle: '2024 · India',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/world-premalu/500/750',
      worldIdentity: _inMalayalam,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.8'),
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'Yi Yi',
      subtitle: '2000 · Taiwan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/world-yi-yi/500/750',
      worldIdentity: _twDrama,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.1'),
    ),
    _HomeMedia(
      title: 'Cinema Paradiso',
      subtitle: '1988 · Italy',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/world-cinema-paradiso/500/750',
      worldIdentity: _itFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.5'),
    ),
  ];

  // ---------------------------------------------------------------------------
  // BECAUSE YOU WATCHED PERFECT DAYS
  // ---------------------------------------------------------------------------

  static const List<_HomeMedia> _becausePerfectDays = <_HomeMedia>[
    _HomeMedia(
      title: 'Shoplifters',
      subtitle: '2018 · Japan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/because-shoplifters/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.9'),
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'Drive My Car',
      subtitle: '2021 · Japan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/because-drive-my-car/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.5'),
    ),
    _HomeMedia(
      title: 'Still Walking',
      subtitle: '2008 · Japan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/because-still-walking/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.0'),
    ),
    _HomeMedia(
      title: 'Our Little Sister',
      subtitle: '2015 · Japan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/because-little-sister/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.5'),
    ),
    _HomeMedia(
      title: 'Tokyo Story',
      subtitle: '1953 · Japan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/because-tokyo-story/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.1'),
    ),
    _HomeMedia(
      title: 'After Life',
      subtitle: '1998 · Japan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/because-after-life/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.6'),
    ),
  ];

  // ---------------------------------------------------------------------------
  // ANIME
  // ---------------------------------------------------------------------------

  static const List<_HomeMedia> _anime = <_HomeMedia>[
    _HomeMedia(
      title: 'Frieren: Beyond Journey\'s End',
      subtitle: '2023 · Fantasy',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/anime-frieren/500/750',
      worldIdentity: _jpAnime,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.9'),
      viewingStatus: PosterViewingStatus.watching,
      progress: 0.62,
      isFavourite: true,
    ),
    _HomeMedia(
      title: 'Steins;Gate',
      subtitle: '2011 · Sci-Fi',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/anime-steins-gate/500/750',
      worldIdentity: _jpAnime,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.8'),
      viewingStatus: PosterViewingStatus.rewatching,
      progress: 0.33,
      isFavourite: true,
    ),
    _HomeMedia(
      title: 'Violet Evergarden',
      subtitle: '2018 · Drama',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/anime-violet/500/750',
      worldIdentity: _jpAnime,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.4'),
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'March Comes in Like a Lion',
      subtitle: '2016 · Drama',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/anime-march-lion/500/750',
      worldIdentity: _jpAnime,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.3'),
    ),
    _HomeMedia(
      title: 'Ping Pong the Animation',
      subtitle: '2014 · Sports',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/anime-ping-pong/500/750',
      worldIdentity: _jpAnime,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.6'),
    ),
    _HomeMedia(
      title: 'A Silent Voice',
      subtitle: '2016 · Movie',
      mediaTypeLabel: 'Anime Movie',
      imageUrl: 'https://picsum.photos/seed/anime-silent-voice/500/750',
      worldIdentity: _jpAnime,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.1'),
    ),
  ];

  // ---------------------------------------------------------------------------
  // K-DRAMA
  // ---------------------------------------------------------------------------

  static const List<_HomeMedia> _kDrama = <_HomeMedia>[
    _HomeMedia(
      title: 'Moving',
      subtitle: '2023 · Action / Drama',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/kdrama-moving/500/750',
      worldIdentity: _krDrama,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.4'),
      viewingStatus: PosterViewingStatus.caughtUp,
      isFavourite: true,
    ),
    _HomeMedia(
      title: 'My Mister',
      subtitle: '2018 · Drama',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/kdrama-my-mister/500/750',
      worldIdentity: _krDrama,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '9.1'),
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'Signal',
      subtitle: '2016 · Thriller',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/kdrama-signal/500/750',
      worldIdentity: _krDrama,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.5'),
    ),
    _HomeMedia(
      title: 'Kingdom',
      subtitle: '2019 · Historical Thriller',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/kdrama-kingdom/500/750',
      worldIdentity: _krDrama,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.3'),
      viewingStatus: PosterViewingStatus.watching,
      progress: 0.38,
    ),
    _HomeMedia(
      title: 'Twenty-Five Twenty-One',
      subtitle: '2022 · Romance / Drama',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/kdrama-2521/500/750',
      worldIdentity: _krDrama,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.6'),
    ),
    _HomeMedia(
      title: 'Misaeng',
      subtitle: '2014 · Workplace Drama',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/kdrama-misaeng/500/750',
      worldIdentity: _krDrama,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.5'),
    ),
  ];

  // ---------------------------------------------------------------------------
  // C-DRAMA
  // ---------------------------------------------------------------------------

  static const List<_HomeMedia> _cDrama = <_HomeMedia>[
    _HomeMedia(
      title: 'Reset',
      subtitle: '2022 · Thriller / Sci-Fi',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/cdrama-reset/500/750',
      worldIdentity: _cnDrama,
      externalRating: PosterExternalRating(sourceLabel: 'TMDb', value: '8.2'),
      viewingStatus: PosterViewingStatus.watching,
      progress: 0.53,
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'The Long Season',
      subtitle: '2023 · Crime / Drama',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/cdrama-long-season/500/750',
      worldIdentity: _cnDrama,
      externalRating: PosterExternalRating(sourceLabel: 'TMDb', value: '8.5'),
      viewingStatus: PosterViewingStatus.onHold,
      progress: 0.58,
    ),
    _HomeMedia(
      title: 'The Bad Kids',
      subtitle: '2020 · Crime / Mystery',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/cdrama-bad-kids/500/750',
      worldIdentity: _cnDrama,
      externalRating: PosterExternalRating(sourceLabel: 'TMDb', value: '8.2'),
    ),
    _HomeMedia(
      title: 'Nirvana in Fire',
      subtitle: '2015 · Historical Drama',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/cdrama-nirvana-fire/500/750',
      worldIdentity: _cnDrama,
      externalRating: PosterExternalRating(sourceLabel: 'TMDb', value: '8.7'),
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'Meet Yourself',
      subtitle: '2023 · Slice of Life',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/cdrama-meet-yourself/500/750',
      worldIdentity: _cnDrama,
      externalRating: PosterExternalRating(sourceLabel: 'TMDb', value: '8.4'),
    ),
    _HomeMedia(
      title: 'Joy of Life',
      subtitle: '2019 · Historical / Comedy',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/cdrama-joy-life/500/750',
      worldIdentity: _cnDrama,
      externalRating: PosterExternalRating(sourceLabel: 'TMDb', value: '8.1'),
    ),
  ];

  // ---------------------------------------------------------------------------
  // HONG KONG
  // ---------------------------------------------------------------------------

  static const List<_HomeMedia> _hongKong = <_HomeMedia>[
    _HomeMedia(
      title: 'In the Mood for Love',
      subtitle: '2000 · Romance / Drama',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/hk-in-the-mood/500/750',
      worldIdentity: _hkFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.1'),
      userRating: '10',
      viewingStatus: PosterViewingStatus.completed,
      isFavourite: true,
    ),
    _HomeMedia(
      title: 'Infernal Affairs',
      subtitle: '2002 · Crime / Thriller',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/hk-infernal-affairs/500/750',
      worldIdentity: _hkFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.0'),
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'Chungking Express',
      subtitle: '1994 · Romance / Drama',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/hk-chungking/500/750',
      worldIdentity: _hkFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.0'),
    ),
    _HomeMedia(
      title: 'A Better Tomorrow',
      subtitle: '1986 · Action / Crime',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/hk-better-tomorrow/500/750',
      worldIdentity: _hkFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.4'),
    ),
    _HomeMedia(
      title: 'Election',
      subtitle: '2005 · Crime / Drama',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/hk-election/500/750',
      worldIdentity: _hkFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.1'),
    ),
    _HomeMedia(
      title: 'Comrades: Almost a Love Story',
      subtitle: '1996 · Romance / Drama',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/hk-comrades/500/750',
      worldIdentity: _hkFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.1'),
    ),
  ];

  // ---------------------------------------------------------------------------
  // JAPANESE CINEMA
  // ---------------------------------------------------------------------------

  static const List<_HomeMedia> _japaneseCinema = <_HomeMedia>[
    _HomeMedia(
      title: 'Perfect Days',
      subtitle: '2023 · Drama',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/jp-perfect-days/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.9'),
      userRating: '9.0',
      viewingStatus: PosterViewingStatus.completed,
      isFavourite: true,
    ),
    _HomeMedia(
      title: 'Shoplifters',
      subtitle: '2018 · Drama',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/jp-shoplifters/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.9'),
    ),
    _HomeMedia(
      title: 'Drive My Car',
      subtitle: '2021 · Drama',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/jp-drive-my-car/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.5'),
    ),
    _HomeMedia(
      title: 'Cure',
      subtitle: '1997 · Mystery / Thriller',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/jp-cure/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.5'),
    ),
    _HomeMedia(
      title: 'Tokyo Story',
      subtitle: '1953 · Drama',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/jp-tokyo-story/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.1'),
    ),
    _HomeMedia(
      title: 'Tampopo',
      subtitle: '1985 · Comedy',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/jp-tampopo/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.9'),
    ),
  ];

  // ---------------------------------------------------------------------------
  // INDIA
  // ---------------------------------------------------------------------------

  static const List<_HomeMedia> _india = <_HomeMedia>[
    _HomeMedia(
      title: 'Premalu',
      subtitle: '2024 · Malayalam',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/india-premalu/500/750',
      worldIdentity: _inMalayalam,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.8'),
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'The Lunchbox',
      subtitle: '2013 · Hindi',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/india-lunchbox/500/750',
      worldIdentity: _inHindi,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.8'),
    ),
    _HomeMedia(
      title: 'Super Deluxe',
      subtitle: '2019 · Tamil',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/india-super-deluxe/500/750',
      worldIdentity: _inTamil,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.2'),
    ),
    _HomeMedia(
      title: 'Kumbalangi Nights',
      subtitle: '2019 · Malayalam',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/india-kumbalangi/500/750',
      worldIdentity: _inMalayalam,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.5'),
    ),
    _HomeMedia(
      title: 'Andhadhun',
      subtitle: '2018 · Hindi',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/india-andhadhun/500/750',
      worldIdentity: _inHindi,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.2'),
    ),
    _HomeMedia(
      title: '96',
      subtitle: '2018 · Tamil',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/india-96/500/750',
      worldIdentity: _inTamil,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.5'),
    ),
  ];

  // ---------------------------------------------------------------------------
  // HIDDEN GEMS
  // ---------------------------------------------------------------------------

  static const List<_HomeMedia> _hiddenGems = <_HomeMedia>[
    _HomeMedia(
      title: 'A Sun',
      subtitle: '2019 · Taiwan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/gem-a-sun/500/750',
      worldIdentity: _twDrama,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.6'),
    ),
    _HomeMedia(
      title: 'Columbus',
      subtitle: '2017 · United States',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/gem-columbus/500/750',
      worldIdentity: _usFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.2'),
    ),
    _HomeMedia(
      title: 'Microhabitat',
      subtitle: '2017 · South Korea',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/gem-microhabitat/500/750',
      worldIdentity: _krFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.4'),
    ),
    _HomeMedia(
      title: 'The Farewell',
      subtitle: '2019 · United States / China',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/gem-farewell/500/750',
      worldIdentity: _cnFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.5'),
    ),
    _HomeMedia(
      title: 'Happy Old Year',
      subtitle: '2019 · Thailand',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/gem-happy-old-year/500/750',
      worldIdentity: _thFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.2'),
    ),
    _HomeMedia(
      title: 'The Great Passage',
      subtitle: '2013 · Japan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/gem-great-passage/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '7.4'),
    ),
  ];

  // ---------------------------------------------------------------------------
  // TOP RATED
  // ---------------------------------------------------------------------------

  static const List<_HomeMedia> _topRated = <_HomeMedia>[
    _HomeMedia(
      title: 'Seven Samurai',
      subtitle: '1954 · Japan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/top-seven-samurai/500/750',
      worldIdentity: _jpFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.6'),
    ),
    _HomeMedia(
      title: 'Parasite',
      subtitle: '2019 · South Korea',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/top-parasite/500/750',
      worldIdentity: _krFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.5'),
    ),
    _HomeMedia(
      title: 'Cinema Paradiso',
      subtitle: '1988 · Italy',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/top-cinema-paradiso/500/750',
      worldIdentity: _itFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.5'),
    ),
    _HomeMedia(
      title: 'City of God',
      subtitle: '2002 · Brazil',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/top-city-of-god/500/750',
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.6'),
    ),
    _HomeMedia(
      title: 'A Separation',
      subtitle: '2011 · Iran',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/top-separation/500/750',
      worldIdentity: _irFilm,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.3'),
    ),
    _HomeMedia(
      title: 'Yi Yi',
      subtitle: '2000 · Taiwan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/top-yi-yi/500/750',
      worldIdentity: _twDrama,
      externalRating: PosterExternalRating(sourceLabel: 'IMDb', value: '8.1'),
    ),
  ];

  // ---------------------------------------------------------------------------
  // COMING SOON
  // ---------------------------------------------------------------------------

  static const List<_ComingSoonPreview> _comingSoon = <_ComingSoonPreview>[
    _ComingSoonPreview(
      title: 'Midnight Across Seoul',
      releaseDate: 'Aug 14',
      secondary: 'South Korea · Thriller',
      imageUrl: 'https://picsum.photos/seed/coming-seoul/500/750',
      worldIdentity: _krFilm,
    ),
    _ComingSoonPreview(
      title: 'The Last Tram Home',
      releaseDate: 'Aug 21',
      secondary: 'Hong Kong · Drama',
      imageUrl: 'https://picsum.photos/seed/coming-hk/500/750',
      worldIdentity: _hkFilm,
    ),
    _ComingSoonPreview(
      title: 'Summer Above Kyoto',
      releaseDate: 'Sep 3',
      secondary: 'Japan · Drama',
      imageUrl: 'https://picsum.photos/seed/coming-kyoto/500/750',
      worldIdentity: _jpFilm,
    ),
    _ComingSoonPreview(
      title: 'Letters from Kochi',
      releaseDate: 'Sep 11',
      secondary: 'India · Malayalam',
      imageUrl: 'https://picsum.photos/seed/coming-kochi/500/750',
      worldIdentity: _inMalayalam,
    ),
    _ComingSoonPreview(
      title: 'A River in Taipei',
      releaseDate: 'Sep 18',
      secondary: 'Taiwan · Drama',
      imageUrl: 'https://picsum.photos/seed/coming-taipei/500/750',
      worldIdentity: _twDrama,
    ),
  ];

  // ---------------------------------------------------------------------------
  // FAVOURITES / WATCHLIST
  // ---------------------------------------------------------------------------

  static const List<_HomeMedia> _favourites = <_HomeMedia>[
    _HomeMedia(
      title: 'In the Mood for Love',
      subtitle: '2000 · Hong Kong',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/fav-in-the-mood/500/750',
      worldIdentity: _hkFilm,
      userRating: '10',
      viewingStatus: PosterViewingStatus.completed,
      isFavourite: true,
    ),
    _HomeMedia(
      title: 'Perfect Days',
      subtitle: '2023 · Japan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/fav-perfect-days/500/750',
      worldIdentity: _jpFilm,
      userRating: '9.0',
      viewingStatus: PosterViewingStatus.completed,
      isFavourite: true,
    ),
    _HomeMedia(
      title: 'Frieren: Beyond Journey\'s End',
      subtitle: '2023 · Anime',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/fav-frieren/500/750',
      worldIdentity: _jpAnime,
      userRating: '9.5',
      viewingStatus: PosterViewingStatus.watching,
      progress: 0.62,
      isFavourite: true,
    ),
    _HomeMedia(
      title: 'Moving',
      subtitle: '2023 · South Korea',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/fav-moving/500/750',
      worldIdentity: _krDrama,
      viewingStatus: PosterViewingStatus.caughtUp,
      isFavourite: true,
    ),
    _HomeMedia(
      title: 'Steins;Gate',
      subtitle: '2011 · Anime',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/fav-steins-gate/500/750',
      worldIdentity: _jpAnime,
      userRating: '10',
      viewingStatus: PosterViewingStatus.rewatching,
      progress: 0.33,
      isFavourite: true,
    ),
  ];

  static const List<_HomeMedia> _watchlist = <_HomeMedia>[
    _HomeMedia(
      title: 'Premalu',
      subtitle: '2024 · Malayalam',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/watch-premalu/500/750',
      worldIdentity: _inMalayalam,
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'Decision to Leave',
      subtitle: '2022 · South Korea',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/watch-decision/500/750',
      worldIdentity: _krFilm,
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'Past Lives',
      subtitle: '2023 · United States',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/watch-past-lives/500/750',
      worldIdentity: _usFilm,
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'Someday',
      subtitle: '2019 · Taiwan',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/watch-someday/500/750',
      worldIdentity: _twDrama,
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'Drive My Car',
      subtitle: '2021 · Japan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/watch-drive/500/750',
      worldIdentity: _jpFilm,
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'My Mister',
      subtitle: '2018 · South Korea',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/watch-my-mister/500/750',
      worldIdentity: _krDrama,
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'Kumbalangi Nights',
      subtitle: '2019 · Malayalam',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/watch-kumbalangi/500/750',
      worldIdentity: _inMalayalam,
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'A Sun',
      subtitle: '2019 · Taiwan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/watch-a-sun/500/750',
      worldIdentity: _twDrama,
      isInWatchlist: true,
    ),
    _HomeMedia(
      title: 'Cure',
      subtitle: '1997 · Japan',
      mediaTypeLabel: 'Movie',
      imageUrl: 'https://picsum.photos/seed/watch-cure/500/750',
      worldIdentity: _jpFilm,
      isInWatchlist: true,
      userRating: '8.5',
    ),
  ];

  // ---------------------------------------------------------------------------
  // INTERACTION HELPERS
  // ---------------------------------------------------------------------------

  void _showAction(String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 900),
        ),
      );
  }

  bool _effectiveWatchlist(_HomeMedia media) {
    return _watchlistOverrides[media.title] ?? media.isInWatchlist;
  }

  bool _effectiveFavourite(_HomeMedia media) {
    return _favouriteOverrides[media.title] ?? media.isFavourite;
  }

  PosterViewingStatus _effectiveViewingStatus(_HomeMedia media) {
    return _viewingStatusOverrides[media.title] ?? media.viewingStatus;
  }

  bool _quickActionIsActive(_HomeMedia media, PosterQuickActionType type) {
    return switch (type) {
      PosterQuickActionType.watchlist => _effectiveWatchlist(media),
      PosterQuickActionType.favourite => _effectiveFavourite(media),
      PosterQuickActionType.watched =>
        _effectiveViewingStatus(media) == PosterViewingStatus.completed,
    };
  }

  void _handleMediaQuickAction(_HomeMedia media, PosterQuickActionType type) {
    setState(() {
      switch (type) {
        case PosterQuickActionType.watchlist:
          final bool nextValue = !_effectiveWatchlist(media);
          _watchlistOverrides[media.title] = nextValue;
          break;

        case PosterQuickActionType.favourite:
          final bool nextValue = !_effectiveFavourite(media);
          _favouriteOverrides[media.title] = nextValue;
          break;

        case PosterQuickActionType.watched:
          final PosterViewingStatus current = _effectiveViewingStatus(media);

          if (current == PosterViewingStatus.completed) {
            _viewingStatusOverrides[media.title] =
                media.viewingStatus == PosterViewingStatus.completed
                ? PosterViewingStatus.notStarted
                : media.viewingStatus;
          } else {
            _viewingStatusOverrides[media.title] =
                PosterViewingStatus.completed;
          }
          break;
      }
    });
  }

  bool get _testQuickActionIsActive {
    return switch (_testQuickActionType) {
      PosterQuickActionType.watchlist => _testWatchlist,
      PosterQuickActionType.favourite => _testFavourite,
      PosterQuickActionType.watched =>
        _testViewingStatus == PosterViewingStatus.completed,
    };
  }

  void _handleTestQuickAction() {
    setState(() {
      switch (_testQuickActionType) {
        case PosterQuickActionType.watchlist:
          _testWatchlist = !_testWatchlist;
          if (_testWatchlist) {
            _testShowStatusDock = true;
          }
          break;

        case PosterQuickActionType.favourite:
          _testFavourite = !_testFavourite;
          if (_testFavourite) {
            _testShowStatusDock = true;
          }
          break;

        case PosterQuickActionType.watched:
          final bool isCompleted =
              _testViewingStatus == PosterViewingStatus.completed;
          _testViewingStatus = isCompleted
              ? PosterViewingStatus.notStarted
              : PosterViewingStatus.completed;
          if (!isCompleted) {
            _testShowStatusDock = true;
          }
          break;
      }
    });
  }

  PosterMediaCard _card(
    _HomeMedia media, {
    PosterMediaCardLayout layout = PosterMediaCardLayout.artworkWithInformation,
    PosterStatusContext statusContext = PosterStatusContext.none,
    PosterQuickActionType? quickActionType,
    bool? quickActionActive,
    VoidCallback? onQuickActionPressed,
    bool showWorldIdentity = true,
    bool showExternalRating = true,

    // Personal ratings are passive poster overlays in the current card design.
    bool showUserRating = true,
    bool showStatusDock = true,
    bool showNewContent = true,
    bool enableTap = true,
    bool enableLongPress = true,
    int maxTitleLines = 2,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final PosterMediaCardLabels posterLabels = l10n.posterMediaCardLabels;

    final bool effectiveFavourite = _effectiveFavourite(media);
    final bool effectiveWatchlist = _effectiveWatchlist(media);
    final PosterViewingStatus effectiveViewingStatus = _effectiveViewingStatus(
      media,
    );

    final bool resolvedQuickActionActive = switch (quickActionType) {
      null => false,
      final PosterQuickActionType type =>
        quickActionActive ?? _quickActionIsActive(media, type),
    };

    return PosterMediaCard(
      title: media.title,
      subtitle: media.subtitle,
      mediaTypeLabel: media.mediaTypeLabel,
      labels: posterLabels,
      imageUrl: media.imageUrl,
      aspectRatio: media.aspectRatio,
      worldIdentity: media.worldIdentity,
      externalRating: media.externalRating,
      userRating: media.userRating,
      statusContext: statusContext,
      viewingStatus: effectiveViewingStatus,
      isFavourite: effectiveFavourite,
      isInWatchlist: effectiveWatchlist,
      collectionCount: media.collectionCount,
      progress: media.progress,
      newContent: media.newContent,
      layout: layout,
      maxTitleLines: maxTitleLines,
      showWorldIdentity: showWorldIdentity,
      showExternalRating: showExternalRating,
      showUserRating: showUserRating,
      showStatusDock: showStatusDock,
      showNewContent: showNewContent,
      quickAction: quickActionType == null
          ? null
          : PosterQuickAction(
              type: quickActionType,
              isActive: resolvedQuickActionActive,
              onPressed:
                  onQuickActionPressed ??
                  () => _handleMediaQuickAction(media, quickActionType),
            ),

      // Tap and long press remain independent so the preview can exercise
      // interactive and purely presentational card configurations.
      onTap: enableTap ? () => _showAction('Open ${media.title}') : null,
      onLongPress: enableLongPress
          ? () => _showAction('Actions for ${media.title}')
          : null,
    );
  }

  Widget _labeledArtworkCard(
    _HomeMedia media, {
    PosterStatusContext statusContext = PosterStatusContext.none,
    PosterQuickActionType? quickActionType,
    bool? quickActionActive,
    bool showExternalRating = false,
    bool showUserRating = true,
    bool showStatusDock = true,
    bool showNewContent = true,
    double width = 138,
  }) {
    return _LabeledPosterCard(
      width: width,
      title: media.title,
      metadata: media.subtitle,
      child: _card(
        media,
        layout: PosterMediaCardLayout.artworkOnly,
        statusContext: statusContext,
        quickActionType: quickActionType,
        quickActionActive: quickActionActive,
        showExternalRating: showExternalRating,
        showUserRating: showUserRating,
        showStatusDock: showStatusDock,
        showNewContent: showNewContent,
      ),
    );
  }

  /// Media used to interactively test status-dock transitions.
  _HomeMedia get _statusDockTestMedia {
    return _HomeMedia(
      title: 'Status Dock Test',
      subtitle: 'Interactive animation preview',
      mediaTypeLabel: 'TV Series',
      imageUrl: 'https://picsum.photos/seed/status-dock-test/500/750',
      worldIdentity: _jpAnime,
      externalRating: const PosterExternalRating(
        sourceLabel: 'IMDb',
        value: '8.9',
      ),
      userRating: '9.5',
      viewingStatus: _testViewingStatus,
      isInWatchlist: _testWatchlist,
      isFavourite: _testFavourite,
      collectionCount: _testCollectionCount,
      newContent: _testNewContent,
      aspectRatio: 16 / 9,
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                CinearaSpacing.md,
                CinearaSpacing.sm,
                CinearaSpacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _HomeTopBar(
                  onSearch: () => _showAction('Open search'),
                  onNotifications: () => _showAction('Open notifications'),
                  onProfile: () => _showAction('Open profile'),
                ),
              ),
            ),

            // ---------------------------------------------------------------------------
            // STATUS DOCK ANIMATION TEST
            // ---------------------------------------------------------------------------
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                CinearaSpacing.md,
                CinearaSpacing.xl,
                CinearaSpacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Poster overlay and status test',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: CinearaSpacing.xs),

                    Text(
                      'Toggle personal states, quick actions and NEW-content variants.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: CinearaSpacing.md),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 200,
                        child: _card(
                          _statusDockTestMedia,
                          showExternalRating: true,
                          showUserRating: _testShowUserRating,
                          showStatusDock: _testShowStatusDock,
                          showNewContent: true,
                          quickActionType: _testShowQuickAction
                              ? _testQuickActionType
                              : null,
                          quickActionActive: _testQuickActionIsActive,
                          onQuickActionPressed: _handleTestQuickAction,
                          enableTap: false,
                          enableLongPress: false,
                        ),
                      ),
                    ),

                    const SizedBox(height: CinearaSpacing.md),

                    Wrap(
                      spacing: CinearaSpacing.xs,
                      runSpacing: CinearaSpacing.xs,
                      children: <Widget>[
                        // -----------------------------------------------------------------
                        // OVERLAY VISIBILITY
                        // -----------------------------------------------------------------
                        FilterChip(
                          avatar: const Icon(Icons.star_rounded, size: 16),
                          label: const Text('User rating'),
                          selected: _testShowUserRating,
                          onSelected: (bool selected) {
                            setState(() {
                              _testShowUserRating = selected;
                            });
                          },
                        ),

                        FilterChip(
                          label: const Text('Status dock'),
                          selected: _testShowStatusDock,
                          onSelected: (bool selected) {
                            setState(() {
                              _testShowStatusDock = selected;
                            });
                          },
                        ),

                        // -----------------------------------------------------------------
                        // NEW CONTENT
                        // -----------------------------------------------------------------
                        FilterChip(
                          label: const Text('New release'),
                          selected:
                              _testNewContent?.type ==
                              PosterNewContentType.release,
                          onSelected: (bool selected) {
                            setState(() {
                              _testNewContent = selected
                                  ? const PosterNewContent(
                                      type: PosterNewContentType.release,
                                    )
                                  : null;
                            });
                          },
                        ),

                        FilterChip(
                          label: const Text('2 new episodes'),
                          selected:
                              _testNewContent?.type ==
                              PosterNewContentType.episodes,
                          onSelected: (bool selected) {
                            setState(() {
                              _testNewContent = selected
                                  ? const PosterNewContent(
                                      type: PosterNewContentType.episodes,
                                      count: 2,
                                    )
                                  : null;

                              if (selected &&
                                  _testViewingStatus ==
                                      PosterViewingStatus.notStarted) {
                                _testViewingStatus =
                                    PosterViewingStatus.watching;
                              }
                            });
                          },
                        ),

                        // -----------------------------------------------------------------
                        // WATCHLIST
                        // -----------------------------------------------------------------
                        FilterChip(
                          label: const Text('Watchlist'),
                          selected: _testWatchlist,
                          onSelected: (bool selected) {
                            setState(() {
                              _testWatchlist = selected;

                              if (selected) {
                                _testShowStatusDock = true;
                              }
                            });
                          },
                        ),

                        // -----------------------------------------------------------------
                        // FAVOURITE
                        // -----------------------------------------------------------------
                        FilterChip(
                          label: const Text('Favourite'),
                          selected: _testFavourite,
                          onSelected: (bool selected) {
                            setState(() {
                              _testFavourite = selected;

                              if (selected) {
                                _testShowStatusDock = true;
                              }
                            });
                          },
                        ),

                        // -----------------------------------------------------------------
                        // COLLECTION
                        // -----------------------------------------------------------------
                        FilterChip(
                          label: const Text('Collection'),
                          selected: _testCollectionCount > 0,
                          onSelected: (bool selected) {
                            setState(() {
                              _testCollectionCount = selected ? 1 : 0;

                              if (selected) {
                                _testShowStatusDock = true;
                              }
                            });
                          },
                        ),

                        // -----------------------------------------------------------------
                        // VIEWING STATUS
                        // -----------------------------------------------------------------
                        FilterChip(
                          label: const Text('Watching'),
                          selected:
                              _testViewingStatus ==
                              PosterViewingStatus.watching,
                          onSelected: (bool selected) {
                            setState(() {
                              _testViewingStatus = selected
                                  ? PosterViewingStatus.watching
                                  : PosterViewingStatus.notStarted;

                              if (selected) {
                                _testShowStatusDock = true;
                              }
                            });
                          },
                        ),

                        FilterChip(
                          label: const Text('Completed'),
                          selected:
                              _testViewingStatus ==
                              PosterViewingStatus.completed,
                          onSelected: (bool selected) {
                            setState(() {
                              _testViewingStatus = selected
                                  ? PosterViewingStatus.completed
                                  : PosterViewingStatus.notStarted;

                              if (selected) {
                                _testShowStatusDock = true;
                              }
                            });
                          },
                        ),

                        FilterChip(
                          label: const Text('On hold'),
                          selected:
                              _testViewingStatus == PosterViewingStatus.onHold,
                          onSelected: (bool selected) {
                            setState(() {
                              _testViewingStatus = selected
                                  ? PosterViewingStatus.onHold
                                  : PosterViewingStatus.notStarted;

                              if (selected) {
                                _testShowStatusDock = true;
                              }
                            });
                          },
                        ),

                        FilterChip(
                          label: const Text('Rewatching'),
                          selected:
                              _testViewingStatus ==
                              PosterViewingStatus.rewatching,
                          onSelected: (bool selected) {
                            setState(() {
                              _testViewingStatus = selected
                                  ? PosterViewingStatus.rewatching
                                  : PosterViewingStatus.notStarted;

                              if (selected) {
                                _testShowStatusDock = true;
                              }
                            });
                          },
                        ),

                        FilterChip(
                          label: const Text('Dropped'),
                          selected:
                              _testViewingStatus == PosterViewingStatus.dropped,
                          onSelected: (bool selected) {
                            setState(() {
                              _testViewingStatus = selected
                                  ? PosterViewingStatus.dropped
                                  : PosterViewingStatus.notStarted;

                              if (selected) {
                                _testShowStatusDock = true;
                              }
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Watchlist action'),
                          selected:
                              _testQuickActionType ==
                              PosterQuickActionType.watchlist,
                          onSelected: (bool selected) {
                            if (!selected) return;

                            setState(() {
                              _testQuickActionType =
                                  PosterQuickActionType.watchlist;
                              _testShowQuickAction = true;
                            });
                          },
                        ),

                        ChoiceChip(
                          label: const Text('Favourite action'),
                          selected:
                              _testQuickActionType ==
                              PosterQuickActionType.favourite,
                          onSelected: (bool selected) {
                            if (!selected) return;

                            setState(() {
                              _testQuickActionType =
                                  PosterQuickActionType.favourite;
                              _testShowQuickAction = true;
                            });
                          },
                        ),

                        ChoiceChip(
                          label: const Text('Watched action'),
                          selected:
                              _testQuickActionType ==
                              PosterQuickActionType.watched,
                          onSelected: (bool selected) {
                            if (!selected) return;

                            setState(() {
                              _testQuickActionType =
                                  PosterQuickActionType.watched;
                              _testShowQuickAction = true;
                            });
                          },
                        ),

                        FilterChip(
                          label: const Text('Show quick action'),
                          selected: _testShowQuickAction,
                          onSelected: (bool selected) {
                            setState(() {
                              _testShowQuickAction = selected;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: CinearaSpacing.sm),

                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _testViewingStatus = PosterViewingStatus.watching;

                          _testWatchlist = false;
                          _testFavourite = false;
                          _testCollectionCount = 0;
                          _testNewContent = null;

                          _testShowUserRating = false;
                          _testShowStatusDock = true;
                        });
                      },
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                CinearaSpacing.md,
                CinearaSpacing.xl,
                CinearaSpacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(child: _Greeting(theme: theme)),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                CinearaSpacing.md,
                CinearaSpacing.xl,
                CinearaSpacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _FeaturedHomeCard(
                  poster: _card(
                    _worldCinema.first,
                    layout: PosterMediaCardLayout.artworkOnly,
                    showExternalRating: true,
                    showStatusDock: true,
                    quickActionType: PosterQuickActionType.favourite,
                    enableLongPress: false,
                  ),
                  eyebrow: 'TONIGHT\'S CINEARA PICK',
                  title: 'In the Mood for Love',
                  description:
                      'A visually rich Hong Kong classic for a slower evening.',
                  metadata: '2000 · 1h 38m · Hong Kong · Cantonese',
                  onOpen: () => _showAction('Open In the Mood for Love'),
                  onAdd: () => _showAction('Add Tonight\'s Pick to Watchlist'),
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // CONTINUE WATCHING
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'Continue watching',
                subtitle: 'Pick up exactly where you left off',
                onSeeAll: () => _showAction('Open Continue Watching'),
                child: _PosterRail(
                  height: 304,
                  itemCount: _continueWatching.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _HomeMedia media = _continueWatching[index];

                    return SizedBox(
                      width: 156,
                      child: _card(
                        media,
                        statusContext: PosterStatusContext.viewingStatus,
                        quickActionType: PosterQuickActionType.favourite,
                      ),
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // NEW EPISODES
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'New episodes',
                subtitle:
                    'Series title, episode name, episode number and date all stay visible',
                onSeeAll: () => _showAction('Open New Episodes'),
                child: _PosterRail(
                  height: 236,
                  itemCount: _newEpisodes.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _EpisodePreview episode = _newEpisodes[index];

                    return _EpisodeHomeCard(
                      episode: episode,
                      onTap: () => _showAction(
                        'Open ${episode.seriesTitle} · ${episode.episodeTitle}',
                      ),
                      onLongPress: () => _showAction(
                        'Episode actions: ${episode.seriesTitle}',
                      ),
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // TRENDING
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'Trending around the world',
                subtitle: 'Popular now across different film cultures',
                onSeeAll: () => _showAction('Open Trending'),
                child: _PosterRail(
                  height: 308,
                  itemCount: _trendingWorldwide.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _HomeMedia media = _trendingWorldwide[index];

                    return SizedBox(
                      width: 158,
                      child: _card(
                        media,
                        quickActionType: PosterQuickActionType.watchlist,
                      ),
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // WORLD CINEMA
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _WorldCinemaSection(
                onExplore: () => _showAction('Open World Cinema'),
                child: _PosterRail(
                  height: 276,
                  itemCount: _worldCinema.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _HomeMedia media = _worldCinema[index];

                    return _labeledArtworkCard(
                      media,
                      width: 138,
                      showStatusDock: false,
                      quickActionType: PosterQuickActionType.watchlist,
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // BECAUSE YOU WATCHED
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'Because you watched Perfect Days',
                subtitle:
                    'Quiet, human stories with a similar emotional rhythm',
                onSeeAll: () => _showAction('Open recommendations'),
                child: _PosterRail(
                  height: 304,
                  itemCount: _becausePerfectDays.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _HomeMedia media = _becausePerfectDays[index];

                    return SizedBox(
                      width: 156,
                      child: _card(
                        media,
                        showStatusDock: false,
                        showUserRating: false,
                        quickActionType: PosterQuickActionType.watchlist,
                      ),
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // ANIME
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'Anime spotlight',
                subtitle: 'Series and films worth your time',
                onSeeAll: () => _showAction('Open Anime'),
                child: _PosterRail(
                  height: 276,
                  itemCount: _anime.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _HomeMedia media = _anime[index];

                    return _labeledArtworkCard(
                      media,
                      width: 138,
                      quickActionType: PosterQuickActionType.watchlist,
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // K-DRAMA
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'K-Drama tonight',
                subtitle:
                    'From quiet character dramas to high-stakes thrillers',
                onSeeAll: () => _showAction('Open K-Dramas'),
                child: _PosterRail(
                  height: 304,
                  itemCount: _kDrama.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _HomeMedia media = _kDrama[index];

                    return SizedBox(
                      width: 156,
                      child: _card(
                        media,
                        quickActionType: PosterQuickActionType.watchlist,
                      ),
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // C-DRAMA
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'C-Drama discovery',
                subtitle:
                    'Crime, romance, history and slice-of-life from China',
                onSeeAll: () => _showAction('Open C-Dramas'),
                child: _PosterRail(
                  height: 276,
                  itemCount: _cDrama.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _HomeMedia media = _cDrama[index];

                    return _labeledArtworkCard(
                      media,
                      width: 138,
                      quickActionType: PosterQuickActionType.watchlist,
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // HONG KONG
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'Hong Kong cinema',
                subtitle: 'Crime, romance and unmistakable city energy',
                onSeeAll: () => _showAction('Open Hong Kong Cinema'),
                child: _PosterRail(
                  height: 304,
                  itemCount: _hongKong.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _HomeMedia media = _hongKong[index];

                    return SizedBox(
                      width: 156,
                      child: _card(
                        media,
                        quickActionType: PosterQuickActionType.watchlist,
                      ),
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // JAPAN BEYOND ANIME
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'Japan beyond anime',
                subtitle: 'Contemporary favourites and essential classics',
                onSeeAll: () => _showAction('Open Japanese Cinema'),
                child: _PosterRail(
                  height: 276,
                  itemCount: _japaneseCinema.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _HomeMedia media = _japaneseCinema[index];

                    return _labeledArtworkCard(
                      media,
                      width: 138,
                      quickActionType: PosterQuickActionType.watchlist,
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // INDIA
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'India across languages',
                subtitle: 'Hindi, Malayalam, Tamil and more in one place',
                onSeeAll: () => _showAction('Open Indian Cinema'),
                child: _PosterRail(
                  height: 304,
                  itemCount: _india.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _HomeMedia media = _india[index];

                    return SizedBox(
                      width: 156,
                      child: _card(
                        media,
                        quickActionType: PosterQuickActionType.watchlist,
                      ),
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // HIDDEN GEMS
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'Hidden gems',
                subtitle: 'Strong films that deserve a much larger audience',
                onSeeAll: () => _showAction('Open Hidden Gems'),
                child: _PosterRail(
                  height: 276,
                  itemCount: _hiddenGems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _HomeMedia media = _hiddenGems[index];

                    return _labeledArtworkCard(
                      media,
                      width: 138,
                      quickActionType: PosterQuickActionType.watchlist,
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // TOP RATED
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'Top rated across Cineara',
                subtitle: 'Highly rated films from several countries and eras',
                onSeeAll: () => _showAction('Open Top Rated'),
                child: _PosterRail(
                  height: 304,
                  itemCount: _topRated.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _HomeMedia media = _topRated[index];

                    return SizedBox(
                      width: 156,
                      child: _card(
                        media,
                        showStatusDock: false,
                        quickActionType: PosterQuickActionType.watchlist,
                      ),
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // COMING SOON
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'Coming soon',
                subtitle:
                    'Release dates are prominent because timing matters here',
                onSeeAll: () => _showAction('Open Release Calendar'),
                child: _PosterRail(
                  height: 304,
                  itemCount: _comingSoon.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _ComingSoonPreview item = _comingSoon[index];

                    return _ComingSoonCard(
                      item: item,
                      onTap: () => _showAction('Open ${item.title}'),
                      onRemind: () => _showAction(
                        'Set reminder for ${item.title} · ${item.releaseDate}',
                      ),
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // FAVOURITES
            // -----------------------------------------------------------------
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'Your favourites',
                subtitle: 'Titles you marked as special',
                onSeeAll: () => _showAction('Open Favourites'),
                child: _PosterRail(
                  height: 276,
                  itemCount: _favourites.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _HomeMedia media = _favourites[index];

                    return _labeledArtworkCard(
                      media,
                      width: 138,
                      statusContext: PosterStatusContext.favourite,
                      quickActionType: PosterQuickActionType.favourite,
                    );
                  },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // WATCHLIST GRID
            // -----------------------------------------------------------------
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                CinearaSpacing.md,
                CinearaSpacing.xxl,
                CinearaSpacing.md,
                CinearaSpacing.xxl,
              ),
              sliver: SliverToBoxAdapter(
                child: _WatchlistGrid(
                  media: _watchlist,
                  cardBuilder: (_HomeMedia media) {
                    return _LabeledPosterCard(
                      title: media.title,
                      metadata: media.subtitle,
                      child: _card(
                        media,
                        layout: PosterMediaCardLayout.artworkOnly,
                        statusContext: PosterStatusContext.watchlist,
                        showExternalRating: false,
                        showUserRating: true,
                        showStatusDock: false,
                        quickActionType: PosterQuickActionType.watchlist,
                      ),
                    );
                  },
                  onSeeAll: () => _showAction('Open Watchlist'),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavigationIndex,
        onDestinationSelected: (int index) {
          if (index == 0) {
            setState(() {
              _selectedNavigationIndex = 0;
            });
            return;
          }

          _showAction(switch (index) {
            1 => 'Open Discover',
            2 => 'Open Library',
            3 => 'Open Profile',
            _ => 'Open Home',
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library_rounded),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HOME CHROME
// =============================================================================

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({
    required this.onSearch,
    required this.onNotifications,
    required this.onProfile,
  });

  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Cineara',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Search',
          onPressed: onSearch,
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: onNotifications,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        IconButton(
          tooltip: 'Profile',
          onPressed: onProfile,
          icon: const Icon(Icons.account_circle_outlined),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Good evening',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: CinearaSpacing.xs),
        Text(
          'Continue something familiar, or travel somewhere new through cinema.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// FEATURED HOME CARD
// =============================================================================

class _FeaturedHomeCard extends StatelessWidget {
  const _FeaturedHomeCard({
    required this.poster,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.metadata,
    required this.onOpen,
    required this.onAdd,
  });

  final Widget poster;
  final String eyebrow;
  final String title;
  final String description;
  final String metadata;
  final VoidCallback onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CinearaSpacing.md),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact = constraints.maxWidth < 520;

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 150, child: poster),
                  const SizedBox(height: CinearaSpacing.lg),
                  _FeaturedText(
                    eyebrow: eyebrow,
                    title: title,
                    description: description,
                    metadata: metadata,
                    onOpen: onOpen,
                    onAdd: onAdd,
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 170, child: poster),
                const SizedBox(width: CinearaSpacing.xl),
                Expanded(
                  child: _FeaturedText(
                    eyebrow: eyebrow,
                    title: title,
                    description: description,
                    metadata: metadata,
                    onOpen: onOpen,
                    onAdd: onAdd,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FeaturedText extends StatelessWidget {
  const _FeaturedText({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.metadata,
    required this.onOpen,
    required this.onAdd,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String metadata;
  final VoidCallback onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          eyebrow,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: CinearaSpacing.xs),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: CinearaSpacing.xs),
        Text(
          metadata,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: CinearaSpacing.sm),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
        ),
        const SizedBox(height: CinearaSpacing.md),
        Wrap(
          spacing: CinearaSpacing.sm,
          runSpacing: CinearaSpacing.xs,
          children: <Widget>[
            FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('View title'),
            ),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('Watchlist'),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// GENERIC HOME SECTION
// =============================================================================

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onSeeAll,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: CinearaSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CinearaSpacing.md),
            child: _SectionHeader(
              title: title,
              subtitle: subtitle,
              onSeeAll: onSeeAll,
            ),
          ),
          const SizedBox(height: CinearaSpacing.md),
          Padding(
            padding: const EdgeInsets.only(left: CinearaSpacing.md),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.onSeeAll,
  });

  final String title;
  final String subtitle;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.25,
                ),
              ),
              const SizedBox(height: CinearaSpacing.xxs),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: CinearaSpacing.sm),
        TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}

// =============================================================================
// WORLD CINEMA FEATURE SECTION
// =============================================================================

class _WorldCinemaSection extends StatelessWidget {
  const _WorldCinemaSection({required this.child, required this.onExplore});

  final Widget child;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: CinearaSpacing.xxl),
      child: DecoratedBox(
        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: CinearaSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CinearaSpacing.md,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.public_rounded,
                                size: 21,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: CinearaSpacing.xs),
                              Text(
                                'World Cinema Passport',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: CinearaSpacing.xxs),
                          Text(
                            'Hong Kong, Iran, Thailand, India, Taiwan, Italy '
                            'and beyond — without hiding the title behind the poster.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: CinearaSpacing.sm),
                    TextButton(
                      onPressed: onExplore,
                      child: const Text('Explore'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CinearaSpacing.md),
              Padding(
                padding: const EdgeInsets.only(left: CinearaSpacing.md),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// HORIZONTAL RAIL
// =============================================================================

class _PosterRail extends StatelessWidget {
  const _PosterRail({
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
  });

  final double height;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: CinearaSpacing.md),
        itemCount: itemCount,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: CinearaSpacing.sm),
        itemBuilder: itemBuilder,
      ),
    );
  }
}

// =============================================================================
// LABELED ARTWORK CARD
//
// This wrapper is important: artwork-only PosterMediaCard is visually compact,
// but the title remains visible beneath it. A user should not need to recognise
// a poster to know what the media is.
// =============================================================================

class _LabeledPosterCard extends StatelessWidget {
  const _LabeledPosterCard({
    required this.title,
    required this.child,
    this.metadata,
    this.width,
  });

  final String title;
  final String? metadata;
  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(aspectRatio: 2 / 3, child: child),
          const SizedBox(height: CinearaSpacing.xs),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              height: 1.18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
          if (metadata case final String value
              when value.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: CinearaSpacing.xxs),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// EPISODE CARD
//
// This intentionally uses a horizontal layout so episodic information has room.
// The poster stays recognisable, while the textual hierarchy is:
//
// Series title
// Episode title
// Season / episode
// Release date
// =============================================================================

class _EpisodeHomeCard extends StatelessWidget {
  const _EpisodeHomeCard({
    required this.episode,
    required this.onTap,
    required this.onLongPress,
  });

  final _EpisodePreview episode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PosterMediaCardLabels posterLabels = AppLocalizations.of(
      context,
    )!.posterMediaCardLabels;

    return SizedBox(
      width: 330,
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(CinearaSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 112,
                  child: PosterMediaCard(
                    title: episode.seriesTitle,
                    mediaTypeLabel: 'TV Series',
                    labels: posterLabels,
                    imageUrl: episode.imageUrl,
                    layout: PosterMediaCardLayout.artworkOnly,
                    worldIdentity: episode.worldIdentity,
                    viewingStatus: PosterViewingStatus.watching,
                    progress: episode.progress,
                    newContent: episode.newContent,
                    isFavourite: episode.isFavourite,
                    showExternalRating: false,
                    showUserRating: false,
                    showStatusDock: false,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.favourite,
                      isActive: episode.isFavourite,
                      onPressed: () {},
                    ),
                  ),
                ),
                const SizedBox(width: CinearaSpacing.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: CinearaSpacing.xxs),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          episode.seriesTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: CinearaSpacing.sm),
                        Text(
                          episode.episodeTitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          episode.seasonEpisode,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: CinearaSpacing.xxs),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: CinearaSpacing.xxs),
                            Expanded(
                              child: Text(
                                episode.releaseLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// COMING SOON CARD
// =============================================================================

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({
    required this.item,
    required this.onTap,
    required this.onRemind,
  });

  final _ComingSoonPreview item;
  final VoidCallback onTap;
  final VoidCallback onRemind;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PosterMediaCardLabels posterLabels = AppLocalizations.of(
      context,
    )!.posterMediaCardLabels;

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 2 / 3,
            child: PosterMediaCard(
              title: item.title,
              mediaTypeLabel: 'Movie',
              labels: posterLabels,
              imageUrl: item.imageUrl,
              layout: PosterMediaCardLayout.artworkOnly,
              worldIdentity: item.worldIdentity,
              showExternalRating: false,
              showUserRating: false,
              showStatusDock: false,
              quickAction: PosterQuickAction(
                type: PosterQuickActionType.watchlist,
                isActive: false,
                onPressed: onRemind,
              ),
              onTap: onTap,
            ),
          ),
          const SizedBox(height: CinearaSpacing.xs),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              height: 1.18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: CinearaSpacing.xxs),
          Row(
            children: <Widget>[
              Icon(
                Icons.event_rounded,
                size: 13,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: CinearaSpacing.xxs),
              Text(
                item.releaseDate,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: CinearaSpacing.xxs),
          Text(
            item.secondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// WATCHLIST GRID
// =============================================================================

class _WatchlistGrid extends StatelessWidget {
  const _WatchlistGrid({
    required this.media,
    required this.cardBuilder,
    required this.onSeeAll,
  });

  final List<_HomeMedia> media;
  final Widget Function(_HomeMedia media) cardBuilder;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionHeader(
          title: 'From your watchlist',
          subtitle: 'Saved titles, with names always visible',
          onSeeAll: onSeeAll,
        ),
        const SizedBox(height: CinearaSpacing.md),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final int columns = switch (constraints.maxWidth) {
              < 430 => 3,
              < 720 => 4,
              _ => 6,
            };

            final double totalSpacing = CinearaSpacing.xs * (columns - 1);
            final double itemWidth =
                (constraints.maxWidth - totalSpacing) / columns;

            // 2:3 artwork plus enough room for title and one metadata line.
            final double estimatedHeight = (itemWidth / (2 / 3)) + 58;
            final double childAspectRatio = itemWidth / estimatedHeight;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: media.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: CinearaSpacing.xs,
                mainAxisSpacing: CinearaSpacing.lg,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (BuildContext context, int index) {
                return cardBuilder(media[index]);
              },
            );
          },
        ),
      ],
    );
  }
}

// =============================================================================
// PREVIEW MODELS
// =============================================================================

@immutable
class _HomeMedia {
  const _HomeMedia({
    required this.title,
    required this.mediaTypeLabel,
    this.subtitle,
    this.imageUrl,
    this.worldIdentity,
    this.externalRating,
    this.userRating,
    this.viewingStatus = PosterViewingStatus.notStarted,
    this.progress,
    this.newContent,
    this.isFavourite = false,
    this.isInWatchlist = false,
    this.collectionCount = 0,
    this.aspectRatio = 2 / 3,
  });

  final String title;
  final String mediaTypeLabel;
  final String? subtitle;
  final String? imageUrl;
  final PosterWorldIdentity? worldIdentity;
  final PosterExternalRating? externalRating;
  final String? userRating;
  final PosterViewingStatus viewingStatus;
  final double? progress;
  final PosterNewContent? newContent;
  final bool isFavourite;
  final bool isInWatchlist;
  final int collectionCount;
  final double aspectRatio;
}

@immutable
class _EpisodePreview {
  const _EpisodePreview({
    required this.seriesTitle,
    required this.episodeTitle,
    required this.seasonEpisode,
    required this.releaseLabel,
    required this.imageUrl,
    required this.worldIdentity,
    required this.newContent,
    required this.progress,
    this.isFavourite = false,
  });

  final String seriesTitle;
  final String episodeTitle;
  final String seasonEpisode;
  final String releaseLabel;
  final String imageUrl;
  final PosterWorldIdentity worldIdentity;
  final PosterNewContent newContent;
  final double progress;
  final bool isFavourite;
}

@immutable
class _ComingSoonPreview {
  const _ComingSoonPreview({
    required this.title,
    required this.releaseDate,
    required this.secondary,
    required this.imageUrl,
    required this.worldIdentity,
  });

  final String title;
  final String releaseDate;
  final String secondary;
  final String imageUrl;
  final PosterWorldIdentity worldIdentity;
}
