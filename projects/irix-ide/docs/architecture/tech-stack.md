# Tech Stack Proposal

## Client Experience
- **Primary UX:** macOS native app (SwiftUI/Catalyst) acting as the main IDE shell.
- **Secondary UX:** Optional IRIX-native UI for on-box editing using Motif; deferred until macOS client stabilizes.
- **Editor Engine:** Leverage the open-source TextMate grammar system or Tree-sitter for syntax highlighting, wrapped in the SwiftUI client; interoperable backend service for headless usage.

## Remote Workflow
- **Transport:** OpenSSH with reusable host profiles (leveraging existing `octane` configuration). All remote operations tunnel through SSH for file operations, builds, and debugging.
- **Sync Layer:** rsync or custom incremental sync module to mirror project directories between macOS and IRIX.
- **Build Orchestration:** Command queue targeting MIPSPro, cross-compilers, or containerized toolchains (future) with streaming logs back to the client.
- **Debugging:** Remote gdb or SGI-specific debugging tools wrapped via CLI to deliver interactive sessions within the IDE.

## Extensibility
- **Plugin Runtime:** Python-based plugin host for quick iteration; embed a Python interpreter in the macOS client to load language/services plugins (linting, formatting, custom build steps).
- **Configuration:** YAML-based project manifests describing build targets, sync paths, and remote hosts.

## Persistence & Data
- **Local Metadata:** SQLite or Core Data on macOS to track project settings, connections, and recent files.
- **Remote Services:** Minimal footprint; rely on existing IRIX filesystem and add lightweight helper scripts as needed.

## Observability
- Structured logging from both client and remote operations (JSON logs). Future plan to integrate with SGI monitoring dashboards.

_This tech stack will be refined after prototype spikes and stakeholder validation._
