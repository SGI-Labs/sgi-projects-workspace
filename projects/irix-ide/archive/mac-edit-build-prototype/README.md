# Remote Edit & Build Prototype

Lightweight proof-of-concept demonstrating the core macOS ↔ IRIX workflow for the future IDE.

## Prerequisites
- macOS environment with Python 3.11+ and `rsync`
- SSH access to an IRIX host (e.g., `octane`) with key-based auth per architecture tech stack
- Sample project directory (see `sample-project/` suggestion below)
- Python dependencies installed: `pip install -r requirements.txt`

## Files
- `config_loader.py` – shared YAML loader
- `config.sample.yml` – template configuration; copy to `config.yml` and edit
- `sync_loop.py` – runs `rsync` to mirror local changes to the remote host
- `remote_build.py` – invokes the remote build command and streams output
- `scp_sync.py` – fallback transfer using `scp` when rsync is unavailable on IRIX
- `README.md` – this guide

## Setup
1. Copy the sample config and adjust paths/credentials:
   ```bash
   cd projects/irix-ide/tools/prototype/edit-build-loop
   cp config.sample.yml config.yml
   ```
2. Populate `config.yml` with your SSH host, user, identity file, local project directory, and desired remote path.
   - Relative paths (for example `./sample-project`) are resolved against the directory containing `config.yml`, so the scripts can be executed from any working directory.
3. Prepare a simple project (for example `sample-project/src/hello.c`). Ensure directories exist on the remote host.

## Usage
Sync files once:
```bash
python sync_loop.py --config config.yml
```
Watch and sync continuously every `poll_interval` seconds (add `--timeout` to stop automatically):
```bash
python sync_loop.py --config config.yml --watch --timeout 10
```
Run remote build:
```bash
python remote_build.py --config config.yml
```
Override build command ad-hoc:
```bash
python remote_build.py --config config.yml --command "cd ~/src/irix_ide_prototype && mkdir -p bin && cc -o bin/hello src/hello.c"
```
Add `--dry-run` to preview commands without executing.

Fallback transfer when rsync is unavailable on IRIX:
```bash
python scp_sync.py --config config.yml
```

## Sample Metrics
Measured on macOS ➜ IRIX (Octane) using the sample project:

| Workflow                       | Command                                                                                       | Duration |
|--------------------------------|------------------------------------------------------------------------------------------------|----------|
| Single sync run                | `/usr/bin/time -p python sync_loop.py --config config.yml`                                     | ~0.44 s |
| Remote build (with mkdir)      | `/usr/bin/time -p python remote_build.py --config config.yml --command "cd ~/... && cc ..."` | ~0.70 s |
| Continuous sync (watch)        | `python sync_loop.py --config config.yml --watch --timeout 5` (two cycles)                    | ~5 s total |

Use these as baseline numbers; capture new timings whenever network/host conditions change.

## Screenshot Capture Guidance
- For documentation, capture Terminal output showing sync/build runs and the resulting binary execution on IRIX.
- Store PNG screenshots under `projects/irix-ide/docs/user-guides/screenshots/` and reference them in the PRD or user guides as visuals.

## Validation Checklist
- After syncing, verify files appear under the remote directory.
- Execute remote build and confirm compiler output streams to the local console.
- Measure end-to-end latency (save file → build completion) to compare against workflow success metrics.

## Observations / Next Steps
- Consider replacing the polling watcher with filesystem notifications for lower latency.
- Investigate retry/backoff strategies for unstable connections.
- Capture performance metrics (sync size, build duration) to feed back into PRD success criteria.
