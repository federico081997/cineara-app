# Cineara product vision

## Product statement

Cineara helps people discover what to watch, organise what they intend to watch, track progress accurately and remain motivated to explore films, television and anime without turning entertainment into administrative work.

The product should feel like a polished personal media companion rather than a raw catalogue browser. It combines dependable metadata with a modern card-based interface, low-friction tracking, explainable suggestions and long-running progression.

## Problem

Existing media applications commonly fragment the experience:

- discovery, watchlists and episode tracking live in separate products;
- anime, films and television are modelled inconsistently;
- specials distort completion percentages;
- large watchlists make choosing something difficult;
- recommendations provide little explanation or control;
- achievement systems eventually end or reward meaningless activity;
- catalogue restrictions are often hidden or inconsistent between builds;
- external provider links are frequently generic or misleading.

Cineara addresses these problems with explicit product rules and one coherent library model.

## Target users

### Primary user

A person who watches a mixture of movies, television and anime and wants one structured place to discover, choose, track and revisit content.

### Secondary users

- users with large watchlists who need a random or preference-weighted picker;
- users who follow currently airing series and need upcoming episode visibility;
- users who enjoy regional discovery, such as Korean dramas, Japanese cinema or Hong Kong cinema;
- completion-oriented users who value progress, statistics, achievements, challenges and ranks;
- privacy-conscious users who want useful guest-mode functionality before creating an account.

## Core jobs to be done

1. **Find something relevant.** Search and browse standard, regional and upcoming catalogues.
2. **Understand a title.** Inspect synopsis, seasons, episodes, people, franchises, runtime, ratings, providers and safe external links.
3. **Choose without decision fatigue.** Receive a daily suggestion or pick randomly from a controlled source.
4. **Track accurately.** Maintain lifecycle status, episode-level progress, rewatches, ratings and optional specials progress.
5. **Stay current.** See upcoming movies, series and episodes and optionally receive reminders.
6. **Remain motivated.** Earn one-time achievements, repeatable completions, rotating challenges, XP and ranks 1–999.
7. **Retain control.** Configure content visibility, providers, region, language, home sections, privacy and notifications.

## Product principles

### Accurate before impressive

Progress, status, availability and external-link labels must be correct and explainable. Cineara must not present uncertain metadata as verified fact.

### One coherent model

Movies, television and anime share common concepts where possible, while format-specific differences remain explicit.

### User control over automation

Automatic transitions should reduce work without silently overriding deliberate user choices. Important automatic changes must support Undo or a clear explanation.

### Discovery without pressure

Suggestions should encourage exploration, not create guilt. Daily picks can be replaced, dismissed or snoozed.

### Progress that does not end

Permanent milestones may be finite, but repeatable achievements, rotating challenges, streaks, personal records, XP and ranks keep progression available.

### Privacy by default

The personal library, viewing history and statistics are private. Account creation is optional until cloud synchronisation is needed.

### Safe distribution boundaries

The Play build and personal build share most code, but their catalogue ceilings are immutable capabilities. The Play binary never exposes the adult catalogue.

### Accessible and resilient

The application must support large text, screen readers, reduced motion, low-memory devices, unstable networks and useful offline library access.

## Product identity

Cineara should feel:

- cinematic but not theatrical or cluttered;
- modern, calm and professional;
- visually rich while preserving readable information hierarchy;
- encouraging rather than gamified to the point of distraction;
- consistent across discovery, detail, tracking and progression surfaces.

## Success indicators

Early product success is measured by behaviour rather than vanity metrics:

- users can find and open a title quickly;
- progress remains correct for series containing Season 0 and specials;
- users understand why a daily pick was suggested;
- users can configure a picker and receive a valid result without repetition problems;
- library changes survive restarts and later synchronise without data loss;
- catalogue visibility never exceeds the build capability;
- core flows remain usable with slow or unavailable networks;
- users continue earning meaningful progress after permanent milestones are exhausted.

## Non-goals

Cineara is not initially:

- a video-hosting or streaming-piracy application;
- a replacement for licensed streaming providers;
- a public social network;
- a source for scraped IMDb or Rotten Tomatoes rating data;
- a machine-learning research project before deterministic product behaviour works;
- a microservice platform.
