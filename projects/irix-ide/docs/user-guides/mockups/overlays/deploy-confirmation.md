# Overlay – Deploy Confirmation Dialog (IRIX)

## Layout Overview
- **Viewport:** 900×600 Motif modal centered within the parent window.
- **Tokens:**
  - Background: `color.bg.panel`
  - Accent: `color.focus.accent` for primary button, `color.status.danger` for destructive emphasis.
  - Overlay scrim emulated via status strip message + dimmed parent window.

## Sections
1. **Header**
   - Title “Confirm Deploy” (`typography.heading.md`).
   - Subtitle describing target host (`typography.body.base`, secondary color).

2. **Summary Panel**
   - Details list: Host, Build ID, Affected Services.
   - Warnings highlighted with `color.status.warning` badges.

3. **Impact Checklist**
   - Items with Motif checkboxes; disabled states when requirements not met.

4. **Footer Actions**
   - Primary button “Deploy Now” (accent fill).
   - Secondary button “Cancel” (outline).
   - Tertiary link “View Diff” (text button or menu entry).

5. **Safety Timer**
   - Countdown chip (5s) before primary button activates, using `color.status.warning` background.

## States Captured
- Countdown active (primary button disabled until timer completes).
- Warning badge visible for pending service downtime.
- Impact checklist partially completed.

## Annotation Requirements
- Describe focus trap behavior and ESC to close.
- Note how timer communicates via screen reader/status strip (live region updates).
- Document confirm button enabling sequence once checklist satisfied.
