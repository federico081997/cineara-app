# Cineara

Cineara is a mobile-first discovery and tracking application for movies, television series, anime and related media. It combines catalogue browsing, structured watch progress, daily suggestions, a configurable random picker, upcoming-release tracking and long-running achievement progression.

This repository currently implements **Phase 0: Product specification and repository foundation**. It intentionally contains no Flutter application or FastAPI service yet. The purpose of this phase is to remove behavioural ambiguity before code and database schemas make those decisions expensive to change.

## Phase 0 deliverables

The repository defines:

- the product vision and non-negotiable principles;
- the complete target feature set;
- the navigation hierarchy and purpose of every major screen;
- media types and catalogue-access levels;
- library lifecycle states and transitions;
- standard and specials progress calculations;
- one-time achievements, repeatable achievements, challenges and ranks 1–999;
- Play Store versus personal-build capability rules;
- version-one scope and explicitly deferred work;
- the initial monorepo and modular-monolith architecture;
- the preliminary visual language and screen specifications.

## Repository layout

```text
cineara/
├── docs/
│   ├── product/        Product behaviour and scope
│   ├── architecture/   System boundaries and technical direction
│   └── design/         Visual language and screen contracts
├── mobile/             Flutter application, introduced in Phase 1
├── backend/            FastAPI modular monolith, introduced in Phase 1
├── admin/              Internal operations application, introduced later
├── packages/           Shared Dart packages and design system
├── contracts/          OpenAPI, event and configuration contracts
├── infrastructure/     Local and hosted infrastructure definitions
├── legal/              Policies and legal documents
├── scripts/            Development, validation and release scripts
└── store-assets/       Play Store and personal-build assets
```

Empty implementation directories contain `.gitkeep` files so the Phase 0 structure remains visible in Git.

## Product invariants

These rules must remain consistent across Flutter, backend, database, tests and documentation:

1. Season 0 and episodes classified as specials never affect standard series completion.
2. Only released standard episodes appear in the standard progress denominator.
3. Specials progress is optional and displayed separately.
4. `Favourite` is an independent flag; it does not replace the current lifecycle status.
5. The Play build can never request or receive adult-catalogue content.
6. The personal build may expose the adult catalogue only when the user explicitly enables it.
7. Catalogue ceilings are enforced by the backend as well as by the client.
8. One-time achievements remain earned permanently; repeatable achievements retain a completion count.
9. XP is awarded for genuine viewing and contribution events, not screen views or repeated status toggling.
10. Public reviews and comments are not released before reporting, blocking and moderation exist.

## Validate Phase 0

The validation script uses only the Python standard library.

```bash
make check
```

Other useful commands:

```bash
make tree       # print the repository structure
make docs-list  # list Phase 0 documentation files
make clean      # remove local caches only
```

## Implementation sequence

1. Read `docs/product/vision.md` to understand the product outcome.
2. Review `docs/product/content-types.md`, `media-statuses.md` and `progress-rules.md`; these become the foundation of shared models and tests.
3. Review `docs/product/play-vs-personal-build.md` before introducing app flavours or catalogue APIs.
4. Use `docs/design/screen-specifications.md` as the acceptance contract for the Flutter shell and later features.
5. Start Phase 1 only after `make check` passes and all Phase 0 completion criteria remain satisfied.

## Next phase

Phase 1 introduces the Flutter environments, FastAPI health service, PostgreSQL, Redis and continuous integration. It must not redesign the product rules established here; behavioural changes should be made in these specifications first.

## Licence

This repository is licensed under the MIT License. See `LICENSE`.
