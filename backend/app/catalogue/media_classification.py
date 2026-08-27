"""Source-independent media classification for Cineara catalogue metadata.

This module classifies normalized Cineara media evidence rather than raw data
from a specific metadata provider.

Provider adapters are responsible for translating upstream metadata into
``MediaClassificationEvidence`` before invoking this classifier. For example,
TMDB genre IDs are translated through ``catalogue.genre_registry`` before they
reach this module.

The classifier supports Movie and TV media works and keeps several independent
classification axes:

``media kind``
    The broad work family: Movie or TV.

``media format``
    Structural form such as Movie, Short Film, TV Movie, Series, Miniseries,
    Special, OVA, or ONA.

``cultural classification``
    A culturally established or useful regional grouping such as Anime,
    Donghua, Korean Animation, K-Drama, C-Drama, J-Drama, Taiwanese Drama,
    Hong Kong Drama, Thai Drama, or Turkish Drama when the supplied evidence
    is sufficiently strong.

``programme classification``
    A TV programme grouping such as Animated Series, Documentary Series,
    Reality Series, Talk Show, News Program, Kids Series, or Soap.

``genres``
    Canonical provider-independent Cineara genres.

``origin``
    Normalized country and original-language metadata.

Keeping these axes separate preserves complete catalogue information while
allowing compact presentation to avoid redundant combinations such as:

    Anime + Animation

    Donghua + Animation

    Korean Animation + Animation

    K-Drama + Drama

    Reality Series + Reality

    TV Movie + TV Movie

Canonical classifications intentionally use stable descriptive identifiers.
Alternative names such as ``aeni``, ``dorama``, ``lakorn``, or ``dizi`` belong
to search, localization, or synonym metadata rather than this classifier.

This module owns deterministic classification only. It does not perform:

- HTTP requests;
- TMDB or Wikidata access;
- provider-specific genre translation;
- persistence;
- caching;
- localization;
- synonym or alias resolution;
- UI formatting;
- Search orchestration;
- user-library logic.

People, companies, collections, and topics are not media works and therefore
do not pass through this classifier.
"""

from __future__ import annotations

from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from enum import StrEnum
from types import MappingProxyType
from typing import Final

from .genre_registry import (
    MediaGenre,
    normalize_media_genres,
)

# =============================================================================
# Media kind
# =============================================================================


class MediaKind(StrEnum):
    """Top-level media-work families supported by the classifier."""

    MOVIE = "movie"
    TV = "tv"


# =============================================================================
# Structural media format
# =============================================================================


class MediaFormat(StrEnum):
    """Normalized structural form of a Cineara media work."""

    MOVIE = "movie"
    SHORT_FILM = "short_film"
    TV_MOVIE = "tv_movie"

    SERIES = "series"
    MINISERIES = "miniseries"

    SPECIAL = "special"
    OVA = "ova"
    ONA = "ona"


# =============================================================================
# Cultural classification
# =============================================================================


class CulturalClassification(StrEnum):
    """High-confidence cultural classifications supported by Cineara.

    Values are stable Cineara domain identifiers rather than every alternative
    name used by audiences.

    For example, South Korean animation is represented canonically as
    ``KOREAN_ANIMATION``. Terms such as ``aeni`` may be supported separately
    as search or localization aliases.
    """

    ANIME = "anime"
    DONGHUA = "donghua"
    KOREAN_ANIMATION = "korean_animation"

    K_DRAMA = "k_drama"
    C_DRAMA = "c_drama"
    J_DRAMA = "j_drama"
    TAIWANESE_DRAMA = "taiwanese_drama"
    HONG_KONG_DRAMA = "hong_kong_drama"
    THAI_DRAMA = "thai_drama"
    TURKISH_DRAMA = "turkish_drama"


# =============================================================================
# Programme classification
# =============================================================================


class ProgrammeClassification(StrEnum):
    """Programme-level classifications supported by Cineara TV works."""

    ANIMATED_SERIES = "animated_series"
    DOCUMENTARY_SERIES = "documentary_series"
    REALITY_SERIES = "reality_series"
    TALK_SHOW = "talk_show"
    NEWS_PROGRAM = "news_program"
    KIDS_SERIES = "kids_series"
    SOAP = "soap"


# =============================================================================
# Origin
# =============================================================================


