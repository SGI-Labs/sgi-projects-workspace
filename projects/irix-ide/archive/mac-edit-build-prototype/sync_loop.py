"""Incremental file sync prototype for macOS ↔ IRIX workflow."""

from __future__ import annotations

import argparse
import subprocess
import time
from pathlib import Path

from config_loader import PrototypeConfig, load_config


RSYNC_FLAGS = ["-r", "-t"]
REMOTE_RSYNC = "/usr/nekoware/bin/rsync"


def run_rsync(cfg: PrototypeConfig, dry_run: bool, delete: bool) -> int:
    cmd = ["rsync", "--rsync-path", REMOTE_RSYNC, *RSYNC_FLAGS]
    if delete:
        cmd.append("--delete")
    if cfg.identity_file:
        cmd.extend(["-e", f"ssh -i {cfg.identity_file}"])
    cmd.append(str(cfg.local_dir) + "/")
    cmd.append(cfg.remote_target)

    print("[sync]", " ".join(cmd) + (" --dry-run" if dry_run else ""))
    if dry_run:
        return 0

    result = subprocess.run(cmd, check=False)
    if result.returncode != 0:
        print(
            "[sync] rsync failed. If the remote host only has legacy rsync, "
            "consider installing GNU rsync (e.g., via Nekoware) or using the scp fallback."
        )
    return result.returncode


def watch_loop(cfg: PrototypeConfig, dry_run: bool, delete: bool, timeout: float | None) -> None:
    print("[sync] Watching for changes. Press Ctrl+C to stop.")
    start = time.time()
    try:
        while True:
            if timeout is not None and time.time() - start > timeout:
                print("[sync] Watch mode timeout reached; stopping.")
                break
            code = run_rsync(cfg, dry_run, delete)
            if code != 0:
                print(f"[sync] rsync exited with code {code}. Retrying in {cfg.poll_interval}s")
            time.sleep(cfg.poll_interval)
    except KeyboardInterrupt:
        print("[sync] Stopped.")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Prototype sync loop for IRIX IDE")
    parser.add_argument("--config", default="config.sample.yml", help="Path to prototype config YAML")
    parser.add_argument("--watch", action="store_true", help="Continuously sync at the configured interval")
    parser.add_argument("--dry-run", action="store_true", help="Preview rsync commands without transferring files")
    parser.add_argument("--delete", action="store_true", help="Mirror deletions to the remote host (requires compatible rsync)")
    parser.add_argument("--timeout", type=float, help="Maximum seconds to run in watch mode before stopping")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    cfg_path = Path(args.config)
    if not cfg_path.exists():
        print(f"[sync] Config file {cfg_path} not found")
        return 1

    cfg = load_config(cfg_path)
    if not cfg.local_dir.exists():
        print(f"[sync] Local directory {cfg.local_dir} does not exist")
        return 1

    if args.watch:
        watch_loop(cfg, args.dry_run, args.delete, args.timeout)
        return 0

    return run_rsync(cfg, args.dry_run, args.delete)


if __name__ == "__main__":
    raise SystemExit(main())
