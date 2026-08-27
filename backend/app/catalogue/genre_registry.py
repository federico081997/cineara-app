"""Canonical Cineara genre registry and TMDB genre translation.

This module defines Cineara's provider-independent genre vocabulary and the
translation between TMDB's official Movie/TV genre registries and those
canonical genres.

TMDB exposes separate genre registries for Movies and TV. Some TV entries
combine multiple concepts into one upstream genre. Cineara expands those
combined entries into individual canonical genres so downstream catalogue,
Search, Discover, filtering, and classification logic does not depend on
TMDB-specific combined labels.

Examples
--------
TMDB TV::

    10759  Action & Adventure

Cineara::

    ACTION
    ADVENTURE

TMDB TV::

    10765  Sci-Fi & Fantasy

Cineara::

    SCIENCE_FICTION
    FANTASY

TMDB TV::

    10768  War & Politics

Cineara::

    WAR
    POLITICS

This module owns:

- Cineara's canonical genre identifiers;
- the complete official TMDB Movie genre registry;
- the complete official TMDB TV genre registry;
- provider-to-canonical genre translation;
- canonical-to-provider reverse lookup;
- ordered genre resolution;
- preservation of unknown TMDB genre IDs;
- validation and deduplication of canonical genre collections.

It does not own:

- HTTP requests;
- TMDB response models;
- localized genre labels;
- media-format classification;
- cultural classification;
- persistence;
- Search orchestration;
- presentation formatting.

The registry is immutable, deterministic, and performs no network operations.
"""

from __future__ import annotations

from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from enum import StrEnum
from types import MappingProxyType
from typing import Final

# =============================================================================
# Canonical Cineara genres
# =============================================================================


class MediaGenre(StrEnum):
    """Stable provider-independent genre identifiers used by Cineara.

    Enum values are application identifiers rather than localized display
    labels.

    ``TV_MOVIE`` is retained because TMDB exposes it as an official Movie
    genre. Higher-level media classification may treat it as structural
    evidence rather than a display genre.

    ``POLITICS`` exists independently because TMDB TV combines War and
    Politics into one upstream genre while Cineara keeps canonical concepts
    provider-independent.
    """

    ACTION = "action"
    ADVENTURE = "adventure"
    ANIMATION = "animation"
    COMEDY = "comedy"
    CRIME = "crime"
    DOCUMENTARY = "documentary"
    DRAMA = "drama"
    FAMILY = "family"
    FANTASY = "fantasy"
    HISTORY = "history"
    HORROR = "horror"
    KIDS = "kids"
    MUSIC = "music"
    MYSTERY = "mystery"
    NEWS = "news"
    POLITICS = "politics"
    REALITY = "reality"
    ROMANCE = "romance"
    SCIENCE_FICTION = "science_fiction"
    SOAP = "soap"
    TALK = "talk"
    THRILLER = "thriller"
    TV_MOVIE = "tv_movie"
    WAR = "war"
    WESTERN = "western"


# =============================================================================
# Canonical genre normalization
# =============================================================================


def _normalize_media_genre(
    value: MediaGenre,
) -> MediaGenre:
    """Validate a canonical Cineara genre."""

    if not isinstance(
        value,
        MediaGenre,
    ):
        raise TypeError("genre must be a MediaGenre.")

    return value


def normalize_media_genres(
    genres: Iterable[MediaGenre],
) -> tuple[MediaGenre, ...]:
    """Validate and deduplicate canonical genres while preserving order.

    Parameters
    ----------
    genres:
        Iterable of canonical Cineara genres.

    Returns
    -------
    tuple[MediaGenre, ...]
        Validated genres with duplicates removed while preserving the first
        occurrence of each value.
    """

    if isinstance(
        genres,
        (
            str,
            bytes,
        ),
    ):
        raise TypeError("genres must be an iterable of MediaGenre values.")

    try:
        iterator = iter(
            genres,
        )

    except TypeError as exc:
        raise TypeError(
            "genres must be an iterable of MediaGenre values."
        ) from exc

    normalized: list[MediaGenre] = []
    seen: set[MediaGenre] = set()

    for value in iterator:
        genre = _normalize_media_genre(
            value,
        )

        if genre in seen:
            continue

        normalized.append(
            genre,
        )

        seen.add(
            genre,
        )

    return tuple(
        normalized,
    )


