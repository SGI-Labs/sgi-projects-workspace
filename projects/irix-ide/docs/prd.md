# IRIX Integrated Development Environment (IDE) – PRD (Draft)

## Vision
Deliver a modern, reliable IDE experience that runs natively on SGI IRIX systems, combining familiar editing workflows with seamless compilation, debugging, and system integration aligned to the IRIX Interactive Desktop.

## Objectives
1. Provide a cohesive IRIX-based workspace that unifies editing, build orchestration, and debugging against local and remote IRIX hosts.
2. Offer first-class support for MIPSPro toolchains, remote gdb sessions, and system tooling while respecting IRIX security and performance constraints.
3. Maintain strict compliance with IRIX Interactive Desktop guidelines for look, feel, accessibility, and tooling integration (Toolchest, Icon Catalog, FTRs).

## Personas (Initial)
### IRIX On-Box Maintainer
- **Goals:** Apply fixes directly on IRIX hardware, manage services, and validate builds without leaving the native desktop.
- **Pain Points:** Legacy editors, fragmented logging, limited visibility into remote host health.
- **Environment:** SGI workstations running IRIX 6.5 with 4Dwm, access to multiple production hosts over SSH.

### IRIX Systems Engineer
- **Goals:** Coordinate builds, monitor telemetry, and automate deploys across clusters of IRIX hosts.
- **Pain Points:** Manual scripting to sync files, poor visibility into retry/queue states, lack of centralized dashboards.
- **Environment:** Mix of high-powered IRIX servers and interactive workstations, extensive use of command-line tooling.

### Team Lead / Reviewer (secondary)
- **Goals:** Audit build outcomes, review logs/debug traces, ensure compliance.
- **Pain Points:** Scattered evidence, inconsistent UI patterns across homegrown tools.
- **Environment:** Primarily IRIX desktop with occasional remote X11 sessions.

## Core Workflows
### Project Bootstrap (IRIX Workspace)
1. Choose a project template from the Toolchest entry.
2. Initialize workspace under the user’s IRIX home directory (create directories, build scripts, manifest).
3. Configure toolchain paths and environment variables (MIPSPro, SDKs, scripts).
4. Register desktop icons and File Typing Rules so applications/data are discoverable via the Icon Catalog.

**Success Metrics:** Workspace ready in under 5 minutes; Toolchest and desktop entries functional without manual file moves.

### On-Box Edit & Build Loop
1. Edit code locally in the IDE; auto-save or manual save triggers the sync service.
2. Sync service queues updates (local or remote hosts) and executes incremental rsync/scp depending on compatibility.
3. Build queue (local or remote) compiles artifacts via MIPSPro, streams logs back into the IDE, and records metrics.
4. IDE surfaces diagnostics with links to offending files and provides retry/rollback actions.

**Success Metrics:** Edit-to-build feedback <30 seconds for small changes; diagnostics link back to source line; queue state visible at all times.

### Remote Debugging Session
1. Launch gdbserver (or SGI debugger) on target host via IDE control panel.
2. Attach IDE debugger UI, exposing breakpoints, variable inspection, call stack, and console output.
3. Capture session logs and export traces; allow watch expressions and value diffing.
4. Handle connection drops gracefully with retry/offline options and status strip messaging.

**Success Metrics:** Debug attach in <10 seconds; breakpoint hits visible immediately; sessions resumable after disconnect.

## Workflow Goals
- Maintain sub-30s turnaround for edit→build loops with actionable diagnostics.
- Preserve session resilience—automatic retries, offline queuing, and conflict handling must prevent work loss.
- Provide visibility across hosts, builds, and debugging sessions directly within the IRIX client, including telemetry and audit trails.

## UI Navigation & State Flows
- Primary navigation follows a left-rail workspace shell (`Dashboard`, `Editor`, `Remote Hosts`, `Build & Logs`, `Debugger`, `Settings`).
- State transitions for remote workflows (bootstrap, edit/build loop, debugging) are documented via Mermaid diagrams in this spec.
- Recovery flows (connection drop → retry → offline queue → resolved) are captured in annotated wireframes under `projects/irix-ide/docs/user-guides/screenshots/`.
- Screen blueprints with layout callouts for Workspace Shell, Project Explorer, Editor, Build & Logs, Remote Hosts, and Settings are centralized in `projects/irix-ide/docs/front-end-spec.md#screen-blueprints` with corresponding IRIX mockups.
- Remote resilience state transitions (Connected → Degraded → Reconnecting → Offline) are standardized via the state chart in `projects/irix-ide/docs/front-end-spec.md#state-transitions--remote-resilience` to align engineering and QA with expected UI cues.

## UI/UX Stylistic Guidelines
- Adopt IRIX Interactive Desktop palette (e.g., `#4F5B66` surfaces, `#6699CC` accents) and Helvetica/Courier typography per SGI guidelines.
- Status pills, banners, and offline drawers use resilience tokens documented in `projects/irix-ide/design/system/resilience-design-tokens.md`.
- Icons follow IRIX conventions (magic-carpet executables, drop shadows) with assets stored under `projects/irix-ide/design/icons/`.
- Motion defaults: 200 ms ease-in-out for banners/toasts; primarily rely on instant state changes where Motif lacks animation support.
- Wireframe references (`01-editor-host-drop.svg` → `05-remote-hosts.svg`, `07-build-logs.svg`, `09-settings.svg`) establish baseline spacing, typography, and component states for engineering handoff.

## Prototype Metrics (Initial)
- Single sync run (sample project): ~0.44 s (rsync via `/usr/nekoware/bin/rsync`).
- Remote build compile (hello.c): ~0.70 s (includes `mkdir -p bin`).
- Continuous watch run (two cycles, 5s timeout): ~5 s total.

Screenshots of these runs should be stored under `projects/irix-ide/docs/user-guides/screenshots/` once captured.

## Hi-Fi Planning Artifacts
- `projects/irix-ide/docs/front-end-component-inventory.md` enumerates reusable components, token dependencies, and accessibility notes for hi-fi mockups.
- `projects/irix-ide/docs/hifi-mockup-plan.md` defines deliverables, directory structure, and review cadence for the high-fidelity effort.
- Repository-managed mockup sources and exports live under `projects/irix-ide/docs/user-guides/mockups/`, with `ui_inventory.json` tracking coverage across screens and states.

- Ensure the IDE offers turnkey support for IRIX-native editing, build, and debugging pipelines across local/remote hosts.
- Maintain visual continuity by following Motif/Indigo Magic styling guidelines for all components.

## Key Questions
- What level of offline capability is required when the target IRIX host is unreachable (queue size limits, manual overrides)?
- How will the IDE integrate with existing SGI toolchains, source-control systems, and deployment scripts hosted on IRIX?
- What telemetry cadence and retention are necessary to support host health dashboards without overloading legacy hardware?

_This PRD will be expanded with detailed requirements, user stories, personas, and success metrics as discovery proceeds._
