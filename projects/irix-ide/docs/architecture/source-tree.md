# Source Tree Reference

```
projects/irix-ide/
├── docs/
│   ├── architecture/
│   │   ├── index.md
│   │   ├── tech-stack.md
│   │   ├── coding-standards.md
│   │   ├── source-tree.md
│   │   └── future-work.md
│   ├── prd/
│   ├── stories/
│   ├── qa/
│   └── user-guides/
├── apps/
│   ├── macos/                  # SwiftUI workspace shell
│   └── irix/                   # Motif/X11 workspace shell (new)
├── tools/
│   ├── services/               # Rust/Python backend services
│   └── remote/                 # IRIX shell scripts and helpers
├── tests/
│   ├── client/                 # XCTest suites
│   ├── services/               # Rust/Python tests
│   └── integration/            # End-to-end scenarios
├── archive/                    # Deprecated prototypes/spikes
└── resources/                  # Shared assets (icons, UI mockups, docs)
```

## Rules
- Keep macOS-specific UI code under `apps/macos/`.
- Place IRIX Motif-specific UI code under `apps/irix/`.
- Place cross-platform services under `tools/services/` with language-specific subfolders.
- Maintain strict separation between production code and prototypes (move old experiments to `archive/`).
- Document any new directories in this file to keep the team aligned.