@dataclass(
    frozen=True,
    slots=True,
)
class MediaOrigin:
    """Normalized country and original-language metadata."""

    country_codes: tuple[str, ...] = ()
    original_language: str | None = None

    def __post_init__(self) -> None:
        """Normalize and validate origin metadata."""

        object.__setattr__(
            self,
            "country_codes",
            _normalize_country_codes(
                self.country_codes,
            ),
        )

        object.__setattr__(
            self,
            "original_language",
            _normalize_language(
                self.original_language,
            ),
        )

    @property
    def primary_country_code(self) -> str | None:
        """Return the first supplied origin country when available."""

        if not self.country_codes:
            return None

        return self.country_codes[0]

    @property
    def is_multinational(self) -> bool:
        """Return whether multiple origin countries are recorded."""

        return (
            len(
                self.country_codes,
            )
            > 1
        )

    @property
    def is_empty(self) -> bool:
        """Return whether no origin metadata is available."""

        return not self.country_codes and self.original_language is None


# =============================================================================
# Classification evidence
# =============================================================================


@dataclass(
    frozen=True,
    slots=True,
)
class MediaClassificationEvidence:
    """Normalized facts supplied to Cineara's media classifier."""

    genres: tuple[MediaGenre, ...] = ()
    country_codes: tuple[str, ...] = ()
    original_language: str | None = None
    format_hint: MediaFormat | None = None

    def __post_init__(self) -> None:
        """Normalize and validate supplied classification evidence."""

        object.__setattr__(
            self,
            "genres",
            normalize_media_genres(
                self.genres,
            ),
        )

        object.__setattr__(
            self,
            "country_codes",
            _normalize_country_codes(
                self.country_codes,
            ),
        )

        object.__setattr__(
            self,
            "original_language",
            _normalize_language(
                self.original_language,
            ),
        )

        if self.format_hint is not None and not isinstance(
            self.format_hint,
            MediaFormat,
        ):
            raise TypeError("format_hint must be a MediaFormat or None.")

    @property
    def origin(self) -> MediaOrigin | None:
        """Return normalized origin metadata when evidence exists."""

        origin = MediaOrigin(
            country_codes=self.country_codes,
            original_language=self.original_language,
        )

        if origin.is_empty:
            return None

        return origin


# =============================================================================
# Classification result
# =============================================================================


@dataclass(
    frozen=True,
    slots=True,
)
class MediaClassification:
    """Final Cineara classification derived from normalized evidence."""

    media_kind: MediaKind
    media_format: MediaFormat

    genres: tuple[MediaGenre, ...] = ()

    cultural_classification: CulturalClassification | None = None
    programme_classification: ProgrammeClassification | None = None

    origin: MediaOrigin | None = None

    def __post_init__(self) -> None:
        """Normalize and validate the completed classification."""

        if not isinstance(
            self.media_kind,
            MediaKind,
        ):
            raise TypeError("media_kind must be a MediaKind.")

        if not isinstance(
            self.media_format,
            MediaFormat,
        ):
            raise TypeError("media_format must be a MediaFormat.")

        object.__setattr__(
            self,
            "genres",
            normalize_media_genres(
                self.genres,
            ),
        )

        if self.cultural_classification is not None and not isinstance(
            self.cultural_classification,
            CulturalClassification,
        ):
            raise TypeError(
                "cultural_classification must be a "
                "CulturalClassification or None."
            )

        if self.programme_classification is not None and not isinstance(
            self.programme_classification,
            ProgrammeClassification,
        ):
            raise TypeError(
                "programme_classification must be a "
                "ProgrammeClassification or None."
            )

        if self.origin is not None and not isinstance(
            self.origin,
            MediaOrigin,
        ):
            raise TypeError("origin must be a MediaOrigin or None.")

        _validate_result(
            self,
        )

    @property
    def redundant_genres(self) -> frozenset[MediaGenre]:
        """Return genres made redundant by stronger classifications."""

        redundant: set[MediaGenre] = set()

        redundant.update(
            _REDUNDANT_GENRES_BY_FORMAT.get(
                self.media_format,
                frozenset(),
            )
        )

        if self.cultural_classification is not None:
            redundant.update(
                _REDUNDANT_GENRES_BY_CULTURAL_CLASSIFICATION.get(
                    self.cultural_classification,
                    frozenset(),
                )
            )

        if self.programme_classification is not None:
            redundant.update(
                _REDUNDANT_GENRES_BY_PROGRAMME_CLASSIFICATION.get(
                    self.programme_classification,
                    frozenset(),
                )
            )

        return frozenset(
            redundant,
        )

    @property
    def display_genres(self) -> tuple[MediaGenre, ...]:
        """Return genres suitable for compact presentation."""

        redundant = self.redundant_genres

        if not redundant:
            return self.genres

        return tuple(genre for genre in self.genres if genre not in redundant)


