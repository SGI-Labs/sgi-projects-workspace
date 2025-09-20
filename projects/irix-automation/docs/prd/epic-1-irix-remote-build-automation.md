# IRIX Remote Build Automation Script – Brownfield Enhancement

## Epic Goal
Automate the existing SSH/SCP/MIPSpro workflow so macOS developers can sync, build, and execute IRIX demos with a single command, reducing manual steps and incidental errors.

## Epic Description
### Existing System Context
- Current relevant functionality: Manual use of `scp` and `ssh` to push sources under `irix_demo_local/`, compile with `cc`, and run demos per the workflow in `docs/irix_remote_workflow.md`.
- Technology stack: macOS client with OpenSSH + Homebrew tooling, IRIX64 Octane server with MIPSpro toolchain, tcsh shell environment.
- Integration points: Reuses the configured `octane` SSH profile, `~/src/irix_demo` directory on the IRIX host, and existing demo sources.

### Enhancement Details
- What's being added/changed: A local CLI script (`irix-build`) that bundles file sync, remote compilation, optional execution, and status reporting.
- How it integrates: Wraps existing SSH key authentication and directory layout, calling `scp`, `ssh`, and `cc` with parametrized targets; stores artifacts in the current `~/src/irix_demo/bin`.
- Success criteria: Single-command workflow copies updated sources, compiles without manual intervention, optionally executes chosen binaries, and surfaces clear success/failure output locally.

## Stories
1. Story 1: Build the `irix-build` CLI that syncs sources and triggers remote compilation with configurable target names.
2. Story 2: Extend the CLI with remote execution and log capture, surfacing compiler/runtime errors locally.
3. Story 3: Package configuration (hosts, paths, flags) and author developer documentation covering usage, prerequisites, and troubleshooting.

## Compatibility Requirements
- [ ] Existing APIs remain unchanged
- [ ] Database schema changes are backward compatible
- [ ] UI changes follow existing patterns
- [ ] Performance impact is minimal

## Risk Mitigation
- Primary Risk: Automation could overwrite remote sources or mask failed compilation steps.
- Mitigation: Dry-run mode plus checksum comparison before overwriting; halt on non-zero exit codes with detailed logs.
- Rollback Plan: Preserve previous remote sources via timestamped backups; restore by copying backup directory back into `~/src/irix_demo`.

## Definition of Done
- [ ] All stories completed with acceptance criteria met
- [ ] Existing functionality verified through testing
- [ ] Integration points working correctly
- [ ] Documentation updated appropriately
- [ ] No regression in existing features

## Validation Checklist
### Scope Validation
- [x] Epic can be completed in 1-3 stories maximum
- [x] No architectural documentation is required
- [x] Enhancement follows existing patterns
- [x] Integration complexity is manageable

### Risk Assessment
- [x] Risk to existing system is low
- [x] Rollback plan is feasible
- [x] Testing approach covers existing functionality
- [x] Team has sufficient knowledge of integration points

### Completeness Check
- [x] Epic goal is clear and achievable
- [x] Stories are properly scoped
- [x] Success criteria are measurable
- [x] Dependencies are identified

## Story Manager Handoff
"Please develop detailed user stories for this brownfield epic. Key considerations:
- This is an enhancement to an existing system running macOS → IRIX remote workflows using OpenSSH, SCP, and the MIPSpro toolchain.
- Integration points: `irix_demo_local/` on macOS, `~/src/irix_demo` on the IRIX host, existing SSH configuration for host `octane`.
- Existing patterns to follow: Key-based SSH auth, per-file `scp`, remote `cc` compilation, tcsh guard patterns described in the workflow doc.
- Critical compatibility requirements: Don’t alter SSH host config; ensure remote directory structure and binaries remain compatible for manual runs; avoid performance regressions during sync.

The epic should maintain system integrity while delivering a one-command automation of the current remote build workflow."
