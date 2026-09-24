import 'dart:collection';

import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/widgets.dart';

import '../../../app/config/app_config.dart';
import '../presentation/pages/search_page.dart';

// =============================================================================
// Transport boundary
// =============================================================================

/// Minimal decoded-JSON GET boundary required by [SearchRepository].
///
/// The repository depends on this narrow transport contract rather than on a
/// specific HTTP implementation. Cineara's shared `ApiClient.getJson` satisfies
/// it directly:
///
/// ```dart
/// final repository = SearchRepository.fromAppConfig(
///   config: appConfig,
///   getJson: apiClient.getJson,
/// );
/// ```
///
/// The callback must:
///
/// - perform an HTTP GET for [uri];
/// - throw the app's normal network/server exception on transport failure;
/// - return already-decoded JSON on success.
///
/// Transport errors deliberately propagate unchanged. Search owns Search-data
/// decoding, not global networking/error policy.
typedef SearchJsonGet = Future<Object?> Function(Uri uri);

/// How Search > All is fetched.
enum SearchAllStrategy {
  /// Uses one grouped Search endpoint.
  ///
  /// The endpoint receives Cineara's backend query parameter:
  ///
  /// `GET /api/v1/search/overview?q=...`
  overview,

  /// Composes Search > All from the backend's focused Search categories.
  ///
  /// The current backend accepts:
  ///
  /// - `type=movies`;
  /// - `type=tv`;
  /// - `type=people`;
  /// - `type=collections`;
  /// - `type=studios`;
  /// - `type=topics`.
  ///
  /// Requests run in parallel and do not perform per-result enrichment.
  fanOut,
}

// =============================================================================
// Repository exception
// =============================================================================

enum SearchRepositoryErrorKind { invalidRequest, invalidPayload }

/// Search-specific validation/decoding failure.
///
/// HTTP, timeout, offline and authentication errors continue to come from
/// Cineara's shared networking layer rather than being wrapped here.
@immutable
final class SearchRepositoryException implements Exception {
  const SearchRepositoryException({
    required this.kind,
    required this.message,
    this.cause,
  });

  final SearchRepositoryErrorKind kind;
  final String message;
  final Object? cause;

  @override
  String toString() {
    final Object? resolvedCause = cause;

    return resolvedCause == null
        ? 'SearchRepositoryException($kind): $message'
        : 'SearchRepositoryException($kind): $message '
              'Cause: $resolvedCause';
  }
}

// =============================================================================
// Repository
// =============================================================================

/// Cineara Search data repository.
///
/// This is deliberately the only Search-specific network/data adapter required
/// by the current feature.
///
/// It:
///
/// - builds Cineara backend Search URIs;
/// - maps UI categories to backend Search types;
/// - decodes focused paginated responses;
/// - decodes grouped All/overview responses;
/// - maps JSON into the result contracts already consumed by `search_page.dart`;
/// - validates top-level payload structure;
/// - ignores a single malformed/unknown result while preserving valid siblings;
/// - never calls `/search/enrich`;
/// - never fetches detail endpoints to improve Search rows.
///
/// It does not:
///
/// - debounce;
/// - own loading state;
/// - persist recent searches;
/// - localize labels;
/// - talk to TMDB directly;
/// - own authentication, retry, timeout or connectivity behaviour.
final class SearchRepository {
  SearchRepository({
    required Uri baseUri,
    required this.getJson,
    this.allStrategy = SearchAllStrategy.fanOut,
    this.searchPath = '/api/v1/search',
    this.overviewPath = '/api/v1/search/overview',
    this.queryParameter = 'q',
    this.typeParameter = 'type',
    this.pageParameter = 'page',
    this.commonQueryParameters = const <String, String>{},
  }) : _baseUri = _validateBaseUri(baseUri),
       assert(searchPath != ''),
       assert(overviewPath != ''),
       assert(queryParameter != ''),
       assert(typeParameter != ''),
       assert(pageParameter != '');

