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
│   └── irix/                   # Motif/X11 workspace shell and supporting modules
├── tools/
│   ├── services/               # Rust/Python backend services
│   └── remote/                 # IRIX shell scripts and helpers
├── tests/
│   ├── client/                 # Motif client automation suites
│   ├── services/               # Rust/Python tests
│   └── integration/            # End-to-end scenarios
├── archive/                    # Deprecated prototypes/spikes
└── resources/                  # Shared assets (icons, UI mockups, docs)
```

## Rules
- Keep IRIX Motif-specific UI code under `apps/irix/`.
- Place shared services under `tools/services/` with language-specific subfolders.
- Maintain strict separation between production code and prototypes (move old experiments to `archive/`).
- Document any new directories in this file to keep the team aligned.
