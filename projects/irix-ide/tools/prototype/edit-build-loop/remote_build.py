"""Remote build launcher prototype."""

from __future__ import annotations

import argparse
import subprocess
from pathlib import Path

from config_loader import PrototypeConfig, load_config


def invoke_remote_build(cfg: PrototypeConfig, override_cmd: list[str] | None, dry_run: bool) -> int:
    command = override_cmd or cfg.build_command
    ssh_cmd = ["ssh"]
    if cfg.identity_file:
        ssh_cmd.extend(["-i", cfg.identity_file])
    ssh_cmd.append(cfg.remote_host)
    ssh_cmd.append(" ".join(command))

    print("[build]", " ".join(ssh_cmd))
    if dry_run:
        return 0

    process = subprocess.Popen(ssh_cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    assert process.stdout is not None
    for line in process.stdout:
        print(line, end="")
    return process.wait()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run remote build via SSH")
    parser.add_argument("--config", default="config.sample.yml", help="Path to config YAML")
    parser.add_argument("--command", nargs=argparse.REMAINDER, help="Override build command")
    parser.add_argument("--dry-run", action="store_true", help="Print command without executing")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    cfg_path = Path(args.config)
    if not cfg_path.exists():
        print(f"[build] Config file {cfg_path} not found")
        return 1
    cfg = load_config(cfg_path)

    override = args.command if args.command else None
    code = invoke_remote_build(cfg, override, args.dry_run)
    if code != 0:
        print(f"[build] Remote build failed with exit code {code}")
    return code


if __name__ == "__main__":
    raise SystemExit(main())
