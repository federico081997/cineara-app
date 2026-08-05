# Screen specifications

## Purpose

Each major screen has a defined user purpose, primary content, actions and required states. These specifications are acceptance contracts, not pixel-perfect mock-ups.

## Global requirements

Every data-driven screen must support:

- loading or skeleton state;
- empty state with a meaningful next action;
- error state with retry where recovery is possible;
- offline/cached state when supported;
- catalogue-policy filtering before content is rendered;
- accessibility semantics, large text and reduced motion;
- safe handling of missing artwork and incomplete metadata.

## Startup and onboarding

### Startup / Splash — V1

**Purpose:** Initialise configuration, local database, session, build capability and safe first route without exposing restricted cached content.

**Primary content:** Cineara branding and minimal progress feedback.

**Actions:** None during normal startup; retry only after recoverable failure.

**Required states:** starting, migration in progress, offline startup, recoverable error, mandatory-update state when later supported.

### Onboarding — V1

**Purpose:** Explain discovery, tracking, picker and privacy; collect only preferences needed to improve the initial experience.

**Primary content:** concise pages for Discover, Track, Choose for me and Personalise.

**Actions:** continue, skip nonessential preferences, choose language/region, configure mature visibility within build ceiling.

**Required states:** first launch, returning incomplete onboarding, personal-build adult preference explanation without enabling by default.

### Authentication — V1

**Purpose:** Offer optional account creation and sign-in for synchronisation without blocking guest use.

**Primary content:** sign in, sign up, recovery and migration explanation.

**Actions:** authenticate, recover account, continue as guest.

**Required states:** validation error, network failure, verification required, guest-data migration preview.

## Primary navigation

### Home — V1

**Purpose:** Provide a configurable, motivating overview of what to continue, watch today and expect next.

**Primary content:** Featured, Continue Watching, Today's Pick, Upcoming, popular/discovery sections, Watchlist, achievement and rank summaries.

**Actions:** open media, continue, configure layout, switch All/Movies/TV/Anime, refresh.

**Required states:** partially cached sections, per-section error, empty new-user Home, offline Home.

### Home layout — V1

**Purpose:** Let users reorder, enable and configure Home sections.

**Primary content:** draggable section list with visibility, card style and item-count controls.

**Actions:** reorder, enable/disable, restore defaults, save.

**Required states:** unsaved changes, sync conflict, reset confirmation.

### Discover — V1

**Purpose:** Route users into Movies, TV, Anime, regional hubs and upcoming releases.

**Primary content:** category cards, pinned hubs, curated sections and search access.

**Actions:** open category/hub, pin hub, search.

**Required states:** no pinned hubs, offline cached discovery, unavailable section.

### Library — V1

**Purpose:** Browse and manage the personal media library efficiently at small or very large scale.

**Primary content:** summary, status/type filters, grid/list toggle and media entries with progress.

**Actions:** filter, sort, bulk edit, open item, quick status/favourite actions.

**Required states:** empty library, no filter matches, offline local mode, pending sync indicators.

### Profile — V1

**Purpose:** Collect identity, progression, history, statistics, account and settings entry points.

**Primary content:** user/guest header, rank summary, recent achievements, statistics preview and settings links.

**Actions:** sign in/out, open achievements, rank, activity, statistics or settings.

**Required states:** guest, authenticated, sync issue, restricted/offline account state.

## Search and discovery

### Search — V1

**Purpose:** Find media and people quickly across the permitted catalogue.

**Primary content:** search field, All/Movies/TV/Anime/People tabs, filters, recent searches and paginated cards.

**Actions:** type, clear, filter, open result, remove history.

**Required states:** idle/recent, debouncing, loading, no results, partial pagination error, policy-hidden direct result.

### Media discovery — V1

**Purpose:** Explore one media category with appropriate filters and deterministic sorting.

**Primary content:** filter summary, sort control and infinite media grid.

**Actions:** open filters, sort, clear, open media.

**Required states:** no matches, end of results, stale cache, pagination retry.

### Regional hubs — V1

**Purpose:** Browse data-driven country, language, genre and editorial discovery destinations.

**Primary content:** pinned and all hubs, each with title, description and representative artwork.

**Actions:** open, pin/unpin, search hubs.

**Required states:** no pinned hubs, temporarily disabled hub, offline cached list.

### Discovery hub — V1

**Purpose:** Present configurable sections for one regional or thematic domain.

**Primary content:** header, editorial description, horizontal sections and optional filters.

**Actions:** open media, filter, pin, see all within a section.

**Required states:** empty section, partly unavailable source, stale-data indicator.

### Upcoming — V1

**Purpose:** Separate future movies, series and episodes so users understand what is releasing and when.

**Primary content:** tabs, date groups, countdowns, region and filter controls.

