# macOS Client Architecture Blueprint

## Goals
- Deliver a native SwiftUI macOS application that embodies the UI blueprint from `docs/front-end-spec.md`.
- Replace the Python-based prototype with Swift services that handle sync, remote build, and resilience state.
- Provide modular structure so future stories can iterate on features (debugger, analytics, offline queue).

## High-Level Layers
| Layer | Responsibility | Notes |
|-------|----------------|-------|
| Application (`IRIXIDEMacosApp`) | App entry point, scene management, dependency container | SwiftUI `App` struct | 
| Presentation | SwiftUI views matching navigation shell (Sidebar + Detail) | Uses design tokens defined in `DesignTokens.swift` |
| ViewModels | Observable objects exposing state for views | Drive resilience states, host lists, build queue |
| Domain Services | Protocols and implementations for sync, build, analytics, settings | Runs on async actors, publishes structured events |
| Infrastructure | Shell wrappers for `rsync`, `ssh`, `gdbserver`, local file watching | Uses `Process` + `FileWatcher` (DispatchSourceFileSystemObject) |

## Modules Overview
- `App` (Sources/IRIXIDEApp): App entry, dependency container.
- `Features/Common`: Shared components (status pill, banners, toolbar).
- `Features/Dashboard`: Aggregated metrics, activity feed.
- `Features/Editor`: Placeholder for editor integration (future story; will coordinate with remote file sync service).
- `Features/Hosts`: Remote host inventory, connection actions.
- `Features/Builds`: Build queue, log streaming view.
- `Features/Debugger`: Layout for debugger panes (sources, call stack, watches, console).
- `Features/Settings`: Profile, preferences, notifications.
- `Services/Sync`: `RsyncSyncService` invoking `rsync` on a poll interval and surfacing `ConnectionState` changes.
- `Services/Build`: `SSHBuildService` for remote compile & log streaming over `ssh`.
- `Services/Host`: `HostService` for health polling + connection management.
- `Services/Analytics`: Event dispatcher, aligns with `design/analytics/resilience-analytics-spec.md`.
- `DesignSystem`: Colors, typography, spacing tokens (auto-generated from design docs for now). 

## Data Flow
1. Views bind to ViewModels via `@StateObject` / `@ObservedObject`.
2. ViewModels depend on service protocols injected at creation.
3. Services emit updates using `AsyncStream` (Combine optional) for resilience states, logs, host status.
4. Analytics service listens to relevant actions and fires events.
5. File watcher monitors workspace directory and triggers sync service; results update view models.

## Resilience State Model
- Use `ConnectionState` enum (`connected`, `degraded`, `reconnecting(attempt:Int,max:Int)`, `offline`) consistent with state diagram (`design/diagrams/resilience-state-model.md`).
- ViewModels expose `connectionState` to drive status pill + banners.
- Retry logic handled inside `HostService`, with exponential backoff parameters configurable via settings.

## Porting Strategy from Prototype
| Prototype Script | Swift Service Replacement |
|------------------|---------------------------|
| `sync_loop.py` | `RsyncSyncService` (uses `Process` to call `rsync` on a configurable interval, emitting connection states) |
| `remote_build.py` | `SSHBuildService` (spawns `ssh`, streams stdout into `AsyncStream<String>`) |
| `config.sample.yml` | `WorkspaceConfig` (Swift struct, loads from YAML via `Yams` or JSON via `Codable` alternative) |

YAML support options:
- Integrate `Yams` Swift package for YAML parsing.
- Provide JSON equivalent fallback (future story) if YAML dependency becomes an issue.

## Dependencies & Tooling
- Swift 5.9+, macOS 13 target.
- SwiftUI, Combine (optional), Dispatch.
- Third-party packages:
  - `Yams` (YAML parsing) – https://github.com/jpsim/Yams
  - `swift-argument-parser` for CLI integration (optional for developer tools).
- `Process` + `Pipe` for shell command execution.
- `OSLog` for structured logging.

## Next Steps
1. Scaffold Swift Package / Xcode project under `projects/irix-ide/apps/macos` with modules listed above.
2. Implement stub services returning sample data so UI can render while backend is ported.
3. Gradually replace stubs with real sync/build implementations (pulling logic from prototype).
4. Add unit tests for services (mocking shell interactions) and snapshot tests for SwiftUI views (future story).
5. Wire analytics events per spec once services emit real state transitions.

## Open Questions
- Editor integration: re-use existing editors via bridging (e.g., run `code`/`vim`) or embed custom code editor? (future discovery)
- Debugger integration: direct gdb remote protocol vs. bridging to existing front-end? (needs architecture spike)
- Local storage of workspace config: persist in `~/Library/Application Support/IRIXIDE/`. (to confirm)
