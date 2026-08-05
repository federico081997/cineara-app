# Complete target feature list

## Purpose

This is the complete product target, not the order of implementation. `release-scope.md` identifies what belongs to version one and what is deferred.

## 1. Application foundation

- Android-first Flutter application with phone and tablet layouts.
- Dark and light themes with reduced-motion and large-text support.
- Bottom navigation: Home, Discover, Library and Profile.
- Independent tab navigation stacks and deep-link handling.
- English and Italian localisation foundation.
- Loading skeletons, empty states, error states and offline indicators.
- Guest mode before account creation.
- Offline personal library and queued synchronisation.

## 2. Catalogue and content policy

- Unified Cineara identity for movies, television, anime and people.
- Media types: Movie, TV series, Anime series, Anime movie, OVA, ONA and Special.
- Catalogue levels: Standard, Mature and Adult.
- Manual classification overrides without changing identity.
- Backend-enforced Play and personal catalogue ceilings.
- Mature and adult artwork-blur preferences where permitted.
- Safe handling when a direct link points to hidden content.

## 3. Search

- Debounced multi-type search.
- All, Movies, TV, Anime and People result tabs.
- Pagination and duplicate prevention.
- Recent searches and clear-history controls.
- Search filters respecting catalogue, language and region preferences.
- Search result poster and person cards.

## 4. Standard discovery

- Dedicated Movies, TV and Anime discovery.
- Genre, date, language, country, rating, popularity and runtime filters.
- Anime series and anime movie separation.
- OVA, ONA and special-aware filtering.
- Sort by popularity, rating, release date and relevance.
- Persistent per-screen filter and sorting preferences.

## 5. Regional and editorial discovery

- Data-driven discovery hubs that can be added without a mobile release.
- Korean dramas and movies.
- Chinese dramas and cinema.
- Hong Kong cinema and Taiwanese media.
- Japanese dramas and cinema.
- Indian cinema, Thai dramas and Turkish dramas.
- Nordic, European, Latin American and African cinema.
- Classic cinema, documentaries and world cinema.
- Hub enable, hide, pin and reorder behaviour.
- Editorial collections and seasonal sections.

## 6. Upcoming content

- Separate views for upcoming movies, series and episodes.
- Region- and time-zone-aware dates.
- Countdown and calendar actions.
- Library-aware upcoming episodes.
- Reminder creation and notification settings.

## 7. Home

- Modern card-based configurable Home feed.
- Featured carousel.
- Continue Watching.
- Today's Pick.
- Upcoming episodes and movies.
- Trending and popular sections for movies, TV and anime.
- Regional sections such as popular K-dramas.
- Watchlist, top-rated and recommendation sections.
- Achievement and rank summaries.
- All, Movies, TV and Anime Home modes.
- Drag-and-drop section ordering.
- Per-section enable, item count and card-style settings.
- Cached offline Home state.

## 8. Daily Pick

- One explainable suggestion per day.
- Candidate signals from library, ratings, preferences, providers and runtime.
- Reason text such as closeness to season completion or time suitability.
- Replace, dismiss and snooze actions.
- Rejection memory and repeat avoidance.
- Catalogue-policy enforcement.

## 9. Random picker

- Sources: Watchlist, Watching, any library status, one or multiple collections, discovery hub or filtered catalogue.
- Media-type filters for movies, TV and anime.
- Provider, availability, runtime and unwatched-only filters.
- Pure random and preference-weighted random.
- Group-friendly, short-watch, movie-night and no-repeat modes.
- Saved presets.
- Pick-again and temporary rejection exclusion.
- Picker history.
- Immediate open, add, rate or mark-watched actions.

## 10. Media details

- Movie and series hero headers with core actions.
- Overview, Seasons, Cast & Crew, Gallery, Reviews and Information tabs as applicable.
- Synopsis, genres, release status, certification and original title.
- Runtime and series runtime summaries.
- Trailers and image galleries.
- Featured crew and full cast/crew navigation.
- Similar and recommended media.
- Franchise and related-media sections.
- Personal status, progress, favourite and rating actions.
- Provider availability by region.
- Safe external links to TMDB, IMDb and other authorised destinations.
- Data freshness and unavailable-rating states.

## 11. Seasons and episodes

- Dedicated season and episode screens.
- Standard season progress and runtime.
- Season 0 represented as Specials.
- Released-only standard denominator.
- Mark episode, season or all standard episodes watched/unwatched.
- Separate specials progress.
- Next eligible standard episode.
- Episode guest cast and crew.
- Previous and next episode navigation.
- Optional spoiler-sensitive thumbnail hiding.
- Ratings for seasons, episodes and specials.

## 12. People and credits

- Person biography and known-for content.
- Movie, TV and Anime tabs.
- Acting, Directing, Writing, Production and Other role tabs.
- Credit filters and timeline.
- Open any credit to its media details.
- Correct handling of multiple roles for one title.

