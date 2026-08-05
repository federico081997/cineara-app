# Achievement, challenge, XP and rank rules

## Purpose

Cineara's progression system must reward meaningful media activity indefinitely without encouraging artificial toggling or making permanent achievements feel disposable.

## Four progression layers

### One-time achievements

Permanent milestones that unlock once and remain earned.

Examples:

- complete the first movie;
- complete the first standard season;
- watch content from 5, 10, 25 and 50 countries;
- rate the first completed title.

Tiered milestones are separate one-time definitions. Completing the 10-country tier does not erase the 5-country tier.

### Repeatable achievements

Objectives that may be completed repeatedly and retain an all-time completion count.

Examples:

- Movie Night: complete any eligible movie;
- Season Finisher: complete any standard season;
- Anime Session: complete an eligible anime title;
- World Explorer: complete content from a country not watched during the current repeat window.

A repeatable completion produces an immutable completion record and increments the total count.

### Rotating challenges

Time-bounded objectives generated or activated on a schedule:

- daily;
- weekly;
- monthly;
- seasonal.

Challenges have a start time, end time, eligibility rule, target, progress, completion state and reward. Expired incomplete challenges remain in history but cannot be completed retroactively unless explicitly configured.

### XP ranks

XP-based progression spans rank 1 through rank 999.

- The rank curve is versioned configuration.
- Rank never falls because a curve version changes; migrations preserve earned rank or provide an explicit conversion.
- Rank 999 is the maximum rank, but repeatable completions and personal records continue afterward.

## Eligible event sources

Progression evaluates domain events rather than UI actions. Initial eligible events include:

- MovieWatched;
- EpisodeWatched;
- SeasonCompleted;
- SeriesCompleted;
- RewatchCompleted;
- CollectionCreated;
- RatingSubmitted;
- ReviewCreated, only after public UGC exists;
- ChallengeCompleted;
- AchievementCompleted.

Opening a screen, refreshing, searching or toggling a filter never awards XP.

## Standard-content dependency

Season and series completion achievements use the standard progress rules:

- Season 0 and specials are excluded;
- only released standard episodes count;
- an ongoing series being caught up is not automatically a completed-series achievement;
- separate achievements may explicitly target specials.

## Definition model

Every achievement or challenge definition includes:

- stable identifier and version;
- display name and description;
- kind: one-time, repeatable or rotating challenge;
- category and optional media-type restrictions;
- criteria expression;
- target value;
- reward XP and optional cosmetic reward;
- visibility: visible or hidden;
- activation and retirement dates;
- anti-abuse policy;
- localisation keys.

Criteria must be data-driven where practical so new definitions do not require a mobile release.

## Completion guarantees

- One-time achievements unlock at most once per user.
- Repeatable achievements use a unique completion key so retries cannot duplicate a completion.
- Challenge completions are unique per challenge instance.
- Historical completions are immutable; corrections use compensating records.
- Achievement evaluation is idempotent and safe to retry.

## XP policy

XP is awarded only for genuine, durable actions. Initial principles:

- completing content can award XP;
- completing an achievement or challenge can award bonus XP;
- the same logical event cannot award XP twice;
- repeated watch/unwatch toggling cannot farm XP;
- deleting or reversing activity may create a compensating negative ledger entry when reward finalisation has already occurred;
- undo within the immediate action window cancels pending rewards cleanly;
- account XP is server-authoritative after synchronisation is introduced;
- guest XP may be local but must migrate with source event identifiers.

## Rewatch policy

Rewatches can contribute to repeatable achievements and XP, but only when a complete rewatch cycle is recorded. Repeatedly toggling Completed and Rewatching does not count.

A rewatch cycle requires:

- a previously completed title;
- a distinct rewatch start;
- genuine completion of the eligible standard content or movie;
- a completion timestamp later than the rewatch start.

## Anti-abuse controls

Controls include:

- idempotency keys;
- immutable event and XP ledgers;
- minimum event separation where appropriate;
- duplicate-event detection;
- limits on contribution-based XP;
- server validation for account data;
- compensating reversals instead of destructive ledger edits;
- anomaly flags for impossible event sequences.

Anti-abuse rules must not punish legitimate bulk imports; imported history is tagged with provenance and may use a distinct XP policy.

## Rarity

Achievement rarity is calculated from eligible active users and displayed only when the sample is sufficiently large. Rarity is informational and does not change whether an achievement is earned.

Suggested labels:

- Common;
- Uncommon;
- Rare;
- Epic;
- Legendary.

Thresholds are configuration, not hard-coded mobile logic.

## Notification behaviour

Achievement and rank-up feedback must be celebratory but non-blocking:

- animations respect reduced-motion preferences;
- multiple unlocks are queued or summarised;
- no modal interrupts active playback-related actions;
- users can disable progression notifications while retaining progression.

## Endless-progression guarantee

A user may complete every permanent milestone and still make progress through:

- repeatable achievement counts;
- daily, weekly, monthly and seasonal challenges;
- streaks and personal records;
- XP and rank progression up to 999;
- seasonal badges;
- post-rank-999 repeatable records.
