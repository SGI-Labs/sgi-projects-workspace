from pathlib import Path

from irix_build import config


def test_load_config_defaults(tmp_path: Path, monkeypatch):
    cfg_path = tmp_path / "config.yml"
    cfg_path.write_text("host: demo\nuser: demo_user\n", encoding="utf-8")

    loaded = config.load_config(cfg_path)

    assert loaded.host == "demo"
    assert loaded.user == "demo_user"
    assert loaded.default_sources == []
    assert loaded.local_source_dir.exists() is False


def test_discover_sources(tmp_path: Path):
    (tmp_path / "foo.c").write_text("int main(){}", encoding="utf-8")
    (tmp_path / "bar.c").write_text("int main(){}", encoding="utf-8")

    cfg = config.BuildConfig(local_source_dir=tmp_path)
    cfg.default_sources = []

    discovered = config._discover_sources(tmp_path)
    assert discovered == ["bar.c", "foo.c"]
