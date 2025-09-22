# IRIX IDE Overview

## Overview
IRIX IDE is a planned native development environment focused on bringing modern tooling to SGI IRIX hosts. It aims to streamline local and remote editing, building, and debugging workflows while preserving the Indigo Magic look and feel.

## Objectives
- Simplify IRIX ↔ IRIX development loops with fast sync, build, and debug feedback (<30s targets).
- Provide first-class MIPSPro toolchain, remote debugging, and system tooling integration within the IRIX desktop.
- Enable future extensibility for additional languages and plugins without hurting performance.

## Target Users
- IRIX on-box maintainer requiring Motif/Indigo Magic visual continuity and dependable terminal integration.
- IRIX systems engineer monitoring telemetry, automation, and multi-host deployments.
- Secondary: team lead/reviewer monitoring builds, logs, and sessions.

## Core Workflows
- **Project bootstrap:** Launch IDE via Toolchest, initialize workspace under home directory, and register desktop icons/File Typing Rules automatically.
- **Edit/build loop:** Local edits trigger incremental sync (local or remote hosts), build queue executes MIPSPro commands, and diagnostics stream into the IDE with retry/rollback controls.
- **Remote debugging:** IDE launches target via gdbserver, attaches Motif debugger UI, exposes breakpoints/inspections, and captures session logs for export.

## Architecture Highlights
- IRIX Motif client as the primary shell with supporting Rust/Python services for sync/build orchestration.
- Remote transport over SSH using reusable host profiles; rsync or custom incremental sync layer handles queued writes.
- Build orchestration targets MIPSPro and other toolchains, returning structured JSON logs for UI consumption.
- Python-based plugin runtime embedded in the client; YAML manifests describe projects/hosts.
- Local metadata stored in SQLite or structured files; remote footprint kept minimal with helper scripts.

## UX & Visual Standards
- Workspace navigation uses Indigo Magic palette and Motif spacing (6px/12px) with status strip messaging.
- Left rail surfaces Dashboard, Editor, Remote Hosts, Build & Logs, Debugger, Settings; status pills and banners follow resilience tokens.
- Overlay components (deploy confirmation, sync conflict, offline drawer) follow Motif idioms with focus traps, keyboard access, and status strip updates.
- Accessibility target WCAG 2.1 AA equivalents, full keyboard navigation, and consistent focus states on 4Dwm.

## Performance Targets & Metrics
- Workspace bootstrap <5 minutes with icons/tooling registered.
- Remote edit-to-build feedback <30s; debug attach <10s.
- Initial workspace load <2.5s, interaction response <150ms, editor scrolling 60 FPS where hardware permits.
- Prototype sync run 0.44s, remote build 0.70s, watch cycle ~5s.

## Open Questions
- Define offline resilience requirements when target hosts are unavailable (queue limits, manual overrides).
- Clarify integration approach with existing SGI toolchains, source-control systems, and deploy scripts.
- Determine telemetry cadence/retention that balances visibility with resource constraints on legacy hardware.
