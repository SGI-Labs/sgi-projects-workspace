# IRIX IDE - Motif UI Shell

This module hosts the Motif/X11 implementation of the IRIX IDE desktop shell. It mirrors the macOS SwiftUI client layouts while adopting Indigo Magic styling and platform-specific interaction patterns.

## Features
- Workspace shell with left-rail navigation (buttons now switch content/banners), remote host status, and project list placeholders.
- Central content panel illustrating editor/build contexts with connection banners and activity summary.
- Status bar exposing connection state, active host, and sync/build telemetry.
- Design tokens sourced from `resources/IRIXIDE.ad` (generated via the shared design token pipeline).

## Directory Structure
```
apps/irix
├── README.md
├── Makefile             # Build entry-point for IRIX (Motif + Xt)
├── resources
│   └── IRIXIDE.ad       # Motif app-defaults file generated from tokens
└── src
    ├── main.c           # Entry point that boots the Motif UI shell
    └── ui_shell.h/.c    # Widget composition helpers
```

## Build (IRIX)
```
$ cd apps/irix
$ make BUILD=release
# produces bin/irix-ide-motif
```
> The `Makefile` assumes MIPSPro (`cc`) and Motif headers/libraries are available at their standard IRIX locations (`/usr/include/Xm`, `/usr/lib32`). Adjust `CC`, `CFLAGS`, and `LDFLAGS` if your environment differs.

## Running
```
$ cd apps/irix
$ xrdb -merge resources/IRIXIDE.ad   # apply design tokens
$ ./bin/irix-ide-motif
```

## Token Pipeline
The Motif resource file is generated from `docs/architecture/token-prototype/tokens.sample.json` via `generate_tokens.py`. When token updates land:
```
$ python docs/architecture/token-prototype/generate_tokens.py \
    --motif-out apps/irix/resources/IRIXIDE.ad \
    --swift-out apps/macos/Sources/IRIXDesignSystem/GeneratedTokens.swift
```

## Next Steps
- Integrate real project/host data sources once backend services are available.
- Expand widget set to cover debugger panes, build logs, and activity feeds.
- Wire up command handlers (menu actions, host switching, offline queue prompts).
- For faster iteration, use `tools/remote/deploy-motif-shell.sh` from the repo root to rsync and rebuild on the Octane host.
