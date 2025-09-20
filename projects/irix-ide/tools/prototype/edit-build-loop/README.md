# Remote Edit & Build Prototype

Lightweight proof-of-concept demonstrating the core macOS ↔ IRIX workflow for the future IDE.

## Prerequisites
- macOS environment with Python 3.11+ and `rsync`
- SSH access to an IRIX host (e.g., `octane`) with key-based auth per architecture tech stack
- Sample project directory (see `sample-project/` suggestion below)
- Optional: create a Python virtualenv and install `PyYAML` (`pip install pyyaml`)

## Files
- `config_loader.py` – shared YAML loader
- `config.sample.yml` – template configuration; copy to `config.yml` and edit
- `sync_loop.py` – runs `rsync` to mirror local changes to the remote host
- `remote_build.py` – invokes the remote build command and streams output
- `README.md` – this guide

## Setup
1. Copy the sample config and adjust paths/credentials:
   ```bash
   cd projects/irix-ide/tools/prototype/edit-build-loop
   cp config.sample.yml config.yml
   ```
2. Populate `config.yml` with your SSH host, user, identity file, local project directory, and desired remote path.
3. Prepare a simple project (for example `sample-project/src/hello.c`). Ensure directories exist on the remote host.

## Usage
Sync files once:
```bash
python sync_loop.py --config config.yml
```
Watch and sync continuously every `poll_interval` seconds:
```bash
python sync_loop.py --config config.yml --watch
```
Run remote build:
```bash
python remote_build.py --config config.yml
```
Override build command ad-hoc:
```bash
python remote_build.py --config config.yml --command "cd ~/src/irix_ide_prototype && cc -o bin/hello src/hello.c"
```
Add `--dry-run` to preview commands without executing.

## Validation Checklist
- After syncing, verify files appear under the remote directory.
- Execute remote build and confirm compiler output streams to the local console.
- Measure end-to-end latency (save file → build completion) to compare against workflow success metrics.

## Observations / Next Steps
- Consider replacing the polling watcher with filesystem notifications for lower latency.
- Investigate retry/backoff strategies for unstable connections.
- Capture performance metrics (sync size, build duration) to feed back into PRD success criteria.
