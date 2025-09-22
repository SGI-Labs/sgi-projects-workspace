# IRIX IDE Component Spec: Remote Resilience Suite

## Document Control
- Version: 0.1 (2025-09-21)
- Authors: UX Team
- Related Artifacts: `docs/front-end-spec.md`, `design/excalidraw/irix-ide-recovery-flows.excalidraw`, `design/inkscape/irix-ide-recovery-flows.svg`

## Scope
Defines resilient UI components used during remote host disruptions, destructive deployments, and offline editing. Components are designed for IRIX Motif workstations.

## Component Inventory

### 1. Status Pill
- **Purpose:** Persistent indicator of connection health in global header and status strip.
- **States:** `Connected` (#94D55A), `Degraded` (#FFD454), `Reconnecting` (#6699CC), `Offline` (#FF6B6B).
- **Anatomy:** 12px horizontal padding, 6px vertical padding; square indicator (10px) + medium label (13px).
- **Behavior:** State updates triggered by connection manager; transitions animate with 150 ms fade where supported, otherwise instant swap.
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
- **Styles:** 8px horizontal padding, 4px vertical padding, border stroke 1px (#FFA94D @ 60%).
- **Placement:** Right-aligned within tab label stack; appears only when file has pending changes.
- **Accessibility:** Provide tooltip `Unsynced changes` on hover/focus.

### 4. Command Palette (Offline Focus)
- **Purpose:** Surface recovery commands (queue sync, open offline diff, switch host).
- **Structure:** Title, input field (e.g., `Ctrl+K` placeholder), option list with primary action first.
- **Interaction:** Opens via shortcut or `Queue Sync` button; supports keyboard navigation, type-ahead filtering.
- **Accessibility:** `role="dialog"` with focus trap; ensure input auto-focuses; escape closes palette.

### 5. Destructive Confirmation Dialog
- **Purpose:** Two-step modal before deploy/kill operations.
- **Content Slots:** Title, impact summary, verification checklist, optional "Don’t show again" toggle, primary/secondary buttons.
- **Defaults:** Secondary (`Cancel`) focused by default; primary styled as danger.
- **Behavior:** On confirmation, fires action + triggers Undo status-strip message; on cancel, closes without side effects.
- **Accessibility:** `role="alertdialog"`; require keyboard traversal of checklist items; ensure ≥44px button targets.

### 6. Undo Status Strip Entry
- **Purpose:** Provide reversal window for deploy/kill actions.
- **Layout:** Status-strip row with icon, message, `Undo` button, countdown badge.
- **Timer:** 5-second countdown; on hover, pause timer.
- **Dismissal:** Auto-dismiss after timer; manual close via `Undo` or `Dismiss` (keyboard accessible).
- **Accessibility:** `role="status"`; include audible countdown cues for screen readers (`Undo available for 5 seconds`).

### 7. Sync Conflict Modal
- **Purpose:** Resolve file conflicts after offline edits.
- **Sections:** Title, description, diff preview pane, action row (`Keep Local`, `Keep Remote`, `Open Merge Tool`).
- **Diff Rules:** Highlight additions (#94D55A), removals (#FF6B6B); limit to 120 lines before requiring external diff.
- **Behavior:** Selection triggers appropriate sync command; modal closes once resolution chosen.
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
| Confirmation Dialog | `operation`, `impactSummary`, `checklist[]`, `allowSuppress:boolean` | Deployment service |
| Undo Status Strip Entry | `operation`, `expiresAt`, `detailsLink` | Deployment service |
| Sync Conflict Modal | `filePath`, `diff`, `mergeCommand` | Sync manager |
| Log Reconnect Panel | `buildId`, `status`, `retryCount` | Build service |

## Visual Tokens
- Background surfaces: `#5E6B7A`
- Panels: `#3B4654`
- Accent: `#6699CC`
- Text primary: `#F2F2F7`
- Text secondary: `#D0D8E2`
- Danger: `#FF6B6B`
- Warning: `#FFD454`

## QA Checklist
- Variant states documented with screenshots/mockups.
- Keyboard loops verified (tab order, focus returns).
- Live-region announcements tested with IRIX assistive tools.
- Undo timer pauses on hover/focus.
- Diff preview supports horizontal scroll without disrupting key commands.

## Change Log
| Date | Version | Notes |
|------|---------|-------|
| 2025-09-21 | 0.1 | Initial component definitions |
