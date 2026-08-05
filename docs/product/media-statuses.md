# Library states and transitions

## Purpose

This document defines the personal library state machine. A title has one lifecycle status and may independently be marked as a favourite.

## Lifecycle statuses

### Watchlist

The user intends to watch the title but has not started standard progress.

### Watching

The user has started the title or is actively following it. For an ongoing series, a user may remain Watching while currently caught up.

### Completed

The user has completed the title according to the completion rules in `progress-rules.md` or has explicitly confirmed completion.

For a continuing series, `100% of currently released episodes watched` means **caught up**, not necessarily Completed. Automatic completion is reserved for ended/cancelled series with all released standard episodes watched. A user may still manually set Completed when appropriate.

### On hold

The user has paused the title with an intention to continue later. Existing progress is retained.

### Dropped

The user has stopped watching and does not currently intend to continue. Existing progress and watch history are retained.

### Rewatching

The user is watching a previously completed title again. Rewatch progress is tracked separately from the original completion history where supported.

## Favourite

`Favourite` is part of the library model but is **not** a mutually exclusive lifecycle status. It is an independent boolean flag that can coexist with Watchlist, Watching, Completed, On hold, Dropped or Rewatching.

This allows valid combinations such as:

- Favourite + Completed;
- Favourite + Rewatching;
- Favourite + Watchlist.

## Allowed transitions

| From | To | Automatic or manual | Notes |
|---|---|---|---|
| No library entry | Watchlist | Manual | Adds the title without progress. |
| No library entry | Watching | Manual or first progress | Used when the user starts immediately. |
| No library entry | Completed | Manual or mark watched | Creates a completed history entry. |
| Watchlist | Watching | Automatic on first standard progress | Undo must be offered. |
| Watchlist | Completed | Automatic when a movie is marked watched | Removes Watchlist lifecycle state. |
| Watching | Completed | Automatic only when completion criteria are satisfied | Ongoing series may remain Watching when caught up. |
| Completed | Rewatching | Manual | Starts a new rewatch cycle. |
| Rewatching | Completed | Automatic or manual | Closes the active rewatch cycle. |
| Any active status | On hold | Manual | Progress remains unchanged. |
| Any status | Dropped | Manual | Progress remains unchanged. |
| On hold | Watching | Manual or new progress | Resumes the title. |
| Dropped | Watching | Manual or new progress | Restarts the title. |
| Any status | Watchlist | Manual | Requires confirmation if progress exists. |
| Any status | No library entry | Manual delete | Personal progress/history handling must be confirmed. |

## Automatic transition rules

### First standard progress

When a Watchlist title receives its first watched standard episode:

1. set lifecycle status to Watching;
2. retain the date it was added to Watchlist;
3. record the watch event;
4. update standard progress;
5. offer Undo.

### Movie marked watched

When a Watchlist movie or anime movie is marked watched:

1. replace Watchlist with Completed;
2. set standard progress to complete;
3. record watch date and activity;
4. optionally offer rating;
5. evaluate achievement, challenge and XP rules;
6. offer Undo.

### Series completion

When the last eligible standard episode is marked watched:

- if the series is ended or cancelled, Watching/Rewatching transitions to Completed;
- if the series is continuing, returning or unknown, the series becomes caught up and normally remains Watching;
- specials never block either outcome.

### New standard episode after completion

If a completed series later receives a newly released standard episode:

- preserve the previous completion event in history;
- mark the title as no longer currently complete;
- transition to Watching when the series is active, unless the user has since chosen Dropped or On hold;
- notify the user only when notification preferences permit it.

## Manual override rules

Users may correct statuses manually. A manual override:

- must not delete progress;
- must not fabricate watched episodes;
- may require confirmation when it conflicts with progress;
- is recorded for synchronisation and audit of personal history;
- does not bypass catalogue-access rules.

## Undo and idempotency

- A single user action must generate at most one logical transition event.
- Repeated API requests with the same idempotency key must not duplicate history or XP.
- Undo restores the previous lifecycle status, progress and pending side effects.
- If an achievement or XP transaction has already been finalised, reversal uses a compensating event rather than deleting ledger history.
