"""Cineara media classification for TMDB search results.

The module converts TMDB search metadata into a stable Cineara representation:

- media type and structural format;
- normalized genres for movies and TV series;
- one optional cultural/editorial classification for TV series;
- unknown TMDB genre IDs preserved for observability.

The classification logic is deterministic and uses only metadata available on
TMDB search results.
"""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass
from enum import StrEnum

# =============================================================================
# Public enums
# =============================================================================


class MediaType(StrEnum):
    """Top-level Cineara media entity type."""

    MOVIE = "movie"
    TV = "tv"
    PERSON = "person"


class MediaFormat(StrEnum):
    """Structural format displayed by Cineara."""

    MOVIE = "movie"
    TV_MOVIE = "tv_movie"
    SERIES = "series"


class MediaGenre(StrEnum):
    """Normalized genre vocabulary used by Cineara."""

    ACTION = "action"
    ACTION_ADVENTURE = "action_adventure"
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
    REALITY = "reality"
    ROMANCE = "romance"
    SCIENCE_FICTION = "science_fiction"
    SCI_FI_FANTASY = "sci_fi_fantasy"
    SOAP = "soap"
    TALK = "talk"
    THRILLER = "thriller"
    TV_MOVIE = "tv_movie"
    WAR = "war"
    WAR_POLITICS = "war_politics"
    WESTERN = "western"


class SpecialClassification(StrEnum):
    """Cultural/editorial TV classifications shown alongside genres."""

    ANIME = "anime"
    K_DRAMA = "k_drama"
    C_DRAMA = "c_drama"
    J_DRAMA = "j_drama"
    TAIWANESE_DRAMA = "taiwanese_drama"
    HONG_KONG_DRAMA = "hong_kong_drama"
    THAI_DRAMA = "thai_drama"
    INDIAN_DRAMA = "indian_drama"
    PAKISTANI_DRAMA = "pakistani_drama"
    TURKISH_DRAMA = "turkish_drama"


# =============================================================================
# Public result
# =============================================================================


@dataclass(frozen=True, slots=True)
class MediaClassification:
    """Normalized classification for one TMDB search result."""

    media_type: MediaType
    media_format: MediaFormat | None
    genres: tuple[MediaGenre, ...] = ()
    special_classification: SpecialClassification | None = None
    unknown_genre_ids: tuple[int, ...] = ()

    def __post_init__(self) -> None:
        if self.media_type is MediaType.PERSON:
            if self.media_format is not None:
                raise ValueError("A person cannot have a media format.")
            if self.genres:
                raise ValueError("A person cannot have media genres.")
            if self.special_classification is not None:
                raise ValueError(
                    "A person cannot have a special classification."
                )
            if self.unknown_genre_ids:
                raise ValueError(
                    "A person cannot have unknown media genre IDs."
                )

        if (
            self.media_type is MediaType.MOVIE
            and self.special_classification is not None
        ):
            raise ValueError(
                "Special classifications are defined for TV search results."
            )

    @property
    def genre_labels(self) -> tuple[str, ...]:
        """Return presentation labels in TMDB result order."""

        return tuple(_GENRE_LABELS[genre] for genre in self.genres)

    @property
    def special_classification_label(self) -> str | None:
        """Return the presentation label for the special classification."""

        if self.special_classification is None:
            return None

        return _SPECIAL_CLASSIFICATION_LABELS[self.special_classification]

    @property
    def display_parts(self) -> tuple[str, ...]:
        """Return compact metadata parts after the structural media format.

        Examples:
            Anime + Animation + Sci-Fi & Fantasy
            K-Drama + Comedy
            Comedy + Crime
        """

        parts: list[str] = []

        if self.special_classification_label is not None:
            parts.append(self.special_classification_label)

        parts.extend(self.genre_labels)
        return tuple(parts)


# =============================================================================
# TMDB genre mappings
# =============================================================================


