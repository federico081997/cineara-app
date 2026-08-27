"""Mapping from raw TMDB Search data into Cineara Search schemas.

This module is the boundary between provider-specific TMDB transport models
and Cineara's provider-independent Search API.

The mapper owns deterministic transformation only:

- TMDB genre IDs -> canonical Cineara genres;
- canonical genres/origin -> media classification;
- raw TMDB image paths -> complete image URLs;
- TMDB dates -> lightweight Search years;
- TMDB ratings -> provider-independent external ratings;
- TMDB companies -> Cineara Studios;
- TMDB keywords -> Cineara Topics;
- Person ``known_for`` entries -> compact Cineara summaries.

It performs no:

- network requests;
- caching;
- persistence;
- user-state lookup;
- Search orchestration.
"""

from __future__ import annotations

from datetime import date

from app.catalogue import (
    MediaClassification,
    MediaClassificationEvidence,
    classify_movie,
    classify_tv,
    resolve_movie_genres,
    resolve_tv_genres,
)
from app.integrations.tmdb.image_url import TmdbImageUrlBuilder
from app.integrations.tmdb.models import (
    TmdbCollectionSearchResult,
    TmdbCompanySearchResult,
    TmdbKeywordSearchResult,
    TmdbKnownForResult,
    TmdbMovieSearchResult,
    TmdbMultiSearchResult,
    TmdbPersonSearchResult,
    TmdbTvSearchResult,
)

from .schemas import (
    CollectionSearchResult,
    ExternalRating,
    ExternalRatingSource,
    KnownForSearchItem,
    MovieSearchResult,
    PersonSearchResult,
    SearchMediaClassification,
    SearchResult,
    StudioSearchResult,
    TopicSearchResult,
    TrendingSearchResult,
    TvSearchResult,
)

# =============================================================================
# Mapper
# =============================================================================