  /// Convenience factory matching Cineara's existing [AppConfig].
  factory SearchRepository.fromAppConfig({
    required AppConfig config,
    required SearchJsonGet getJson,
    SearchAllStrategy allStrategy = SearchAllStrategy.fanOut,
    Map<String, String> commonQueryParameters = const <String, String>{},
  }) {
    return SearchRepository(
      baseUri: config.apiBaseUri,
      getJson: getJson,
      allStrategy: allStrategy,
      commonQueryParameters: commonQueryParameters,
    );
  }

  final Uri _baseUri;
  final SearchJsonGet getJson;

  final SearchAllStrategy allStrategy;

  final String searchPath;
  final String overviewPath;

  final String queryParameter;
  final String typeParameter;
  final String pageParameter;

  /// Parameters copied to every Search request.
  ///
  /// Use this only for request-wide backend parameters that are not already
  /// applied by the shared API client/interceptors.
  final Map<String, String> commonQueryParameters;

  /// Function signature expected by `CinearaSearchDependencies.loader`.
  Future<CinearaSearchResponse> search(CinearaSearchRequest request) async {
    final String query = _normalizeQuery(request.query);

    if (query.isEmpty) {
      throw const SearchRepositoryException(
        kind: SearchRepositoryErrorKind.invalidRequest,
        message: 'Search query must not be empty.',
      );
    }

    if (request.page < 1) {
      throw const SearchRepositoryException(
        kind: SearchRepositoryErrorKind.invalidRequest,
        message: 'Search page must be at least 1.',
      );
    }

    if (request.category == CinearaSearchCategory.all) {
      return switch (allStrategy) {
        SearchAllStrategy.overview => _loadOverview(query),
        SearchAllStrategy.fanOut => _loadAllByFanOut(query),
      };
    }

    return _loadPage(
      query: query,
      category: request.category,
      page: request.page,
    );
  }

  // ===========================================================================
  // Search > All
  // ===========================================================================

  Future<CinearaSearchResponse> _loadOverview(String query) async {
    final Uri uri = _buildUri(overviewPath, <String, String>{
      ...commonQueryParameters,
      queryParameter: query,
    });

    final Map<String, Object?> root = _expectMap(
      await getJson(uri),
      context: 'Search overview',
    );

    final List<CinearaSearchResult> results = _parseOverview(root);

    final int totalResults =
        _readInt(root, const <String>['total_results', 'totalResults']) ??
        results.length;

    return CinearaSearchResponse(
      results: List<CinearaSearchResult>.unmodifiable(results),
      page: 1,

      // All/overview has no global pagination because its sections have
      // independent result sets.
      totalPages: results.isEmpty ? 0 : 1,
      totalResults: totalResults < 0 ? 0 : totalResults,
    );
  }

  Future<CinearaSearchResponse> _loadAllByFanOut(String query) async {
    final List<CinearaSearchResponse>
    pages = await Future.wait<CinearaSearchResponse>(<
      Future<CinearaSearchResponse>
    >[
      _loadPage(query: query, category: CinearaSearchCategory.movies, page: 1),
      _loadPage(
        query: query,
        category: CinearaSearchCategory.tvSeries,
        page: 1,
      ),
      _loadPage(query: query, category: CinearaSearchCategory.people, page: 1),
      _loadPage(
        query: query,
        category: CinearaSearchCategory.collections,
        page: 1,
      ),
      _loadPage(query: query, category: CinearaSearchCategory.studios, page: 1),
      _loadPage(
        query: query,
        category: CinearaSearchCategory.keywords,
        page: 1,
      ),
    ]);

    final LinkedHashMap<String, CinearaSearchResult> deduplicated =
        LinkedHashMap<String, CinearaSearchResult>();

    int totalResults = 0;

    for (final CinearaSearchResponse page in pages) {
      totalResults += page.totalResults ?? page.results.length;

      for (final CinearaSearchResult result in page.results) {
        deduplicated[result.stableKey] = result;
      }
    }

    final List<CinearaSearchResult> results =
        List<CinearaSearchResult>.unmodifiable(deduplicated.values);

    return CinearaSearchResponse(
      results: results,
      page: 1,
      totalPages: results.isEmpty ? 0 : 1,
      totalResults: totalResults,
    );
  }

