# Component Library – Hi-Fi Templates

Align the master components in your design tool with the semantic inventory defined in `projects/irix-ide/docs/front-end-component-inventory.md`. This document captures the base configuration, states, and export naming expected for each component family.

## 1. Navigation & Shell
- **Workspace Shell Rail** – Master frame 96×Full height. Variants: default, hover, active, keyboard focus. Export as `component.shell-rail.<state>.svg`.
- **Secondary Tabs** – Labeled tab set with underline indicator; include disabled variant. Export as `component.secondary-tab.<state>.svg`.
- **Breadcrumb Bar** – 3-level example with hyperlink states and overflow chevron.

## 2. Status & Feedback
- **Status Pills** – Pill container with icon and label; variants for connected, degraded, offline, retrying.
- **Connection Banner** – Banner with icon, message, CTA styled per Motif (square corners, etched borders).
- **Status Strip Message** – Entry for offline/retry states with keyboard focus affordances.

## 3. Content Panels & Tables
- **Project Explorer Tree** – 3-level nested nodes with sync badges.
- **Build Queue Table** – Header row + 3 sample builds (success, running, failed).
- **Remote Host Card** – Host name, status, metrics, actions.
- **Log Viewer** – Frame containing monospace text, search bar, reconnect banner slot.

## 4. Editors & Forms
- **Code Editor Canvas** – Syntax sample with diff highlight, lint underline, inline quick fix chip.
- **Diff Split Pane** – Side-by-side layout with line numbers and hunk header.
- **Host Profile Form** – Modal frame with form fields (text, dropdown, checkbox) plus validation message.
- **Terminal Embed** – Shell prompt with streaming text, status indicator, toolbar.

## 5. Overlays & Dialogs
- **Deploy Confirmation Dialog** – Title, summary list, action buttons, countdown.
- **Sync Conflict Resolver** – Diff area with radio button choices and merge button.
- **Offline Work Drawer** – Slide-out panel with queued actions list and retry button.
- **Debug Attach Modal** – Form with target host selection, port entry, attach button.

## 6. Utilities & Micro-interactions
- **Activity Feed Item** – Timestamp, icon, text, optional badge.
- **Keyboard Shortcut Hint** – Chip containing key glyphs, label, tooltip.
- **Retry Timer** – Circular countdown ring + numeric label (specify animation arcs).
- **Auto-Save Badge** – Tab-level indicator for sync statuses.

## Layer & Token Notes
- Name layers using `component/tokens/...` convention (e.g., `component/shell-rail/background`).
- Bind fills/strokes to design tokens; include annotation layer describing mapping.
- Keep variant toggles limited to states enumerated in the inventory to simplify engineering handoff.