**Actions:** open item, add reminder, add to Watchlist, change region/filter.

**Required states:** no upcoming items, unknown exact time, reminder permission denied.

## Choosing content

### Daily Pick — V1

**Purpose:** Encourage one suitable viewing choice without overwhelming the user.

**Primary content:** one hero card, explanation, runtime/provider context and recent replacement state.

**Actions:** open, watch/add, replace, dismiss, snooze.

**Required states:** insufficient personal data fallback, no eligible candidate, offline cached pick, replacement limit if introduced.

### Picker configuration — V1

**Purpose:** Define the candidate source and random-selection constraints.

**Primary content:** source, mode, media type, providers, runtime, watched-state and repeat-avoidance controls.

**Actions:** run picker, save/update preset, reset.

**Required states:** no eligible source, invalid conflicting filters, offline local-only source.

### Picker result — V1

**Purpose:** Reveal one valid result and support immediate next actions.

**Primary content:** result card, selection reason/mode and source context.

**Actions:** open, pick again, temporarily reject, add/update status, mark watched.

**Required states:** result loading/reveal, source exhausted, stale availability warning.

### Picker history and presets — V1

**Purpose:** Review prior selections and reuse configurations.

**Primary content:** dated history, rejection state and preset cards.

**Actions:** rerun preset, edit, delete, open result, clear history.

**Required states:** empty history, deleted source collection, partially invalid preset.

## Details

### Movie details — V1

**Purpose:** Explain a movie and make discovery, tracking, rating and provider actions available in one place.

**Primary content:** hero, synopsis, facts, cast/crew, trailers, providers, franchise, recommendations and information.

**Actions:** set status/favourite, mark watched, rate, add collection, open person/franchise/provider/external link.

**Required states:** hidden artwork, missing runtime, unavailable provider data, stale external data.

### Series details — V1

**Purpose:** Explain a series and expose season structure, standard progress, specials and next action.

**Primary content:** hero, synopsis, progress/runtime summary, seasons, cast/crew, providers and relations.

**Actions:** set status/favourite, continue next episode, rate series, bulk standard-progress actions.

**Required states:** no released episodes, caught up, completed, metadata uncertainty, Season 0 present.

### Season details — V1

**Purpose:** Show one season's standard progress, runtime and episodes without mixing specials.

**Primary content:** season header, release facts, progress, runtime and episode list.

**Actions:** mark released standard episodes watched/unwatched, open/rate episode or season.

**Required states:** unreleased season, empty metadata, partial release, complete season.

### Specials — V1

**Purpose:** Present Season 0 and special-classified episodes separately from standard completion.

**Primary content:** explanation, separate progress and special episode list.

**Actions:** mark individual/all released specials watched, rate supported targets.

**Required states:** no released specials, unreleased extras, classification warning.

### Episode details — V1

**Purpose:** Explain one episode and expose progress, rating, cast, crew and navigation.

**Primary content:** title, image/spoiler cover, synopsis, air date, runtime, guest cast, crew and adjacent episodes.

**Actions:** mark watched, rate, open people, previous/next.

**Required states:** unreleased episode, hidden thumbnail, missing synopsis, special classification.

### Person details — V1

**Purpose:** Show a person's biography and understandable role-based credits.

**Primary content:** Biography, Known For, Movies, TV, Anime, Acting, Directing, Writing, Production and Other tabs.

**Actions:** filter/sort credits, open media.

**Required states:** no biography, no credits for a tab, duplicate-role consolidation.

### Franchise details — V1

**Purpose:** Explain ordered and typed relationships across movies, series and anime.

**Primary content:** franchise description, timeline and relation labels.

**Actions:** open member, change display order where supported.

**Required states:** uncertain chronology, partial catalogue visibility, missing member metadata.

## Personal tracking

### Library item editor — V1

**Purpose:** Edit lifecycle status, favourite, dates, notes and rewatch controls without losing progress.

**Primary content:** current state, progress summary, history and editable fields.

**Actions:** update status, favourite, start/finish rewatch, remove entry.

**Required states:** conflict confirmation, pending sync, delete/history preservation choice.

### Continue Watching — V1

**Purpose:** Surface the next eligible standard episode or incomplete movie for active titles.

**Primary content:** landscape cards with next action, progress and remaining runtime.

**Actions:** open next episode/title, place on hold, remove from row.

**Required states:** caught up only, no active titles, unavailable next episode metadata.

### Collections — V1

**Purpose:** Browse private mixed-media collections and use them as picker sources.

**Primary content:** collection cards with item count, cover collage and notes.

**Actions:** create, open, reorder collections, run picker.

**Required states:** no collections, offline local changes, sync conflict.

### Collection details/editor — V1