  List<CinearaSearchResult> _parseOverview(Map<String, Object?> root) {
    final LinkedHashMap<String, CinearaSearchResult> deduplicated =
        LinkedHashMap<String, CinearaSearchResult>();

    int encountered = 0;
    int rejected = 0;

    // Preferred grouped response shape.
    const List<String> sectionKeys = <String>[
      'top_results',
      'topResults',
      'movies',
      'tv',
      'tv_series',
      'tvSeries',
      'people',
      'collections',
      'companies',
      'studios',
      'keywords',
      'topics',
    ];

    for (final String key in sectionKeys) {
      if (!root.containsKey(key)) {
        continue;
      }

      final List<Object?> items = _extractItems(root[key]);
      final CinearaSearchCategory? categoryHint = _overviewCategoryHintForKey(
        key,
      );

      for (final Object? raw in items) {
        encountered++;

        final CinearaSearchResult? result = _tryParseResult(
          raw,
          categoryHint: categoryHint,
        );

        if (result == null) {
          rejected++;
          continue;
        }

        deduplicated[result.stableKey] = result;
      }
    }

    // Also accept:
    //
    // {
    //   "sections": [
    //     {"type": "collections", "results": [...]},
    //     ...
    //   ]
    // }
    final Object? sectionsRaw = root['sections'];

    if (sectionsRaw is List) {
      for (final Object? sectionRaw in sectionsRaw) {
        if (sectionRaw is! Map) {
          continue;
        }

        final Map<String, Object?> section = _stringKeyedMap(sectionRaw);
        final String? sectionType = _readString(section, const <String>[
          'type',
          'category',
          'result_type',
          'resultType',
        ]);
        final CinearaSearchCategory? categoryHint = sectionType == null
            ? null
            : _overviewCategoryHintForKey(sectionType);

        for (final Object? raw in _extractItems(section)) {
          encountered++;

          final CinearaSearchResult? result = _tryParseResult(
            raw,
            categoryHint: categoryHint,
          );

          if (result == null) {
            rejected++;
            continue;
          }

          deduplicated[result.stableKey] = result;
        }
      }
    }

    // Flat-overview compatibility.
    if (deduplicated.isEmpty && root.containsKey('results')) {
      for (final Object? raw in _extractItems(root['results'])) {
        encountered++;

        final CinearaSearchResult? result = _tryParseResult(raw);

        if (result == null) {
          rejected++;
          continue;
        }

        deduplicated[result.stableKey] = result;
      }
    }

    if (encountered > 0 && deduplicated.isEmpty && rejected > 0) {
      throw const SearchRepositoryException(
        kind: SearchRepositoryErrorKind.invalidPayload,
        message:
            'Search overview returned results, but none matched a supported '
            'Cineara Search result type.',
      );
    }

    return List<CinearaSearchResult>.unmodifiable(deduplicated.values);
  }

  // ===========================================================================
  // Focused paginated Search
  // ===========================================================================