# =============================================================================
# Regional scripted-series rules
# =============================================================================


@dataclass(
    frozen=True,
    slots=True,
)
class _RegionalSeriesRule:
    """Origin rule for one regional scripted-series classification."""

    country_code: str
    original_languages: frozenset[str]
    classification: CulturalClassification


_REGIONAL_SERIES_RULES: Final[
    tuple[
        _RegionalSeriesRule,
        ...,
    ]
] = (
    _RegionalSeriesRule(
        country_code="KR",
        original_languages=frozenset(
            {
                "ko",
            }
        ),
        classification=CulturalClassification.K_DRAMA,
    ),
    _RegionalSeriesRule(
        country_code="CN",
        original_languages=frozenset(
            {
                "zh",
            }
        ),
        classification=CulturalClassification.C_DRAMA,
    ),
    _RegionalSeriesRule(
        country_code="JP",
        original_languages=frozenset(
            {
                "ja",
            }
        ),
        classification=CulturalClassification.J_DRAMA,
    ),
    _RegionalSeriesRule(
        country_code="TW",
        original_languages=frozenset(
            {
                "zh",
            }
        ),
        classification=CulturalClassification.TAIWANESE_DRAMA,
    ),
    _RegionalSeriesRule(
        country_code="HK",
        original_languages=frozenset(
            {
                "zh",
                "yue",
            }
        ),
        classification=CulturalClassification.HONG_KONG_DRAMA,
    ),
    _RegionalSeriesRule(
        country_code="TH",
        original_languages=frozenset(
            {
                "th",
            }
        ),
        classification=CulturalClassification.THAI_DRAMA,
    ),
    _RegionalSeriesRule(
        country_code="TR",
        original_languages=frozenset(
            {
                "tr",
            }
        ),
        classification=CulturalClassification.TURKISH_DRAMA,
    ),
)

# =============================================================================
# Genre evidence groups
# =============================================================================


_SCRIPTED_COMPATIBLE_TV_GENRES: Final[frozenset[MediaGenre]] = frozenset(
    {
        MediaGenre.ACTION,
        MediaGenre.ADVENTURE,
        MediaGenre.COMEDY,
        MediaGenre.CRIME,
        MediaGenre.DRAMA,
        MediaGenre.FAMILY,
        MediaGenre.FANTASY,
        MediaGenre.MYSTERY,
        MediaGenre.POLITICS,
        MediaGenre.ROMANCE,
        MediaGenre.SCIENCE_FICTION,
        MediaGenre.SOAP,
        MediaGenre.THRILLER,
        MediaGenre.WAR,
        MediaGenre.WESTERN,
    }
)

_REGIONAL_SCRIPTED_BLOCKERS: Final[frozenset[MediaGenre]] = frozenset(
    {
        MediaGenre.ANIMATION,
        MediaGenre.DOCUMENTARY,
        MediaGenre.KIDS,
        MediaGenre.NEWS,
        MediaGenre.REALITY,
        MediaGenre.TALK,
    }
)

_DIRECT_PROGRAMME_CLASSIFICATIONS: Final[
    tuple[
        tuple[
            MediaGenre,
            ProgrammeClassification,
        ],
        ...,
    ]
] = (
    (
        MediaGenre.NEWS,
        ProgrammeClassification.NEWS_PROGRAM,
    ),
    (
        MediaGenre.TALK,
        ProgrammeClassification.TALK_SHOW,
    ),
    (
        MediaGenre.REALITY,
        ProgrammeClassification.REALITY_SERIES,
    ),
    (
        MediaGenre.DOCUMENTARY,
        ProgrammeClassification.DOCUMENTARY_SERIES,
    ),
    (
        MediaGenre.SOAP,
        ProgrammeClassification.SOAP,
    ),
    (
        MediaGenre.KIDS,
        ProgrammeClassification.KIDS_SERIES,
    ),
)

# =============================================================================
# Animation cultural classifications
# =============================================================================