## 13. Franchises and media relations

- Movie collections and cross-media franchises.
- Ordered franchise timeline.
- Sequel, prequel, spin-off, remake, adaptation and related-work links.
- Manual curation and source provenance.

## 14. Library

- Lifecycle statuses: Watchlist, Watching, Completed, On hold, Dropped and Rewatching.
- Independent Favourite flag.
- Grid and list views.
- Filters by status, type, genre, progress and favourite.
- Bulk status edits.
- Quick actions and long-press poster actions.
- Optimistic updates with Undo.
- Multiple rewatches and complete watch history.
- Notes and dates where supported.
- Large-library performance.

## 15. Progress and runtime

- Episode-level standard progress.
- Season and series progress bars.
- Caught-up state separate from Completed.
- Season 0 and specials excluded from standard completion.
- Separate optional specials progress.
- Released-only denominator.
- Watched, remaining, released and total runtime summaries.
- Estimated runtime labels.
- Automatic next standard episode.
- Automatic status transitions with safeguards.

## 16. Ratings

- Personal ratings for movies, series, anime, seasons, episodes and specials.
- Rating prompt after completion.
- Rating edit and removal.
- Personal rating history.
- Aggregate Cineara distribution after sufficient data exists.
- External rating display only from authorised sources.
- External link fallback when rating integration is unavailable.

## 17. Collections

- Private mixed-media collections.
- Manual ordering and notes.
- Offline editing and cloud synchronisation.
- Picker-source integration.
- Add one title to multiple collections.

## 18. Calendar and notifications

- Agenda, week and month views.
- Upcoming movies, series and episodes.
- Library-aware episode schedule.
- Region and time-zone handling.
- Release reminders and deep links.
- Spoiler-safe notification content.
- Per-category notification controls.

## 19. Achievements, challenges and ranks

- One-time permanent achievements.
- Tiered permanent milestones.
- Repeatable achievements with completion counts.
- Daily, weekly, monthly and seasonal challenges.
- Hidden achievements.
- Rarity labels when statistically valid.
- XP ledger and anti-abuse rules.
- Ranks 1–999 with non-blocking rank-up feedback.
- Post-rank-999 repeatable records.
- Reduced-motion support.

## 20. Activity and statistics

- Private chronological viewing history.
- Watch dates and rewatch cycles.
- Estimated watch time.
- Genre, country and language statistics.
- Movie, series, anime and episode counts.
- Streaks and personal records.
- Regional exploration map.
- Recalculable statistics after metadata corrections.

## 21. Accounts and synchronisation

- Optional account creation.
- Guest-data migration.
- Email verification and recovery.
- Secure token storage.
- Offline operation outbox.
- Retryable synchronisation and deterministic conflict resolution.
- Multi-device library, progress, ratings and collections.
- Data export and account deletion.

## 22. Recommendations

- Deterministic, explainable recommendation engine first.
- Genre, country, language, keyword, cast and provider signals.
- Popularity fallback for cold-start users.
- Exclude completed titles by default.
- Not-interested feedback.
- Reason chips for every suggestion.
- Advanced machine-learning ranking only after sufficient data and evaluation.

## 23. Reviews, comments and safety

- Authenticated public reviews for supported targets.
- Spoiler marking and spoiler cover.
- Helpful votes.
- Comment threads.
- Reporting and blocking.
- Moderation queue, suspensions and appeals.
- Audit trail for moderation actions.
- Public launch only after safety operations exist.

## 24. External links and streaming availability

- Region-specific availability.
- Separation of availability, verified title deep link and fallback link.
- JustWatch attribution where required by the data source.
- URL allow-listing and validation.
- Broken-link reporting and administrative override.
- Never label a generic provider homepage as an exact title deep link.
- No scraping of IMDb or Rotten Tomatoes ratings.

## 25. Administration

- Role-based internal web application.
- Catalogue and anime-classification overrides.
- Franchise and media-relation curation.
- Discovery hub and Home-section management.
- Achievement, challenge and rank-curve management.
- External-link and provider verification.
- Metadata feedback queue.
- Review/comment moderation and user reports.
- Feature flags, audit logs and system health.

## 26. Data control and legal surfaces

- Privacy policy, terms and content policy.
- Community, review and moderation guidelines before UGC release.
- Data export and account deletion.
- Third-party attribution.
- Copyright and reporting process.
- Play Store Data Safety and content-rating readiness.

## 27. Quality attributes

- Automated unit, widget, integration, contract, load and security tests.
- Request IDs, structured logging, metrics and tracing.
- No sensitive information in logs.
- Controlled caching and invalidation.
- Smooth image-heavy scrolling.
- Support for thousands of library items and long-running series.
- Database backups and restore testing.
- Accessibility review across core journeys.
