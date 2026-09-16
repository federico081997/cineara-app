import 'package:go_router/go_router.dart';

import '../../features/media/media.dart';
import '../../features/search/search.dart';
import '../shell/app_root_destination.dart';
import 'app_routes.dart';

/// Builds the nested routes shared by every Cineara root navigation branch.
///
/// Each root branch exposes the same normal application flows:
///
/// ```text
/// search
///
/// media/:mediaType/:mediaId
/// └── season/:seasonNumber
///     └── episode/:episodeNumber
/// ```
///
/// For example, the same media details page can therefore exist at:
///
/// ```text
/// /home/media/movie/550
/// /discover/media/movie/550
/// /library/media/movie/550
/// /profile/media/movie/550
/// ```
///
/// The owning root destination affects only the route location and navigation
/// stack. It does not produce destination-specific versions of feature pages.
///
/// In particular, there should be one:
///
/// ```text
/// MediaDetailsPage
/// ```
///
/// rather than separate `HomeMediaDetailsPage`,
/// `DiscoverMediaDetailsPage`, and similar wrappers.
///
/// These routes deliberately do not specify a `parentNavigatorKey`. They remain
/// on the navigator belonging to the current [StatefulShellBranch], allowing
/// Cineara's persistent bottom navigation and branch history to remain intact.
List<RouteBase> buildSharedBranchRoutes({
  required AppRootDestination destination,
}) {
  return [
    // -------------------------------------------------------------------------
    // Search
    // -------------------------------------------------------------------------
    GoRoute(
      path: AppRoutes.searchSegment,
      builder: (context, state) {
        return const SearchPage();
      },
    ),

    // -------------------------------------------------------------------------
    // Media details
    // -------------------------------------------------------------------------
    GoRoute(
      path: AppRoutes.mediaSegment,
      redirect: (context, state) {
        if (!_hasValidMediaParameters(state)) {
          return AppRoutes.locationFor(destination);
        }

        return null;
      },
      builder: (context, state) {
        final mediaType = _mediaTypeFrom(state);
        final mediaId = _positiveIntFrom(state, AppRoutes.mediaIdParameter);

        return MediaDetailsPage(mediaType: mediaType, mediaId: mediaId);
      },
      routes: [
        // ---------------------------------------------------------------------
        // Season details
        // ---------------------------------------------------------------------
        GoRoute(
          path: AppRoutes.seasonSegment,
          redirect: (context, state) {
            if (!_hasValidMediaParameters(state)) {
              return AppRoutes.locationFor(destination);
            }

            final seasonNumber = _nonNegativeIntOrNull(
              state,
              AppRoutes.seasonNumberParameter,
            );

            if (seasonNumber == null) {
              return _mediaLocationFor(destination: destination, state: state);
            }

            return null;
          },
          builder: (context, state) {
            final mediaType = _mediaTypeFrom(state);
            final mediaId = _positiveIntFrom(state, AppRoutes.mediaIdParameter);
            final seasonNumber = _nonNegativeIntFrom(
              state,
              AppRoutes.seasonNumberParameter,
            );

            return SeasonDetailsPage(
              mediaType: mediaType,
              mediaId: mediaId,
              seasonNumber: seasonNumber,
            );
          },
          routes: [
            // -----------------------------------------------------------------
            // Episode details
            // -----------------------------------------------------------------
            GoRoute(
              path: AppRoutes.episodeSegment,
              redirect: (context, state) {
                if (!_hasValidMediaParameters(state)) {
                  return AppRoutes.locationFor(destination);
                }

                final seasonNumber = _nonNegativeIntOrNull(
                  state,
                  AppRoutes.seasonNumberParameter,
                );

                if (seasonNumber == null) {
                  return _mediaLocationFor(
                    destination: destination,
                    state: state,
                  );
                }

                final episodeNumber = _positiveIntOrNull(
                  state,
                  AppRoutes.episodeNumberParameter,
                );

                if (episodeNumber == null) {
                  return _seasonLocationFor(
                    destination: destination,
                    state: state,
                    seasonNumber: seasonNumber,
                  );
                }

                return null;
              },
              builder: (context, state) {
                final mediaType = _mediaTypeFrom(state);
                final mediaId = _positiveIntFrom(
                  state,
                  AppRoutes.mediaIdParameter,
                );
                final seasonNumber = _nonNegativeIntFrom(
                  state,
                  AppRoutes.seasonNumberParameter,
                );
                final episodeNumber = _positiveIntFrom(
                  state,
                  AppRoutes.episodeNumberParameter,
                );

                return EpisodeDetailsPage(
                  mediaType: mediaType,
                  mediaId: mediaId,
                  seasonNumber: seasonNumber,
                  episodeNumber: episodeNumber,
                );
              },
            ),
          ],
        ),
      ],
    ),
  ];
}