# =============================================================================
# TMDB genre definition
# =============================================================================


@dataclass(
    frozen=True,
    slots=True,
)
class TmdbGenreDefinition:
    """One entry from a TMDB genre registry.

    Parameters
    ----------
    name:
        Official English TMDB genre name.

    genres:
        One or more canonical Cineara genres represented by the TMDB entry.

        Most TMDB genres map one-to-one. Combined TV genres map to multiple
        canonical genres.
    """

    name: str

    genres: tuple[MediaGenre, ...]

    def __post_init__(self) -> None:
        """Validate the immutable definition."""

        if not isinstance(
            self.name,
            str,
        ):
            raise TypeError("name must be a string.")

        normalized_name = self.name.strip()

        if not normalized_name:
            raise ValueError("name must not be blank.")

        object.__setattr__(
            self,
            "name",
            normalized_name,
        )

        normalized_genres = normalize_media_genres(
            self.genres,
        )

        if not normalized_genres:
            raise ValueError("genres must contain at least one MediaGenre.")

        object.__setattr__(
            self,
            "genres",
            normalized_genres,
        )


# =============================================================================
# Genre resolution
# =============================================================================


@dataclass(
    frozen=True,
    slots=True,
)
class GenreResolution:
    """Result of translating TMDB genre IDs into canonical Cineara genres.

    Parameters
    ----------
    genres:
        Canonical genres in source order.

        One TMDB genre may expand into multiple Cineara genres. Duplicates are
        removed while preserving the first occurrence.

    unknown_tmdb_ids:
        Positive TMDB genre IDs not present in the selected registry.

        Unknown IDs are preserved rather than silently ignored or interpreted
        through the other media registry.
    """

    genres: tuple[MediaGenre, ...] = ()

    unknown_tmdb_ids: tuple[int, ...] = ()

    @property
    def is_complete(self) -> bool:
        """Return whether every supplied TMDB genre ID was recognized."""

        return not self.unknown_tmdb_ids

    @property
    def has_genres(self) -> bool:
        """Return whether at least one canonical genre was resolved."""

        return bool(
            self.genres,
        )


# =============================================================================
# Complete official TMDB Movie genre registry
# =============================================================================


_MOVIE_GENRES_BY_TMDB_ID: Final[
    Mapping[
        int,
        TmdbGenreDefinition,
    ]
] = MappingProxyType(
    {
        28: TmdbGenreDefinition(
            name="Action",
            genres=(MediaGenre.ACTION,),
        ),
        12: TmdbGenreDefinition(
            name="Adventure",
            genres=(MediaGenre.ADVENTURE,),
        ),
        16: TmdbGenreDefinition(
            name="Animation",
            genres=(MediaGenre.ANIMATION,),
        ),
        35: TmdbGenreDefinition(
            name="Comedy",
            genres=(MediaGenre.COMEDY,),
        ),
        80: TmdbGenreDefinition(
            name="Crime",
            genres=(MediaGenre.CRIME,),
        ),
        99: TmdbGenreDefinition(
            name="Documentary",
            genres=(MediaGenre.DOCUMENTARY,),
        ),
        18: TmdbGenreDefinition(
            name="Drama",
            genres=(MediaGenre.DRAMA,),
        ),
        10751: TmdbGenreDefinition(
            name="Family",
            genres=(MediaGenre.FAMILY,),
        ),
        14: TmdbGenreDefinition(
            name="Fantasy",
            genres=(MediaGenre.FANTASY,),
        ),
        36: TmdbGenreDefinition(
            name="History",
            genres=(MediaGenre.HISTORY,),
        ),
        27: TmdbGenreDefinition(
            name="Horror",
            genres=(MediaGenre.HORROR,),
        ),
        10402: TmdbGenreDefinition(
            name="Music",
            genres=(MediaGenre.MUSIC,),
        ),
        9648: TmdbGenreDefinition(
            name="Mystery",
            genres=(MediaGenre.MYSTERY,),
        ),
        10749: TmdbGenreDefinition(
            name="Romance",
            genres=(MediaGenre.ROMANCE,),
        ),
        878: TmdbGenreDefinition(
            name="Science Fiction",
            genres=(MediaGenre.SCIENCE_FICTION,),
        ),
        10770: TmdbGenreDefinition(
            name="TV Movie",
            genres=(MediaGenre.TV_MOVIE,),
        ),
        53: TmdbGenreDefinition(
            name="Thriller",
            genres=(MediaGenre.THRILLER,),
        ),
        10752: TmdbGenreDefinition(
            name="War",
            genres=(MediaGenre.WAR,),
        ),
        37: TmdbGenreDefinition(
            name="Western",
            genres=(MediaGenre.WESTERN,),
        ),
    }
)