**Purpose:** Inspect and manually order collection members.

**Primary content:** metadata, notes and ordered media list.

**Actions:** add/remove, reorder, edit, run picker.

**Required states:** empty collection, hidden member, deleted source metadata.

### Rating dialog — V1

**Purpose:** Capture or edit a personal rating quickly after viewing or from details.

**Primary content:** selected score, target identity and optional remove action.

**Actions:** save, remove, cancel.

**Required states:** pending save, offline queued save, validation error.

## Calendar and progression

### Calendar — V1

**Purpose:** Show relevant releases in agenda, week and month forms.

**Primary content:** date navigation, release cards and filter controls.

**Actions:** open item, create/remove reminder, change view.

**Required states:** no events, unknown release time, notification permission issue.

### Achievements — V1

**Purpose:** Browse permanent and repeatable achievements with progress and history.

**Primary content:** category filters, progress summary, cards and recent unlocks.

**Actions:** open details, filter by locked/earned/repeatable/hidden where permitted.

**Required states:** no progress, offline cached progression, multiple recent unlocks.

### Achievement details — V1

**Purpose:** Explain criteria, current progress, reward, rarity and completion history.

**Primary content:** badge, description, progress, reward and timestamps/count.

**Actions:** inspect related challenge or qualifying history where available.

**Required states:** hidden locked achievement, retired definition, rarity unavailable.

### Challenges — V1

**Purpose:** Show active rotating objectives and time remaining.

**Primary content:** daily, weekly, monthly and seasonal cards.

**Actions:** open details, navigate to qualifying discovery when useful.

**Required states:** no active challenge, expired, completed, offline countdown caveat.

### Rank details — V1

**Purpose:** Explain current rank, XP position and recent XP ledger entries.

**Primary content:** rank frame, progress to next rank, XP history and reward milestones.

**Actions:** inspect XP source details.

**Required states:** rank 999, pending offline XP, compensated transaction.

### Activity — V1

**Purpose:** Provide a private chronological record of watched, rated and progression events.

**Primary content:** grouped timeline and filters.

**Actions:** filter, open related item, correct eligible personal history.

**Required states:** no activity, imported events, deleted/corrected event representation.

### Statistics — V1

**Purpose:** Summarise private viewing behaviour without presenting estimates as exact measurements.

**Primary content:** watch-time, counts, genres, countries, languages, streaks and exploration map.

**Actions:** change period, inspect methodology, recalculate where supported.

**Required states:** insufficient data, estimated runtime, recalculation pending.

## Settings and account

### Settings — V1

**Purpose:** Provide one stable entry point for appearance, content, region, providers, notifications, privacy and data controls.

**Primary content:** grouped setting tiles and current values.

**Actions:** open subsettings, sign out, access attribution.

**Required states:** guest/authenticated differences, setting unavailable in current build.

### Content preferences — V1

**Purpose:** Control mature/adult visibility and artwork treatment within the immutable build ceiling.

**Primary content:** build-aware toggles, explanations and current effective level.

**Actions:** enable/disable permitted levels, configure blur.

**Required states:** Play build without adult controls, confirmation for personal adult enablement, policy-enforced restriction.

### Notification settings — V1

**Purpose:** Configure upcoming-release, progress and achievement notifications.

**Primary content:** permission state, category toggles, quiet hours and spoiler preferences.

**Actions:** request permission, change settings, open system settings.

**Required states:** denied, permanently denied, token unavailable, offline local settings.

### Privacy, export and account deletion — V1

**Purpose:** Give users direct control over data, consent and account removal.

**Primary content:** privacy summary, export action, deletion workflow and retention explanation.

**Actions:** export, revoke consent, delete account.

**Required states:** guest export, authenticated export generation, deletion confirmation and cooling-off state if adopted.

## Deferred community screens

### Reviews and review details — Later

**Purpose:** Browse authenticated public reviews with spoiler protection, helpful votes, comments and reports.

**Release dependency:** reporting, blocking, moderation, audit and operational response must exist first.

### Review editor — Later

**Purpose:** Create or edit a review for a supported target with explicit spoiler classification.

**Release dependency:** authentication, content policy and moderation.

### Report and block — Later

**Purpose:** Report harmful content and block users within the app.

**Release dependency:** moderation queue, enforcement and appeals workflow.

## Internal administration — Later

### Admin dashboard

**Purpose:** Summarise system health, moderation, metadata feedback and configuration changes.

### Catalogue override

**Purpose:** Correct media/anime classification, relations and external links with audit history.

### Discovery and progression editors

**Purpose:** Manage hubs, Home sections, achievements, challenges and rank curve without mobile releases.

### Moderation queue

**Purpose:** Review reports, apply policy actions, manage appeals and preserve audit evidence.