_MOVIE_GENRE_BY_ID: dict[int, MediaGenre] = {
    28: MediaGenre.ACTION,
    12: MediaGenre.ADVENTURE,
    16: MediaGenre.ANIMATION,
    35: MediaGenre.COMEDY,
    80: MediaGenre.CRIME,
    99: MediaGenre.DOCUMENTARY,
    18: MediaGenre.DRAMA,
    10751: MediaGenre.FAMILY,
    14: MediaGenre.FANTASY,
    36: MediaGenre.HISTORY,
    27: MediaGenre.HORROR,
    10402: MediaGenre.MUSIC,
    9648: MediaGenre.MYSTERY,
    10749: MediaGenre.ROMANCE,
    878: MediaGenre.SCIENCE_FICTION,
    10770: MediaGenre.TV_MOVIE,
    53: MediaGenre.THRILLER,
    10752: MediaGenre.WAR,
    37: MediaGenre.WESTERN,
}

_TV_GENRE_BY_ID: dict[int, MediaGenre] = {
    10759: MediaGenre.ACTION_ADVENTURE,
    16: MediaGenre.ANIMATION,
    35: MediaGenre.COMEDY,
    80: MediaGenre.CRIME,
    99: MediaGenre.DOCUMENTARY,
    18: MediaGenre.DRAMA,
    10751: MediaGenre.FAMILY,
    10762: MediaGenre.KIDS,
    9648: MediaGenre.MYSTERY,
    10763: MediaGenre.NEWS,
    10764: MediaGenre.REALITY,
    10765: MediaGenre.SCI_FI_FANTASY,
    10766: MediaGenre.SOAP,
    10767: MediaGenre.TALK,
    10768: MediaGenre.WAR_POLITICS,
    37: MediaGenre.WESTERN,
}

# A small number of TV search records can contain IDs from the movie
# vocabulary. Mapping them preserves useful metadata instead of dropping a
# genre TMDB supplied.
_TV_FALLBACK_GENRE_BY_ID: dict[int, MediaGenre] = {
    genre_id: genre
    for genre_id, genre in _MOVIE_GENRE_BY_ID.items()
    if genre_id not in _TV_GENRE_BY_ID
}

_GENRE_LABELS: dict[MediaGenre, str] = {
    MediaGenre.ACTION: "Action",
    MediaGenre.ACTION_ADVENTURE: "Action & Adventure",
    MediaGenre.ADVENTURE: "Adventure",
    MediaGenre.ANIMATION: "Animation",
    MediaGenre.COMEDY: "Comedy",
    MediaGenre.CRIME: "Crime",
    MediaGenre.DOCUMENTARY: "Documentary",
    MediaGenre.DRAMA: "Drama",
    MediaGenre.FAMILY: "Family",
    MediaGenre.FANTASY: "Fantasy",
    MediaGenre.HISTORY: "History",
    MediaGenre.HORROR: "Horror",
    MediaGenre.KIDS: "Kids",
    MediaGenre.MUSIC: "Music",
    MediaGenre.MYSTERY: "Mystery",
    MediaGenre.NEWS: "News",
    MediaGenre.REALITY: "Reality",
    MediaGenre.ROMANCE: "Romance",
    MediaGenre.SCIENCE_FICTION: "Science Fiction",
    MediaGenre.SCI_FI_FANTASY: "Sci-Fi & Fantasy",
    MediaGenre.SOAP: "Soap",
    MediaGenre.TALK: "Talk",
    MediaGenre.THRILLER: "Thriller",
    MediaGenre.TV_MOVIE: "TV Movie",
    MediaGenre.WAR: "War",
    MediaGenre.WAR_POLITICS: "War & Politics",
    MediaGenre.WESTERN: "Western",
}

# =============================================================================
# Special-classification metadata
# =============================================================================


_COUNTRY_JAPAN = "JP"
_COUNTRY_SOUTH_KOREA = "KR"
_COUNTRY_CHINA = "CN"
_COUNTRY_TAIWAN = "TW"
_COUNTRY_HONG_KONG = "HK"
_COUNTRY_THAILAND = "TH"
_COUNTRY_INDIA = "IN"
_COUNTRY_PAKISTAN = "PK"
_COUNTRY_TURKEY = "TR"