# =============================================================================
# Complete official TMDB TV genre registry
# =============================================================================


_TV_GENRES_BY_TMDB_ID: Final[
    Mapping[
        int,
        TmdbGenreDefinition,
    ]
] = MappingProxyType(
    {
        10759: TmdbGenreDefinition(
            name="Action & Adventure",
            genres=(
                MediaGenre.ACTION,
                MediaGenre.ADVENTURE,
            ),
        ),
        16: TmdbGenreDefinition(
            name="Animation",
            genres=(MediaGenre.ANIMATION,),
        ),
        35: TmdbGenreDefinition(
            name="Comedy",
            genres=(MediaGenre.COMEDY,),
        ),
        80: TmdbGenreDefinition(
            name="Crime",
            genres=(MediaGenre.CRIME,),
        ),
        99: TmdbGenreDefinition(
            name="Documentary",
            genres=(MediaGenre.DOCUMENTARY,),
        ),
        18: TmdbGenreDefinition(
            name="Drama",
            genres=(MediaGenre.DRAMA,),
        ),
        10751: TmdbGenreDefinition(
            name="Family",
            genres=(MediaGenre.FAMILY,),
        ),
        10762: TmdbGenreDefinition(
            name="Kids",
            genres=(MediaGenre.KIDS,),
        ),
        9648: TmdbGenreDefinition(
            name="Mystery",
            genres=(MediaGenre.MYSTERY,),
        ),
        10763: TmdbGenreDefinition(
            name="News",
            genres=(MediaGenre.NEWS,),
        ),
        10764: TmdbGenreDefinition(
            name="Reality",
            genres=(MediaGenre.REALITY,),
        ),
        10765: TmdbGenreDefinition(
            name="Sci-Fi & Fantasy",
            genres=(
                MediaGenre.SCIENCE_FICTION,
                MediaGenre.FANTASY,
            ),
        ),
        10766: TmdbGenreDefinition(
            name="Soap",
            genres=(MediaGenre.SOAP,),
        ),
        10767: TmdbGenreDefinition(
            name="Talk",
            genres=(MediaGenre.TALK,),
        ),
        10768: TmdbGenreDefinition(
            name="War & Politics",
            genres=(
                MediaGenre.WAR,
                MediaGenre.POLITICS,
            ),
        ),
        37: TmdbGenreDefinition(
            name="Western",
            genres=(MediaGenre.WESTERN,),
        ),
    }
)


# =============================================================================
# Reverse-registry construction
# =============================================================================


def _build_reverse_registry(
    registry: Mapping[
        int,
        TmdbGenreDefinition,
    ],
) -> Mapping[MediaGenre, tuple[int, ...]]:
    """Build an immutable canonical-genre to TMDB-ID registry."""

    mutable: dict[
        MediaGenre,
        list[int],
    ] = {}

    for tmdb_id, definition in registry.items():
        for genre in definition.genres:
            mutable.setdefault(
                genre,
                [],
            ).append(
                tmdb_id,
            )

    return MappingProxyType(
        {
            genre: tuple(
                tmdb_ids,
            )
            for genre, tmdb_ids in mutable.items()
        }
    )


