# Architecture Overview

This repository now hosts multiple efforts under `projects/`. The active SGI automation work lives in `projects/irix-automation/`, focused on the Python CLI that orchestrates remote builds on the IRIX Octane.

## Components
- **Local Automation (macOS):** Python-based `irix-build` CLI located in `projects/irix-automation/tools/irix_build/`. It synchronizes source, triggers remote compilation, and will execute binaries.
- **Remote Build Target (IRIX Octane):** MIPSPro toolchain compiling demo C programs inside `~/src/irix_demo` with binaries under `~/src/irix_demo/bin`.
- **Documentation Set:** Project documentation resides in `projects/irix-automation/docs/`, including the architecture shards (`tech-stack.md`, `coding-standards.md`, `source-tree.md`, `future-work.md`).
- **Archive:** Historical experiments have been moved to `projects/irix-automation/archive/legacy-desktop-demo/` and should not influence new work.

## Guiding Principles
1. **SGI-first Standards:** Code must follow SGI-era discipline—predictable build flags, defensive shell integration, and strict coding conventions captured in the architecture shards.
2. **Single Path to Production:** All remote interactions reuse the `octane` SSH profile. Alternate credentials or ad-hoc scripts are prohibited.
3. **Composable Modules:** Local automation remains split into thin modules (CLI, sync, build, run, ssh helpers) with mirrored tests so work scales predictably.
4. **Documentation as Code:** Architecture shards are authoritative; update them alongside implementation to keep the project organized.
5. **Shared Root Hygiene:** New initiatives should create sibling directories under `projects/` and replicate the same docs/tools/tests structure to avoid clutter.

## Related Documents
- `projects/irix-automation/docs/architecture/tech-stack.md`
- `projects/irix-automation/docs/architecture/coding-standards.md`
- `projects/irix-automation/docs/architecture/source-tree.md`
- `projects/irix-automation/docs/architecture/future-work.md`
- `projects/irix-automation/docs/irix_remote_workflow.md` (deprecation stub referencing archived notes)
- `projects/irix-automation/archive/legacy-desktop-demo/` (legacy experiments)

Use this overview as the entry point when adding new capabilities or onboarding future projects into the shared repository structure.
