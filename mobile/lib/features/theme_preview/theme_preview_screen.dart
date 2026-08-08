import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cineara Theme'),
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('Cineara', style: theme.textTheme.displayLarge),

          const SizedBox(height: 8),

          Text(
            'Explore cinema from around the world.',
            style: theme.textTheme.bodyLarge,
          ),

          const SizedBox(height: 32),

          Text('Cards', style: theme.textTheme.titleLarge),

          const SizedBox(height: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //
              // =========================================================================
              // WORLD DISCOVERY — STANDARD TWO-COLUMN CARDS
              // =========================================================================
              //
              Text(
                'World discovery',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: CinearaSpacing.md),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: CinearaSpacing.sm,
                mainAxisSpacing: CinearaSpacing.lg,

                // 2:3 artwork + external title/information area.
                childAspectRatio: 0.50,

                children: <Widget>[
                  //
                  // Japanese movie.
                  // Tests:
                  // - completed
                  // - favourite
                  // - external rating
                  // - personal rating
                  // - inactive Watchlist shortcut
                  //
                  PosterMediaCard(
                    title: 'Perfect Days',
                    subtitle: 'Japan · Japanese',
                    mediaTypeLabel: 'Movie',
                    imageUrl: 'https://picsum.photos/seed/perfect-days/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'JP · Film',
                      compactLabel: 'JP',
                      semanticLabel: 'Japan, Japanese cinema',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '7.9',
                    ),
                    userRating: '9.0',
                    viewingStatus: PosterViewingStatus.completed,
                    isFavourite: true,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                    onUserRatingTap: () {},
                  ),

                  //
                  // Anime.
                  // Tests:
                  // - deliberately long title
                  // - watching
                  // - progress
                  // - two NEW episodes
                  // - favourite
                  // - multiple collections
                  // - active Watchlist
                  // - both external and personal ratings
                  //
                  PosterMediaCard(
                    title:
                        'Frieren: Beyond Journey\'s End With a Deliberately Long Title',
                    subtitle: 'S1 E17 · Japan',
                    mediaTypeLabel: 'TV Series',
                    imageUrl: 'https://picsum.photos/seed/frieren/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'JP · Anime',
                      compactLabel: 'JP',
                      semanticLabel: 'Japan, Anime',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.9',
                    ),
                    userRating: '9.5',
                    viewingStatus: PosterViewingStatus.watching,
                    progress: 0.62,
                    newEpisodeCount: 2,
                    isFavourite: true,
                    collectionCount: 2,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                    onUserRatingTap: () {},
                  ),

                  //
                  // K-Drama.
                  // Tests:
                  // - caught up
                  // - favourite
                  // - one collection
                  //
                  PosterMediaCard(
                    title: 'Moving',
                    subtitle: 'Caught up · South Korea',
                    mediaTypeLabel: 'TV Series',
                    imageUrl: 'https://picsum.photos/seed/moving/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'KR · K-Drama',
                      compactLabel: 'KR',
                      semanticLabel: 'South Korea, K-Drama',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.4',
                    ),
                    viewingStatus: PosterViewingStatus.caughtUp,
                    isFavourite: true,
                    collectionCount: 1,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // C-Drama.
                  // Tests:
                  // - another external rating provider
                  // - progress
                  // - active Watchlist
                  // - one collection
                  // - one newly released episode
                  //
                  PosterMediaCard(
                    title: 'Reset',
                    subtitle: 'E8 of 15 · Mandarin',
                    mediaTypeLabel: 'TV Series',
                    imageUrl: 'https://picsum.photos/seed/reset-cdrama/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'CN · C-Drama',
                      compactLabel: 'CN',
                      semanticLabel: 'China, C-Drama',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'TMDb',
                      value: '8.2',
                    ),
                    viewingStatus: PosterViewingStatus.watching,
                    progress: 0.53,
                    newEpisodeCount: 1,
                    collectionCount: 1,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Hong Kong cinema.
                  // Tests:
                  // - completed
                  // - favourite
                  // - several collections
                  // - maximum personal rating
                  //
                  PosterMediaCard(
                    title: 'In the Mood for Love',
                    subtitle: 'Hong Kong · Cantonese',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/in-the-mood-for-love/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'HK · Film',
                      compactLabel: 'HK',
                      semanticLabel: 'Hong Kong, Cantonese cinema',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.1',
                    ),
                    userRating: '10',
                    viewingStatus: PosterViewingStatus.completed,
                    isFavourite: true,
                    collectionCount: 3,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                    onUserRatingTap: () {},
                  ),

                  //
                  // Indian cinema.
                  // Tests a longer world identity label.
                  //
                  PosterMediaCard(
                    title: 'Premalu',
                    subtitle: 'India · Malayalam',
                    mediaTypeLabel: 'Movie',
                    imageUrl: 'https://picsum.photos/seed/premalu/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'IN · Malayalam',
                      compactLabel: 'IN',
                      semanticLabel: 'India, Malayalam cinema',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '7.8',
                    ),
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Thai cinema.
                  //
                  PosterMediaCard(
                    title: 'Bad Genius',
                    subtitle: 'Thailand · Thai',
                    mediaTypeLabel: 'Movie',
                    imageUrl: 'https://picsum.photos/seed/bad-genius/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'TH · Film',
                      compactLabel: 'TH',
                      semanticLabel: 'Thailand, Thai cinema',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '7.6',
                    ),
                    userRating: '8.5',
                    viewingStatus: PosterViewingStatus.completed,
                    collectionCount: 1,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                    onUserRatingTap: () {},
                  ),

                  //
                  // Taiwan.
                  //
                  PosterMediaCard(
                    title: 'Someday or One Day',
                    subtitle: 'Taiwan · Mandarin',
                    mediaTypeLabel: 'TV Series',
                    imageUrl: 'https://picsum.photos/seed/taiwan-drama/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'TW · Drama',
                      compactLabel: 'TW',
                      semanticLabel: 'Taiwan, Taiwanese drama',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.6',
                    ),
                    viewingStatus: PosterViewingStatus.notStarted,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: CinearaSpacing.xxl),

              //
              // =========================================================================
              // NEW EPISODE MARKER TESTS
              // =========================================================================
              //
              Text(
                'New episode states',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: CinearaSpacing.md),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: CinearaSpacing.sm,
                mainAxisSpacing: CinearaSpacing.lg,
                childAspectRatio: 0.50,
                children: <Widget>[
                  //
                  // One NEW episode.
                  //
                  PosterMediaCard(
                    title: 'One New Episode',
                    subtitle: 'E7 of 12 · Japan',
                    mediaTypeLabel: 'TV Series',
                    imageUrl:
                        'https://picsum.photos/seed/one-new-episode/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'JP · Anime',
                      compactLabel: 'JP',
                      semanticLabel: 'Japan, Anime',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.3',
                    ),
                    viewingStatus: PosterViewingStatus.watching,
                    progress: 0.50,
                    newEpisodeCount: 1,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Several NEW episodes.
                  //
                  PosterMediaCard(
                    title: 'Several New Episodes',
                    subtitle: 'E9 of 16 · South Korea',
                    mediaTypeLabel: 'TV Series',
                    imageUrl:
                        'https://picsum.photos/seed/several-new-episodes/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'KR · K-Drama',
                      compactLabel: 'KR',
                      semanticLabel: 'South Korea, K-Drama',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.0',
                    ),
                    viewingStatus: PosterViewingStatus.watching,
                    progress: 0.56,
                    newEpisodeCount: 4,
                    isFavourite: true,
                    collectionCount: 1,
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // On Hold + new episodes.
                  // Useful to ensure NEW can coexist with the amber pause state.
                  //
                  PosterMediaCard(
                    title: 'On Hold but New Episodes Arrived',
                    subtitle: 'On hold · E20 of 36',
                    mediaTypeLabel: 'TV Series',
                    imageUrl: 'https://picsum.photos/seed/on-hold-new/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'CN · C-Drama',
                      compactLabel: 'CN',
                      semanticLabel: 'China, C-Drama',
                    ),
                    viewingStatus: PosterViewingStatus.onHold,
                    progress: 0.55,
                    newEpisodeCount: 3,
                    collectionCount: 2,
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // IMPORTANT NEGATIVE TEST:
                  // newEpisodeCount is intentionally non-zero, but NOT STARTED should
                  // suppress the NEW marker.
                  //
                  PosterMediaCard(
                    title: 'Never Started',
                    subtitle: 'South Korea · Korean',
                    mediaTypeLabel: 'TV Series',
                    imageUrl:
                        'https://picsum.photos/seed/not-started-new/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'KR · K-Drama',
                      compactLabel: 'KR',
                      semanticLabel: 'South Korea, K-Drama',
                    ),
                    viewingStatus: PosterViewingStatus.notStarted,
                    newEpisodeCount: 5,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: CinearaSpacing.xxl),

              //
              // =========================================================================
              // VIEWING STATUS + COLOUR STRESS TEST
              // =========================================================================
              //
              Text(
                'Viewing states',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: CinearaSpacing.md),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: CinearaSpacing.sm,
                mainAxisSpacing: CinearaSpacing.lg,
                childAspectRatio: 0.50,
                children: <Widget>[
                  //
                  // Watching without progress.
                  // This forces the purple PLAY state icon to appear.
                  //
                  PosterMediaCard(
                    title: 'Watching Without Progress',
                    subtitle: 'Currently watching',
                    mediaTypeLabel: 'TV Series',
                    imageUrl:
                        'https://picsum.photos/seed/watching-no-progress/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'TH · Series',
                      compactLabel: 'TH',
                      semanticLabel: 'Thailand, Thai television series',
                    ),
                    viewingStatus: PosterViewingStatus.watching,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Caught up — green double-check.
                  //
                  PosterMediaCard(
                    title: 'Caught Up Series',
                    subtitle: 'Caught up',
                    mediaTypeLabel: 'TV Series',
                    imageUrl:
                        'https://picsum.photos/seed/caught-up-state/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'KR · K-Drama',
                      compactLabel: 'KR',
                      semanticLabel: 'South Korea, K-Drama',
                    ),
                    viewingStatus: PosterViewingStatus.caughtUp,
                    isFavourite: true,
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Completed — green check.
                  //
                  PosterMediaCard(
                    title: 'Completed Movie',
                    subtitle: 'Japan · Japanese',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/completed-state/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'JP · Film',
                      compactLabel: 'JP',
                      semanticLabel: 'Japan, Japanese cinema',
                    ),
                    viewingStatus: PosterViewingStatus.completed,
                    isFavourite: true,
                    collectionCount: 2,
                    userRating: '8.5',
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Rewatching — violet replay.
                  //
                  PosterMediaCard(
                    title: 'Steins;Gate',
                    subtitle: 'Rewatch · E8 of 24',
                    mediaTypeLabel: 'TV Series',
                    imageUrl: 'https://picsum.photos/seed/steins-gate/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'JP · Anime',
                      compactLabel: 'JP',
                      semanticLabel: 'Japan, Anime',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.8',
                    ),
                    userRating: '10',
                    viewingStatus: PosterViewingStatus.rewatching,
                    progress: 0.33,
                    isFavourite: true,
                    collectionCount: 4,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                    onUserRatingTap: () {},
                  ),

                  //
                  // On Hold — amber pause.
                  //
                  PosterMediaCard(
                    title: 'Long Running Drama',
                    subtitle: 'On hold · E24 of 50',
                    mediaTypeLabel: 'TV Series',
                    imageUrl:
                        'https://picsum.photos/seed/on-hold-drama/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'CN · C-Drama',
                      compactLabel: 'CN',
                      semanticLabel: 'China, C-Drama',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'TMDb',
                      value: '7.9',
                    ),
                    viewingStatus: PosterViewingStatus.onHold,
                    progress: 0.48,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Dropped — error/red state.
                  //
                  PosterMediaCard(
                    title: 'Dropped Series',
                    subtitle: 'Dropped · South Korea',
                    mediaTypeLabel: 'TV Series',
                    imageUrl:
                        'https://picsum.photos/seed/dropped-series/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'KR · K-Drama',
                      compactLabel: 'KR',
                      semanticLabel: 'South Korea, K-Drama',
                    ),
                    viewingStatus: PosterViewingStatus.dropped,

                    // Should NOT display NEW because Dropped suppresses it.
                    newEpisodeCount: 7,

                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: CinearaSpacing.xxl),

              //
              // =========================================================================
              // RATING COMBINATIONS
              // =========================================================================
              //
              Text(
                'Rating combinations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: CinearaSpacing.md),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: CinearaSpacing.sm,
                mainAxisSpacing: CinearaSpacing.lg,
                childAspectRatio: 0.50,
                children: <Widget>[
                  //
                  // External rating only.
                  //
                  PosterMediaCard(
                    title: 'External Rating Only',
                    subtitle: 'Japan · Japanese',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/external-only/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'JP · Film',
                      compactLabel: 'JP',
                      semanticLabel: 'Japan, Japanese cinema',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.2',
                    ),
                    onTap: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Personal rating only.
                  //
                  PosterMediaCard(
                    title: 'Personal Rating Only',
                    subtitle: 'Thailand · Thai',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/user-rating-only/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'TH · Film',
                      compactLabel: 'TH',
                      semanticLabel: 'Thailand, Thai cinema',
                    ),
                    userRating: '9.0',
                    viewingStatus: PosterViewingStatus.completed,
                    onTap: () {},
                    onUserRatingTap: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Both rating systems.
                  //
                  PosterMediaCard(
                    title: 'Both Ratings',
                    subtitle: 'Hong Kong · Cantonese',
                    mediaTypeLabel: 'Movie',
                    imageUrl: 'https://picsum.photos/seed/both-ratings/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'HK · Film',
                      compactLabel: 'HK',
                      semanticLabel: 'Hong Kong, Cantonese cinema',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '7.4',
                    ),
                    userRating: '9.5',
                    viewingStatus: PosterViewingStatus.completed,
                    onTap: () {},
                    onUserRatingTap: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // No ratings.
                  //
                  PosterMediaCard(
                    title: 'No Ratings',
                    subtitle: 'India · Telugu',
                    mediaTypeLabel: 'Movie',
                    imageUrl: 'https://picsum.photos/seed/no-ratings/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'IN · Telugu',
                      compactLabel: 'IN',
                      semanticLabel: 'India, Telugu cinema',
                    ),
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onWorldIdentityTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: CinearaSpacing.xxl),

              //
              // =========================================================================
              // QUICK ACTION TYPES
              // =========================================================================
              //
              Text(
                'Quick actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: CinearaSpacing.md),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: CinearaSpacing.sm,
                mainAxisSpacing: CinearaSpacing.lg,
                childAspectRatio: 0.50,
                children: <Widget>[
                  //
                  // Watchlist inactive.
                  //
                  PosterMediaCard(
                    title: 'Add to Watchlist',
                    subtitle: 'Japan · Japanese',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/watchlist-off/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'JP · Film',
                      compactLabel: 'JP',
                      semanticLabel: 'Japan, Japanese cinema',
                    ),
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                  ),

                  //
                  // Watchlist active.
                  //
                  PosterMediaCard(
                    title: 'Already in Watchlist',
                    subtitle: 'South Korea · Korean',
                    mediaTypeLabel: 'Movie',
                    imageUrl: 'https://picsum.photos/seed/watchlist-on/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'KR · Film',
                      compactLabel: 'KR',
                      semanticLabel: 'South Korea, Korean cinema',
                    ),
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                  ),

                  //
                  // Favourite inactive.
                  //
                  PosterMediaCard(
                    title: 'Quick Favourite',
                    subtitle: 'France · French',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/favourite-off/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'FR · Film',
                      compactLabel: 'FR',
                      semanticLabel: 'France, French cinema',
                    ),
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.favourite,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                  ),

                  //
                  // Favourite active.
                  //
                  PosterMediaCard(
                    title: 'Quick Favourite Active',
                    subtitle: 'Taiwan · Mandarin',
                    mediaTypeLabel: 'Movie',
                    imageUrl: 'https://picsum.photos/seed/favourite-on/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'TW · Film',
                      compactLabel: 'TW',
                      semanticLabel: 'Taiwan, Taiwanese cinema',
                    ),
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.favourite,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                  ),

                  //
                  // Mark watched inactive.
                  //
                  PosterMediaCard(
                    title: 'Quick Mark Watched',
                    subtitle: 'India · Hindi',
                    mediaTypeLabel: 'Movie',
                    imageUrl: 'https://picsum.photos/seed/watched-off/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'IN · Hindi',
                      compactLabel: 'IN',
                      semanticLabel: 'India, Hindi cinema',
                    ),
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watched,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                  ),

                  //
                  // Mark watched active.
                  //
                  PosterMediaCard(
                    title: 'Already Watched',
                    subtitle: 'Thailand · Thai',
                    mediaTypeLabel: 'Movie',
                    imageUrl: 'https://picsum.photos/seed/watched-on/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'TH · Film',
                      compactLabel: 'TH',
                      semanticLabel: 'Thailand, Thai cinema',
                    ),
                    viewingStatus: PosterViewingStatus.completed,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watched,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: CinearaSpacing.xxl),

              //
              // =========================================================================
              // CONTEXT-SPECIFIC PRESENTATIONS
              // =========================================================================
              //
              Text(
                'Context-specific cards',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: CinearaSpacing.md),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: CinearaSpacing.sm,
                mainAxisSpacing: CinearaSpacing.lg,
                childAspectRatio: 0.50,
                children: <Widget>[
                  //
                  // Continue Watching.
                  // External/community score deliberately hidden.
                  //
                  PosterMediaCard(
                    title: 'Frieren',
                    subtitle: 'S1 E17 · 62%',
                    mediaTypeLabel: 'TV Series',
                    imageUrl:
                        'https://picsum.photos/seed/frieren-continue/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'JP · Anime',
                      compactLabel: 'JP',
                      semanticLabel: 'Japan, Anime',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.9',
                    ),
                    viewingStatus: PosterViewingStatus.watching,
                    progress: 0.62,
                    newEpisodeCount: 1,
                    isFavourite: true,
                    showExternalRating: false,
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Watched page.
                  // User score matters more than external score.
                  //
                  PosterMediaCard(
                    title: 'Drive My Car',
                    subtitle: 'Japan · Japanese',
                    mediaTypeLabel: 'Movie',
                    imageUrl: 'https://picsum.photos/seed/drive-my-car/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'JP · Film',
                      compactLabel: 'JP',
                      semanticLabel: 'Japan, Japanese cinema',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '7.5',
                    ),
                    userRating: '9.5',
                    viewingStatus: PosterViewingStatus.completed,
                    isFavourite: true,
                    collectionCount: 2,
                    showExternalRating: false,
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                    onUserRatingTap: () {},
                  ),

                  //
                  // Dedicated Anime page.
                  // The page already communicates Anime, so the world chip is hidden.
                  //
                  PosterMediaCard(
                    title: 'Violet Evergarden',
                    subtitle: '2018 · Japan',
                    mediaTypeLabel: 'TV Series',
                    imageUrl:
                        'https://picsum.photos/seed/violet-evergarden/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'JP · Anime',
                      compactLabel: 'JP',
                      semanticLabel: 'Japan, Anime',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.4',
                    ),
                    userRating: '9.0',
                    viewingStatus: PosterViewingStatus.completed,
                    isFavourite: true,
                    showWorldIdentity: false,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onUserRatingTap: () {},
                  ),

                  //
                  // Collection page.
                  // Do not repeat collection membership visually.
                  //
                  PosterMediaCard(
                    title: 'The Handmaiden',
                    subtitle: 'South Korea · Korean',
                    mediaTypeLabel: 'Movie',
                    imageUrl: 'https://picsum.photos/seed/handmaiden/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'KR · Film',
                      compactLabel: 'KR',
                      semanticLabel: 'South Korea, Korean cinema',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.1',
                    ),
                    userRating: '9.0',
                    viewingStatus: PosterViewingStatus.completed,
                    isFavourite: true,

                    // Deliberately zero even though this represents a Collection page,
                    // because the page itself already communicates membership.
                    collectionCount: 0,

                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: CinearaSpacing.xxl),

              //
              // =========================================================================
              // ARTWORK-ONLY — THREE-COLUMN RESPONSIVE TEST
              // =========================================================================
              //
              Text(
                'Artwork only · 3 columns',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: CinearaSpacing.md),

              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: CinearaSpacing.sm,
                mainAxisSpacing: CinearaSpacing.sm,

                // No title or metadata below, so preserve the actual poster ratio.
                childAspectRatio: 2 / 3,

                children: <Widget>[
                  //
                  // Compact JP + external score + Watchlist.
                  //
                  PosterMediaCard(
                    title: 'Tokyo Story',
                    mediaTypeLabel: 'Movie',
                    imageUrl: 'https://picsum.photos/seed/tokyo-story/400/600',
                    layout: PosterMediaCardLayout.artworkOnly,
                    worldIdentity: const PosterWorldIdentity(
                      label: 'JP · Film',
                      compactLabel: 'JP',
                      semanticLabel: 'Japan, Japanese cinema',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.1',
                    ),
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Korean series + progress + favourite + active Watchlist.
                  //
                  PosterMediaCard(
                    title: 'Kingdom',
                    mediaTypeLabel: 'TV Series',
                    imageUrl:
                        'https://picsum.photos/seed/kingdom-korea/400/600',
                    layout: PosterMediaCardLayout.artworkOnly,
                    worldIdentity: const PosterWorldIdentity(
                      label: 'KR · K-Drama',
                      compactLabel: 'KR',
                      semanticLabel: 'South Korea, K-Drama',
                    ),
                    viewingStatus: PosterViewingStatus.watching,
                    progress: 0.38,
                    newEpisodeCount: 1,
                    isFavourite: true,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Dense small card:
                  // - completed
                  // - favourite
                  // - collections
                  // - quick action
                  //
                  PosterMediaCard(
                    title: 'Infernal Affairs',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/infernal-affairs/400/600',
                    layout: PosterMediaCardLayout.artworkOnly,
                    worldIdentity: const PosterWorldIdentity(
                      label: 'HK · Film',
                      compactLabel: 'HK',
                      semanticLabel: 'Hong Kong, Cantonese cinema',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.0',
                    ),
                    viewingStatus: PosterViewingStatus.completed,
                    isFavourite: true,
                    collectionCount: 3,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Thailand — deliberately simple.
                  //
                  PosterMediaCard(
                    title: 'Thai Discovery',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/thai-discovery/400/600',
                    layout: PosterMediaCardLayout.artworkOnly,
                    worldIdentity: const PosterWorldIdentity(
                      label: 'TH · Film',
                      compactLabel: 'TH',
                      semanticLabel: 'Thailand, Thai cinema',
                    ),
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Malayalam + favourite + collection + active Watchlist.
                  //
                  PosterMediaCard(
                    title: 'Malayalam Discovery',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/malayalam-discovery/400/600',
                    layout: PosterMediaCardLayout.artworkOnly,
                    worldIdentity: const PosterWorldIdentity(
                      label: 'IN · Malayalam',
                      compactLabel: 'IN',
                      semanticLabel: 'India, Malayalam cinema',
                    ),
                    isFavourite: true,
                    collectionCount: 1,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Rewatch + favourite + collection.
                  // Tests +N collapse in a narrow card.
                  //
                  PosterMediaCard(
                    title: 'Chinese Drama',
                    mediaTypeLabel: 'TV Series',
                    imageUrl:
                        'https://picsum.photos/seed/chinese-drama/400/600',
                    layout: PosterMediaCardLayout.artworkOnly,
                    worldIdentity: const PosterWorldIdentity(
                      label: 'CN · C-Drama',
                      compactLabel: 'CN',
                      semanticLabel: 'China, C-Drama',
                    ),
                    viewingStatus: PosterViewingStatus.rewatching,
                    progress: 0.71,
                    isFavourite: true,
                    collectionCount: 2,
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // NEW badge in compact mode.
                  //
                  PosterMediaCard(
                    title: 'Compact New Episode',
                    mediaTypeLabel: 'TV Series',
                    imageUrl: 'https://picsum.photos/seed/compact-new/400/600',
                    layout: PosterMediaCardLayout.artworkOnly,
                    worldIdentity: const PosterWorldIdentity(
                      label: 'TW · Drama',
                      compactLabel: 'TW',
                      semanticLabel: 'Taiwan, Taiwanese drama',
                    ),
                    viewingStatus: PosterViewingStatus.watching,
                    progress: 0.44,
                    newEpisodeCount: 4,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Missing artwork in tiny mode.
                  //
                  PosterMediaCard(
                    title: 'Missing Artwork',
                    mediaTypeLabel: 'Movie',
                    layout: PosterMediaCardLayout.artworkOnly,
                    worldIdentity: const PosterWorldIdentity(
                      label: 'IN · Tamil',
                      compactLabel: 'IN',
                      semanticLabel: 'India, Tamil cinema',
                    ),
                    viewingStatus: PosterViewingStatus.completed,
                    isFavourite: true,
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Completely clean artwork-only card.
                  //
                  PosterMediaCard(
                    title: 'Clean Artwork',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/clean-artwork-only/400/600',
                    layout: PosterMediaCardLayout.artworkOnly,
                    showWorldIdentity: false,
                    showExternalRating: false,
                    showUserRating: false,
                    showStatusDock: false,
                    showWorldline: false,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: CinearaSpacing.xxl),

              //
              // =========================================================================
              // MINIMAL / VISUAL CLEANLINESS TESTS
              // =========================================================================
              //
              Text(
                'Minimal variants',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: CinearaSpacing.md),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: CinearaSpacing.sm,
                mainAxisSpacing: CinearaSpacing.lg,
                childAspectRatio: 0.50,
                children: <Widget>[
                  //
                  // Nothing over the image at all.
                  //
                  PosterMediaCard(
                    title: 'Completely Clean',
                    subtitle: 'France · French',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/completely-clean/400/600',
                    showWorldIdentity: false,
                    showExternalRating: false,
                    showUserRating: false,
                    showStatusDock: false,
                    showWorldline: false,
                    onTap: () {},
                  ),

                  //
                  // Only Cineara's world identity.
                  //
                  PosterMediaCard(
                    title: 'World Identity Only',
                    subtitle: 'Hong Kong · Cantonese',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/world-identity-only/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'HK · Film',
                      compactLabel: 'HK',
                      semanticLabel: 'Hong Kong, Cantonese cinema',
                    ),
                    showExternalRating: false,
                    showUserRating: false,
                    showStatusDock: false,
                    onTap: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Only rating.
                  //
                  PosterMediaCard(
                    title: 'External Rating Only Overlay',
                    subtitle: 'Japan · Japanese',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/rating-overlay-only/400/600',
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.7',
                    ),
                    showWorldIdentity: false,
                    showStatusDock: false,
                    showUserRating: false,
                    showWorldline: false,
                    onTap: () {},
                  ),

                  //
                  // Only progress.
                  //
                  PosterMediaCard(
                    title: 'Progress Only',
                    subtitle: 'E5 of 12',
                    mediaTypeLabel: 'TV Series',
                    imageUrl:
                        'https://picsum.photos/seed/progress-only/400/600',
                    viewingStatus: PosterViewingStatus.watching,
                    progress: 0.42,
                    showWorldIdentity: false,
                    showExternalRating: false,
                    showUserRating: false,
                    showStatusDock: false,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: CinearaSpacing.xxl),

              //
              // =========================================================================
              // ERROR / EDGE CASES
              // =========================================================================
              //
              Text('Edge cases', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: CinearaSpacing.md),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: CinearaSpacing.sm,
                mainAxisSpacing: CinearaSpacing.lg,
                childAspectRatio: 0.50,
                children: <Widget>[
                  //
                  // No poster URL.
                  //
                  PosterMediaCard(
                    title: 'Missing Poster Artwork',
                    subtitle: 'India · Tamil',
                    mediaTypeLabel: 'Movie',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'IN · Tamil',
                      compactLabel: 'IN',
                      semanticLabel: 'India, Tamil cinema',
                    ),
                    userRating: '8.0',
                    viewingStatus: PosterViewingStatus.completed,
                    isFavourite: true,
                    collectionCount: 2,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Deliberately invalid image URL.
                  //
                  PosterMediaCard(
                    title: 'Failed Network Image',
                    subtitle: 'Japan · Japanese',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://this-domain-should-not-exist.invalid/poster.jpg',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'JP · Film',
                      compactLabel: 'JP',
                      semanticLabel: 'Japan, Japanese cinema',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '7.2',
                    ),
                    onTap: () {},
                  ),

                  //
                  // Very long title and subtitle.
                  //
                  PosterMediaCard(
                    title:
                        'This Is an Extremely Long Film Title Designed to Test Two-Line Ellipsis Behaviour',
                    subtitle:
                        'Hong Kong · Cantonese · Extremely long supporting information',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/very-long-title/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'HK · Film',
                      compactLabel: 'HK',
                      semanticLabel: 'Hong Kong, Cantonese cinema',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.3',
                    ),
                    userRating: '9.5',
                    viewingStatus: PosterViewingStatus.completed,
                    isFavourite: true,
                    collectionCount: 5,
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  //
                  // Everything possible at once.
                  // The card should still remain readable and collapse status icons.
                  //
                  PosterMediaCard(
                    title: 'Maximum Density Stress Test',
                    subtitle: 'Rewatch · E18 of 24',
                    mediaTypeLabel: 'TV Series',
                    imageUrl:
                        'https://picsum.photos/seed/maximum-density/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'JP · Anime',
                      compactLabel: 'JP',
                      semanticLabel: 'Japan, Anime',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '9.1',
                    ),
                    userRating: '10',
                    viewingStatus: PosterViewingStatus.rewatching,
                    progress: 0.75,
                    newEpisodeCount: 3,
                    isFavourite: true,
                    collectionCount: 8,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                    onUserRatingTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: CinearaSpacing.xxl),

              //
              // =========================================================================
              // WIDE CARD TEST
              //
              // Important because this lets you verify the "spacious" density where
              // full world labels, IMDb/TMDb source names and multi-episode NEW labels
              // have enough room.
              // =========================================================================
              //
              Text(
                'Wide density',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: CinearaSpacing.md),

              GridView.count(
                crossAxisCount: 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: CinearaSpacing.lg,

                // Wide card, still allowing enough vertical room for 2:3 artwork.
                childAspectRatio: 0.92,

                children: <Widget>[
                  //
                  // Full labels should appear:
                  //
                  // JP · Anime
                  // IMDb 8.9
                  // 3 NEW
                  // [status status status]
                  // You ★9.5
                  //
                  PosterMediaCard(
                    title: 'Frieren: Beyond Journey\'s End',
                    subtitle: 'S2 E7 · Japan · Japanese',
                    mediaTypeLabel: 'TV Series',
                    imageUrl: 'https://picsum.photos/seed/wide-frieren/600/900',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'JP · Anime',
                      compactLabel: 'JP',
                      semanticLabel: 'Japan, Anime',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.9',
                    ),
                    userRating: '9.5',
                    viewingStatus: PosterViewingStatus.watching,
                    progress: 0.58,
                    newEpisodeCount: 3,
                    isFavourite: true,
                    collectionCount: 4,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                    onUserRatingTap: () {},
                  ),

                  //
                  // Long world identity.
                  // Checks that "IN · Malayalam" has enough room at spacious density.
                  //
                  PosterMediaCard(
                    title: 'Malayalam Cinema Wide Test',
                    subtitle: 'India · Malayalam',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/wide-malayalam/600/900',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'IN · Malayalam',
                      compactLabel: 'IN',
                      semanticLabel: 'India, Malayalam cinema',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.2',
                    ),
                    userRating: '9.0',
                    viewingStatus: PosterViewingStatus.completed,
                    isFavourite: true,
                    collectionCount: 3,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.favourite,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                    onUserRatingTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: CinearaSpacing.xxl),

              //
              // -------------------------------------------------------------------------
              // ARTWORK-ONLY — COMPACT DISCOVERY
              // -------------------------------------------------------------------------
              //
              Text(
                'Artwork only',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: CinearaSpacing.md),

              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: CinearaSpacing.sm,
                mainAxisSpacing: CinearaSpacing.sm,

                // Artwork is naturally 2:3.
                childAspectRatio: 2 / 3,

                children: <Widget>[
                  PosterMediaCard(
                    title: 'Tokyo Story',
                    mediaTypeLabel: 'Movie',
                    imageUrl: 'https://picsum.photos/seed/tokyo-story/400/600',
                    layout: PosterMediaCardLayout.artworkOnly,
                    worldIdentity: const PosterWorldIdentity(
                      label: 'JP · Film',
                      compactLabel: 'JP',
                      semanticLabel: 'Japan, Japanese cinema',
                    ),
                    externalRating: const PosterExternalRating(
                      sourceLabel: 'IMDb',
                      value: '8.1',
                    ),
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  PosterMediaCard(
                    title: 'Kingdom',
                    mediaTypeLabel: 'TV Series',
                    imageUrl:
                        'https://picsum.photos/seed/kingdom-korea/400/600',
                    layout: PosterMediaCardLayout.artworkOnly,
                    worldIdentity: const PosterWorldIdentity(
                      label: 'KR · K-Drama',
                      compactLabel: 'KR',
                      semanticLabel: 'South Korea, K-Drama',
                    ),
                    viewingStatus: PosterViewingStatus.watching,
                    progress: 0.38,
                    isFavourite: true,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  PosterMediaCard(
                    title: 'Infernal Affairs',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/infernal-affairs/400/600',
                    layout: PosterMediaCardLayout.artworkOnly,
                    worldIdentity: const PosterWorldIdentity(
                      label: 'HK · Film',
                      compactLabel: 'HK',
                      semanticLabel: 'Hong Kong, Cantonese cinema',
                    ),
                    viewingStatus: PosterViewingStatus.completed,
                    isFavourite: true,
                    collectionCount: 3,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  PosterMediaCard(
                    title: 'Thai Discovery',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/thai-discovery/400/600',
                    layout: PosterMediaCardLayout.artworkOnly,
                    worldIdentity: const PosterWorldIdentity(
                      label: 'TH · Film',
                      compactLabel: 'TH',
                      semanticLabel: 'Thailand, Thai cinema',
                    ),
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  PosterMediaCard(
                    title: 'Malayalam Discovery',
                    mediaTypeLabel: 'Movie',
                    imageUrl:
                        'https://picsum.photos/seed/malayalam-discovery/400/600',
                    layout: PosterMediaCardLayout.artworkOnly,
                    worldIdentity: const PosterWorldIdentity(
                      label: 'IN · Malayalam',
                      compactLabel: 'IN',
                      semanticLabel: 'India, Malayalam cinema',
                    ),
                    isFavourite: true,
                    collectionCount: 1,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: true,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),

                  PosterMediaCard(
                    title: 'Chinese Drama',
                    mediaTypeLabel: 'TV Series',
                    imageUrl:
                        'https://picsum.photos/seed/chinese-drama/400/600',
                    layout: PosterMediaCardLayout.artworkOnly,
                    worldIdentity: const PosterWorldIdentity(
                      label: 'CN · C-Drama',
                      compactLabel: 'CN',
                      semanticLabel: 'China, C-Drama',
                    ),
                    viewingStatus: PosterViewingStatus.rewatching,
                    progress: 0.71,
                    isFavourite: true,
                    collectionCount: 2,
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: CinearaSpacing.xxl),

              //
              // -------------------------------------------------------------------------
              // MINIMAL / CLEAN CARDS
              // -------------------------------------------------------------------------
              //
              Text(
                'Minimal variants',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: CinearaSpacing.md),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: CinearaSpacing.sm,
                mainAxisSpacing: CinearaSpacing.lg,
                childAspectRatio: 0.50,
                children: <Widget>[
                  //
                  // Almost completely clean artwork.
                  //
                  PosterMediaCard(
                    title: 'Clean Poster',
                    subtitle: 'France · French',
                    mediaTypeLabel: 'Movie',
                    imageUrl: 'https://picsum.photos/seed/clean-poster/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'FR · Film',
                      compactLabel: 'FR',
                      semanticLabel: 'France, French cinema',
                    ),
                    showWorldIdentity: false,
                    showExternalRating: false,
                    showUserRating: false,
                    showStatusDock: false,
                    showWorldline: false,
                    onTap: () {},
                    onLongPress: () {},
                  ),

                  //
                  // World discovery is the only overlay.
                  //
                  PosterMediaCard(
                    title: 'World First',
                    subtitle: 'Hong Kong · Cantonese',
                    mediaTypeLabel: 'Movie',
                    imageUrl: 'https://picsum.photos/seed/world-first/400/600',
                    worldIdentity: const PosterWorldIdentity(
                      label: 'HK · Film',
                      compactLabel: 'HK',
                      semanticLabel: 'Hong Kong, Cantonese cinema',
                    ),
                    showExternalRating: false,
                    showUserRating: false,
                    showStatusDock: false,
                    quickAction: PosterQuickAction(
                      type: PosterQuickActionType.watchlist,
                      isActive: false,
                      onPressed: () {},
                    ),
                    onTap: () {},
                    onLongPress: () {},
                    onWorldIdentityTap: () {},
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          Text('Buttons', style: theme.textTheme.titleLarge),

          const SizedBox(height: 12),

          FilledButton(onPressed: () {}, child: const Text('Add to Watchlist')),

          const SizedBox(height: 12),

          OutlinedButton(onPressed: () {}, child: const Text('View Details')),

          const SizedBox(height: 12),

          TextButton(onPressed: () {}, child: const Text('See all')),

          const SizedBox(height: 32),

          Text('Chips', style: theme.textTheme.titleLarge),

          const SizedBox(height: 12),

          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Chip(label: Text('Anime')),
              Chip(label: Text('Movies')),
              Chip(label: Text('K-Dramas')),
              Chip(label: Text('World Cinema')),
            ],
          ),

          const SizedBox(height: 32),

          Text('Search field', style: theme.textTheme.titleLarge),

          const SizedBox(height: 12),

          const TextField(
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: 'Movies, series, anime...',
              prefixIcon: Icon(Icons.search),
            ),
          ),

          const SizedBox(height: 32),

          Text('Progress', style: theme.textTheme.titleLarge),

          const SizedBox(height: 12),

          const LinearProgressIndicator(value: 0.65),

          const SizedBox(height: 8),

          Text('8 of 12 episodes watched', style: theme.textTheme.bodySmall),

          const SizedBox(height: 32),

          Text('Controls', style: theme.textTheme.titleLarge),

          const SizedBox(height: 12),

          const SwitchListTile(
            value: true,
            onChanged: null,
            title: Text('Show mature content'),
          ),

          const CheckboxListTile(
            value: true,
            onChanged: null,
            title: Text('Notifications'),
          ),

          const SizedBox(height: 32),

          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cineara theme preview'),
                  action: SnackBarAction(label: 'Undo', onPressed: _doNothing),
                ),
              );
            },
            child: const Text('Show snackbar'),
          ),

          const SizedBox(height: 64),
        ],
      ),
    );
  }
}

void _doNothing() {}
