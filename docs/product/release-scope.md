# Release scope

## Purpose

This document separates version-one product scope from later capabilities. It does not replace the phased engineering roadmap; a V1 feature may still be implemented late because of dependencies.

## Version-one outcome

Version one is a polished Android media companion that lets users discover, understand, choose, track and stay motivated across movies, television and anime. It is useful in guest mode, supports optional synchronisation, and maintains strict Play/personal catalogue boundaries.

## V1 — Included

### Catalogue and discovery

- Movie, TV series, Anime series, Anime movie, OVA, ONA and Special classification.
- Standard, Mature and Adult catalogue policy with build ceilings.
- Search across media and people.
- Dedicated Movies, TV and Anime discovery.
- Initial regional discovery hubs.
- Upcoming movies, series and episodes.

### Details and navigation

- Movie, series, season, episode and person details.
- Franchise and related-media navigation.
- Runtime summaries.
- Provider availability and safe external links.
- English and Italian localisation foundation.

### Personal tracking

- Guest-mode local library.
- Watchlist, Watching, Completed, On hold, Dropped and Rewatching.
- Independent Favourite flag.
- Released-only standard progress.
- Season 0 and specials excluded from standard completion.
- Separate specials progress.
- Ratings for movies, series, seasons, episodes and specials.
- Collections and rewatch history.

### Choice and motivation

- Configurable Home feed.
- Explainable Daily Pick.
- Pure and preference-weighted Random Picker with saved presets.
- Calendar and release reminders.
- One-time and repeatable achievements.
- Rotating challenges.
- XP and ranks 1–999.
- Private activity and core statistics.

### Accounts and control

- Optional account creation and cloud synchronisation.
- Guest-data migration.
- Region, language, provider, theme and content preferences.
- Data export in Cineara JSON/CSV formats.
- Account deletion.
- Play and personal Android builds with backend enforcement.

### Operational minimum

- Seed/configuration-based management of hubs, achievements, challenges and rank curve.
- Internal scripts for corrections and configuration deployment.
- Crash reporting, structured logs, backups and critical integration tests.
- Public privacy policy, terms and third-party attribution.

## V1 — Explicitly excluded

The following are not required for the first public release:

- public reviews and comments;
- public profiles, following or social feeds;
- full moderation and appeals administration UI;
- machine-learning recommendation ranking;
- collaborative or shared collections;
- watch-party coordination;
- direct playback or hosting of media;
- scraped IMDb or Rotten Tomatoes rating data;
- iOS, desktop or web consumer applications;
- a microservice architecture;
- automatic import from every third-party tracking service.

## Later releases

### V1.1 — Quality and operational expansion

- broader regional hubs;
- richer statistics and personal records;
- improved import adapters;
- full internal admin interface for catalogue, hubs and progression;
- additional accessibility and tablet optimisation;
- more sophisticated deterministic recommendation strategies.

### V2 — Community features

- authenticated reviews and comments;
- helpful votes and comment threads;
- reporting, blocking, moderation, appeals and audit workflows;
- public-profile controls only after privacy and safety review.

### V2+ — Advanced intelligence and platforms

- evaluated machine-learning recommendation ranking;
- group-friendly recommendation profiles;
- iOS or web clients if product demand justifies them;
- richer provider deep-link integrations where authorised;
- optional social or collaborative features with separate safety specifications.

## V1 launch gates

V1 is not releasable until:

- progress calculations pass Season 0, specials and unreleased-episode tests;
- Play clients cannot retrieve adult-catalogue records through any route;
- personal catalogue controls default to restrictive settings;
- library changes survive restart and synchronisation conflict tests;
- external URLs are validated and link quality is labelled accurately;
- core screens support loading, empty, error and offline states;
- account deletion and export are accessible when accounts are enabled;
- TMDB and provider attribution requirements are met;
- legal and store-policy checks are complete;
- crash reporting and database backups are operational.

## Change control

A proposed V1 addition must identify:

1. the user problem it solves;
2. dependencies and data model impact;
3. offline and synchronisation behaviour;
4. catalogue-policy implications;
5. accessibility requirements;
6. test and operational cost;
7. which existing V1 item will be delayed or removed.
