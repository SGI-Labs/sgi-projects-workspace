"""Load shared configuration for the IDE remote edit/build prototype."""

from __future__ import annotations

import dataclasses
import os
from pathlib import Path
from typing import List, Optional

try:
    import yaml
except ModuleNotFoundError as exc:  # pragma: no cover - user-facing dependency hint
    raise SystemExit(
        "PyYAML is required for the IRIX IDE prototype. Install dependencies with "
        "`pip install -r projects/irix-ide/tools/prototype/edit-build-loop/requirements.txt`."
    ) from exc


def _expand_path(path_value: Path | str, base_dir: Path) -> Path:
    """Resolve relative paths against the config file directory."""

    raw = os.path.expanduser(str(path_value))
    candidate = Path(raw)
    if candidate.is_absolute():
        return candidate.resolve()
    return (base_dir / candidate).resolve()


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

    def expand_paths(self, base_dir: Path) -> None:
        self.local_dir = _expand_path(self.local_dir, base_dir)
        if self.identity_file:
            self.identity_file = str(_expand_path(self.identity_file, base_dir))


def load_config(path: Path) -> PrototypeConfig:
    data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    cfg = PrototypeConfig(**data)
    cfg.expand_paths(path.resolve().parent)
    return cfg
