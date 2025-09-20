# IRIX IDE Architecture Overview

This project will deliver a native development environment for IRIX that streamlines editing, building, and debugging on SGI hardware.

## Core Documents
- `tech-stack.md`: Proposed client/server components, remote workflow, extensibility model.
- `coding-standards.md`: Language-specific conventions for SwiftUI client, Rust/Python services, and IRIX scripts.
- `source-tree.md`: Canonical directory layout for IDE modules, services, tests, and documentation.
- `future-work.md`: Open questions and planned research.

## Architectural Principles
1. **Cross platform first:** macOS client with modular backend services and optional IRIX-native components.
2. **Remote-first workflows:** All editing, build, and debugging interactions must operate over secure SSH.
3. **Plugin extensibility:** Plugin framework allows language/tool integrations without core rewrites.
4. **Documentation as code:** Keep these shards current as prototypes evolve.

Refer to the individual shards for detailed guidance.
