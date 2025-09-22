# Coding Standards

## IRIX Client (Motif/X11)
- **Language:** ANSI C with Motif (IRIS IM) widgets; use SGI compiler defaults.
- **UI Structure:** Separate widget construction from controller logic. Encapsulate callbacks per module and log transitions for telemetry.
- **Formatting:** K&R style, 4-space indentation; keep line length ≤100 characters for readability in legacy editors.
- **Testing:** Employ scripted UI smoke tests using `xdotool`/`xrunner` where available; complement with manual checklists for critical flows.

## Shared Services (Rust/Python)
- **Language:** Rust for performance-critical sync/build helpers; Python for plugin host scripts and orchestration.
- **Error Handling:** Use `Result`/`Option` in Rust; raise custom exceptions in Python with clear operator guidance.
- **Testing:** Rust `cargo test`; Python `pytest` with fixtures for remote interactions and mocked IRIX hosts.

## Remote Scripts (IRIX Shell)
- **Shell:** POSIX-compliant `sh`; avoid GNU/bash-specific constructs to retain compatibility with IRIX defaults.
- **Packaging:** Store helper scripts under `projects/irix-ide/tools/remote/`; ensure idempotent operations, structured logging, and configurable timeouts.

## Cross-Cutting Practices
- Document all commands and workflows in user guides and knowledge base shards.
- Maintain architecture shards as living documents; update after every major change.
- Adopt CI checks (formatting, lint, unit tests) once core architecture stabilizes.