_LANGUAGE_JAPANESE = "ja"
_LANGUAGE_KOREAN = "ko"
_LANGUAGE_CHINESE = "zh"
_LANGUAGE_CANTONESE = "cn"
_LANGUAGE_THAI = "th"
_LANGUAGE_TURKISH = "tr"

_SPECIAL_CLASSIFICATION_LABELS: dict[SpecialClassification, str] = {
    SpecialClassification.ANIME: "Anime",
    SpecialClassification.K_DRAMA: "K-Drama",
    SpecialClassification.C_DRAMA: "C-Drama",
    SpecialClassification.J_DRAMA: "J-Drama",
    SpecialClassification.TAIWANESE_DRAMA: "Taiwanese Drama",
    SpecialClassification.HONG_KONG_DRAMA: "Hong Kong Drama",
    SpecialClassification.THAI_DRAMA: "Thai Drama",
    SpecialClassification.INDIAN_DRAMA: "Indian Drama",
    SpecialClassification.PAKISTANI_DRAMA: "Pakistani Drama",
    SpecialClassification.TURKISH_DRAMA: "Turkish Drama",
}


@dataclass(frozen=True, slots=True)
class _RegionalSeriesRule:
    country_code: str
    classification: SpecialClassification
    expected_languages: frozenset[str] | None = None


_REGIONAL_SERIES_RULES: tuple[_RegionalSeriesRule, ...] = (
    _RegionalSeriesRule(
        country_code=_COUNTRY_SOUTH_KOREA,
        classification=SpecialClassification.K_DRAMA,
        expected_languages=frozenset({_LANGUAGE_KOREAN}),
    ),
    _RegionalSeriesRule(
        country_code=_COUNTRY_CHINA,
        classification=SpecialClassification.C_DRAMA,
        expected_languages=frozenset({_LANGUAGE_CHINESE}),
    ),
    _RegionalSeriesRule(
        country_code=_COUNTRY_TAIWAN,
        classification=SpecialClassification.TAIWANESE_DRAMA,
        expected_languages=frozenset({_LANGUAGE_CHINESE}),
    ),
    _RegionalSeriesRule(
        country_code=_COUNTRY_HONG_KONG,
        classification=SpecialClassification.HONG_KONG_DRAMA,
        expected_languages=frozenset(
            {
                _LANGUAGE_CHINESE,
                _LANGUAGE_CANTONESE,
            }
        ),
    ),
    _RegionalSeriesRule(
        country_code=_COUNTRY_JAPAN,
        classification=SpecialClassification.J_DRAMA,
        expected_languages=frozenset({_LANGUAGE_JAPANESE}),
    ),
    _RegionalSeriesRule(
        country_code=_COUNTRY_THAILAND,
        classification=SpecialClassification.THAI_DRAMA,
        expected_languages=frozenset({_LANGUAGE_THAI}),
    ),
    _RegionalSeriesRule(
        country_code=_COUNTRY_INDIA,
        classification=SpecialClassification.INDIAN_DRAMA,
    ),
    _RegionalSeriesRule(
        country_code=_COUNTRY_PAKISTAN,
        classification=SpecialClassification.PAKISTANI_DRAMA,
    ),
    _RegionalSeriesRule(
        country_code=_COUNTRY_TURKEY,
        classification=SpecialClassification.TURKISH_DRAMA,
        expected_languages=frozenset({_LANGUAGE_TURKISH}),
    ),
)

_NON_SCRIPTED_TV_GENRES: frozenset[MediaGenre] = frozenset(
    {
        MediaGenre.DOCUMENTARY,
        MediaGenre.NEWS,
        MediaGenre.REALITY,
        MediaGenre.TALK,
    }
)

