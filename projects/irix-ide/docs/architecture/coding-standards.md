# Coding Standards

## macOS Client (SwiftUI)
- **Language:** Swift 5.9+.
- **UI Structure:** MVVM with Combine for state management. Views kept declarative; business logic resides in ViewModels and services.
- **Formatting:** Enforce SwiftFormat/SwiftLint defaults. 120-character line limit.
- **Testing:** Unit tests with XCTest; UI tests optional during prototype.

## Shared Services (Rust/Python)
- **Language:** Rust for performance-critical sync/build helpers; Python for plugin host scripts.
- **Error Handling:** Use Result/Option in Rust; raise custom exceptions in Python.
- **Testing:** Rust `cargo test`; Python `pytest` with fixtures for remote interactions.

## Remote Scripts (IRIX)
- **Shell:** POSIX-compliant sh. Avoid bash-only features.
- **Packaging:** Store helper scripts under `projects/irix-ide/tools/remote/`; ensure idempotent operations and clear logging.

## Cross-Cutting Practices
- Document all commands and workflows in user guides.
- Maintain architecture shards as living documents; update after every major change.
- Adopt CI checks (formatting, lint, unit tests) once core architecture stabilizes.
