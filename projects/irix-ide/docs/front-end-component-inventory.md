# IRIX IDE Component Inventory (Hi-Fi Prep)

## Purpose
This inventory enumerates the UI components required for the IRIX IDE high-fidelity mockups and subsequent frontend implementation. It maps each component to semantic tokens, key interaction states, accessibility notes, and engineering dependencies. Use this document as the source of truth when constructing Figma frames and planning component work in the design system.

## Consumption Targets
- **IRIX Motif/X11 client:** Primary consumer; relies on Indigo Magic theming, Motif density, and pointer conventions.
- **CLI/automation surfaces:** Consume status events for scripting interfaces exposed alongside the IDE.
- **Shared token pipeline:** Tokens sourced from `projects/irix-ide/docs/architecture/token-prototype/` and the resilience design system.

## Component Families

### 1. Navigation & Shell
| Component | Description | Primary Tokens | States | Accessibility |
|-----------|-------------|----------------|--------|----------------|
| Workspace Shell Rail | Left navigation with icons + labels | `color.bg.panel`, `color.text.secondary`, `color.focus.accent` | Default, Collapsed, Hover, Active | 44px targets, aria-current for active section |
| Secondary Tabs | Contextual tabs within views | `color.bg.surface`, `color.focus.accent`, `color.border.subtle` | Default, Hover, Selected, Disabled | Ensure keyboard focus ring; announce tab switches |
| Breadcrumb Bar | Hierarchical navigation | `color.text.primary`, `color.text.link`, `color.icon.neutral` | Default, Hover, Focus | Provide `aria-label` for entire path |
| Command Palette Overlay | Global invocation (for example, `Ctrl+P`) | `color.bg.overlay`, `shadow.modal`, `typography.body` | Idle, Search Active, No Results | Trap focus, support screen-reader item counts |

### 2. Status & Feedback
| Component | Description | Primary Tokens | States | Accessibility |
|-----------|-------------|----------------|--------|----------------|
| Status Pills | Sync/build/host pills | `color.status.connected`, `color.status.degraded`, `color.status.offline`, `typography.small` | Connected, Degraded, Reconnecting, Offline | Live region updates; color + icon pairing for redundancy |
| Connection Banner | Global banner across editor | `color.bg.banner.info`, `color.bg.banner.warning`, `color.text.banner` | Info, Warning, Error, Resolved | Timeout announcements, action buttons keyboard reachable |
| Toast Notifications | Undo/retry toasts | `color.bg.toast`, `color.action.primary`, `shadow.toast` | Default, Undo with timer, Error | Provide countdown text; auto-dismiss with user override |
| Build Progress Bar | Inline progress indicator | `color.status.queued`, `color.status.running`, `color.status.success`, `color.status.error` | Queued, Running, Success, Failure | ARIA progress attributes and status updates |

### 3. Content Panels & Tables
| Component | Description | Primary Tokens | States | Accessibility |
|-----------|-------------|----------------|--------|----------------|
| Project Explorer Tree | Hierarchical file list | `color.bg.surface`, `color.text.primary`, `color.icon.folder` | Default, Sync Pending, Conflict, Locked | Keyboard navigation, screen reader announcements for badges |
| Build Queue Table | Build list with metrics | `color.table.header`, `color.table.row`, `color.table.row.alt`, `typography.body` | Idle, Selected, Hover, Error Row | Row grouping with `<table>` semantics |
| Remote Host List | Host cards/table hybrid | `color.status.connected`, `color.status.degraded`, `color.status.offline` | Connected, Degraded, Offline, Retry Pending | Include host role in label; ensure action buttons have labels |
| Log Viewer | Virtualized log stream | `color.bg.terminal`, `color.text.code`, `typography.mono` | Streaming, Paused, Reconnecting, Filtered | Provide search results summary; allow copy with keyboard |
| Dashboard Cards | KPI summaries | `color.bg.card`, `color.icon.metric`, `shadow.card` | Normal, Alert, Disabled | Support enlarge on focus for accessibility |

