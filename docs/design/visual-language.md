# Visual language

## Design direction

Cineara uses a modern, cinematic and professional card-based interface. Artwork creates emotional appeal, while typography, spacing and restrained motion maintain clarity.

The interface should not resemble a streaming playback service. It is a discovery and tracking companion: actions, progress, provenance and availability must remain legible.

## Core principles

### Artwork-led, information-first

Posters and backdrops attract attention, but titles, media type, year, status, progress and action state remain readable without opening a detail screen.

### Calm density

Screens can contain rich catalogues without feeling crowded. Use clear section boundaries, predictable card proportions and progressive disclosure.

### Consistent card grammar

Cards share tokens and interaction rules. A poster card, episode card and achievement card may differ in shape but use consistent radii, elevation, focus, loading and disabled states.

### Visible state

Watch status, progress, favourite, content visibility, link quality and offline freshness must not rely on colour alone.

### Accessible motion

Motion explains hierarchy and result changes. It never blocks interaction and must respect reduced-motion settings.

## Preliminary colour system

These values are Phase 0 direction and become implementation tokens in Phase 2.

### Dark theme

| Token | Value | Use |
|---|---:|---|
| Background | `#0B1020` | Main canvas |
| Surface | `#151C2F` | Cards and sheets |
| Elevated surface | `#1D2740` | Dialogs and highlighted cards |
| Primary | `#8B5CF6` | Primary actions and active navigation |
| Secondary | `#38BDF8` | Informational accents and links |
| Text primary | `#F8FAFC` | Main text |
| Text secondary | `#A8B3C7` | Supporting metadata |
| Border | `#2B3855` | Dividers and card outlines |
| Success | `#22C55E` | Completed and successful states |
| Warning | `#F59E0B` | Mature notices and caution states |
| Error | `#EF4444` | Destructive/error states |

### Light theme

| Token | Value | Use |
|---|---:|---|
| Background | `#F5F7FB` | Main canvas |
| Surface | `#FFFFFF` | Cards and sheets |
| Elevated surface | `#FFFFFF` | Dialogs and highlighted cards |
| Primary | `#6D28D9` | Primary actions and active navigation |
| Secondary | `#0369A1` | Informational accents and links |
| Text primary | `#111827` | Main text |
| Text secondary | `#5B6475` | Supporting metadata |
| Border | `#D9E0EA` | Dividers and card outlines |

Final tokens must pass contrast checks for their actual foreground/background pairings.

## Typography

Use a clean sans-serif family with strong Android rendering and a complete italic/bold range. Typography roles:

| Role | Intent |
|---|---|
| Display | Rare cinematic hero text |
| Headline | Screen and major section titles |
| Title | Card and subsection titles |
| Body | Synopsis and explanatory content |
| Label | Buttons, chips, tabs and metadata |
| Numeric | Progress, rank, countdown and runtime values |

Rules:

- titles may use two lines on poster cards before truncation;
- synopsis text uses comfortable line height;
- all text respects system scaling;
- essential metadata is not embedded only in images;
- numeric progress aligns consistently.

## Spacing and layout

Use a 4 dp base grid with common spacing tokens:

```text
4, 8, 12, 16, 20, 24, 32, 40, 48
```

Recommended defaults:

- screen horizontal padding: 16 dp on phones, adaptive on tablets;
- section gap: 24–32 dp;
- card internal padding: 12–16 dp;
- minimum touch target: 48 × 48 dp;
- responsive content-width cap on large screens.

## Shape and elevation

- primary cards: 16 dp radius;
- compact controls/chips: pill or 10–12 dp radius;
- bottom sheets: 24 dp top radius;
- dialogs: 20 dp radius;
- elevation is subtle and supplemented by borders in dark mode;
- selected cards use outline and state indicator, not a large shadow alone.

## Card families

### Hero card

Backdrop-led, wide card for featured content and Daily Pick. Includes gradient protection, title, concise reason/metadata and one primary action.

### Poster card

2:3 artwork ratio. Includes title, year/type, rating or progress and optional quick-state badge. Long press opens quick actions.

### Landscape media card

Used for Continue Watching, episodes and upcoming releases. Includes image, progress/date, concise metadata and primary continuation action.

### Compact card

Used in search suggestions, people credits and dense library lists.

### Progression card

Used for achievements, challenges and rank. Includes icon/badge, current/target value, progress bar and reward without imitating a gambling interface.

## Navigation

Bottom navigation contains four destinations: Home, Discover, Library and Profile. Labels remain visible. Active state uses icon, label weight and colour.

Tablets may replace bottom navigation with an adaptive navigation rail while preserving the same information architecture.

## Imagery

- poster aspect ratio: 2:3;
- backdrop aspect ratio: approximately 16:9;
- use placeholders with stable dimensions to prevent layout shift;
- mature/adult blur is applied before artwork becomes legible;
- episode imagery can be hidden until watched when spoiler protection is enabled;
- attribution remains readable and not obscured by artwork.

## Progress presentation

Progress must show more than a bar:

```text
8 of 12 released episodes
3 h 42 min remaining
Caught up
Specials 1 of 3
```

Standard and specials progress use separate labels and visual groups.

## Motion

- standard transitions: 150–250 ms;
- result reveals and card expansion may use 250–400 ms;
- picker and achievement animations are cancellable and non-blocking;
- reduced motion replaces large movement with fades or immediate state changes;
- no infinite decorative animation on information-heavy screens.

## Empty, loading, error and offline states

Every data-driven screen defines:

- skeleton/loading state with stable layout;
- useful empty state and next action;
- recoverable error state with retry;
- offline state indicating whether cached data is available;
- stale-data timestamp where relevant.

## Accessibility

- colour is never the only state indicator;
- touch targets meet platform guidance;
- cards have meaningful semantic labels;
- reading order follows visual order;
- poster images have concise semantic descriptions or are decorative where the title is already announced;
- focus states are visible for keyboard/tablet navigation;
- charts and progress visuals have text equivalents;
- animations respect reduced motion;
- content warnings are announced before hidden artwork is revealed.
