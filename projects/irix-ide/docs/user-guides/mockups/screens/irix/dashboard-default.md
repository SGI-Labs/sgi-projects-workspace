# Dashboard – Motif Shell Default (IRIX)

## Layout Overview
- **Viewport:** 1280×900 canvas anchored to Motif window chrome.
- **Tokens:**
  - Background: `color.bg.base` (motif override `#4F5B66`).
  - Panels: `color.bg.surface` with inset shadow treatment (`shadow.motif.panel`).
  - Navigation rail: `color.bg.panel` with square focus outlines.
  - Accent/focus: `color.focus.accent` (motif override `#6699CC`).

## Regions
1. **Workspace Shell Rail (Left, 96px width)**
   - Uses Indigo Magic icon set with 2px corner radius.
   - Active item indicated by 2px left border and `color.focus.accent` background hatch.
   - Keyboard navigation instructions surfaced in status line.

2. **Title Bar + Menu Row**
   - Motif window controls stacked at top left; title “IRIX Workspace Overview”.
   - Menu row (File / Edit / Hosts / Tools) persists above content area.

3. **Metrics Panel Grid**
   - Three columns using 12px gutters; each card employs beveled edges and embossed heading bar.
   - Text styles map to Motif tokens: `typography.heading.md` → Helvetica 22px.

4. **Activity Ticker (Center column)**
   - Scrollable list within recessed panel; selection uses dotted outline.
   - Status glyphs pulled from `design/icons/irix/status/`.

5. **Operations Drawer (Right column, 280px)**
   - Buttons rendered as Motif push buttons; disabled state greys to `color.text.secondary` @ 60%.
   - Includes host health summary chips using square pill design.

6. **Status Strip (Bottom)**
   - Displays connection string and pending alerts; uses `color.status.offline` when host queue stalled.

## States Captured
- Dashboard navigation focus highlighted via keyboard traversal (Tab).
- Activity entry showing degraded host event (warning icon).
- Operations drawer disable state when offline host selected.
- Status strip flashing retry countdown (text + icon pairing).

## Annotation Notes
- Specify window chrome padding (18px) and menu height (32px) to match Motif baseline.
- Document assistive cues: accelerators (Alt+D), status strip alerts announced every 5s.
- Flag motion guidance: status strip flash limited to opacity pulse, no slide motion.
