# Storybook QA Checklist: Resilience Components

Run through this checklist when validating Storybook stories for recovery components.

## Status Pill
- [ ] Variants render with correct colors (Connected, Degraded, Reconnecting, Offline).
- [ ] Live-update story shows smooth 150ms transition.
- [ ] Label truncates gracefully ≤8 characters.

## Connection Banner
- [ ] Stories include Host Drop, Retrying, Offline, Failure states.
- [ ] Buttons fire stub actions and are keyboard focusable.
- [ ] Attempt counter updates from controls (knobs/args) and reflected in copy.

## Offline Badge + Editor Tab
- [ ] Appears only when `unsynced=true` arg.
- [ ] Tooltip fires on hover/focus.

## Command Palette
- [ ] Opens with focus on search; Escape closes.
- [ ] Arrow keys navigate options; Enter triggers handler.
- [ ] Stories cover offline-focused options and default palette.

## Confirmation Sheet
- [ ] Checklist items togglable; confirm button disabled until all checked (if required by story).
- [ ] Danger styling aligns with tokens.
- [ ] Suppress toggle persists state within story controls.

## Undo Toast
- [ ] Countdown timer visible (control to set secs remaining).
- [ ] Hover pauses timer indicator (simulate via story action).
- [ ] Undo button triggers callback.

## Sync Conflict Modal
- [ ] Diff lines color-coded (#34C759 additions, #FF3B30 removals).
- [ ] Scrollbar accessible; large diff story shows virtualization or overflow.
- [ ] Buttons emit correct action names.

## Log Reconnect Panel
- [ ] Skeleton rows animate or show shimmer.
- [ ] Retry count visible when `retrying`.

## Regression Snapshot
- [ ] Capture Chromatic/Visual regression for all stories.
- [ ] Document token consumption (color/spacing) in story notes.