_SCRIPTED_COMPATIBLE_TV_GENRES: frozenset[MediaGenre] = frozenset(
    {
        MediaGenre.ACTION,
        MediaGenre.ACTION_ADVENTURE,
        MediaGenre.ADVENTURE,
        MediaGenre.COMEDY,
        MediaGenre.CRIME,
        MediaGenre.DRAMA,
        MediaGenre.FAMILY,
        MediaGenre.FANTASY,
        MediaGenre.HISTORY,
        MediaGenre.HORROR,
        MediaGenre.KIDS,
        MediaGenre.MUSIC,
        MediaGenre.MYSTERY,
        MediaGenre.ROMANCE,
        MediaGenre.SCIENCE_FICTION,
        MediaGenre.SCI_FI_FANTASY,
        MediaGenre.SOAP,
        MediaGenre.THRILLER,
        MediaGenre.TV_MOVIE,
        MediaGenre.WAR,
        MediaGenre.WAR_POLITICS,
        MediaGenre.WESTERN,
    }
)


# =============================================================================
# Public API
# =============================================================================


def classify_media(
    media_type: MediaType | str,
    *,
    genre_ids: Iterable[int] | None = None,
    origin_country: Iterable[str] | None = None,
    original_language: str | None = None,
) -> MediaClassification:
    """Classify one movie, TV or person search result."""

    normalized_media_type = _coerce_media_type(media_type)

    if normalized_media_type is MediaType.MOVIE:
        return classify_movie(genre_ids=genre_ids)

    if normalized_media_type is MediaType.TV:
        return classify_tv(
            genre_ids=genre_ids,
            origin_country=origin_country,
            original_language=original_language,
        )

    return classify_person()


def classify_movie(
    *,
    genre_ids: Iterable[int] | None = None,
) -> MediaClassification:
    """Classify one TMDB movie search result."""

    genres, unknown_genre_ids = _extract_genres(
        genre_ids,
        mapping=_MOVIE_GENRE_BY_ID,
    )

    media_format = (
        MediaFormat.TV_MOVIE
        if MediaGenre.TV_MOVIE in genres
        else MediaFormat.MOVIE
    )

    return MediaClassification(
        media_type=MediaType.MOVIE,
        media_format=media_format,
        genres=genres,
        special_classification=None,
        unknown_genre_ids=unknown_genre_ids,
    )


def classify_tv(
    *,
    genre_ids: Iterable[int] | None = None,
    origin_country: Iterable[str] | None = None,
    original_language: str | None = None,
) -> MediaClassification:
    """Classify one TMDB TV search result."""

    genres, unknown_genre_ids = _extract_tv_genres(genre_ids)
    countries = _normalize_country_codes(origin_country)
    language = _normalize_language(original_language)

    special_classification = _classify_tv_special(
        genres=genres,
        countries=countries,
        original_language=language,
    )

    return MediaClassification(
        media_type=MediaType.TV,
        media_format=MediaFormat.SERIES,
        genres=genres,
        special_classification=special_classification,
        unknown_genre_ids=unknown_genre_ids,
    )


def classify_person() -> MediaClassification:
    """Return the structural classification for a person search result."""

    return MediaClassification(
        media_type=MediaType.PERSON,
        media_format=None,
    )


# =============================================================================
# TV special classification
# =============================================================================


def _classify_tv_special(
    *,
    genres: tuple[MediaGenre, ...],
    countries: frozenset[str],
    original_language: str | None,
) -> SpecialClassification | None:
    """Return one high-confidence TV classification."""

    genre_set = frozenset(genres)

    if MediaGenre.ANIMATION in genre_set and _COUNTRY_JAPAN in countries:
        return SpecialClassification.ANIME

    if not _is_scripted_regional_series_candidate(genre_set):
        return None

    matches = tuple(
        rule.classification
        for rule in _REGIONAL_SERIES_RULES
        if _regional_rule_matches(
            rule=rule,
            countries=countries,
            original_language=original_language,
        )
    )

    if len(matches) != 1:
        return None

    return matches[0]


def _is_scripted_regional_series_candidate(
    genres: frozenset[MediaGenre],
) -> bool:
    """Return whether genres are compatible with a scripted regional series."""

    if not genres:
        return False

    if MediaGenre.ANIMATION in genres:
        return False

    if not genres.isdisjoint(_NON_SCRIPTED_TV_GENRES):
        return False

    return not genres.isdisjoint(_SCRIPTED_COMPATIBLE_TV_GENRES)