_ANIMATION_CULTURAL_CLASSIFICATIONS: Final[
    frozenset[CulturalClassification]
] = frozenset(
    {
        CulturalClassification.ANIME,
        CulturalClassification.DONGHUA,
        CulturalClassification.KOREAN_ANIMATION,
    }
)

# =============================================================================
# Display de-duplication
# =============================================================================


_REDUNDANT_GENRES_BY_FORMAT: Final[
    Mapping[
        MediaFormat,
        frozenset[MediaGenre],
    ]
] = MappingProxyType(
    {
        MediaFormat.TV_MOVIE: frozenset(
            {
                MediaGenre.TV_MOVIE,
            }
        ),
    }
)

_REDUNDANT_GENRES_BY_CULTURAL_CLASSIFICATION: Final[
    Mapping[
        CulturalClassification,
        frozenset[MediaGenre],
    ]
] = MappingProxyType(
    {
        CulturalClassification.ANIME: frozenset(
            {
                MediaGenre.ANIMATION,
            }
        ),
        CulturalClassification.DONGHUA: frozenset(
            {
                MediaGenre.ANIMATION,
            }
        ),
        CulturalClassification.KOREAN_ANIMATION: frozenset(
            {
                MediaGenre.ANIMATION,
            }
        ),
        CulturalClassification.K_DRAMA: frozenset(
            {
                MediaGenre.DRAMA,
            }
        ),
        CulturalClassification.C_DRAMA: frozenset(
            {
                MediaGenre.DRAMA,
            }
        ),
        CulturalClassification.J_DRAMA: frozenset(
            {
                MediaGenre.DRAMA,
            }
        ),
        CulturalClassification.TAIWANESE_DRAMA: frozenset(
            {
                MediaGenre.DRAMA,
            }
        ),
        CulturalClassification.HONG_KONG_DRAMA: frozenset(
            {
                MediaGenre.DRAMA,
            }
        ),
        CulturalClassification.THAI_DRAMA: frozenset(
            {
                MediaGenre.DRAMA,
            }
        ),
        CulturalClassification.TURKISH_DRAMA: frozenset(
            {
                MediaGenre.DRAMA,
            }
        ),
    }
)

_REDUNDANT_GENRES_BY_PROGRAMME_CLASSIFICATION: Final[
    Mapping[
        ProgrammeClassification,
        frozenset[MediaGenre],
    ]
] = MappingProxyType(
    {
        ProgrammeClassification.ANIMATED_SERIES: frozenset(
            {
                MediaGenre.ANIMATION,
            }
        ),
        ProgrammeClassification.DOCUMENTARY_SERIES: frozenset(
            {
                MediaGenre.DOCUMENTARY,
            }
        ),
        ProgrammeClassification.REALITY_SERIES: frozenset(
            {
                MediaGenre.REALITY,
            }
        ),
        ProgrammeClassification.TALK_SHOW: frozenset(
            {
                MediaGenre.TALK,
            }
        ),
        ProgrammeClassification.NEWS_PROGRAM: frozenset(
            {
                MediaGenre.NEWS,
            }
        ),
        ProgrammeClassification.KIDS_SERIES: frozenset(
            {
                MediaGenre.KIDS,
            }
        ),
        ProgrammeClassification.SOAP: frozenset(
            {
                MediaGenre.SOAP,
            }
        ),
    }
)

# =============================================================================
# Format compatibility
# =============================================================================


_MOVIE_FORMATS: Final[frozenset[MediaFormat]] = frozenset(
    {
        MediaFormat.MOVIE,
        MediaFormat.SHORT_FILM,
        MediaFormat.TV_MOVIE,
        MediaFormat.SPECIAL,
        MediaFormat.OVA,
        MediaFormat.ONA,
    }
)

_TV_FORMATS: Final[frozenset[MediaFormat]] = frozenset(
    {
        MediaFormat.SERIES,
        MediaFormat.MINISERIES,
        MediaFormat.SPECIAL,
        MediaFormat.OVA,
        MediaFormat.ONA,
    }
)


# =============================================================================
# Public classification API
# =============================================================================


def classify_media(
    media_kind: MediaKind | str,
    evidence: MediaClassificationEvidence,
) -> MediaClassification:
    """Classify normalized evidence for any supported media work."""

    normalized_media_kind = _normalize_media_kind(
        media_kind,
    )

    normalized_evidence = _normalize_evidence(
        evidence,
    )

    if normalized_media_kind is MediaKind.MOVIE:
        return classify_movie(
            normalized_evidence,
        )

    return classify_tv(
        normalized_evidence,
    )