  Future<CinearaSearchResponse> _loadPage({
    required String query,
    required CinearaSearchCategory category,
    required int page,
  }) async {
    if (category == CinearaSearchCategory.all) {
      throw const SearchRepositoryException(
        kind: SearchRepositoryErrorKind.invalidRequest,
        message: 'All Search must be composed from focused Search categories.',
      );
    }

    final Uri uri = _buildUri(searchPath, <String, String>{
      ...commonQueryParameters,
      queryParameter: query,
      typeParameter: _backendType(category),
      pageParameter: '$page',
    });

    final Map<String, Object?> root = _expectMap(
      await getJson(uri),
      context: 'Search page',
    );

    final List<Object?> rawResults = _extractItems(root['results']);
    final List<CinearaSearchResult> results = <CinearaSearchResult>[];

    int rejected = 0;

    for (final Object? raw in rawResults) {
      final CinearaSearchResult? result = _tryParseResult(
        raw,
        categoryHint: category,
      );

      if (result == null) {
        rejected++;
        continue;
      }

      results.add(result);
    }

    if (rawResults.isNotEmpty && results.isEmpty && rejected > 0) {
      throw SearchRepositoryException(
        kind: SearchRepositoryErrorKind.invalidPayload,
        message:
            'Search returned ${rawResults.length} result(s), but none matched '
            'a supported Cineara Search result type.',
      );
    }

    final int parsedPage = _readInt(root, const <String>['page']) ?? page;
    final int responsePage = parsedPage < 1 ? page : parsedPage;

    final int parsedTotalPages =
        _readInt(root, const <String>['total_pages', 'totalPages']) ??
        (results.isEmpty ? 0 : responsePage);

    final int parsedTotalResults =
        _readInt(root, const <String>['total_results', 'totalResults']) ??
        results.length;

    return CinearaSearchResponse(
      results: List<CinearaSearchResult>.unmodifiable(results),
      page: responsePage,
      totalPages: parsedTotalPages < 0 ? 0 : parsedTotalPages,
      totalResults: parsedTotalResults < 0 ? 0 : parsedTotalResults,
    );
  }

  CinearaSearchCategory? _overviewCategoryHintForKey(String value) {
    final String normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    return switch (normalized) {
      'movies' || 'movie' => CinearaSearchCategory.movies,
      'tv' ||
      'tv_series' ||
      'tvseries' ||
      'series' => CinearaSearchCategory.tvSeries,
      'people' || 'person' => CinearaSearchCategory.people,
      'collections' || 'collection' => CinearaSearchCategory.collections,
      'companies' ||
      'company' ||
      'studios' ||
      'studio' => CinearaSearchCategory.studios,
      'keywords' ||
      'keyword' ||
      'topics' ||
      'topic' => CinearaSearchCategory.keywords,
      _ => null,
    };
  }

  // ===========================================================================
  // Result parsing
  // ===========================================================================

  CinearaSearchResult? _tryParseResult(
    Object? raw, {
    CinearaSearchCategory? categoryHint,
  }) {
    try {
      return _parseResult(raw, categoryHint: categoryHint);
    } on SearchRepositoryException {
      return null;
    }
  }

  CinearaSearchResult? _parseResult(
    Object? raw, {
    CinearaSearchCategory? categoryHint,
  }) {
    if (raw is! Map) {
      return null;
    }

    final Map<String, Object?> json = _stringKeyedMap(raw);

    final String? type = _resultType(json, categoryHint: categoryHint);

    if (type == null) {
      return null;
    }

    return switch (type) {
      'movie' => _parseMedia(json, kind: CinearaSearchMediaKind.movie),

      'tv' ||
      'tv_series' ||
      'series' => _parseMedia(json, kind: CinearaSearchMediaKind.tvSeries),

      'person' => _parsePerson(json),

      'collection' => _parseEntity(
        json,
        kind: CinearaSearchEntityKind.collection,
      ),

      'company' ||
      'studio' => _parseEntity(json, kind: CinearaSearchEntityKind.studio),

      'keyword' || 'topic' => _parseKeyword(json),

      _ => null,
    };
  }

  CinearaSearchMediaResult _parseMedia(
    Map<String, Object?> json, {
    required CinearaSearchMediaKind kind,
  }) {
    final String id = _requireId(json);

    final String title = _requireText(json, const <String>[
      'title',
      'name',
    ], description: 'media title');

    final double? rating = _boundedRating(
      _readDouble(json, const <String>[
        'external_rating',
        'externalRating',
        'vote_average',
        'voteAverage',
      ]),
    );

    return CinearaSearchMediaResult(
      id: id,
      title: title,
      kind: kind,
      descriptor: _descriptorFor(kind, json),
      poster: _networkImage(
        _readString(json, const <String>[
          'image_url',
          'imageUrl',
          'poster_url',
          'posterUrl',
        ]),
      ),
      year: _readYear(json),
      primaryGenre: _readPrimaryGenre(json),
      externalRating: rating,
      heroTag: 'search:${kind.name}:$id',
    );
  }

