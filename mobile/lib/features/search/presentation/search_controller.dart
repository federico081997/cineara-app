import 'dart:async';

import 'package:flutter/material.dart';

import '../data/search_repository.dart';
import 'search_content_view.dart';

/// Coordinates query changes, filtering and backend Search requests.
///
/// The controller intentionally owns:
///
/// - query debouncing;
/// - backend filter selection;
/// - loading state;
/// - error state;
/// - stale-request protection;
/// - backend DTO -> presentation-model mapping.
///
/// Search widgets remain presentation-only.
class CinearaSearchController extends ChangeNotifier {
  CinearaSearchController({
    required SearchRepository repository,
    this.minimumQueryLength = 2,
    this.debounceDuration = const Duration(milliseconds: 350),
  }) : _repository = repository;

  final SearchRepository _repository;

  final int minimumQueryLength;
  final Duration debounceDuration;

  Timer? _debounce;

  String _query = '';

  CinearaSearchFilter _filter = CinearaSearchFilter.all;

  List<CinearaSearchResult> _results = const <CinearaSearchResult>[];

  bool _isLoading = false;
  String? _errorMessage;

  int _requestGeneration = 0;

  String get query => _query;

  CinearaSearchFilter get filter => _filter;

  List<CinearaSearchResult> get results => _results;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasSearchableQuery => _query.length >= minimumQueryLength;

  /// Called whenever the text field changes.
  ///
  /// Requests are debounced so typing several characters quickly does not send
  /// one HTTP request for every keystroke.
  void onQueryChanged(String value) {
    final String nextQuery = value.trim();

    if (_query == nextQuery) {
      return;
    }

    _query = nextQuery;

    _debounce?.cancel();

    if (!hasSearchableQuery) {
      _requestGeneration++;

      _results = const <CinearaSearchResult>[];
      _errorMessage = null;
      _isLoading = false;

      notifyListeners();
      return;
    }

    _debounce = Timer(debounceDuration, () {
      search();
    });
  }

  /// Immediately searches the submitted query.
  Future<void> submit(String value) async {
    _query = value.trim();

    _debounce?.cancel();

    if (!hasSearchableQuery) {
      _requestGeneration++;

      _results = const <CinearaSearchResult>[];
      _errorMessage = null;
      _isLoading = false;

      notifyListeners();
      return;
    }

    await search();
  }

  /// Changes the backend Search category.
  ///
  /// Filtering is performed by the backend rather than by filtering one
  /// paginated "all" response locally.
  Future<void> setFilter(CinearaSearchFilter filter) async {
    if (_filter == filter) {
      return;
    }

    _filter = filter;

    _debounce?.cancel();

    if (!hasSearchableQuery) {
      notifyListeners();
      return;
    }

    await search();
  }

  Future<void> retry() {
    return search();
  }