class SearchMapper:
    """Pure mapper from TMDB Search transport models to Cineara schemas."""

    __slots__ = (
        "_image_urls",
        "_known_for_limit",
    )

    def __init__(
        self,
        *,
        image_urls: TmdbImageUrlBuilder | None = None,
        known_for_limit: int = 3,
    ) -> None:
        """Create a Search mapper."""

        if isinstance(
            known_for_limit,
            bool,
        ) or not isinstance(
            known_for_limit,
            int,
        ):
            raise TypeError("known_for_limit must be an integer.")

        if known_for_limit < 0:
            raise ValueError(
                "known_for_limit must be greater than or equal to 0."
            )

        self._image_urls = (
            image_urls if image_urls is not None else TmdbImageUrlBuilder()
        )
        self._known_for_limit = known_for_limit

    # =========================================================================
    # Movie
    # =========================================================================

    def movie(
        self,
        value: TmdbMovieSearchResult,
    ) -> MovieSearchResult:
        """Map one raw TMDB Movie Search result."""

        if not isinstance(
            value,
            TmdbMovieSearchResult,
        ):
            raise TypeError("value must be a TmdbMovieSearchResult.")

        genre_resolution = resolve_movie_genres(
            value.genre_ids,
        )

        classification = classify_movie(
            MediaClassificationEvidence(
                genres=genre_resolution.genres,
                original_language=value.original_language,
            )
        )

        return MovieSearchResult(
            id=value.id,
            title=value.title,
            original_title=value.original_title,
            image_url=self._image_urls.poster(
                value.poster_path,
            ),
            year=_extract_year(
                value.release_date,
            ),
            classification=_map_classification(
                classification,
            ),
            external_ratings=_map_external_ratings(
                vote_average=value.vote_average,
                vote_count=value.vote_count,
            ),
        )

    # =========================================================================
    # TV
    # =========================================================================

    def tv(
        self,
        value: TmdbTvSearchResult,
    ) -> TvSearchResult:
        """Map one raw TMDB TV Search result."""

        if not isinstance(
            value,
            TmdbTvSearchResult,
        ):
            raise TypeError("value must be a TmdbTvSearchResult.")

        genre_resolution = resolve_tv_genres(
            value.genre_ids,
        )

        classification = classify_tv(
            MediaClassificationEvidence(
                genres=genre_resolution.genres,
                country_codes=tuple(
                    value.origin_country,
                ),
                original_language=value.original_language,
            )
        )

        return TvSearchResult(
            id=value.id,
            title=value.name,
            original_title=value.original_name,
            image_url=self._image_urls.poster(
                value.poster_path,
            ),
            year=_extract_year(
                value.first_air_date,
            ),
            classification=_map_classification(
                classification,
            ),
            external_ratings=_map_external_ratings(
                vote_average=value.vote_average,
                vote_count=value.vote_count,
            ),
        )

    # =========================================================================
    # Person
    # =========================================================================

    def person(
        self,
        value: TmdbPersonSearchResult,
    ) -> PersonSearchResult:
        """Map one raw TMDB Person Search result."""

        if not isinstance(
            value,
            TmdbPersonSearchResult,
        ):
            raise TypeError("value must be a TmdbPersonSearchResult.")

        known_for: list[KnownForSearchItem] = []
        seen: set[tuple[str, int]] = set()

        for item in value.known_for:
            if (
                len(
                    known_for,
                )
                >= self._known_for_limit
            ):
                break

            mapped = _map_known_for_item(
                item,
            )

            identity = (
                mapped.result_type,
                mapped.id,
            )

            if identity in seen:
                continue

            seen.add(
                identity,
            )
            known_for.append(
                mapped,
            )

        return PersonSearchResult(
            id=value.id,
            name=value.name,
            image_url=self._image_urls.profile(
                value.profile_path,
            ),
            known_for_department=_normalize_optional_text(
                value.known_for_department,
            ),
            known_for=tuple(
                known_for,
            ),
        )

    # =========================================================================
    # Collection
    # =========================================================================

    def collection(
        self,
        value: TmdbCollectionSearchResult,
    ) -> CollectionSearchResult:
        """Map one raw TMDB Collection Search result."""

        if not isinstance(
            value,
            TmdbCollectionSearchResult,
        ):
            raise TypeError("value must be a TmdbCollectionSearchResult.")

        return CollectionSearchResult(
            id=value.id,
            name=value.name,
            image_url=self._image_urls.poster(
                value.poster_path,
            ),
        )

    # =========================================================================
    # Studio
    # =========================================================================

    def studio(
        self,
        value: TmdbCompanySearchResult,
    ) -> StudioSearchResult:
        """Map one raw TMDB Company result into a Cineara Studio."""

        if not isinstance(
            value,
            TmdbCompanySearchResult,
        ):
            raise TypeError("value must be a TmdbCompanySearchResult.")

        return StudioSearchResult(
            id=value.id,
            name=value.name,
            image_url=self._image_urls.logo(
                value.logo_path,
            ),
            origin_country_code=_normalize_country_code(
                value.origin_country,
            ),
        )

    # =========================================================================
    # Topic
    # =========================================================================

    @staticmethod
    def topic(
        value: TmdbKeywordSearchResult,
    ) -> TopicSearchResult:
        """Map one raw TMDB Keyword result into a Cineara Topic."""

        if not isinstance(
            value,
            TmdbKeywordSearchResult,
        ):
            raise TypeError("value must be a TmdbKeywordSearchResult.")

        return TopicSearchResult(
            id=value.id,
            name=value.name,
        )

    # =========================================================================
    # Multi / Trending
    # =========================================================================

    def multi(
        self,
        value: TmdbMultiSearchResult,
    ) -> TrendingSearchResult:
        """Map a Movie, TV, or Person result from TMDB Multi Search."""

        if isinstance(
            value,
            TmdbMovieSearchResult,
        ):
            return self.movie(
                value,
            )

        if isinstance(
            value,
            TmdbTvSearchResult,
        ):
            return self.tv(
                value,
            )

        if isinstance(
            value,
            TmdbPersonSearchResult,
        ):
            return self.person(
                value,
            )

        raise TypeError("Unsupported TMDB Multi Search result.")

    def search_result(
        self,
        value: object,
    ) -> SearchResult:
        """Map any raw TMDB Search result supported by Cineara."""

        if isinstance(
            value,
            TmdbMovieSearchResult,
        ):
            return self.movie(
                value,
            )

        if isinstance(
            value,
            TmdbTvSearchResult,
        ):
            return self.tv(
                value,
            )

        if isinstance(
            value,
            TmdbPersonSearchResult,
        ):
            return self.person(
                value,
            )

        if isinstance(
            value,
            TmdbCollectionSearchResult,
        ):
            return self.collection(
                value,
            )

        if isinstance(
            value,
            TmdbCompanySearchResult,
        ):
            return self.studio(
                value,
            )

        if isinstance(
            value,
            TmdbKeywordSearchResult,
        ):
            return self.topic(
                value,
            )

        raise TypeError(
            f"Unsupported TMDB Search result type: {type(value).__name__}."
        )


