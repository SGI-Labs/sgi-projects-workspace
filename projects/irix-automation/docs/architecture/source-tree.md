# Source Tree Reference

Repository layout uses a shared `projects/` directory so multiple efforts can coexist cleanly. Current active work lives under `projects/irix-automation/` with archived experiments preserved alongside it.

```
/
├── projects/
│   └── irix-automation/
│       ├── docs/
│       │   ├── architecture/
│       │   │   ├── index.md
│       │   │   ├── tech-stack.md
│       │   │   ├── coding-standards.md
│       │   │   ├── source-tree.md
│       │   │   └── future-work.md
│       │   ├── prd/
│       │   ├── stories/
│       │   ├── qa/
│       │   ├── user-guides/          # Placeholder for CLI docs delivered in later stories
│       │   └── irix_remote_workflow.md
│       ├── archive/
│       │   ├── README.md
│       │   └── legacy-desktop-demo/
│       ├── tools/
│       │   └── irix_build/           # CLI modules live here (to be implemented)
│       ├── tests/
│       │   └── irix_build/           # Test suite mirrors runtime modules
│       └── irix_demo_local/          # Local C demos synced to IRIX
├── resources/
│   └── nekoware_mirror/              # Shared artifacts used across projects
├── AGENTS.md
├── Makefile
└── README.md
```

## Directory Rules
- **projects/<project>/docs/** contains all project-specific documentation. Add new projects as peers under `projects/` when needed.
- **projects/<project>/tools/** and **tests/** host implementation code and test suites. Keep module names scoped to the project to avoid collisions.
- **projects/<project>/archive/** preserves deprecated assets; no active development occurs there without a new architectural decision.
- **resources/** is for shared data or mirrors reused by multiple projects.

## Naming Conventions
- Python modules: `snake_case.py`
- Tests: `test_<module>.py`
- Configuration: YAML (`*.yml` / `*.yaml`)

Follow this structure for future projects: create a sibling directory under `projects/` and replicate the docs/tools/tests layout to keep the root clean.
