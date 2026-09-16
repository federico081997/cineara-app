import '../shell/app_root_destination.dart';

/// Route locations, relative route patterns, parameter names, and path-building
/// helpers used by Cineara.
///
/// Cineara's four primary destinations are root locations:
///
/// ```text
/// /home
/// /discover
/// /library
/// /profile
/// ```
///
/// Normal application flows are nested beneath the root destination from which
/// they were opened:
///
/// ```text
/// /home/search
/// /discover/media/movie/123
/// /library/media/tv/456/season/2
/// /home/media/tv/456/season/2/episode/5
/// ```
///
/// Keeping these routes inside their corresponding shell branch preserves the
/// persistent bottom navigation and allows each branch to retain its own
/// navigation stack.
///
/// Route declarations should use the relative segment constants such as
/// [searchSegment], [mediaSegment], [seasonSegment], and [episodeSegment].
/// Application navigation should generally use the path-building helpers such
/// as [mediaFor] instead of assembling route strings manually.
abstract final class AppRoutes {
  // ---------------------------------------------------------------------------
  // Root locations
  // ---------------------------------------------------------------------------

  static const String root = '/';

  static const String home = '/home';
  static const String discover = '/discover';
  static const String library = '/library';
  static const String profile = '/profile';

  // ---------------------------------------------------------------------------
  // Root route names
  // ---------------------------------------------------------------------------

  static const String homeName = 'home';
  static const String discoverName = 'discover';
  static const String libraryName = 'library';
  static const String profileName = 'profile';

  // ---------------------------------------------------------------------------
  // Route parameter names
  // ---------------------------------------------------------------------------

  static const String mediaTypeParameter = 'mediaType';
  static const String mediaIdParameter = 'mediaId';
  static const String seasonNumberParameter = 'seasonNumber';
  static const String episodeNumberParameter = 'episodeNumber';

  // ---------------------------------------------------------------------------
  // Relative nested route segments
  // ---------------------------------------------------------------------------

  /// Search route nested directly beneath a root destination.
  ///
  /// Example:
  ///
  /// ```text
  /// /discover/search
  /// ```
  static const String searchSegment = 'search';

  /// Media-details route nested directly beneath a root destination.
  ///
  /// Example:
  ///
  /// ```text
  /// /discover/media/movie/123
  /// ```
  static const String mediaSegment =
      'media/:$mediaTypeParameter/:$mediaIdParameter';

  /// Season route nested beneath a media-details route.
  ///
  /// Example:
  ///
  /// ```text
  /// /discover/media/tv/123/season/2
  /// ```
  static const String seasonSegment = 'season/:$seasonNumberParameter';

  /// Episode route nested beneath a season route.
  ///
  /// Example:
  ///
  /// ```text
  /// /discover/media/tv/123/season/2/episode/5
  /// ```
  static const String episodeSegment = 'episode/:$episodeNumberParameter';

  // ---------------------------------------------------------------------------
  // Root destination helpers
  // ---------------------------------------------------------------------------

  /// Returns the absolute root location for [destination].
  static String locationFor(AppRootDestination destination) {
    return switch (destination) {
      AppRootDestination.home => home,
      AppRootDestination.discover => discover,
      AppRootDestination.library => library,
      AppRootDestination.profile => profile,
    };
  }

  /// Returns the route name for [destination].
  static String nameFor(AppRootDestination destination) {
    return switch (destination) {
      AppRootDestination.home => homeName,
      AppRootDestination.discover => discoverName,
      AppRootDestination.library => libraryName,
      AppRootDestination.profile => profileName,
    };
  }

  // ---------------------------------------------------------------------------
  // Absolute path builders
  // ---------------------------------------------------------------------------

  /// Returns the Search location nested beneath [destination].
  ///
  /// Example:
  ///
  /// ```dart
  /// AppRoutes.searchFor(AppRootDestination.discover);
  /// // /discover/search
  /// ```
  static String searchFor(AppRootDestination destination) {
    return '${locationFor(destination)}/$searchSegment';
  }

