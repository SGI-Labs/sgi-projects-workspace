# SGI Projects Workspace

This repository hosts multiple SGI-related efforts. The root stays lightweight—projects live under `projects/`, and shared assets sit under `resources/`.

## Current Projects
- `projects/irix-automation/` – Python-based automation that syncs, builds, and runs IRIX demos via SSH.

When adding a new project, create a peer directory under `projects/` that mirrors the same structure: `docs/`, `tools/`, `tests/`, and `archive/` as needed.

## Directory Map
```
/
├── projects/
│   └── irix-automation/
│       ├── docs/            # Architecture, stories, PRD shards, QA outputs
│       ├── tools/           # Implementation code (e.g., irix_build CLI)
│       ├── tests/           # Test suites mirroring tools/
│       ├── archive/         # Deprecated experiments retained for reference
│       └── irix_demo_local/ # Sample C sources synced to the IRIX host
├── resources/
│   └── nekoware_mirror/     # Shared SGI software mirror
├── AGENTS.md
├── Makefile                 # Shared utility targets
└── README.md                # (this file)
```

## Getting Started with irix-automation
1. Review `projects/irix-automation/docs/architecture/index.md` for the current architectural snapshot.
2. Stories awaiting implementation live under `projects/irix-automation/docs/stories/`.
3. When developing, place new modules in `projects/irix-automation/tools/`, mirror tests in `projects/irix-automation/tests/`, and update the architecture shards as needed.

The original IRIX system monitor sample has been archived in `projects/irix-automation/archive/legacy-desktop-demo/` for historical reference.
