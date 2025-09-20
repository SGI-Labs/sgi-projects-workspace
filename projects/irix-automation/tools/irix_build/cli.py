"""Command line interface for the irix-build automation tool."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import List

from .config import BuildConfig, load_config
from . import build as build_module
from . import config as config_module
from . import sync as sync_module


def _parse_args(argv: List[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Automation tooling for IRIX demos")
    parser.add_argument("--config", type=Path, help="Path to configuration YAML", default=None)
    parser.add_argument("--dry-run", action="store_true", help="Show commands without executing")

    subparsers = parser.add_subparsers(dest="command", required=True)

    sync_parser = subparsers.add_parser("sync", help="Sync local sources to the IRIX host")
    sync_parser.add_argument("sources", nargs="*", help="Specific source files to sync")

    build_parser = subparsers.add_parser("build", help="Compile sources on the IRIX host")
    build_parser.add_argument("--sources", nargs="*", help="Sources to compile")
    build_parser.add_argument("--target", help="Output target name")

    all_parser = subparsers.add_parser("all", help="Sync then build in a single run")
    all_parser.add_argument("--sources", nargs="*", help="Sources to sync/build")
    all_parser.add_argument("--target", help="Output target name")

    return parser.parse_args(argv)


def _resolve_sources(cfg: BuildConfig, provided: List[str] | None) -> List[str]:
    if provided:
        return provided
    return cfg.default_sources


def handle_sync(cfg: BuildConfig, sources: List[str] | None, *, dry_run: bool) -> None:
    files = sync_module.determine_files_to_sync(cfg, sources)
    sync_module.sync_files(cfg, files, dry_run=dry_run)


def handle_build(cfg: BuildConfig, sources: List[str] | None, target: str | None, *, dry_run: bool) -> None:
    resolved_sources = _resolve_sources(cfg, sources)
    if not resolved_sources:
        print("No sources available to build", file=sys.stderr)
        sys.exit(1)
    resolved_target = target or cfg.default_target
    build_module.build_target(cfg, resolved_sources, resolved_target, dry_run=dry_run)


def main(argv: List[str] | None = None) -> int:
    args = _parse_args(argv or sys.argv[1:])
    cfg = load_config(args.config)
    cfg.local_source_dir = cfg.local_source_dir

    if args.command == "sync":
        handle_sync(cfg, args.sources, dry_run=args.dry_run)
    elif args.command == "build":
        handle_build(cfg, args.sources, args.target, dry_run=args.dry_run)
    elif args.command == "all":
        handle_sync(cfg, args.sources, dry_run=args.dry_run)
        handle_build(cfg, args.sources, args.target, dry_run=args.dry_run)
    else:
        print(f"Unknown command {args.command}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
