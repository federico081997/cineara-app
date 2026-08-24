import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// One page returned by Cineara's backend Search endpoint.
class SearchPageDto {
  const SearchPageDto({
    required this.query,
    required this.searchType,
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.results,
  });

  final String query;
  final String searchType;

  final int page;
  final int totalPages;
  final int totalResults;

  final List<SearchResultDto> results;

  factory SearchPageDto.fromJson(Map<String, dynamic> json) {
    return SearchPageDto(
      query: json['query'] as String,
      searchType: json['search_type'] as String,
      page: json['page'] as int,
      totalPages: json['total_pages'] as int,
      totalResults: json['total_results'] as int,
      results: (json['results'] as List<dynamic>? ?? const <dynamic>[])
          .map(
            (dynamic value) =>
                SearchResultDto.fromJson(value as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }
}

/// One result returned by Cineara's backend Search endpoint.
class SearchResultDto {
  const SearchResultDto({
    required this.id,
    required this.mediaType,
    required this.title,
    required this.genres,
    this.mediaFormat,
    this.imageUrl,
    this.year,
    this.specialClassification,
    this.knownForDepartment,
  });

  final int id;

  /// Backend values:
  ///
  /// movie
  /// tv
  /// person
  final String mediaType;

  /// Backend values:
  ///
  /// movie
  /// tv_movie
  /// series
  final String? mediaFormat;

  final String title;
  final String? imageUrl;
  final int? year;

  /// Presentation-ready genre names returned by the backend.
  ///
  /// Examples:
  ///
  /// Animation
  /// Romance
  /// Sci-Fi & Fantasy
  final List<String> genres;

  /// Optional Cineara classification.
  ///
  /// Examples:
  ///
  /// anime
  /// k_drama
  /// c_drama
  final String? specialClassification;

  final String? knownForDepartment;

  factory SearchResultDto.fromJson(Map<String, dynamic> json) {
    return SearchResultDto(
      id: json['id'] as int,
      mediaType: json['media_type'] as String,
      mediaFormat: json['media_format'] as String?,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String?,
      year: json['year'] as int?,
      genres:
          (json['genres'] as List<dynamic>?)?.whereType<String>().toList(
            growable: false,
          ) ??
          const <String>[],
      specialClassification: json['special_classification'] as String?,
      knownForDepartment: json['known_for_department'] as String?,
    );
  }
}

/// Failure returned while communicating with Cineara's Search API.
class SearchRepositoryException implements Exception {
  const SearchRepositoryException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() {
    if (statusCode == null) {
      return 'SearchRepositoryException: $message';
    }

    return 'SearchRepositoryException($statusCode): $message';
  }
}

/// Repository responsible for Cineara Search HTTP requests.
///
/// Flutter communicates only with Cineara's backend. Redis and TMDB remain
/// backend implementation details.
class SearchRepository {
  SearchRepository({
    required http.Client client,
    required Uri baseUri,
    this.requestTimeout = const Duration(seconds: 12),
  }) : _client = client,
       _baseUri = _withTrailingSlash(baseUri);

  final http.Client _client;
  final Uri _baseUri;

  final Duration requestTimeout;

  Future<SearchPageDto> search({
    required String query,
    required String type,
    int page = 1,
  }) async {
    final String normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      throw const SearchRepositoryException('Search query must not be empty.');
    }

    if (page < 1) {
      throw const SearchRepositoryException(
        'Search page must be greater than zero.',
      );
    }

    final Uri uri = _baseUri
        .resolve('search')
        .replace(
          queryParameters: <String, String>{
            'query': normalizedQuery,
            'type': type,
            'page': page.toString(),
          },
        );

    final http.Response response;

    try {
      response = await _client
          .get(
            uri,
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(requestTimeout);
    } on TimeoutException {
      throw const SearchRepositoryException('The search request timed out.');
    } on Exception catch (error) {
      throw SearchRepositoryException(
        'Could not connect to the Cineara backend: $error',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SearchRepositoryException(
        _errorMessageFromResponse(response),
        statusCode: response.statusCode,
      );
    }

    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const SearchRepositoryException(
        'The search response was not valid JSON.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const SearchRepositoryException(
        'The search response had an unexpected format.',
      );
    }

    try {
      return SearchPageDto.fromJson(decoded);
    } on Object catch (error) {
      throw SearchRepositoryException(
        'The search response could not be parsed: $error',
      );
    }
  }
}

Uri _withTrailingSlash(Uri uri) {
  if (uri.path.endsWith('/')) {
    return uri;
  }

  return uri.replace(path: '${uri.path}/');
}

String _errorMessageFromResponse(http.Response response) {
  try {
    final dynamic decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      final dynamic detail = decoded['detail'];

      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }
    }
  } on FormatException {
    // Fall through to the generic HTTP error.
  }

  return 'Search failed with HTTP ${response.statusCode}.';
}