# =============================================================================
# Reverse registries
# =============================================================================


_MOVIE_TMDB_IDS_BY_GENRE: Final[
    Mapping[
        MediaGenre,
        tuple[int, ...],
    ]
] = _build_reverse_registry(
    _MOVIE_GENRES_BY_TMDB_ID,
)

_TV_TMDB_IDS_BY_GENRE: Final[
    Mapping[
        MediaGenre,
        tuple[int, ...],
    ]
] = _build_reverse_registry(
    _TV_GENRES_BY_TMDB_ID,
)


# =============================================================================
# Registry metadata
# =============================================================================


def movie_tmdb_genre_count() -> int:
    """Return the number of registered official TMDB Movie genres."""

    return len(
        _MOVIE_GENRES_BY_TMDB_ID,
    )


def tv_tmdb_genre_count() -> int:
    """Return the number of registered official TMDB TV genres."""

    return len(
        _TV_GENRES_BY_TMDB_ID,
    )


def movie_tmdb_genre_ids() -> tuple[int, ...]:
    """Return all registered TMDB Movie genre IDs in registry order."""

    return tuple(
        _MOVIE_GENRES_BY_TMDB_ID,
    )


def tv_tmdb_genre_ids() -> tuple[int, ...]:
    """Return all registered TMDB TV genre IDs in registry order."""

    return tuple(
        _TV_GENRES_BY_TMDB_ID,
    )


# =============================================================================
# TMDB Movie lookup
# =============================================================================


def movie_genre_definition(
    tmdb_genre_id: int,
) -> TmdbGenreDefinition | None:
    """Return the definition for a TMDB Movie genre ID."""

    normalized_id = _normalize_tmdb_genre_id(
        tmdb_genre_id,
    )

    return _MOVIE_GENRES_BY_TMDB_ID.get(
        normalized_id,
    )


def movie_genres_from_tmdb_id(
    tmdb_genre_id: int,
) -> tuple[MediaGenre, ...]:
    """Return canonical genres represented by a TMDB Movie genre ID.

    An empty tuple indicates a valid positive ID that is not registered.
    """

    definition = movie_genre_definition(
        tmdb_genre_id,
    )

    if definition is None:
        return ()

    return definition.genres


def movie_tmdb_genre_name(
    tmdb_genre_id: int,
) -> str | None:
    """Return the official TMDB Movie genre name for an ID."""

    definition = movie_genre_definition(
        tmdb_genre_id,
    )

    if definition is None:
        return None

    return definition.name


# =============================================================================
# TMDB TV lookup
# =============================================================================


def tv_genre_definition(
    tmdb_genre_id: int,
) -> TmdbGenreDefinition | None:
    """Return the definition for a TMDB TV genre ID."""

    normalized_id = _normalize_tmdb_genre_id(
        tmdb_genre_id,
    )

    return _TV_GENRES_BY_TMDB_ID.get(
        normalized_id,
    )


def tv_genres_from_tmdb_id(
    tmdb_genre_id: int,
) -> tuple[MediaGenre, ...]:
    """Return canonical genres represented by a TMDB TV genre ID.

    An empty tuple indicates a valid positive ID that is not registered.
    """

    definition = tv_genre_definition(
        tmdb_genre_id,
    )

    if definition is None:
        return ()

    return definition.genres


def tv_tmdb_genre_name(
    tmdb_genre_id: int,
) -> str | None:
    """Return the official TMDB TV genre name for an ID."""

    definition = tv_genre_definition(
        tmdb_genre_id,
    )

    if definition is None:
        return None

    return definition.name


# =============================================================================
# Canonical-to-TMDB reverse lookup
# =============================================================================


