"""Remote build helpers."""

from __future__ import annotations

import shlex
from typing import Iterable, List

from .config import BuildConfig
from .ssh import run_remote


def build_target(
    cfg: BuildConfig,
    sources: Iterable[str],
    target: str,
    *,
    dry_run: bool = False,
) -> None:
    quoted_sources = " ".join(shlex.quote(str(source)) for source in sources)
    remote_cmd = (
        f"cd {shlex.quote(cfg.remote_source_dir)} && "
        f"mkdir -p {shlex.quote(cfg.remote_bin_dir)} && "
        f"cc -o {shlex.quote(cfg.remote_bin_dir)}/{shlex.quote(target)} {quoted_sources}"
    )
    run_remote(
        cfg.remote_host,
        remote_cmd,
        dry_run=dry_run,
        identity_file=cfg.identity_file,
        stream_output=True,
    )
