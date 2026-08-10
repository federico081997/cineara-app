import 'package:cineara_design_system/cineara_design_system.dart';

import '../../l10n/app_localizations.dart';

/// Adapts Cineara's generated app localizations to the strings required by
/// [PosterMediaCard].
extension PosterMediaCardLocalization on AppLocalizations {
  /// Localized strings and semantic descriptions used by poster media cards.
  PosterMediaCardLabels get posterMediaCardLabels {
    return PosterMediaCardLabels(
      notStarted: posterStatusNotStarted,
      watching: posterStatusWatching,
      caughtUp: posterStatusCaughtUp,
      completed: posterStatusCompleted,
      rewatching: posterStatusRewatching,
      onHold: posterStatusOnHold,
      dropped: posterStatusDropped,
      favourite: posterFavourite,
      watchlist: posterWatchlist,
      userRating: posterUserRating,
      collectionCount: posterCollectionCount,
      progress: posterProgress,
      newContent: posterNewContent,
      newContentDescription: (PosterNewContentType type, int? count) {
        return switch (type) {
          PosterNewContentType.release => posterNewRelease,
          PosterNewContentType.episodes =>
            count == null
                ? posterNewEpisodesAvailable
                : posterNewEpisodeCount(count),
        };
      },
      quickAction:
          (PosterQuickActionType type, bool isActive, String mediaTitle) {
            return switch (type) {
              PosterQuickActionType.watchlist =>
                isActive
                    ? posterRemoveFromWatchlist(mediaTitle)
                    : posterAddToWatchlist(mediaTitle),
              PosterQuickActionType.favourite =>
                isActive
                    ? posterRemoveFromFavourites(mediaTitle)
                    : posterAddToFavourites(mediaTitle),
              PosterQuickActionType.watched =>
                isActive
                    ? posterMarkAsUnwatched(mediaTitle)
                    : posterMarkAsWatched(mediaTitle),
            };
          },
    );
  }
}
