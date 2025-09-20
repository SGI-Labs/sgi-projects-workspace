from unittest import mock

import pytest

from irix_build import cli, config


@pytest.fixture()
def sample_config(tmp_path):
    local_dir = tmp_path / "src"
    local_dir.mkdir()
    (local_dir / "alpha.c").write_text("int main() {return 0;}", encoding="utf-8")
    cfg_path = tmp_path / "config.yml"
    cfg_path.write_text(
        """
local_source_dir: {local}
default_sources:
  - alpha.c
""".format(local=str(local_dir)),
        encoding="utf-8",
    )
    return cfg_path


def test_cli_sync_triggers_sync(monkeypatch, sample_config):
    calls = {}

    def fake_load_config(path):
        return config.load_config(sample_config)

    def fake_handle_sync(cfg, sources, dry_run):
        calls["handled"] = (tuple(sources) if sources else None, dry_run)

    monkeypatch.setattr(cli, "load_config", fake_load_config)
    monkeypatch.setattr(cli, "handle_sync", fake_handle_sync)

    cli.main(["--config", str(sample_config), "--dry-run", "sync", "alpha.c"])
    assert calls["handled"] == (("alpha.c",), True)


def test_cli_all_runs_both(monkeypatch, sample_config):
    sequence = []

    def fake_load_config(path):
        return config.load_config(sample_config)

    monkeypatch.setattr(cli, "load_config", fake_load_config)
    monkeypatch.setattr(cli, "handle_sync", lambda *args, **kwargs: sequence.append("sync"))
    monkeypatch.setattr(cli, "handle_build", lambda *args, **kwargs: sequence.append("build"))

    cli.main(["--config", str(sample_config), "all"])
    assert sequence == ["sync", "build"]
