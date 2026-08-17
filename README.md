# Cineara

**Cineara** is a personal media-tracking and discovery application for movies, TV series, anime, and international cinema.

The project is designed around a simple idea: provide a single place to **track what you watch, manage your media library, follow your progress, and explore cinema from around the world**.

> **Project status:** Cineara is currently under active development and is intended **for personal use only**. It is not currently distributed as a public application or offered as a commercial service.

---

## About Cineara

Cineara is not a streaming service and does not host or provide movies or television episodes.

Instead, it is being developed as a companion application for managing and exploring a user's viewing activity.

The application aims to combine traditional media tracking with richer discovery and personalization features, including international cinema, personal statistics, achievements, viewing progress, and contextual recommendations.

---

## Current Status

Cineara is currently a **personal development project**.

The application, backend architecture, data model, user interface, and feature set are still evolving. Features visible in the repository may therefore be incomplete, experimental, or subject to significant changes.

At this stage:

* the application is intended only for personal use;
* no production service is currently guaranteed;
* public registration and public distribution are not currently supported;
* APIs, database schemas, and UI components may change without notice;
* backward compatibility is not guaranteed;
* test and preview data may be used throughout the application during development.

A public release may be considered in the future, but the current repository should be treated as an actively developed personal project rather than a finished consumer application.

---

## Main Goals

Cineara is being designed around four main areas.

### Track

Keep track of movies, series, seasons, and episodes.

Planned and developing functionality includes:

* watch status;
* watchlist management;
* favourites;
* viewing history;
* episode progress;
* continue-watching tracking;
* recently watched titles;
* completion state for seasons and series.

### Discover

Explore media without turning the Home screen into a generic catalogue browser.

Discovery is intended to include:

* movies and TV series;
* anime;
* international cinema;
* countries and regions;
* languages;
* decades;
* genres and moods;
* people;
* editorial collections;
* world-cinema discovery;
* personalized discovery tools.

### Understand Your Viewing

Cineara is also intended to provide a richer view of a user's viewing habits through features such as:

* personal statistics;
* viewing-time insights;
* movie and series counts;
* genre and country statistics;
* achievements;
* ranks and experience progression;
* Cinema Passport progress.

### Personalize

The application is being designed so that the experience can gradually adapt to the user.

This includes concepts such as:

* configurable Home sections;
* personalized recommendations;
* pinned discovery collections;
* watchlist suggestions;
* smart sections;
* viewing-based insights.

---

## Application Structure

Cineara uses a modular project structure separating the mobile application, backend services, shared packages, infrastructure, contracts, and supporting tools.

```text
cineara/
├── mobile/
├── backend/
├── admin/
├── packages/
├── contracts/
├── infrastructure/
├── legal/
├── scripts/
└── store-assets/
```

### `mobile`

The Flutter application used by the end user.

The mobile application contains the main Cineara interface, navigation, media pages, discovery experience, library, profile functionality, and reusable presentation components.

### `backend`

Backend services responsible for application-specific data and server-side functionality.

### `packages`

Shared packages, including reusable Cineara design-system components and common functionality.

### `contracts`

Shared API and data contracts used to keep communication between different parts of the system consistent.

### `infrastructure`

Infrastructure and deployment-related configuration.

### `admin`

Administration and content-management tooling.

### `scripts`

Development, setup, validation, and maintenance scripts.

### `legal`

Project licensing and other legal documentation.

### `store-assets`

Application-store artwork and supporting release assets.

---

## Mobile Application

The mobile application is built with **Flutter and Dart**.

The main navigation model currently revolves around four root destinations:

```text
Home
Discover
Library
Profile
```

### Home

Home is intended to answer:

> What matters to me right now?

Rather than duplicating the catalogue exploration available in Discover, Home focuses on personal and time-relevant information such as viewing progress, new episodes, watchlist selections, recommendations, achievements, and user-configured sections.

### Discover

Discover is the primary catalogue-exploration area.

It is intended for browsing by country, region, language, genre, mood, decade, people, collections, and other discovery dimensions.

### Library

Library provides access to the user's saved and tracked media.

### Profile

Profile contains the user's Cineara identity, viewing statistics, achievements, Cinema Passport progress, application settings, and related personal features.

---

## Design System

Cineara includes a dedicated reusable design system.

Its purpose is to keep visual and interaction behaviour consistent across the application rather than defining styles independently inside individual features.

The design system includes concepts such as:

```text
Colour
Typography
Spacing
Radii
Elevation
Motion
Breakpoints
Buttons
Cards
Chips
Navigation
Text fields
Overlays
```

The interface supports both light and dark presentation and is being developed with accessibility, scalable text, internationalization, and right-to-left layouts in mind.

