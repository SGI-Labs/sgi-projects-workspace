from unittest import mock

from irix_build import build, config


def test_build_target_constructs_remote_command(monkeypatch):
    cfg = config.BuildConfig()
    executed = {}

    def fake_run_remote(host, remote_command, **kwargs):
        executed["host"] = host
        executed["remote_command"] = remote_command
        executed["kwargs"] = kwargs

    monkeypatch.setattr(build, "run_remote", fake_run_remote)

    build.build_target(cfg, ["hello.c"], "hello", dry_run=True)

    assert executed["host"] == cfg.remote_host
    assert "hello.c" in executed["remote_command"]
    assert executed["kwargs"]["dry_run"] is True
