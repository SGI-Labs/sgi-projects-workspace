# IRIX Integrated Development Environment (IDE) – PRD (Draft)

## Vision
Deliver a modern, reliable IDE experience tailored to SGI IRIX developers, combining familiar editing workflows with seamless remote compilation, debugging, and system integration.

## Objectives
1. Simplify the developer workflow between macOS workstations and IRIX hosts.
2. Provide first-class support for MIPSPro compilation, remote debugging, and system tooling.
3. Offer extensibility for future language/tool plugins without compromising performance.

## Personas (Initial)
### Mac-First IDE Operator
- **Goals:** Iterate quickly from a macOS workstation while targeting IRIX hosts, with smooth sync/build/debug loops.
- **Pain Points:** Manual SCP workflows, inconsistent build feedback, difficulty keeping local changes aligned with IRIX filesystem state.
- **Environment:** macOS Sonoma + SSH access to multiple IRIX machines; relies on VSCode/Xcode today with ad-hoc scripts.

### IRIX On-Box Maintainer
- **Goals:** Apply hotfixes or maintenance tasks directly on IRIX hardware while preserving native look-and-feel and shell tooling.
- **Pain Points:** Legacy editors, fragmented debugging experience, limited integrations with modern source control.
- **Environment:** Works on SGI systems with Motif/Indigo Magic UI; expects compatibility with IRIX terminals and system utilities.

## Core Workflows
### Project Bootstrap (Mac → IRIX)
1. Select IRIX host profile from the macOS IDE.
2. Initialize remote project skeleton (directories, build scripts) using predefined templates.
3. Sync starter files to the IRIX host and validate permissions.
4. Generate local project metadata (manifests, plugin configuration).

**Success Metrics:** Remote workspace ready in under 2 minutes; zero manual SSH steps.

**Assumptions:** SSH profiles already configured; developer has write access on target host.

### Remote Edit & Build Loop
1. Open local project in macOS IDE; edits saved locally trigger incremental sync.
2. IDE invokes remote build queue (MIPSPro, cross toolchains) with live log streaming.
3. Build results surface in IDE with actionable diagnostics (link to source, suggestions).
4. Optional post-build tasks (artifact copy, tests) run automatically.

**Success Metrics:** Code-save-to-build feedback under 30 seconds; build diagnostics hyperlink back to source lines.

**Assumptions:** Network latency acceptable (<150 ms); remote toolchain installed and versioned.

### Remote Debugging Session
1. Start program on IRIX host via IDE-controlled session (gdbserver or SGI debugger).
2. Attach macOS IDE debugger UI, exposing breakpoints, variable inspection, console I/O.
3. Capture session logs and exportable traces for later analysis.
4. Terminate session cleanly, restoring remote environment.

**Success Metrics:** Debug session attach in <10 seconds; breakpoint hits displayed within IDE; session artifacts persisted.

**Assumptions:** gdbserver or equivalent available on IRIX; network ports reachable and secured.

## Workflow Goals
- Ensure the macOS IDE offers turnkey support for remote editing, build, and debugging pipelines targeting IRIX hosts.
- Maintain visual continuity on IRIX by following Motif/Indigo Magic styling guidelines for any native components.
## Key Questions
- Should the primary UI run on macOS, IRIX, or both through a hybrid architecture?
- What level of offline capability is required when the IRIX host is unreachable?
- How will the IDE integrate with existing SGI toolchains and source-control systems?

_This PRD will be expanded with detailed requirements, user stories, personas, and success metrics as discovery proceeds._
