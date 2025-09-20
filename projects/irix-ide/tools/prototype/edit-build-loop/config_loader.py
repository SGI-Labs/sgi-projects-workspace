"""Load shared configuration for the IDE remote edit/build prototype."""

from __future__ import annotations

import dataclasses
import os
from pathlib import Path
from typing import List, Optional

import yaml


@dataclasses.dataclass
class PrototypeConfig:
    host: str
    user: Optional[str] = None
    identity_file: Optional[str] = None
    local_dir: Path = Path.cwd()
    remote_dir: str = "~/projects/demo"
    build_command: List[str] = dataclasses.field(default_factory=lambda: ["cc", "-o", "bin/app", "src/main.c"])
    poll_interval: float = 2.0

    @property
    def remote_target(self) -> str:
        if self.user:
            return f"{self.user}@{self.host}:{self.remote_dir}"
        return f"{self.host}:{self.remote_dir}"

    @property
    def remote_host(self) -> str:
        if self.user:
            return f"{self.user}@{self.host}"
        return self.host

    def expand_paths(self) -> None:
        self.local_dir = Path(os.path.expanduser(str(self.local_dir))).resolve()
        if self.identity_file:
            self.identity_file = os.path.expanduser(self.identity_file)


def load_config(path: Path) -> PrototypeConfig:
    data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    cfg = PrototypeConfig(**data)
    cfg.expand_paths()
    return cfg