  /// Fetches the first page for the current query/filter.
  Future<void> search() async {
    if (!hasSearchableQuery) {
      return;
    }

    final String requestedQuery = _query;
    final CinearaSearchFilter requestedFilter = _filter;

    final int generation = ++_requestGeneration;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final SearchPageDto page = await _repository.search(
        query: requestedQuery,
        type: _backendSearchType(requestedFilter),
        page: 1,
      );

      if (generation != _requestGeneration) {
        return;
      }

      if (_query != requestedQuery || _filter != requestedFilter) {
        return;
      }

      _results = page.results.map(_mapSearchResult).toList(growable: false);

      _isLoading = false;
      _errorMessage = null;

      notifyListeners();
    } on SearchRepositoryException catch (error) {
      if (generation != _requestGeneration) {
        return;
      }

      _results = const <CinearaSearchResult>[];
      _isLoading = false;
      _errorMessage = error.message;

      notifyListeners();
    } on Object {
      if (generation != _requestGeneration) {
        return;
      }

      _results = const <CinearaSearchResult>[];
      _isLoading = false;
      _errorMessage = 'Search could not be completed.';

      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

String _backendSearchType(CinearaSearchFilter filter) {
  return switch (filter) {
    CinearaSearchFilter.all => 'all',
    CinearaSearchFilter.movies => 'movies',
    CinearaSearchFilter.series => 'tv',
    CinearaSearchFilter.people => 'people',
  };
}

CinearaSearchResult _mapSearchResult(SearchResultDto dto) {
  final CinearaSearchResultType type = switch (dto.mediaType) {
    'movie' => CinearaSearchResultType.movie,
    'tv' => CinearaSearchResultType.series,
    'person' => CinearaSearchResultType.person,
    _ => throw ArgumentError.value(
      dto.mediaType,
      'mediaType',
      'Unsupported Search media type.',
    ),
  };

  final String? imageUrl = _normalizedOptionalText(dto.imageUrl);

  return CinearaSearchResult(
    id: '${dto.mediaType}:${dto.id}',
    title: dto.title,
    typeLabel: _buildTypeLabel(dto),
    metadata: _buildSupportingMetadata(dto),
    type: type,
    imageProvider: imageUrl == null ? null : NetworkImage(imageUrl),
  );
}

/// Builds the middle line of a Search row.
///
/// Examples:
///
/// Series · Anime · Fantasy
/// Series · K-Drama · Comedy
/// Series · Drama · Crime
/// Movie · Animation · Romance
String _buildTypeLabel(SearchResultDto dto) {
  if (dto.mediaType == 'person') {
    return 'Person';
  }

  final List<String> parts = <String>[_mediaFormatLabel(dto)];

  final String? classification = _normalizedOptionalText(
    dto.specialClassification,
  );

  if (classification != null) {
    parts.add(_specialClassificationLabel(classification));
  }

  final List<String> genres = _displayGenres(dto);

  // Search rows are compact. With a special classification, one genre usually
  // provides enough additional information. Without one, show up to two.
  final int genreLimit = classification == null ? 2 : 1;

  parts.addAll(genres.take(genreLimit));

  return parts.join(' · ');
}

/// Builds the third line.
///
/// Media results show the year.
///
/// Person results show TMDB's known-for department when available.
String _buildSupportingMetadata(SearchResultDto dto) {
  if (dto.mediaType == 'person') {
    return _normalizedOptionalText(dto.knownForDepartment) ?? '';
  }

  return dto.year?.toString() ?? '';
}

List<String> _displayGenres(SearchResultDto dto) {
  final List<String> genres = dto.genres
      .map((String value) => value.trim())
      .where((String value) => value.isNotEmpty)
      .toList(growable: true);

  final String? classification = _normalizedOptionalText(
    dto.specialClassification,
  );

  // "Anime · Animation" is redundant in a compact Search row.
  if (classification == 'anime') {
    genres.removeWhere((String genre) => genre.toLowerCase() == 'animation');
  }

  // K-Drama/C-Drama/etc. do not mean the TMDB Drama genre, but when more
  // descriptive genres are available, showing "Drama" immediately after the
  // regional classification adds little information.
  if (_isRegionalDrama(classification) && genres.length > 1) {
    genres.removeWhere((String genre) => genre.toLowerCase() == 'drama');
  }

  return genres;
}

bool _isRegionalDrama(String? classification) {
  return switch (classification) {
    'k_drama' ||
    'c_drama' ||
    'j_drama' ||
    'taiwanese_drama' ||
    'hong_kong_drama' ||
    'thai_drama' ||
    'indian_drama' ||
    'pakistani_drama' ||
    'turkish_drama' => true,
    _ => false,
  };
}

String _mediaFormatLabel(SearchResultDto dto) {
  return switch (dto.mediaFormat) {
    'movie' => 'Movie',
    'tv_movie' => 'TV Movie',
    'series' => 'Series',

    // Defensive fallbacks.
    _ when dto.mediaType == 'movie' => 'Movie',
    _ when dto.mediaType == 'tv' => 'Series',
    _ => 'Media',
  };
}

String _specialClassificationLabel(String classification) {
  return switch (classification) {
    'anime' => 'Anime',
    'k_drama' => 'K-Drama',
    'c_drama' => 'C-Drama',
    'j_drama' => 'J-Drama',
    'taiwanese_drama' => 'Taiwanese Drama',
    'hong_kong_drama' => 'Hong Kong Drama',
    'thai_drama' => 'Thai Drama',
    'indian_drama' => 'Indian Drama',
    'pakistani_drama' => 'Pakistani Drama',
    'turkish_drama' => 'Turkish Drama',
    _ => classification,
  };
}

String? _normalizedOptionalText(String? value) {
  if (value == null) {
    return null;
  }

  final String normalized = value.trim();

  return normalized.isEmpty ? null : normalized;
}
