# IRIX Integrated Development Environment (IDE) – PRD (Draft)

## Vision
Deliver a modern, reliable IDE experience tailored to SGI IRIX developers, combining familiar editing workflows with seamless remote compilation, debugging, and system integration.

## Objectives
1. Simplify the developer workflow between macOS workstations and IRIX hosts.
2. Provide first-class support for MIPSPro compilation, remote debugging, and system tooling.
3. Offer extensibility for future language/tool plugins without compromising performance.

## Personas (Initial)
- **Mac-First IDE Operator:** Primary development occurs on macOS using the IDE, orchestrating remote sync/build/debug cycles on IRIX while relying on native macOS productivity tooling.
- **IRIX On-Box Maintainer:** Works directly on IRIX systems for maintenance tasks; expects the IDE to respect Motif/Indigo Magic styling when any native UI is delivered, and to integrate smoothly with legacy workflows.

## Workflow Goals
- Ensure the macOS IDE offers turnkey support for remote editing, build, and debugging pipelines targeting IRIX hosts.
- Maintain visual continuity on IRIX by following Motif/Indigo Magic styling guidelines for any native components.

## Key Questions
- Should the primary UI run on macOS, IRIX, or both through a hybrid architecture?
- What level of offline capability is required when the IRIX host is unreachable?
- How will the IDE integrate with existing SGI toolchains and source-control systems?

_This PRD will be expanded with detailed requirements, user stories, personas, and success metrics as discovery proceeds._