def tmdb_movie_genre_ids_for(
    genre: MediaGenre,
) -> tuple[int, ...]:
    """Return TMDB Movie genre IDs representing a canonical genre."""

    normalized_genre = _normalize_media_genre(
        genre,
    )

    return _MOVIE_TMDB_IDS_BY_GENRE.get(
        normalized_genre,
        (),
    )


def tmdb_tv_genre_ids_for(
    genre: MediaGenre,
) -> tuple[int, ...]:
    """Return TMDB TV genre IDs representing a canonical genre."""

    normalized_genre = _normalize_media_genre(
        genre,
    )

    return _TV_TMDB_IDS_BY_GENRE.get(
        normalized_genre,
        (),
    )


# =============================================================================
# Registry membership
# =============================================================================


def is_movie_genre(
    genre: MediaGenre,
) -> bool:
    """Return whether a canonical genre has a TMDB Movie mapping."""

    normalized_genre = _normalize_media_genre(
        genre,
    )

    return normalized_genre in _MOVIE_TMDB_IDS_BY_GENRE


def is_tv_genre(
    genre: MediaGenre,
) -> bool:
    """Return whether a canonical genre has a TMDB TV mapping."""

    normalized_genre = _normalize_media_genre(
        genre,
    )

    return normalized_genre in _TV_TMDB_IDS_BY_GENRE


# =============================================================================
# TMDB genre resolution
# =============================================================================


def resolve_movie_genres(
    genre_ids: Iterable[int],
) -> GenreResolution:
    """Resolve TMDB Movie genre IDs into canonical Cineara genres."""

    return _resolve_tmdb_genres(
        genre_ids,
        registry=_MOVIE_GENRES_BY_TMDB_ID,
    )


def resolve_tv_genres(
    genre_ids: Iterable[int],
) -> GenreResolution:
    """Resolve TMDB TV genre IDs into canonical Cineara genres."""

    return _resolve_tmdb_genres(
        genre_ids,
        registry=_TV_GENRES_BY_TMDB_ID,
    )


# =============================================================================
# Internal resolution
# =============================================================================


def _resolve_tmdb_genres(
    genre_ids: Iterable[int],
    *,
    registry: Mapping[
        int,
        TmdbGenreDefinition,
    ],
) -> GenreResolution:
    """Resolve IDs through one explicit TMDB media-specific registry."""

    if isinstance(
        genre_ids,
        (
            str,
            bytes,
        ),
    ):
        raise TypeError("TMDB genre IDs must be an iterable of integers.")

    try:
        iterator = iter(
            genre_ids,
        )

    except TypeError as exc:
        raise TypeError(
            "TMDB genre IDs must be an iterable of integers."
        ) from exc

    genres: list[MediaGenre] = []
    unknown_tmdb_ids: list[int] = []

    seen_genres: set[MediaGenre] = set()
    seen_unknown_ids: set[int] = set()

    for raw_genre_id in iterator:
        genre_id = _normalize_tmdb_genre_id(
            raw_genre_id,
        )

        definition = registry.get(
            genre_id,
        )

        if definition is None:
            if genre_id not in seen_unknown_ids:
                unknown_tmdb_ids.append(
                    genre_id,
                )

                seen_unknown_ids.add(
                    genre_id,
                )

            continue

        for genre in definition.genres:
            if genre in seen_genres:
                continue

            genres.append(
                genre,
            )

            seen_genres.add(
                genre,
            )

    return GenreResolution(
        genres=tuple(
            genres,
        ),
        unknown_tmdb_ids=tuple(
            unknown_tmdb_ids,
        ),
    )


# =============================================================================
# TMDB validation
# =============================================================================


def _normalize_tmdb_genre_id(
    value: int,
) -> int:
    """Validate a TMDB genre identifier."""

    if isinstance(
        value,
        bool,
    ) or not isinstance(
        value,
        int,
    ):
        raise TypeError("TMDB genre ID must be an integer.")

    if value <= 0:
        raise ValueError("TMDB genre ID must be greater than 0.")

    return value
