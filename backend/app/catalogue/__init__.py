"""Public exports for Cineara catalogue classification support.

This package contains provider-independent catalogue concepts and deterministic
classification utilities used across Cineara features.

The package root exposes:

- canonical media genres;
- TMDB-to-canonical genre translation helpers;
- normalized media classification evidence;
- structural media formats;
- cultural and program classifications;
- media classification functions.

The catalogue package does not perform:

- network requests;
- TMDB or Wikidata access;
- caching;
- persistence;
- Search orchestration;
- presentation formatting;
- user-library logic.

Provider integrations are responsible for translating their raw metadata into
the normalized types exported here before invoking catalogue classification.
"""

from __future__ import annotations

from .genre_registry import (
    GenreResolution,
    MediaGenre,
    TmdbGenreDefinition,
    is_movie_genre,
    is_tv_genre,
    movie_genre_definition,
    movie_genres_from_tmdb_id,
    movie_tmdb_genre_count,
    movie_tmdb_genre_ids,
    movie_tmdb_genre_name,
    normalize_media_genres,
    resolve_movie_genres,
    resolve_tv_genres,
    tmdb_movie_genre_ids_for,
    tmdb_tv_genre_ids_for,
    tv_genre_definition,
    tv_genres_from_tmdb_id,
    tv_tmdb_genre_count,
    tv_tmdb_genre_ids,
    tv_tmdb_genre_name,
)
from .media_classification import (
    CulturalClassification,
    MediaClassification,
    MediaClassificationEvidence,
    MediaFormat,
    MediaKind,
    MediaOrigin,
    ProgrammeClassification,
    classify_media,
    classify_movie,
    classify_tv,
)

# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "CulturalClassification",
    "GenreResolution",
    "MediaClassification",
    "MediaClassificationEvidence",
    "MediaFormat",
    "MediaGenre",
    "MediaKind",
    "MediaOrigin",
    "ProgrammeClassification",
    "TmdbGenreDefinition",
    "classify_media",
    "classify_movie",
    "classify_tv",
    "is_movie_genre",
    "is_tv_genre",
    "movie_genre_definition",
    "movie_genres_from_tmdb_id",
    "movie_tmdb_genre_count",
    "movie_tmdb_genre_ids",
    "movie_tmdb_genre_name",
    "normalize_media_genres",
    "resolve_movie_genres",
    "resolve_tv_genres",
    "tmdb_movie_genre_ids_for",
    "tmdb_tv_genre_ids_for",
    "tv_genre_definition",
    "tv_genres_from_tmdb_id",
    "tv_tmdb_genre_count",
    "tv_tmdb_genre_ids",
    "tv_tmdb_genre_name",
]