def classify_movie(
    evidence: MediaClassificationEvidence,
) -> MediaClassification:
    """Classify normalized evidence for a Movie work."""

    normalized_evidence = _normalize_evidence(
        evidence,
    )

    genres = frozenset(
        normalized_evidence.genres,
    )

    cultural_classification = _classify_animation_culture(
        genres=genres,
        country_codes=frozenset(
            normalized_evidence.country_codes,
        ),
        original_language=normalized_evidence.original_language,
    )

    return MediaClassification(
        media_kind=MediaKind.MOVIE,
        media_format=_resolve_movie_format(
            normalized_evidence,
        ),
        genres=normalized_evidence.genres,
        cultural_classification=cultural_classification,
        origin=normalized_evidence.origin,
    )


def classify_tv(
    evidence: MediaClassificationEvidence,
) -> MediaClassification:
    """Classify normalized evidence for a TV work."""

    normalized_evidence = _normalize_evidence(
        evidence,
    )

    genres = frozenset(
        normalized_evidence.genres,
    )

    country_codes = frozenset(
        normalized_evidence.country_codes,
    )

    cultural_classification = _classify_animation_culture(
        genres=genres,
        country_codes=country_codes,
        original_language=normalized_evidence.original_language,
    )

    programme_classification = _classify_programme_type(
        genres=genres,
        cultural_classification=cultural_classification,
    )

    if cultural_classification is None and _is_regional_scripted_candidate(
        genres,
    ):
        cultural_classification = _classify_regional_scripted_series(
            country_codes=country_codes,
            original_language=normalized_evidence.original_language,
        )

    return MediaClassification(
        media_kind=MediaKind.TV,
        media_format=_resolve_tv_format(
            normalized_evidence,
        ),
        genres=normalized_evidence.genres,
        cultural_classification=cultural_classification,
        programme_classification=programme_classification,
        origin=normalized_evidence.origin,
    )


# =============================================================================
# Format resolution
# =============================================================================


def _resolve_movie_format(
    evidence: MediaClassificationEvidence,
) -> MediaFormat:
    """Resolve a structural format for a Movie work."""

    format_hint = evidence.format_hint

    if format_hint is not None:
        if format_hint not in _MOVIE_FORMATS:
            raise ValueError(
                f"Media format {format_hint.value!r} is not "
                "compatible with a Movie work."
            )

        return format_hint

    if MediaGenre.TV_MOVIE in evidence.genres:
        return MediaFormat.TV_MOVIE

    return MediaFormat.MOVIE


def _resolve_tv_format(
    evidence: MediaClassificationEvidence,
) -> MediaFormat:
    """Resolve a structural format for a TV work."""

    format_hint = evidence.format_hint

    if format_hint is not None:
        if format_hint not in _TV_FORMATS:
            raise ValueError(
                f"Media format {format_hint.value!r} is not "
                "compatible with a TV work."
            )

        return format_hint

    return MediaFormat.SERIES


# =============================================================================
# Cultural classification
# =============================================================================


def _classify_animation_culture(
    *,
    genres: frozenset[MediaGenre],
    country_codes: frozenset[str],
    original_language: str | None,
) -> CulturalClassification | None:
    """Classify animation from strong origin and language evidence."""

    if MediaGenre.ANIMATION not in genres:
        return None

    if "JP" in country_codes and original_language == "ja":
        return CulturalClassification.ANIME

    if "CN" in country_codes and original_language == "zh":
        return CulturalClassification.DONGHUA

    if "KR" in country_codes and original_language == "ko":
        return CulturalClassification.KOREAN_ANIMATION

    return None


def _classify_regional_scripted_series(
    *,
    country_codes: frozenset[str],
    original_language: str | None,
) -> CulturalClassification | None:
    """Classify a regional scripted TV work from strong origin evidence."""

    if not country_codes or original_language is None:
        return None

    matches = tuple(
        rule.classification
        for rule in _REGIONAL_SERIES_RULES
        if (
            rule.country_code in country_codes
            and original_language in rule.original_languages
        )
    )

    if (
        len(
            matches,
        )
        != 1
    ):
        return None

    return matches[0]