  CinearaSearchPersonResult _parsePerson(Map<String, Object?> json) {
    final String id = _requireId(json);

    return CinearaSearchPersonResult(
      id: id,
      title: _requireText(json, const <String>[
        'name',
        'title',
      ], description: 'person name'),
      portrait: _networkImage(
        _readString(json, const <String>[
          'image_url',
          'imageUrl',
          'profile_url',
          'profileUrl',
        ]),
      ),
      knownForDepartment: _readString(json, const <String>[
        'known_for_department',
        'knownForDepartment',
      ]),
      knownFor: _readKnownFor(json),
      heroTag: 'search:person:$id',
    );
  }

  CinearaSearchEntityResult _parseEntity(
    Map<String, Object?> json, {
    required CinearaSearchEntityKind kind,
  }) {
    final String id = _requireId(json);

    final String description = switch (kind) {
      CinearaSearchEntityKind.collection => 'collection name',
      CinearaSearchEntityKind.studio => 'studio/company name',
    };

    return CinearaSearchEntityResult(
      id: id,
      title: _requireText(json, const <String>[
        'name',
        'title',
      ], description: description),
      kind: kind,
      artwork: _networkImage(
        _readString(json, const <String>[
          'image_url',
          'imageUrl',
          'poster_url',
          'posterUrl',
          'logo_url',
          'logoUrl',
        ]),
      ),
      heroTag: 'search:entity:${kind.name}:$id',
    );
  }

  CinearaSearchKeywordResult _parseKeyword(Map<String, Object?> json) {
    return CinearaSearchKeywordResult(
      id: _requireId(json),
      title: _requireText(json, const <String>[
        'name',
        'title',
      ], description: 'keyword name'),
    );
  }

  // ===========================================================================
  // Known-for parsing
  // ===========================================================================

  List<CinearaPersonKnownForItem> _readKnownFor(Map<String, Object?> json) {
    final Object? raw =
        json['known_for'] ??
        json['knownFor'] ??
        json['known_for_titles'] ??
        json['knownForTitles'];

    if (raw is! List) {
      return const <CinearaPersonKnownForItem>[];
    }

    final List<CinearaPersonKnownForItem> items = <CinearaPersonKnownForItem>[];

    for (final Object? entry in raw) {
      if (entry is String) {
        final String title = entry.trim();

        if (title.isNotEmpty) {
          items.add(CinearaPersonKnownForItem(title: title));
        }

        continue;
      }

      if (entry is! Map) {
        continue;
      }

      final Map<String, Object?> map = _stringKeyedMap(entry);

      final String? title = _readString(map, const <String>['title', 'name']);

      if (title == null) {
        continue;
      }

      items.add(CinearaPersonKnownForItem(title: title, year: _readYear(map)));
    }

    return List<CinearaPersonKnownForItem>.unmodifiable(items.take(3));
  }

  // ===========================================================================
  // Backend category mapping
  // ===========================================================================

  String _backendType(CinearaSearchCategory category) {
    return switch (category) {
      CinearaSearchCategory.all => throw const SearchRepositoryException(
        kind: SearchRepositoryErrorKind.invalidRequest,
        message: 'All Search must be composed from focused Search categories.',
      ),
      CinearaSearchCategory.movies => 'movies',
      CinearaSearchCategory.tvSeries => 'tv',
      CinearaSearchCategory.people => 'people',
      CinearaSearchCategory.collections => 'collections',
      CinearaSearchCategory.studios => 'studios',
      CinearaSearchCategory.keywords => 'topics',
    };
  }

  // ===========================================================================
  // URI construction
  // ===========================================================================