---

## Internationalization and Accessibility

Cineara is intended to support international users and media from many regions.

UI components are therefore designed with considerations including:

* localized strings rather than hard-coded interface text;
* left-to-right and right-to-left layouts;
* directional padding and alignment;
* scalable system text;
* high-contrast accessibility settings;
* reduced-motion preferences;
* screen-reader semantics;
* responsive layouts for different display sizes.

These areas remain under active testing as development continues.

---

## Media Data

Cineara uses external metadata sources for information about movies, television series, episodes, people, artwork, and related catalogue information.

Application-specific information—such as user activity, Cineara-specific discovery features, achievements, progress, and manually curated data—is handled separately from external catalogue metadata.

Third-party data remains subject to the terms, attribution requirements, and usage policies of the respective providers.

---

## What Cineara Is Not

Cineara does **not**:

* stream movies or television episodes;
* host copyrighted video content;
* replace legitimate streaming services;
* provide access to paid media;
* guarantee the availability of a title on a particular provider.

Where external providers or services are referenced, Cineara acts only as a tracking or informational companion.

---

## Development

The project is under active development, and the exact development workflow may change as the architecture evolves.

A typical Flutter development environment requires:

```text
Flutter
Dart
Android Studio or another Flutter-compatible IDE
Android SDK
Git
```

After cloning the repository, dependencies for the mobile project can typically be installed with:

```bash
cd mobile
flutter pub get
```

The application can then be started on a configured device or emulator with the appropriate development entry point.

For example:

```bash
flutter run
```

Environment-specific configuration may be required depending on the current development branch and backend setup.

Do not commit private API keys, database credentials, service tokens, signing credentials, or other secrets to the repository.

---

## Development Builds

Cineara may contain multiple application entry points or build configurations used for development and experimentation.

Development builds should not be assumed to represent a final release configuration.

Features may also depend on backend services, development databases, local configuration, or API credentials that are intentionally excluded from source control.

---

## Testing

Reusable components should be tested independently where practical.

The project also contains interactive preview screens used to evaluate UI components under conditions such as:

```text
Light / dark themes
Different screen widths
Large text
Long localized strings
RTL layouts
High contrast
Reduced motion
Different application states
```

These previews are development tools and are not necessarily part of the final user-facing application.

---

## Privacy

Because Cineara is currently intended for personal use, its privacy and account infrastructure should not yet be assumed to meet the requirements of a publicly operated production service.

Before any future public release, areas such as authentication, account security, data retention, privacy controls, analytics, backups, deletion workflows, and regulatory requirements would need to be reviewed for the intended deployment environment.

---

## Security

Sensitive configuration must remain outside version control.

Examples include:

```text
API keys
Access tokens
Database credentials
Private certificates
Signing keys
Service-account credentials
Environment secrets
```

Local development secrets should be stored using the project's environment/configuration system rather than directly inside source files.

---

## Personal-Use Notice

**Cineara is currently intended solely for personal use and development.**

The existence of source code in this repository should not be interpreted as indicating that Cineara is a publicly available service, supported product, or production-ready application.

The project may contain unfinished functionality, experimental features, development-only integrations, placeholder content, test data, or components that have not undergone production security and reliability review.

Do not deploy, redistribute, publish, or commercially operate the project unless permitted by the applicable project licence and all relevant third-party service terms.

---

## Licence

Refer to the repository's `LICENSE` file and documentation under `legal/` for the applicable licensing terms.

Unless explicitly permitted by those terms, no assumption should be made that the project may be commercially redistributed, repackaged, or offered as a third-party service.

Third-party packages, APIs, media metadata, trademarks, artwork, and other external resources remain subject to their respective licences and terms.

---

## Roadmap

Cineara is an evolving project rather than a fixed specification.

Development is expected to continue across areas such as:

* media tracking and progress;
* Home personalization;
* international discovery;
* recommendations;
* statistics and insights;
* achievements and ranks;
* Cinema Passport;
* advanced movie and character information;
* backend services;
* caching and offline behaviour;
* localization;
* accessibility;
* application performance;
* testing and release infrastructure.

Implementation priorities may change as the application develops.

---

## Contributing

Cineara is currently a personal project and is **not presently accepting general public contributions**.

This may change if the project is opened to external development in the future.

---

## Disclaimer

Cineara is an independent project.

Names, trademarks, artwork, metadata, and other material associated with movies, television series, streaming providers, databases, or third-party services belong to their respective owners.

Integration with or reference to a third-party platform does not imply endorsement, sponsorship, or affiliation unless explicitly stated.

---

## Author

Cineara is currently developed as a personal software project.

---

**Cineara — track what you watch, understand your journey, and discover cinema beyond borders.**