def _is_regional_scripted_candidate(
    genres: frozenset[MediaGenre],
) -> bool:
    """Return whether TV genres support regional scripted classification."""

    if not genres:
        return False

    if not genres.isdisjoint(
        _REGIONAL_SCRIPTED_BLOCKERS,
    ):
        return False

    return not genres.isdisjoint(
        _SCRIPTED_COMPATIBLE_TV_GENRES,
    )


def _classify_programme_type(
    *,
    genres: frozenset[MediaGenre],
    cultural_classification: CulturalClassification | None,
) -> ProgrammeClassification | None:
    """Resolve a TV programme classification from canonical genres."""

    for genre, classification in _DIRECT_PROGRAMME_CLASSIFICATIONS:
        if genre in genres:
            return classification

    if (
        MediaGenre.ANIMATION in genres
        and cultural_classification not in _ANIMATION_CULTURAL_CLASSIFICATIONS
    ):
        return ProgrammeClassification.ANIMATED_SERIES

    return None


# =============================================================================
# Validation
# =============================================================================


def _validate_result(
    classification: MediaClassification,
) -> None:
    """Validate compatibility between classification axes."""

    if classification.media_kind is MediaKind.MOVIE:
        if classification.media_format not in _MOVIE_FORMATS:
            raise ValueError(
                "Movie classification contains an incompatible media format."
            )

        if classification.programme_classification is not None:
            raise ValueError(
                "Movie classification cannot contain a TV "
                "programme classification."
            )

        return

    if classification.media_format not in _TV_FORMATS:
        raise ValueError(
            "TV classification contains an incompatible media format."
        )


def _normalize_evidence(
    value: MediaClassificationEvidence,
) -> MediaClassificationEvidence:
    """Validate normalized classification evidence."""

    if not isinstance(
        value,
        MediaClassificationEvidence,
    ):
        raise TypeError("evidence must be MediaClassificationEvidence.")

    return value


def _normalize_media_kind(
    value: MediaKind | str,
) -> MediaKind:
    """Normalize a supported media-kind value."""

    if isinstance(
        value,
        MediaKind,
    ):
        return value

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("media_kind must be a MediaKind or string.")

    normalized = value.strip().lower()

    if not normalized:
        raise ValueError("media_kind must not be blank.")

    if normalized == MediaKind.MOVIE.value:
        return MediaKind.MOVIE

    if normalized == MediaKind.TV.value:
        return MediaKind.TV

    supported = ", ".join(item.value for item in MediaKind)

    raise ValueError(
        f"Unsupported media kind {value!r}. Supported values are: {supported}."
    )


# =============================================================================
# Country-code normalization
# =============================================================================


def _normalize_country_codes(
    values: Iterable[str],
) -> tuple[str, ...]:
    """Normalize and deduplicate country codes."""

    if isinstance(
        values,
        (
            str,
            bytes,
        ),
    ):
        raise TypeError(
            "country_codes must be an iterable of country-code strings."
        )

    try:
        iterator = iter(
            values,
        )

    except TypeError as exc:
        raise TypeError(
            "country_codes must be an iterable of country-code strings."
        ) from exc

    normalized_codes: list[str] = []
    seen_codes: set[str] = set()

    for raw_value in iterator:
        if not isinstance(
            raw_value,
            str,
        ):
            raise TypeError("Each country code must be a string.")

        code = raw_value.strip().upper()

        if not code:
            continue

        if not _is_valid_country_code(
            code,
        ):
            raise ValueError(f"Invalid country code {raw_value!r}.")

        if code in seen_codes:
            continue

        normalized_codes.append(
            code,
        )

        seen_codes.add(
            code,
        )

    return tuple(
        normalized_codes,
    )


def _is_valid_country_code(
    value: str,
) -> bool:
    """Return whether a normalized country code has valid syntax."""

    return len(value) == 2 and all(
        "A" <= character <= "Z" for character in value
    )


# =============================================================================
# Language normalization
# =============================================================================


def _normalize_language(
    value: str | None,
) -> str | None:
    """Normalize an original-language value to its primary subtag."""

    if value is None:
        return None

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("original_language must be a string or None.")

    normalized = (
        value.strip()
        .lower()
        .replace(
            "_",
            "-",
        )
    )

    if not normalized:
        return None

    primary_language = normalized.split(
        "-",
        maxsplit=1,
    )[0]

    if not 2 <= len(
        primary_language,
    ) <= 8 or not all(
        "a" <= character <= "z" for character in primary_language
    ):
        raise ValueError(f"Invalid original language {value!r}.")

    return primary_language
