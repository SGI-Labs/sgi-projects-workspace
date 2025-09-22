# Tech Stack Proposal

## Client Experience
- **Primary UX:** IRIX native Motif application built on IRIS IM and 4Dwm conventions.
- **Editor Engine:** Integrate an extensible text component (e.g., Xaw/Motif-based editor or custom widget) with syntax highlighting powered by Tree-sitter or ctags backends compiled for IRIX.
- **IRIX UI Styling:** All surfaces adopt Indigo Magic palettes, magic-carpet iconography, and Motif spacing guidelines outlined in the IRIX Interactive Desktop manuals.

## Workflow Services
- **Transport:** OpenSSH with reusable host profiles; all remote operations (sync, builds, debugging) tunnel through SSH.
- **Sync Layer:** rsync or scp fallback modules running natively on IRIX, with queueing and conflict detection for offline scenarios.
- **Build Orchestration:** Command queue targeting MIPSPro and other IRIX toolchains; stream logs back to the client via pipes with line-delimited JSON metadata.
- **Debugging:** Remote gdb or SGI debugger integration using CLI wrappers that feed breakpoint and variable events into the Motif UI.

## Extensibility
- **Plugin Runtime:** Python-based plugin host embedded in the IRIX client to support linting, formatting, and custom build steps without recompiling the UI.
- **Configuration:** YAML-based project manifests describing build targets, sync paths, telemetry cadence, and remote hosts.

## Persistence & Data
- **Local Metadata:** Lightweight SQLite (if available) or structured flat files to track project settings, connections, and recent files on IRIX.
- **Remote Services:** Minimal footprint—augmented by helper scripts deployed to hosts for telemetry, queue inspection, and log retrieval.

## Observability
- Structured logging (JSON or syslog-compatible) from both client and remote operations with hooks for SGI monitoring dashboards.
- Telemetry endpoints publish host health, retry attempts, and build metrics consumable by the Remote Hosts and Dashboard views.

_This tech stack will be refined after prototype spikes and stakeholder validation._
