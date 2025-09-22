# Build & Logs – Motif Variant

## Layout Overview
- **Viewport:** 1280×900.
- **Tokens:**
  - Background: `color.bg.base` (motif `#4F5B66`).
  - Queue table: `color.bg.surface` with beveled header.
  - Log viewer: `color.bg.panel`.
  - Status colors map to `color.status.*` tokens.

## Regions
1. **Queue Table (Upper half)**
   - Columns: Build ID, Trigger, Duration, Result, Artifacts.
   - Header uses embossed Motif style; selected row has inset border.
   - Result cell icons from Indigo Magic set.

2. **Log Viewer (Lower half)**
   - Monospace text (Courier 13px) on dark slate background.
   - Scrollbar uses Motif track + thumb; highlight matches accent color.
   - Reconnect banner sits above log area with `color.status.offline` fill and bold text.

3. **Filter Drawer (Right side, 240px)**
   - Offers toggles for build types, host filters, search field.
   - Toggle buttons behave as Motif check boxes; align to 12px grid.

4. **Action Bar (Top)**
   - Buttons: Retry Failed, Export Logs, Clear Queue.
   - Primary/danger states apply accent/danger tokens with square corners.

## States Captured
- Active build streaming (row flagged with running icon).
- Failed build row highlighted danger background.
- Log viewer showing reconnect banner with countdown.
- Retry toast rendered as status line update (not floating toast).

## Annotation Notes
- Describe ANSI color translation approach (map to token palette) pending backend decision.
- Include note on screen reader announcements for queue row updates.
- Document requirement for keyboard shortcuts (Ctrl+R retry, Ctrl+E export).
