# Coding Standards

Active development focuses on the Python automation CLI under `projects/irix-automation/tools/irix_build/`. Legacy C++ experiments live in `projects/irix-automation/archive/` and are not part of the supported codebase.

## General Principles
- Favor explicit, predictable code; optimizations come second to clarity.
- Keep modules single-purpose and limit cross-module coupling.
- Treat linter and type-checker warnings as defects—resolve or document them immediately.
- Update architecture shards and stories whenever implementation deviates from plan.

## Python (CLI)
- **Style:** PEP 8 with a 100-character line limit. Enable `ruff` locally to enforce format.
- **Typing:** Add type hints to all functions and dataclasses. Run `mypy --strict` before committing.
- **Module Layout:**
  - `projects/irix-automation/tools/irix_build/cli.py` – argument parsing and orchestration only.
  - `projects/irix-automation/tools/irix_build/sync.py` – local change detection and `scp` preparation.
  - `projects/irix-automation/tools/irix_build/build.py` – remote compilation routines.
  - `projects/irix-automation/tools/irix_build/run.py` – remote execution and log capture.
  - `projects/irix-automation/tools/irix_build/ssh.py` – subprocess wrappers, retry/backoff logic, error translation.
  - `projects/irix-automation/tools/irix_build/config.py` – configuration dataclasses and YAML loading.
- **Error Handling:** Wrap subprocess failures in `RemoteCommandError` capturing command, exit code, stdout, and stderr.
- **Logging:** Standard `logging` module initialized in `cli.py`. Log critical events with structured key/value pairs.
- **Testing:**
  - Place tests under `projects/irix-automation/tests/irix_build/` mirroring runtime modules.
  - Use `pytest` with monkeypatched subprocess wrappers.
  - Each acceptance criterion requires at least one automated test or documented manual validation step.

## Shell & Remote Interactions
- Construct command arguments as arrays; never interpolate user inputs into strings.
- Quote paths when bridging to shell contexts on macOS and IRIX.
- Respect permissions expectations from the host profile; do not run `chmod` unless acceptance criteria require it.

## Documentation Expectations
- Update architecture shards under `projects/irix-automation/docs/architecture/` as stories deliver CLI features.
- Introduce or expand `projects/irix-automation/docs/user-guides/` entries as stories deliver new commands.
- Keep story Dev Notes synchronized with architecture documents; missing references are treated as blockers.

## Reviews & Governance
- Require architectural review for changes under `projects/irix-automation/tools/irix_build/` and `projects/irix-automation/docs/architecture/`.
- One story per PR with the story file included for traceability.
- Record any approved deviation from these standards in the relevant story’s Dev Notes and Change Log.

Legacy C++ standards are preserved in the archive for historical context but must not guide new implementations without formal reinstatement.
