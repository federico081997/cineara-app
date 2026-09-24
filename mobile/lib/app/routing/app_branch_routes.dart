import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/media/media.dart';
import '../../features/search/search.dart';
import '../shell/app_root_destination.dart';
import 'app_routes.dart';

/// Builds the nested routes shared by every Cineara root navigation branch.
///
/// Search remains on the current [StatefulShellBranch]. Its route uses a
/// [NoTransitionPage] because the persistent shell owns the Search-bar morph,
/// while [SearchPage] owns category, loading and result motion inside the page.
///
/// Media, season and episode routes remain branch-local so Cineara's persistent
/// bottom navigation and independent branch history stay intact.
List<RouteBase> buildSharedBranchRoutes({
  required AppRootDestination destination,
}) {
  return <RouteBase>[
    // -------------------------------------------------------------------------
    // Search
    // -------------------------------------------------------------------------
    GoRoute(
      path: AppRoutes.searchSegment,
      pageBuilder: (BuildContext context, GoRouterState state) {
        debugPrint('[SEARCH] Route matched: ${state.uri}');

        return NoTransitionPage<void>(
          key: state.pageKey,
          child: SearchPage(destination: destination),
        );
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
        final String mediaType = _mediaTypeFrom(state);
        final int mediaId = _positiveIntFrom(state, AppRoutes.mediaIdParameter);

        return MediaDetailsPage(mediaType: mediaType, mediaId: mediaId);
      },
      routes: <RouteBase>[
        // ---------------------------------------------------------------------
        // Season details
        // ---------------------------------------------------------------------
        GoRoute(
          path: AppRoutes.seasonSegment,
          redirect: (context, state) {
            if (!_hasValidMediaParameters(state)) {
              return AppRoutes.locationFor(destination);
            }

            final int? seasonNumber = _nonNegativeIntOrNull(
              state,
              AppRoutes.seasonNumberParameter,
            );

            if (seasonNumber == null) {
              return _mediaLocationFor(destination: destination, state: state);
            }

            return null;
          },
          builder: (context, state) {
            final String mediaType = _mediaTypeFrom(state);
            final int mediaId = _positiveIntFrom(
              state,
              AppRoutes.mediaIdParameter,
            );
            final int seasonNumber = _nonNegativeIntFrom(
              state,
              AppRoutes.seasonNumberParameter,
            );

            return SeasonDetailsPage(
              mediaType: mediaType,
              mediaId: mediaId,
              seasonNumber: seasonNumber,
            );
          },
          routes: <RouteBase>[
            // -----------------------------------------------------------------
            // Episode details
            // -----------------------------------------------------------------
            GoRoute(
              path: AppRoutes.episodeSegment,
              redirect: (context, state) {
                if (!_hasValidMediaParameters(state)) {
                  return AppRoutes.locationFor(destination);
                }

                final int? seasonNumber = _nonNegativeIntOrNull(
                  state,
                  AppRoutes.seasonNumberParameter,
                );

                if (seasonNumber == null) {
                  return _mediaLocationFor(
                    destination: destination,
                    state: state,
                  );
                }

                final int? episodeNumber = _positiveIntOrNull(
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
                final String mediaType = _mediaTypeFrom(state);
                final int mediaId = _positiveIntFrom(
                  state,
                  AppRoutes.mediaIdParameter,
                );
                final int seasonNumber = _nonNegativeIntFrom(
                  state,
                  AppRoutes.seasonNumberParameter,
                );
                final int episodeNumber = _positiveIntFrom(
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

bool _hasValidMediaParameters(GoRouterState state) {
  final String? mediaType = state.pathParameters[AppRoutes.mediaTypeParameter];

  if (mediaType == null || mediaType.trim().isEmpty) {
    return false;
  }

  return _positiveIntOrNull(state, AppRoutes.mediaIdParameter) != null;
}

// =============================================================================
// Parameter extraction
// =============================================================================

String _mediaTypeFrom(GoRouterState state) {
  final String? value = state.pathParameters[AppRoutes.mediaTypeParameter];

  if (value == null || value.trim().isEmpty) {
    throw StateError(
      'Missing or empty "${AppRoutes.mediaTypeParameter}" route parameter.',
    );
  }

  return value;
}

int _positiveIntFrom(GoRouterState state, String parameter) {
  final int? value = _positiveIntOrNull(state, parameter);

  if (value == null) {
    throw StateError(
      'Route parameter "$parameter" must be a positive integer.',
    );
  }

  return value;
}

int? _positiveIntOrNull(GoRouterState state, String parameter) {
  final String? raw = state.pathParameters[parameter];

  if (raw == null) {
    return null;
  }

  final int? value = int.tryParse(raw);

  if (value == null || value <= 0) {
    return null;
  }

  return value;
}

int _nonNegativeIntFrom(GoRouterState state, String parameter) {
  final int? value = _nonNegativeIntOrNull(state, parameter);

  if (value == null) {
    throw StateError(
      'Route parameter "$parameter" must be a non-negative integer.',
    );
  }

  return value;
}

int? _nonNegativeIntOrNull(GoRouterState state, String parameter) {
  final String? raw = state.pathParameters[parameter];

  if (raw == null) {
    return null;
  }

  final int? value = int.tryParse(raw);

  if (value == null || value < 0) {
    return null;
  }

  return value;
}

// =============================================================================
// Invalid-route fallbacks
// =============================================================================

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
