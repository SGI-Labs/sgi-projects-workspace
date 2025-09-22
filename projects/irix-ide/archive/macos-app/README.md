# IRIX IDE macOS Client (Scaffold)

This Swift Package hosts the native macOS application that will evolve into the full IRIX IDE. It closely follows the UI/UX blueprint stored in `docs/front-end-spec.md` and the design assets under `docs/user-guides/screenshots/`.

## Highlights
- SwiftUI navigation shell with sidebar + detail layout.
- Stubbed services (`IRIXServices`) for sync, build queue, hosts, and analytics so UI can render while backend logic is ported from the Python prototype.
- Design tokens (`IRIXDesignSystem`) mirroring the palette and spacing captured in the spec.
- Feature views (`IRIXFeatures`) implementing Dashboard, Remote Hosts, Build & Logs, and placeholder panes for Editor, Debugger, and Settings.
- Executable target `IRIXIDEApp` that wires everything together via dependency injection.

## Building
```sh
cd projects/irix-ide/apps/macos
swift build
IRIX_IDE_CONFIG=/path/to/config.yml swift run IRIXIDEApp
# launches a basic UI window when run from an environment with display access
```

> Note: `swift run` requires a GUI environment; when running headless (CI), stick to `swift build` to validate compilation.

If no `IRIX_IDE_CONFIG` is provided the app falls back to the sample configuration at
`projects/irix-ide/tools/prototype/edit-build-loop/config.sample.yml`.

## Next Steps
- Replace stub services with real implementations that wrap `rsync`/`ssh` (migrated from the Python prototype in `tools/prototype/edit-build-loop`).
- Expand the editor surface (e.g., integrate a code editor component) and debugger panels as future stories land.
- Wire analytics emissions per `design/analytics/resilience-analytics-spec.md`.
- Add unit tests for service adapters and UI snapshot tests for critical components.