  /// Returns the media-details location nested beneath [destination].
  ///
  /// Dynamic path values are URI encoded before being inserted into the route.
  ///
  /// Example:
  ///
  /// ```dart
  /// AppRoutes.mediaFor(
  ///   AppRootDestination.discover,
  ///   'movie',
  ///   550,
  /// );
  ///
  /// // /discover/media/movie/550
  /// ```
  static String mediaFor(
    AppRootDestination destination,
    String mediaType,
    int mediaId,
  ) {
    assert(mediaType.isNotEmpty, 'mediaType must not be empty.');
    assert(mediaId > 0, 'mediaId must be greater than zero.');

    final encodedMediaType = Uri.encodeComponent(mediaType);

    return '${locationFor(destination)}'
        '/media/$encodedMediaType/$mediaId';
  }

  /// Returns the season-details location for a media item.
  ///
  /// Example:
  ///
  /// ```dart
  /// AppRoutes.seasonFor(
  ///   AppRootDestination.discover,
  ///   'tv',
  ///   1399,
  ///   3,
  /// );
  ///
  /// // /discover/media/tv/1399/season/3
  /// ```
  static String seasonFor(
    AppRootDestination destination,
    String mediaType,
    int mediaId,
    int seasonNumber,
  ) {
    assert(seasonNumber >= 0, 'seasonNumber must not be negative.');

    return '${mediaFor(destination, mediaType, mediaId)}'
        '/season/$seasonNumber';
  }

  /// Returns the episode-details location for a season.
  ///
  /// Example:
  ///
  /// ```dart
  /// AppRoutes.episodeFor(
  ///   AppRootDestination.discover,
  ///   'tv',
  ///   1399,
  ///   3,
  ///   4,
  /// );
  ///
  /// // /discover/media/tv/1399/season/3/episode/4
  /// ```
  static String episodeFor(
    AppRootDestination destination,
    String mediaType,
    int mediaId,
    int seasonNumber,
    int episodeNumber,
  ) {
    assert(episodeNumber > 0, 'episodeNumber must be greater than zero.');

    return '${seasonFor(destination, mediaType, mediaId, seasonNumber)}/episode/$episodeNumber';
  }

  // ---------------------------------------------------------------------------
  // Location classification
  // ---------------------------------------------------------------------------

  /// Whether [location] points exactly to one of Cineara's root destinations.
  ///
  /// Query parameters and fragments do not affect root classification:
  ///
  /// ```text
  /// /home                  -> true
  /// /home?section=continue -> true
  /// /home#watchlist        -> true
  ///
  /// /home/search           -> false
  /// /home/media/movie/550  -> false
  /// ```
  ///
  /// A trailing slash is treated equivalently to the corresponding root path:
  ///
  /// ```text
  /// /home/ -> true
  /// ```
  static bool isRootLocation(String location) {
    final path = _normalizedPath(location);

    return switch (path) {
      home || discover || library || profile => true,
      _ => false,
    };
  }

  /// Returns the root destination that owns [location].
  ///
  /// Nested locations are associated with the branch under which they live:
  ///
  /// ```text
  /// /discover/search
  ///     -> AppRootDestination.discover
  ///
  /// /library/media/movie/550
  ///     -> AppRootDestination.library
  /// ```
  ///
  /// Returns `null` when the location is outside the known root branches.
  static AppRootDestination? destinationForLocation(String location) {
    final path = _normalizedPath(location);

    for (final destination in AppRootDestination.values) {
      final rootLocation = locationFor(destination);

      if (path == rootLocation || path.startsWith('$rootLocation/')) {
        return destination;
      }
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Extracts and normalizes the path portion of a route location.
  static String _normalizedPath(String location) {
    if (location.isEmpty) {
      return root;
    }

    final uri = Uri.tryParse(location);
    var path = uri?.path ?? location;

    if (path.isEmpty) {
      return root;
    }

    if (!path.startsWith('/')) {
      path = '/$path';
    }

    while (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    return path;
  }
}
