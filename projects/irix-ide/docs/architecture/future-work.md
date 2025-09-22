# Architecture Future Work

Document open questions, research spikes, and pending decisions uncovered while preparing the IRIX IDE architecture.

## Pending Topics (Initial)
- Confirm UI framework scope (pure Motif vs. custom toolkit augmentations).
- Determine build orchestration strategy (local vs. remote compilation, containerization on IRIX).
- Assess debugging experience requirements (remote gdb integration, graphical debugger support).
- Identify plugin system approach for extensibility.

_Update this list as discovery progresses._

- Validate Motif/Indigo Magic style guidelines for all IDE components.
- Measure performance impact of continuous sync on large repositories and tune queue backoff.
- Design metrics collection for workflow success criteria (build times, debug attach latency).
- Evaluate moving from polling-based rsync to filesystem notifications available on IRIX (e.g., FAM).
- Define error-handling and retry strategies for remote build command failures (network, compiler).
- Capture terminal screenshots (sync/build/log output) and add them to user guides for onboarding.
- Ensure resilience analytics events are emitted from the IRIX client and aggregated centrally.
- Determine if additional IRIX-native iconography needs bespoke assets beyond the current kit.
- Explore approach for localizing resilience microcopy while preserving concise banner copy.
- Investigate shared component abstractions so Motif/X11 shells can consume a single design token source of truth _(see `projects/irix-ide/docs/architecture/shared-design-tokens-spike.md`)._
- Validate feasibility of real-time host telemetry streaming required by the Remote Hosts blueprint (health pills, retry timers, activity feed).
- Assess accessibility tooling needed to announce resilience state transitions consistently across IRIX assistive technologies.
- Clarify whether the command palette should leverage local indexing only or also query remote APIs for host/project discovery.
- Determine if the log viewer requires ANSI color support beyond monochrome tokens to mirror IRIX terminal output faithfully.
- Validate the Motif-equivalent interaction pattern for toast notifications (status strip vs. modal) before engineering handoff.
- Coordinate hi-fi telemetry states with backend delivery milestones to avoid placeholder states in Remote Hosts dashboards _(see `projects/irix-ide/docs/team/backend-coordination.md`)._
- Integrate the Motif UI shell (`apps/irix`) with live data sources once backend services stabilize (project lists, sync queue, build telemetry).
