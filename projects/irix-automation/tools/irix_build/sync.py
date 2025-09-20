"""File synchronisation helpers."""

from __future__ import annotations

import hashlib
from pathlib import Path
from typing import Iterable, List

from . import config as config_module
from .ssh import scp_files


def _file_signature(path: Path) -> str:
    hasher = hashlib.sha256()
    hasher.update(str(path.stat().st_mtime_ns).encode())
    hasher.update(str(path.stat().st_size).encode())
    return hasher.hexdigest()


def determine_files_to_sync(
    cfg: config_module.BuildConfig,
    requested_sources: Iterable[str] | None = None,
) -> List[Path]:
    local_dir = cfg.local_source_dir
    sources = list(requested_sources) if requested_sources else cfg.default_sources
    state = config_module.load_state(cfg)
    changed: List[Path] = []

    for source in sources:
        path = local_dir / source
        if not path.exists():
            continue
        signature = _file_signature(path)
        if state.get(source) != signature:
            changed.append(path)
            state[source] = signature

    config_module.save_state(cfg, state)
    return changed


def sync_files(
    cfg: config_module.BuildConfig,
    files: List[Path],
    *,
    dry_run: bool = False,
) -> None:
    if not files:
        print("No files changed; sync skipped.")
        return

    destination = f"{cfg.remote_host}:{cfg.remote_source_dir}/"
    scp_files([str(path) for path in files], destination, identity_file=cfg.identity_file, dry_run=dry_run)
