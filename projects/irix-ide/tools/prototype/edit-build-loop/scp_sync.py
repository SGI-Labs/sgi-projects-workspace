"""Fallback sync using scp when rsync is unavailable on the remote host."""

from __future__ import annotations

import argparse
import subprocess
import tempfile
from pathlib import Path

from config_loader import PrototypeConfig, load_config


def gather_files(base: Path) -> list[Path]:
    return [p for p in base.rglob('*') if p.is_file()]


def scp_files(cfg: PrototypeConfig, files: list[Path], dry_run: bool) -> int:
    if not files:
        print('[scp-sync] No files to copy.')
        return 0

    ssh_command = ['scp']
    if cfg.identity_file:
        ssh_command.extend(['-i', cfg.identity_file])
    ssh_command.extend(str(file) for file in files)
    ssh_command.append(cfg.remote_target)

    print('[scp-sync]', ' '.join(ssh_command))
    if dry_run:
        return 0
    return subprocess.run(ssh_command, check=False).returncode


def main() -> int:
    parser = argparse.ArgumentParser(description='Fallback sync using scp')
    parser.add_argument('--config', default='config.sample.yml', help='Path to config YAML')
    parser.add_argument('--dry-run', action='store_true', help='Preview scp commands without execution')
    args = parser.parse_args()

    cfg_path = Path(args.config)
    if not cfg_path.exists():
        print(f"[scp-sync] Config file {cfg_path} not found")
        return 1

    cfg = load_config(cfg_path)
    files = gather_files(cfg.local_dir)
    return scp_files(cfg, files, args.dry_run)


if __name__ == '__main__':
    raise SystemExit(main())
