# Settings – Appearance & Theme (IRIX Motif)

## Layout Overview
- **Viewport:** 1280×900 Motif dialog.
- **Tokens:**
  - Background: `color.bg.base`.
  - Dialog panels: `color.bg.surface` with beveled borders.
  - Accent/focus: `color.focus.accent` `#6699CC`.
  - Warning states: `color.status.warning`.

## Regions
1. **Navigation Tabs (Left column, 200px)**
   - Tabs rendered as Motif list items with square indicator.
   - Appearance tab selected; others display keyboard accelerators.

2. **Theme Selector (Center)**
   - Radio button set: Indigo Magic Default, High Contrast Dark, Motif Classic.
   - Preview pane to the right with sample UI using corresponding tokens.
   - Changing theme triggers warning modal for restart requirement when Motif Classic selected.

3. **Customization Panel (Below)**
   - Controls: toggle for “Match Remote Host Accent”, slider for density (12px–16px).
   - Provide explanation text using `color.text.secondary`.

4. **Restart Warning Banner**
   - Visible when a restart is required; uses `color.status.warning` background.
   - Includes countdown and `Restart Later` button.

5. **Action Buttons (Bottom)**
   - OK, Apply, Cancel aligned right; OK disabled until change made.

## States Captured
- Motif Classic selected with warning banner visible.
- Density slider set to 12px (Motif default) with tooltip.
- Apply button enabled, OK disabled (pending restart).

## Annotation Notes
- Document that radio buttons must expose alt-key shortcuts.
- Note required localization space for longer language names.
- Call out that warning banner must announce via screen reader and status strip simultaneously.
