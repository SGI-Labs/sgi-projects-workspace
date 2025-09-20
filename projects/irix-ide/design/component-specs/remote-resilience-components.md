# IRIX IDE Component Spec: Remote Resilience Suite

## Document Control
- Version: 0.1 (2025-09-21)
- Authors: UX Team
- Related Artifacts: `docs/front-end-spec.md`, `design/excalidraw/irix-ide-recovery-flows.excalidraw`, `design/inkscape/irix-ide-recovery-flows.svg`

## Scope
Defines resilient UI components used during remote host disruptions, destructive deployments, and offline editing. Components are designed for desktop (macOS + IRIX workstations).

## Component Inventory

### 1. Status Pill
- **Purpose:** Persistent indicator of connection health in global header and status bar.
- **States:** `Connected` (#34C759), `Degraded` (#FFD60A), `Reconnecting` (#4C6EF5), `Offline` (#FF3B30).
- **Anatomy:** 12px horizontal padding, 6px vertical padding; circular indicator (10px) + medium label (13px).
- **Behavior:** State updates triggered by connection manager; transitions animate with 150ms fade.
- **Accessibility:** Announce state changes using `aria-live="polite"`; ensure color is not sole indicator (text label required).

### 2. Connection Banner
- **Purpose:** Inline messaging for host drops, retry cadence, or offline guidance.
- **Variants:** `Host Drop`, `Retrying`, `Offline` (accent bar colors align with status pill states).
- **Layout:** 6px accent bar, content stack (20px padding), button row (primary + secondary).
- **Copy Blocks:** Title (≤60 chars), body (≤160 chars), actions (verb-first). Retry banner must include attempt counter.
- **Dismissal:** Automatic collapse when resolved; manual close only provided for offline variant.
- **Accessibility:** `role="status"`; focus trap not required, but primary action should be reachable via keyboard.

### 3. Offline Badge
- **Purpose:** Flag unsynced editor tabs during offline mode.
- **Styles:** 8px horizontal padding, 4px vertical padding, border stroke 1px (#FF9500 @ 60%).
- **Placement:** Right-aligned within tab label stack; appears only when file has pending changes.
- **Accessibility:** Provide tooltip `Unsynced changes` on hover/focus.

### 4. Command Palette (Offline Focus)
- **Purpose:** Surface recovery commands (queue sync, open offline diff, switch host).
- **Structure:** Title, input field (⌘K placeholder), option list with primary action first.
- **Interaction:** Opens via ⌘K or `Queue Sync` button; supports keyboard navigation, type-ahead filtering.
- **Accessibility:** `role="dialog"` with focus trap; ensure input auto-focuses; escape closes palette.

### 5. Destructive Confirmation Sheet
- **Purpose:** Two-step modal before deploy/kill operations.
- **Content Slots:** Title, impact summary, verification checklist, optional "Don’t show again" toggle, primary/secondary buttons.
- **Defaults:** Secondary (`Cancel`) focused by default; primary styled as danger.
- **Behavior:** On confirmation, fires action + triggers Undo Toast; on cancel, closes without side effects.
- **Accessibility:** `role="alertdialog"`; require keyboard traversal of checklist items; ensure 44px button targets.

### 6. Undo Toast
- **Purpose:** Provide reversal window for deploy/kill actions.
- **Layout:** Accent bar (4px), title, message, action button (`Undo` or `View Logs`).
- **Timer:** 5-second countdown; on hover, pause timer.
- **Dismissal:** Auto-dismiss after timer; manual close via `Undo` or `×` (keyboard accessible).
- **Accessibility:** `role="status"`; include audible countdown cues for screen readers (`Undo available for 5 seconds`).

### 7. Sync Conflict Modal
- **Purpose:** Resolve file conflicts after offline edits.
- **Sections:** Title, description, diff preview pane, action row (`Keep Local`, `Keep Remote`, `Open Merge Tool`).
- **Diff Rules:** Highlight additions (#34C759), removals (#FF3B30); limit to 120 lines before requiring external diff.
- **Behavior:** Selection triggers appropriate git/rsync command; modal closes once resolution chosen.
- **Accessibility:** Provide pre-focus on diff pane; arrow keys scroll; actions available via keyboard.

### 8. Log Reconnect Panel
- **Purpose:** Maintain visibility during streaming pauses.
- **Contents:** Header, skeleton log entries, action row (`Reconnect Logs`, `View Offline Snapshot`).
- **States:** `Paused` (skeleton), `Retrying` (progress indicator), `Failed` (escalation copy).
- **Accessibility:** Represent skeleton rows with `aria-busy="true"`; ensure buttons remain focusable.

## Data Contracts
| Component | Inputs | Source |
|-----------|--------|--------|
| Status Pill | `connectionState` (enum) | Connection service |
| Connection Banner | `state`, `attempt`, `totalAttempts`, `message` | Connection service |
| Offline Badge | `unsyncedChanges:boolean` | Sync manager |
| Command Palette | `actions[] (label, description, shortcut)` | Command registry |
| Confirmation Sheet | `operation`, `impactSummary`, `checklist[]`, `allowSuppress:boolean` | Deployment service |
| Undo Toast | `operation`, `expiresAt`, `detailsLink` | Deployment service |
| Sync Conflict Modal | `filePath`, `diff`, `mergeCommand` | Sync manager |
| Log Reconnect Panel | `buildId`, `status`, `retryCount` | Build service |

## Visual Tokens
- Primary fill: `#1E1E1E` (card background)
- Accent strokes: `#4C6EF5`
- Text primary: `#F2F2F7`
- Text secondary: `#D1D1D6`
- Danger: `#FF3B30`
- Warning: `#FFD60A`

## QA Checklist
- Variant states documented with screenshots/mockups.
- Keyboard loops verified (tab order, focus returns).
- Live-region announcements tested with VoiceOver.
- Undo timer pauses on hover/focus.
- Diff preview supports horizontal scroll without wrapping key commands.

## Change Log
| Date | Version | Notes |
|------|---------|-------|
| 2025-09-21 | 0.1 | Initial component definitions |
