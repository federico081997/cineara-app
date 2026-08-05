# Content types and catalogue access

## Purpose

This document defines the media categories used throughout Cineara. These definitions are product contracts: API schemas, database records, filters, progress logic and UI labels must use the same meaning.

## Common media identity

Every catalogue item has a common identity containing at least:

- a Cineara identifier;
- one primary media type;
- title and original title;
- synopsis;
- release or first-air date;
- catalogue-access level;
- artwork references;
- genres, countries and languages;
- source identifiers, where available;
- release status;
- classification provenance and optional manual override.

A source provider's raw type is not automatically the Cineara media type. Mapping and classification occur in the backend.

## Media types

### Movie

A non-anime, movie-shaped work intended to be consumed as one primary feature. It uses binary standard progress: unwatched or watched. Additional editions, extras and bonus features do not create standard episode progress.

Examples of product behaviour:

- a movie can be Watchlist, Watching, Completed, On hold, Dropped or Rewatching;
- a partially watched movie may use `Watching` even though exact playback position is outside the initial scope;
- marking it watched completes its standard progress;
- a movie may belong to a collection or cross-media franchise.

### TV series

A non-anime episodic work organised into seasons and episodes. Standard progress is calculated from released standard episodes. Season 0 and episodes classified as specials are handled separately.

This type includes scripted, documentary, reality and other episodic television unless a more specific Cineara type applies.

### Anime series

An episodic animated work classified by Cineara as anime. Anime is not inferred from animation genre alone. Classification may use origin, language, production data, source metadata and a manual override.

Anime series follow the same standard-versus-specials progress model as TV series while retaining anime-specific discovery filters and relations.

### Anime movie

A movie-shaped work classified by Cineara as anime. It follows movie progress rules but appears in anime discovery and anime-specific statistics.

### OVA

An **Original Video Animation** released primarily for home-video distribution rather than an initial television or theatrical run.

Product rules:

- an OVA may be a standalone top-level title with one or more standard episodes;
- a top-level episodic OVA counts its own released standard episodes normally;
- an OVA attached to another series as Season 0 or as special episodes does not affect that parent series' standard completion;
- classification is explicit and may be manually corrected.

### ONA

An **Original Net Animation** released primarily through internet distribution.

Product rules mirror OVA behaviour:

- a standalone ONA can have one or more standard episodes;
- an ONA attached to a parent title as specials remains outside the parent standard denominator;
- release platform alone does not make every streaming-first animation an ONA; classification is curated or rule-based with override support.

### Special

A non-standard media item or episode associated with a primary work. This includes bonus episodes, recap episodes classified as specials, promotional episodes, unaired extras and similar material.

Specials:

- remain visible and playable as catalogue records;
- have released/unreleased state;
- can be marked watched and rated when supported;
- contribute only to separate optional specials progress;
- never change the standard completion percentage of the parent series.

## Movie-shaped and episodic behaviour

| Media type | Shape | Standard denominator |
|---|---|---|
| Movie | Movie | 1 released work |
| Anime movie | Movie | 1 released work |
| TV series | Episodic | Released standard episodes |
| Anime series | Episodic | Released standard episodes |
| OVA | Usually episodic | Released standard episodes when standalone |
| ONA | Usually episodic | Released standard episodes when standalone |
| Special | Special | Separate specials denominator only |

## Catalogue-access levels

Catalogue access is separate from media type and separate from regional age certification.

### Standard

General catalogue content permitted in both builds without enabling mature or adult catalogue visibility. Individual regional certifications may still vary.

### Mature

Age-restricted or mature entertainment that is not classified as part of the explicit-adult catalogue. Mature visibility is available in both builds but is disabled by default and controlled by user preferences within the build ceiling.

### Adult

The explicit-adult catalogue. It is never available in the Play build. It may be available in the personal build only when the user explicitly enables it.

`Adult` is a catalogue capability classification, not a promise about legality, regional availability or a universal age rating. Distribution and content policies must be reviewed before release.

## Classification precedence

When classification sources disagree, the precedence is:

1. active administrative/manual override;
2. Cineara classification rules;
3. trusted source metadata;
4. conservative fallback.

The system stores enough provenance to explain how the current type and catalogue level were assigned.

## Required invariants

- A title has exactly one primary media type at a time.
- Anime is not equivalent to all animation.
- A title may be reclassified without changing its Cineara identity.
- Catalogue level is enforced by the backend before results reach a client.
- Specials cannot silently enter the standard progress denominator.