  Uri _buildUri(String endpointPath, Map<String, String> queryParameters) {
    final Uri endpoint = _resolveFromOrigin(_baseUri, endpointPath);

    return endpoint.replace(
      queryParameters: <String, String>{
        ...endpoint.queryParameters,
        ...queryParameters,
      },
    );
  }

  static Uri _resolveFromOrigin(Uri baseUri, String endpointPath) {
    final String normalized = endpointPath.startsWith('/')
        ? endpointPath
        : '/$endpointPath';

    return Uri(
      scheme: baseUri.scheme,
      userInfo: baseUri.userInfo,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      path: normalized,
    );
  }

  // ===========================================================================
  // Discriminator / presentation metadata
  // ===========================================================================

  String? _resultType(
    Map<String, Object?> json, {
    CinearaSearchCategory? categoryHint,
  }) {
    final String? explicit = _readString(json, const <String>[
      'result_type',
      'resultType',
      'media_type',
      'mediaType',
      'type',
      'kind',
    ]);

    if (explicit != null) {
      return _normalizeResultType(explicit);
    }

    // Focused category endpoints may omit a redundant row discriminator.
    return switch (categoryHint) {
      CinearaSearchCategory.movies => 'movie',
      CinearaSearchCategory.tvSeries => 'tv',
      CinearaSearchCategory.people => 'person',
      CinearaSearchCategory.collections => 'collection',
      CinearaSearchCategory.studios => 'company',
      CinearaSearchCategory.keywords => 'keyword',
      CinearaSearchCategory.all || null => null,
    };
  }

  String _normalizeResultType(String value) {
    final String normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    return switch (normalized) {
      'movies' => 'movie',
      'television' || 'television_series' || 'tvseries' => 'tv',
      'people' => 'person',
      'collections' => 'collection',
      'companies' ||
      'production_company' ||
      'production_companies' => 'company',
      'studios' => 'studio',
      'keywords' || 'topics' => 'keyword',
      _ => normalized,
    };
  }

  String _descriptorFor(
    CinearaSearchMediaKind kind,
    Map<String, Object?> json,
  ) {
    final String? backendValue = _readString(json, const <String>[
      'descriptor',
      'display_type',
      'displayType',
      'classification_label',
      'classificationLabel',
    ]);

    if (backendValue != null) {
      return backendValue;
    }

    // Machine-token fallback only. `search_page.dart` localizes these values
    // before rendering, so the repository remains language agnostic.
    return switch (kind) {
      CinearaSearchMediaKind.movie => 'movie',
      CinearaSearchMediaKind.tvSeries => 'tv',
    };
  }

  // ===========================================================================
  // Generic JSON helpers
  // ===========================================================================

  Map<String, Object?> _expectMap(Object? raw, {required String context}) {
    if (raw is Map) {
      return _stringKeyedMap(raw);
    }

    throw SearchRepositoryException(
      kind: SearchRepositoryErrorKind.invalidPayload,
      message: '$context response must be a JSON object.',
      cause: raw,
    );
  }

  Map<String, Object?> _stringKeyedMap(Map<dynamic, dynamic> raw) {
    final Map<String, Object?> result = <String, Object?>{};

    for (final MapEntry<dynamic, dynamic> entry in raw.entries) {
      final Object key = entry.key;

      if (key is String) {
        result[key] = entry.value;
      }
    }

    return result;
  }

  List<Object?> _extractItems(Object? raw) {
    if (raw is List<Object?>) {
      return raw;
    }

    if (raw is List) {
      return List<Object?>.from(raw);
    }

    if (raw is Map) {
      final Map<String, Object?> map = _stringKeyedMap(raw);

      final Object? nested = map['results'] ?? map['items'] ?? map['entries'];

      if (nested is List<Object?>) {
        return nested;
      }

      if (nested is List) {
        return List<Object?>.from(nested);
      }
    }

    return const <Object?>[];
  }

