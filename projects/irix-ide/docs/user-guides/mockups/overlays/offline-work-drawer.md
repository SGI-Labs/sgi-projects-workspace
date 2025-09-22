# Offline Work Drawer / Status Strip Entry

## Purpose
Communicate queued edits and retry actions when the IRIX host connection is unavailable.

## Drawer Panel
- Slides up from bottom (height 320px) with `color.bg.panel` background and 24px padding.
- Sections: Summary header, queued files list, retry controls.
- Each queued file entry lists path, size, and retry ETA.
- Primary action “Retry Now” (accent) and secondary “Work Offline”.
- Include info callout describing offline editing limitations.

## Status Strip Entry
- Persist message in status strip with scrollable detail pane (activated via button or F2).
- Show count of queued files and next retry timestamp.
- Provide `Retry` and `Cancel Queue` buttons using Motif style.

## States
- Queue building (0 files yet) – message encouraging user patience.
- Files queued with countdown timer.
- Retry success (drawer collapses / status strip message updates to success).

## Accessibility & Telemetry
- Announce queue updates as polite live region.
- Log telemetry events: offline_entered, retry_initiated, retry_success.

## Export Targets
- `../exports/irix/offline-work-drawer.svg`
- `../exports/irix/offline-status-strip.svg`