// =============================================================================
// Route validation
// =============================================================================

/// Whether the required media route parameters are valid.
///
/// Media identifiers must be positive TMDB identifiers. The media type only
/// needs to be a non-empty path value here; interpretation of supported media
/// types belongs to the media-details feature rather than this generic routing
/// helper.
bool _hasValidMediaParameters(GoRouterState state) {
  final mediaType = state.pathParameters[AppRoutes.mediaTypeParameter];

  if (mediaType == null || mediaType.trim().isEmpty) {
    return false;
  }

  return _positiveIntOrNull(state, AppRoutes.mediaIdParameter) != null;
}

// =============================================================================
// Parameter extraction
// =============================================================================

String _mediaTypeFrom(GoRouterState state) {
  final value = state.pathParameters[AppRoutes.mediaTypeParameter];

  if (value == null || value.trim().isEmpty) {
    throw StateError(
      'Missing or empty "${AppRoutes.mediaTypeParameter}" route parameter.',
    );
  }

  return value;
}

int _positiveIntFrom(GoRouterState state, String parameter) {
  final value = _positiveIntOrNull(state, parameter);

  if (value == null) {
    throw StateError(
      'Route parameter "$parameter" must be a positive integer.',
    );
  }

  return value;
}

int? _positiveIntOrNull(GoRouterState state, String parameter) {
  final raw = state.pathParameters[parameter];

  if (raw == null) {
    return null;
  }

  final value = int.tryParse(raw);

  if (value == null || value <= 0) {
    return null;
  }

  return value;
}

int _nonNegativeIntFrom(GoRouterState state, String parameter) {
  final value = _nonNegativeIntOrNull(state, parameter);

  if (value == null) {
    throw StateError(
      'Route parameter "$parameter" must be a non-negative integer.',
    );
  }

  return value;
}

int? _nonNegativeIntOrNull(GoRouterState state, String parameter) {
  final raw = state.pathParameters[parameter];

  if (raw == null) {
    return null;
  }

  final value = int.tryParse(raw);

  if (value == null || value < 0) {
    return null;
  }

  return value;
}

// =============================================================================
// Invalid-route fallbacks
// =============================================================================

/// Returns the media-details location represented by [state].
///
/// If the media parameters themselves are invalid, the owning root destination
/// is returned instead.
String _mediaLocationFor({
  required AppRootDestination destination,
  required GoRouterState state,
}) {
  if (!_hasValidMediaParameters(state)) {
    return AppRoutes.locationFor(destination);
  }

  return AppRoutes.mediaFor(
    destination,
    _mediaTypeFrom(state),
    _positiveIntFrom(state, AppRoutes.mediaIdParameter),
  );
}

/// Returns the season-details location represented by [state].
///
/// Invalid media parameters fall back to the root destination.
String _seasonLocationFor({
  required AppRootDestination destination,
  required GoRouterState state,
  required int seasonNumber,
}) {
  if (!_hasValidMediaParameters(state)) {
    return AppRoutes.locationFor(destination);
  }

  return AppRoutes.seasonFor(
    destination,
    _mediaTypeFrom(state),
    _positiveIntFrom(state, AppRoutes.mediaIdParameter),
    seasonNumber,
  );
}