  String _requireId(Map<String, Object?> json) {
    final Object? raw = json['id'];

    if (raw is int && raw > 0) {
      return '$raw';
    }

    if (raw is num &&
        raw > 0 &&
        raw.isFinite &&
        raw == raw.truncateToDouble()) {
      return raw.toInt().toString();
    }

    if (raw is String) {
      final String value = raw.trim();

      if (value.isNotEmpty) {
        return value;
      }
    }

    throw const SearchRepositoryException(
      kind: SearchRepositoryErrorKind.invalidPayload,
      message: 'Search result is missing a valid id.',
    );
  }

  String _requireText(
    Map<String, Object?> json,
    List<String> keys, {
    required String description,
  }) {
    final String? value = _readString(json, keys);

    if (value != null) {
      return value;
    }

    throw SearchRepositoryException(
      kind: SearchRepositoryErrorKind.invalidPayload,
      message: 'Search result is missing $description.',
    );
  }

  String? _readString(Map<String, Object?> json, List<String> keys) {
    for (final String key in keys) {
      final Object? raw = json[key];

      if (raw is! String) {
        continue;
      }

      final String value = raw.trim();

      if (value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  int? _readInt(Map<String, Object?> json, List<String> keys) {
    for (final String key in keys) {
      final Object? raw = json[key];

      if (raw is int) {
        return raw;
      }

      if (raw is num && raw.isFinite && raw == raw.truncateToDouble()) {
        return raw.toInt();
      }

      if (raw is String) {
        final int? parsed = int.tryParse(raw.trim());

        if (parsed != null) {
          return parsed;
        }
      }
    }

    return null;
  }

  double? _readDouble(Map<String, Object?> json, List<String> keys) {
    for (final String key in keys) {
      final Object? raw = json[key];

      if (raw is num && raw.isFinite) {
        return raw.toDouble();
      }

      if (raw is String) {
        final double? parsed = double.tryParse(raw.trim());

        if (parsed != null && parsed.isFinite) {
          return parsed;
        }
      }
    }

    return null;
  }

  int? _readYear(Map<String, Object?> json) {
    final int? direct = _readInt(json, const <String>[
      'year',
      'release_year',
      'releaseYear',
    ]);

    if (direct != null && direct >= 1000 && direct <= 9999) {
      return direct;
    }

    final String? date = _readString(json, const <String>[
      'release_date',
      'releaseDate',
      'first_air_date',
      'firstAirDate',
    ]);

    if (date == null || date.length < 4) {
      return null;
    }

    final int? parsed = int.tryParse(date.substring(0, 4));

    if (parsed == null || parsed < 1000 || parsed > 9999) {
      return null;
    }

    return parsed;
  }

  String? _readPrimaryGenre(Map<String, Object?> json) {
    final String? direct = _readString(json, const <String>[
      'primary_genre',
      'primaryGenre',
    ]);

    if (direct != null) {
      return direct;
    }

    final Object? raw = json['genres'];

    if (raw is! List || raw.isEmpty) {
      return null;
    }

    final Object? first = raw.first;

    if (first is String) {
      final String value = first.trim();
      return value.isEmpty ? null : value;
    }

    if (first is Map) {
      return _readString(_stringKeyedMap(first), const <String>[
        'name',
        'label',
      ]);
    }

    return null;
  }

  double? _boundedRating(double? value) {
    if (value == null || !value.isFinite || value < 0 || value > 10) {
      return null;
    }

    return value;
  }

  ImageProvider<Object>? _networkImage(String? value) {
    if (value == null) {
      return null;
    }

    final Uri? uri = Uri.tryParse(value);

    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return null;
    }

    return NetworkImage(uri.toString());
  }

  String _normalizeQuery(String value) {
    return value.trim().replaceAll(RegExp(r'\s+', unicode: true), ' ');
  }

  static Uri _validateBaseUri(Uri value) {
    if (!value.hasScheme ||
        value.host.isEmpty ||
        (value.scheme != 'http' && value.scheme != 'https')) {
      throw ArgumentError.value(
        value,
        'baseUri',
        'Expected an absolute HTTP or HTTPS URI.',
      );
    }

    return value;
  }
}