# =============================================================================
# Classification mapping
# =============================================================================


def _map_classification(
    value: MediaClassification,
) -> SearchMediaClassification:
    """Map catalogue classification into the public Search schema."""

    origin = value.origin

    return SearchMediaClassification(
        media_format=value.media_format,
        genres=value.genres,
        display_genres=value.display_genres,
        cultural_classification=value.cultural_classification,
        programme_classification=value.programme_classification,
        country_codes=(origin.country_codes if origin is not None else ()),
        original_language=(
            origin.original_language if origin is not None else None
        ),
    )


# =============================================================================
# Rating mapping
# =============================================================================


def _map_external_ratings(
    *,
    vote_average: float,
    vote_count: int,
) -> tuple[ExternalRating, ...]:
    """Map TMDB vote metadata into provider-independent ratings."""

    if vote_count <= 0:
        return ()

    value = min(
        max(
            float(
                vote_average,
            ),
            0.0,
        ),
        10.0,
    )

    return (
        ExternalRating(
            source=ExternalRatingSource.TMDB,
            value=value,
            scale=10.0,
            vote_count=vote_count,
        ),
    )


# =============================================================================
# Known-for mapping
# =============================================================================


def _map_known_for_item(
    value: TmdbKnownForResult,
) -> KnownForSearchItem:
    """Map one embedded Movie/TV known-for record."""

    if isinstance(
        value,
        TmdbMovieSearchResult,
    ):
        return KnownForSearchItem(
            result_type="movie",
            id=value.id,
            title=value.title,
            year=_extract_year(
                value.release_date,
            ),
        )

    return KnownForSearchItem(
        result_type="tv",
        id=value.id,
        title=value.name,
        year=_extract_year(
            value.first_air_date,
        ),
    )


# =============================================================================
# Date normalization
# =============================================================================


def _extract_year(
    value: str | None,
) -> int | None:
    """Extract a valid year from a TMDB ISO-style date string."""

    if value is None:
        return None

    normalized = value.strip()

    if not normalized:
        return None

    try:
        parsed = date.fromisoformat(
            normalized,
        )

    except ValueError:
        if (
            len(
                normalized,
            )
            >= 4
            and normalized[:4].isdigit()
        ):
            year = int(
                normalized[:4],
            )

            if 1000 <= year <= 9999:
                return year

        return None

    return parsed.year


# =============================================================================
# Text normalization
# =============================================================================


def _normalize_optional_text(
    value: str | None,
) -> str | None:
    """Trim optional text and collapse blank values to ``None``."""

    if value is None:
        return None

    normalized = value.strip()

    if not normalized:
        return None

    return normalized


def _normalize_country_code(
    value: str,
) -> str | None:
    """Normalize a lightweight TMDB country code for public Search."""

    normalized = value.strip().upper()

    if not normalized:
        return None

    if len(
        normalized,
    ) != 2 or not all("A" <= character <= "Z" for character in normalized):
        return None

    return normalized
