# Remote Tooling

Utilities that sync and build IRIX-specific components on remote hosts.

## Scripts

### `deploy-motif-shell.sh`
Automates deployment of the Motif UI shell to an IRIX host (default `mario950@octane`).

Usage:
```
$ tools/remote/deploy-motif-shell.sh
```
Environment overrides:
- `REMOTE_HOST` – SSH target (`user@host`). Defaults to `mario950@octane`.
- `REMOTE_ROOT` – Base directory on the remote machine (`/tmp/irix-ide-app`).
- `CC_FLAGS`, `LD_FLAGS` – Compiler/linker overrides if toolchains live elsewhere.

The script rsyncs `apps/irix/` to the remote host, runs the Motif build (`cc ...`), and prints the resulting binary path plus the `xrdb -merge` command for design tokens.

## Requirements
- Passwordless SSH (e.g., keys) to the target host.
- `rsync` on both local and remote machines.
- IRIX toolchain with Motif headers (`/usr/include/Xm`) and libraries (`/usr/lib32`).
