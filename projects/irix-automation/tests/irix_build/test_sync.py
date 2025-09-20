from pathlib import Path

import pytest

from irix_build import config, sync


@pytest.fixture()
def cfg(tmp_path: Path) -> config.BuildConfig:
    local_dir = tmp_path / "src"
    local_dir.mkdir()
    return config.BuildConfig(local_source_dir=local_dir, default_sources=[])


def test_determine_files_to_sync_detects_changes(cfg: config.BuildConfig):
    src = cfg.local_source_dir / "hello.c"
    src.write_text("int main() {return 0;}\n", encoding="utf-8")
    cfg.default_sources = ["hello.c"]

    first = sync.determine_files_to_sync(cfg)
    assert first == [src]

    second = sync.determine_files_to_sync(cfg)
    assert second == []

    src.write_text("int main() {return 1;}\n", encoding="utf-8")
    third = sync.determine_files_to_sync(cfg)
    assert third == [src]


def test_sync_files_dry_run_prints_commands(cfg: config.BuildConfig, capsys, monkeypatch):
    src = cfg.local_source_dir / "hello.c"
    src.write_text("int main() {return 0;}\n", encoding="utf-8")
    files = [src]

    sync.sync_files(cfg, files, dry_run=True)
    captured = capsys.readouterr()
    assert "scp" in captured.out