### 4. Editors & Forms
| Component | Description | Primary Tokens | States | Accessibility |
|-----------|-------------|----------------|--------|----------------|
| Code Editor Canvas | Central editing surface | `typography.code`, `color.bg.editor`, `color.syntax.*` | Idle, Highlighted diff, Error, Read-only | Ensure caret visibility, announce diagnostics |
| Diff Split Pane | Side-by-side diff layout | `color.border.divider`, `color.bg.surface.alt`, `typography.code` | Unified, Split, Inline comments | Provide keyboard toggle, describe column headers |
| Host Profile Form | Modal/page for host settings | `color.bg.surface`, `typography.body`, `color.border.input` | Idle, Validation Error, Disabled, Loading | Inline validation messages tied with `aria-describedby` |
| Terminal Embed | Interactive shell | `color.bg.terminal`, `color.text.code`, `color.status.*` | Live, Busy, Error, Disconnected | Screen reader label for prompt; maintain accessible history |

### 5. Overlays & Dialogs
| Component | Description | Primary Tokens | States | Accessibility |
|-----------|-------------|----------------|--------|----------------|
| Deploy Confirmation Sheet | Destructive action modal | `color.bg.overlay`, `color.status.danger`, `typography.body` | Idle, Detailed Summary, Confirm, Cancel | Focus trap, default button set to Cancel |
| Sync Conflict Resolver | Modal with diff + actions | `color.bg.surface`, `typography.body`, `color.action.primary` | Choose Local, Choose Remote, Open Merge Tool | Summaries read aloud, keyboard support for diff navigation |
| Offline Work Drawer | Slide-out panel for offline queue | `color.bg.drawer`, `shadow.drawer`, `typography.body` | Offline Queue, Retry Pending, Resolved | Ensure ESC closes; track focus on open/close |
| Debug Attach Modal | Configures remote debugging | `color.bg.surface`, `color.border.input`, `typography.body` | Idle, Validated, Error, Connecting | Provide status text for connection attempts |

### 6. Micro-interactions & Utilities
| Component | Description | Primary Tokens | States | Accessibility |
|-----------|-------------|----------------|--------|----------------|
| Activity Feed Items | Timeline of recent actions | `color.bg.surface`, `color.icon.activity`, `typography.body` | Normal, Highlighted, Muted | Timestamp formatting for screen readers |
| Keyboard Shortcut Hint | Inline command hints | `color.bg.chip`, `color.text.secondary`, `typography.small` | Default | Ensure tooltip counterpart for hover-only hints |
| Retry Timer Indicator | Countdown UI in banners | `color.text.emphasis`, `color.status.warning` | Counting, Paused, Complete | Provide textual countdown value |
| Auto-Save Badge | Tab-level indicator | `color.status.success`, `typography.small` | Synced, Pending, Conflict | Label with file + state (`Filename – Pending Sync`) |

## Platform Variants
- **IRIX Motif:** Flattened depth (2px shadows), 2px radius, square focus outlines. Use monochrome Indigo Magic icons and adhere to Motif padding.
- **Shared:** Maintain identical semantics and component hierarchy to enable token-driven theming.

## Token Dependencies
- Base tokens: `projects/irix-ide/docs/architecture/token-prototype/tokens.sample.json` (to be finalized via generator).
- Motif output: `projects/irix-ide/docs/architecture/token-prototype/IRIXIDE.generated.ad`.
- Resilience kit: `projects/irix-ide/design/system/resilience-design-tokens.md` for status/telemetry cues.

## Component Build Priorities
1. Navigation & Shell components (critical path for all flows).
2. Status/feedback surfaces to unblock resilience work.
3. Editor + diff surfaces aligned with remote workflows.
4. Remote host forms & tables for telemetry dashboards.
5. Dialogs & conflict resolution modules.

## Outstanding Questions
- Confirm whether command palette uses local search only or remote API for host/projects.
- Determine if log viewer requires ANSI color support beyond monochrome tokens.
- Validate Motif equivalent for toast notifications (modal vs. status line?).
- Align telemetry streaming UI with backend delivery schedule to avoid placeholder states.

## Next Actions
- Align with design team on repository-managed component library setup (e.g., shared SVG templates under `projects/irix-ide/design/`).
- Ensure generator script supports all tokens referenced above before engineering handoff.
- Schedule design-engineering review to validate inventory coverage vs. story requirements.