def _regional_rule_matches(
    *,
    rule: _RegionalSeriesRule,
    countries: frozenset[str],
    original_language: str | None,
) -> bool:
    """Return whether explicit regional metadata satisfies one rule."""

    if rule.country_code not in countries:
        return False

    if rule.expected_languages is None:
        return True

    if original_language is None:
        return True

    return original_language in rule.expected_languages


# =============================================================================
# Genre extraction
# =============================================================================


def _extract_genres(
    genre_ids: Iterable[int] | None,
    *,
    mapping: dict[int, MediaGenre],
) -> tuple[tuple[MediaGenre, ...], tuple[int, ...]]:
    """Map TMDB genre IDs while preserving their original order."""

    normalized_ids = _normalize_genre_ids(genre_ids)

    genres: list[MediaGenre] = []
    unknown_ids: list[int] = []
    seen_genres: set[MediaGenre] = set()

    for genre_id in normalized_ids:
        genre = mapping.get(genre_id)

        if genre is None:
            unknown_ids.append(genre_id)
            continue

        if genre in seen_genres:
            continue

        genres.append(genre)
        seen_genres.add(genre)

    return tuple(genres), tuple(unknown_ids)


def _extract_tv_genres(
    genre_ids: Iterable[int] | None,
) -> tuple[tuple[MediaGenre, ...], tuple[int, ...]]:
    """Map TV genre IDs using the TV vocabulary and supported fallbacks."""

    normalized_ids = _normalize_genre_ids(genre_ids)

    genres: list[MediaGenre] = []
    unknown_ids: list[int] = []
    seen_genres: set[MediaGenre] = set()

    for genre_id in normalized_ids:
        genre = _TV_GENRE_BY_ID.get(genre_id)

        if genre is None:
            genre = _TV_FALLBACK_GENRE_BY_ID.get(genre_id)

        if genre is None:
            unknown_ids.append(genre_id)
            continue

        if genre in seen_genres:
            continue

        genres.append(genre)
        seen_genres.add(genre)

    return tuple(genres), tuple(unknown_ids)


# =============================================================================
# Normalization
# =============================================================================


def _normalize_genre_ids(
    values: Iterable[int] | None,
) -> tuple[int, ...]:
    """Normalize integer TMDB genre IDs without changing their order."""

    if values is None:
        return ()

    normalized: list[int] = []
    seen: set[int] = set()

    for value in values:
        if isinstance(value, bool) or not isinstance(value, int):
            continue

        if value <= 0 or value in seen:
            continue

        normalized.append(value)
        seen.add(value)

    return tuple(normalized)


def _normalize_country_codes(
    values: Iterable[str] | None,
) -> frozenset[str]:
    """Normalize ISO-style two-letter country codes."""

    if values is None:
        return frozenset()

    if isinstance(values, str):
        iterable: Iterable[str] = (values,)
    else:
        iterable = values

    normalized: set[str] = set()

    for value in iterable:
        if not isinstance(value, str):
            continue

        code = value.strip().upper()

        if len(code) == 2 and code.isalpha():
            normalized.add(code)

    return frozenset(normalized)


def _normalize_language(value: str | None) -> str | None:
    """Normalize a TMDB original-language code."""

    if not isinstance(value, str):
        return None

    normalized = value.strip().lower()
    return normalized or None


def _coerce_media_type(value: MediaType | str) -> MediaType:
    """Normalize the public media-type argument."""

    if isinstance(value, MediaType):
        return value

    if not isinstance(value, str):
        raise TypeError(
            "media_type must be a MediaType or string, "
            f"got {type(value).__name__}"
        )

    normalized = value.strip().lower()

    try:
        return MediaType(normalized)
    except ValueError as exc:
        allowed = ", ".join(media_type.value for media_type in MediaType)
        raise ValueError(
            f"Unsupported media_type {value!r}. Expected one of: {allowed}"
        ) from exc


__all__ = [
    "MediaClassification",
    "MediaFormat",
    "MediaGenre",
    "MediaType",
    "SpecialClassification",
    "classify_media",
    "classify_movie",
    "classify_person",
    "classify_tv",
]
