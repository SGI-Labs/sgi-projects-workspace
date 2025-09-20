"""Configuration loading for the irix-build CLI."""

from __future__ import annotations

import dataclasses
import json
import os
from pathlib import Path
from typing import List, Optional

import yaml


DEFAULT_CONFIG_PATH = Path(__file__).with_name("config.yml")
STATE_FILE_NAME = ".irix_build_state.json"


@dataclasses.dataclass
class BuildConfig:
    host: str = "octane"
    user: Optional[str] = "mario"
    identity_file: Optional[str] = None
    local_source_dir: Path = Path("projects/irix-automation/irix_demo_local")
    remote_source_dir: str = "~/src/irix_demo"
    remote_bin_dir: str = "~/src/irix_demo/bin"
    default_sources: List[str] = dataclasses.field(default_factory=list)
    default_target: str = "hello_irix"

    @property
    def remote_host(self) -> str:
        if self.user:
            return f"{self.user}@{self.host}"
        return self.host

    @property
    def state_file(self) -> Path:
        return self.local_source_dir / STATE_FILE_NAME


def _coerce_path(value: Optional[str]) -> Optional[Path]:
    if value is None:
        return None
    expanded = os.path.expanduser(value)
    return Path(expanded)


def load_config(path: Optional[Path] = None) -> BuildConfig:
    """Load the build configuration from YAML, falling back to defaults."""
    config_path = path or DEFAULT_CONFIG_PATH
    data: dict = {}
    if config_path.exists():
        with config_path.open("r", encoding="utf-8") as fh:
            data = yaml.safe_load(fh) or {}

    cfg = BuildConfig()
    for field in dataclasses.fields(BuildConfig):
        if field.name in data:
            setattr(cfg, field.name, data[field.name])

    # Normalize paths
    cfg.local_source_dir = _coerce_path(str(cfg.local_source_dir)) or Path.cwd()
    cfg.identity_file = (
        str(_coerce_path(cfg.identity_file)) if cfg.identity_file is not None else None
    )

    # Discover default sources if not provided explicitly
    if not cfg.default_sources:
        cfg.default_sources = _discover_sources(cfg.local_source_dir)

    return cfg


def _discover_sources(local_dir: Path) -> List[str]:
    if not local_dir.exists():
        return []
    return sorted(str(path.name) for path in local_dir.glob("*.c"))


def load_state(config: BuildConfig) -> dict:
    if config.state_file.exists():
        with config.state_file.open("r", encoding="utf-8") as fh:
            return json.load(fh)
    return {}


def save_state(config: BuildConfig, state: dict) -> None:
    config.state_file.parent.mkdir(parents=True, exist_ok=True)
    with config.state_file.open("w", encoding="utf-8") as fh:
        json.dump(state, fh, indent=2)
