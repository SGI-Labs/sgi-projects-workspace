# Architecture Future Work

Document open questions, research spikes, and pending decisions uncovered while preparing the IRIX IDE architecture.

## Pending Topics (Initial)
- Evaluate UI framework options (Motif vs. custom toolkit vs. remote macOS UI).
- Determine build orchestration strategy (local vs. remote compilation, containerization on IRIX).
- Assess debugging experience requirements (remote gdb integration, graphical debugger support).
- Identify plugin system approach for extensibility.

_Update this list as discovery progresses._

- Evaluate feasibility of embedding Motif UI elements inside the macOS client via remote visualization.
- Prototype remote debugging workflow using gdbserver on IRIX with a macOS front-end.
- Validate Motif/Indigo Magic style guidelines for any IRIX-native IDE components.
- Detail macOS IDE features explicitly aimed at assisting IRIX development workflows (remote tooling, code insights).
- Validate performance impact of continuous sync on large repositories.
- Design metrics collection for workflow success criteria (build times, debug attach latency).
- Evaluate replacing rsync polling with filesystem notifications (e.g., FSEvents) for lower sync latency.
- Define error-handling and retry strategies for remote build command failures (network, compiler).
- Capture terminal screenshots (sync/build/log output) and add them to user guides for onboarding.
- Validate implementation plan for resilience analytics events (ensure macOS client exposes required hooks).
- Determine if additional IRIX-native iconography needs bespoke assets beyond the current kit.
- Explore approach for localizing resilience microcopy while preserving concise banner copy.
- Replace polling-based `rsync` sync loop with filesystem notifications (FSEvents) for lower latency once Swift service stabilizes.
- Investigate shared component abstractions so macOS SwiftUI and Motif/X11 shells can consume a single design token source of truth _(see `projects/irix-ide/docs/architecture/shared-design-tokens-spike.md` for spike plan)._ 
- Validate feasibility of real-time host telemetry streaming required by the Remote Hosts blueprint (health pills, retry timers, activity feed).
- Assess accessibility tooling needed to announce resilience state transitions consistently across macOS (VoiceOver) and IRIX (screen readers/AT not yet identified).
- Integrate the Motif UI shell (`apps/irix`) with live data sources once backend services stabilize (project lists, sync queue, build telemetry).
