import 'package:flutter/material.dart';

/// Broad category represented by a Cineara search result.
///
/// Search distinguishes only movies, series and people.
/// More specific classifications such as anime and K-drama remain descriptive
/// metadata and do not become global-search categories.
enum CinearaSearchResultType { movie, series, person }

/// Presentation model for one result displayed by Cineara Search.
///
/// Domain entities, backend DTOs and TMDB response objects should be mapped to
/// this model before they reach the presentation layer.
@immutable
class CinearaSearchResult {
  const CinearaSearchResult({
    required this.id,
    required this.title,
    required this.metadata,
    required this.typeLabel,
    required this.type,
    this.imageProvider,
    this.semanticLabel,
  });

  /// Stable result identifier.
  final String id;

  /// Primary result title.
  final String title;

  /// Compact supporting metadata.
  ///
  /// Examples:
  ///
  /// ```text
  /// 2023 • Japan
  /// 2024 • South Korea
  /// Director • Japan
  /// ```
  final String metadata;

  /// Localized descriptive result classification.
  ///
  /// Examples:
  ///
  /// ```text
  /// Movie
  /// Series
  /// Series • Anime
  /// Series • K-drama
  /// Person
  /// ```
  final String typeLabel;

  /// Broad Search category.
  final CinearaSearchResultType type;

  /// Optional poster or profile artwork.
  ///
  /// Movies and series use poster artwork. Person results use
  /// profile artwork.
  final ImageProvider<Object>? imageProvider;

  /// Optional accessibility description for the complete result.
  ///
  /// When null, [SearchResultItem] derives a description from the visible
  /// result fields.
  final String? semanticLabel;
}
