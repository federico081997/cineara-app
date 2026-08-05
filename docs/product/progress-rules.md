# Progress rules

## Purpose

Progress must remain predictable across television, anime, OVA, ONA and specials. This document defines eligibility, calculation, completion and status interaction.

## Core rule

Standard progress is:

```text
watched released standard episodes / released standard episodes
```

Only released standard episodes satisfying every eligibility condition enter the denominator.

## Standard episode eligibility

An episode counts toward standard progress when:

- it belongs to a standard numbered season rather than Season 0;
- it is not classified as a special, bonus feature, recap-special or unaired extra;
- its release/air date has passed in the user's effective time zone, or the backend marks it released;
- it has not been removed or superseded by a canonical metadata correction.

## Explicit exclusions

The standard denominator excludes:

- Season 0;
- episodes classified as specials;
- bonus features;
- recap episodes marked as specials;
- unaired extras;
- unreleased standard episodes;
- placeholder episodes without a confirmed release.

## Series progress

Let:

- `E` be the set of eligible released standard episodes;
- `W` be the subset of `E` marked watched.

Then:

```text
standard_progress = |W| / |E|
```

Display rules:

- when `|E| > 0`, show the percentage and `|W| of |E| episodes`;
- when `|E| = 0`, show `No released standard episodes` rather than `0%`;
- progress is capped at 100%;
- metadata corrections trigger recalculation.

## Season progress

For each standard season, use the same formula restricted to eligible episodes in that season.

A standard season is complete when all its eligible released standard episodes are watched and at least one eligible episode exists.

Season 0 never appears as a standard season. It is represented in the Specials area.

## Specials progress

Specials use a separate optional calculation:

```text
watched released specials / released specials
```

Rules:

- specials progress is not shown when no released specials exist;
- watching or ignoring specials never changes standard completion;
- users may mark all released specials watched or unwatched;
- specials can be rated individually when the rating target supports it;
- a title can be 100% standard-complete while specials remain unwatched.

## Movies and anime movies

Movie-shaped content uses binary standard progress:

```text
0 / 1 = not completed
1 / 1 = completed
```

A movie may temporarily be Watching, On hold or Dropped, but exact playback-position tracking is outside the initial scope.

## OVA and ONA

A standalone episodic OVA or ONA uses released standard episodes as its denominator.

When OVA/ONA material is attached to another series as Season 0 or special episodes, it contributes only to that parent title's specials progress.

## Released-state rule

The backend owns the canonical released-state decision. A client may display localised dates, but it must not include an episode in the denominator solely because a device clock says the release time has passed when the backend has not confirmed release.

When exact release time is unavailable, the effective release date becomes released at the start of that date in the configured regional time zone, subject to later metadata correction.

## Caught up versus completed

These states are intentionally distinct:

- **Caught up:** all currently released standard episodes are watched.
- **Completed:** the title satisfies completion criteria and has lifecycle status Completed.

For an ongoing series, the user can be caught up at 100% while remaining Watching.

Automatic Completed status requires:

- an ended or cancelled series status;
- at least one eligible released standard episode;
- every eligible released standard episode watched.

The user may manually confirm completion when source status is unreliable.

## Newly released episodes

When a new standard episode becomes released:

1. add it to the denominator;
2. recalculate series and season percentages;
3. preserve all historical completion events;
4. update caught-up state;
5. apply the status rule in `media-statuses.md`;
6. do not remove achievement completions already valid at the time they were awarded.

## Bulk actions

### Mark standard season watched

Marks all eligible released standard episodes in the selected season watched. It does not mark Season 0 or specials watched.

### Mark series watched

Marks all eligible released standard episodes watched. The interface must explicitly state that specials are excluded and offer a separate optional specials action.

### Mark unwatched

A bulk-unwatch action requires confirmation, preserves activity history according to the user's chosen history option and triggers compensating progression logic where necessary.

## Runtime progress

Where episode runtimes are available:

```text
watched_runtime = sum(runtime of watched eligible standard episodes)
remaining_runtime = sum(runtime of unwatched eligible released standard episodes)
released_runtime = watched_runtime + remaining_runtime
```

Specials runtime is reported separately. Estimated values must be labelled as estimated.

## Metadata uncertainty

When episode classification or release status is uncertain:

- prefer exclusion from automatic completion until classified;
- display a metadata status where useful;
- allow administrative correction;
- recalculate deterministically after correction.

## Acceptance examples

### Example A: standard series with specials

A series has 12 released standard episodes and 3 released Season 0 specials. The user watched all standard episodes and 1 special.

```text
Standard progress: 12 / 12 = 100%
Specials progress: 1 / 3 = 33%
```

The unwatched specials do not prevent standard completion.

### Example B: airing series

A continuing series has released 8 of 12 announced standard episodes. The user watched all 8.

```text
Standard progress: 8 / 8 = 100%
State: Caught up
Lifecycle: Watching
```

The four unreleased episodes do not enter the denominator.

### Example C: newly released episode

The ninth episode releases. The denominator becomes 9, while watched episodes remain 8.

```text
Standard progress: 8 / 9 = 88.9%
State: Not caught up
Lifecycle: Watching
```
