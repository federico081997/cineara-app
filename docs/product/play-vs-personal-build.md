# Play Store and personal build policy

## Purpose

Cineara uses one codebase with distinct distribution capabilities. The difference is intentionally narrow and enforced at both compile time and backend request time.

This document is a product and architecture contract, not legal advice. Store policies must be re-verified before every release.

## Distribution channels

### Play build

Intended for Google Play distribution.

Capabilities:

```text
Maximum catalogue level: Mature
Show mature content: Off by default, user-controlled
Blur mature artwork: User-controlled
Adult catalogue: Unavailable
Adult toggle: Not compiled into the product capability
```

The Play binary must never expose, request or receive adult-catalogue results. The adult capability cannot be remotely enabled in this binary.

### Personal build

Distributed outside the Play Store for personal use.

Capabilities:

```text
Maximum catalogue level: Adult
Show mature content: Off by default, user-controlled
Show adult catalogue: Off by default, user-controlled
Blur mature artwork: User-controlled
Blur adult artwork: On by default, user-controlled
```

Adult visibility requires an explicit user action and remains constrained by backend policy, regional requirements and source availability.

## Capability model

Each client has immutable build capabilities:

```text
CatalogueCapabilities
├── distribution channel
├── maximum catalogue level
├── mature-toggle availability
├── adult-toggle availability
└── artwork-blur defaults
```

User preferences can reduce visibility below the build maximum but can never raise it.

Effective catalogue visibility is:

```text
effective level = minimum(build ceiling, backend client ceiling, user preference)
```

## Backend enforcement

Client-side hiding is insufficient. The backend identifies the app client and applies its maximum catalogue level before search, discovery, recommendations, picker candidates, daily picks, home sections or direct detail responses are returned.

The app-client record includes conceptually:

```text
id
channel
package name
signing-certificate hash
maximum catalogue level
active state
created timestamp
```

A modified Play client calling the API directly must still be unable to retrieve adult-catalogue data.

## Request behaviour

Every catalogue-affecting request carries a verified app-channel identity. User preference headers or query parameters are treated only as requests to reduce the visible catalogue.

Examples:

```text
Play client + mature disabled  -> Standard only
Play client + mature enabled   -> Standard + permitted Mature
Play client + adult requested  -> Reject or clamp; never return Adult
Personal client + adult off    -> Standard + optional Mature
Personal client + adult on     -> Standard + Mature + permitted Adult
```

## Cross-feature enforcement

Catalogue policy applies consistently to:

- search and autocomplete;
- standard and regional discovery;
- upcoming releases;
- Home sections;
- daily picks and recommendations;
- random picker candidates and history;
- people credits and franchises;
- external links and provider availability;
- notifications and deep links;
- cached and offline records.

A hidden title must not leak through a person page, notification, image cache, activity feed or recommendation explanation.

## Local cache behaviour

When the effective visibility level becomes more restrictive:

- hidden catalogue entries are removed from browse caches;
- personal library records remain represented safely when legally and technically appropriate, but artwork and metadata visibility follow policy;
- search history and notifications do not reveal hidden titles;
- cached images are invalidated according to the artwork policy.

## Build separation

The two builds may use different:

- package names;
- application names;
- launcher icons;
- compile-time configuration;
- signing keys;
- store metadata.

They should share business logic, UI components and API contracts wherever the catalogue capability does not require divergence.

## Prohibited implementation shortcuts

- Do not ship an adult-capable Play binary with only a hidden toggle.
- Do not rely exclusively on remote feature flags to disable adult access.
- Do not trust a client-provided catalogue level without app-client verification.
- Do not return adult records and merely blur them in the Play build.
- Do not allow deep links to bypass catalogue checks.
- Do not describe a generic provider homepage as a verified title deep link.

## Release verification

Before a Play release:

1. build the signed Play variant;
2. run automated capability tests against search, details, recommendations and deep links;
3. inspect the compiled UI for adult controls;
4. verify the backend app-client ceiling;
5. clear test caches and repeat direct-ID access tests;
6. review current Google Play content and user-generated-content policies;
7. confirm screenshots and store descriptions are policy-safe.
