"""Shared subprocess helpers for SSH and SCP invocations."""

from __future__ import annotations

import shlex
import subprocess
from typing import Iterable, List, Optional


class RemoteCommandError(RuntimeError):
    """Raised when a remote command fails."""

    def __init__(self, command: List[str], returncode: int, stdout: str, stderr: str):
        super().__init__(
            f"Command {' '.join(shlex.quote(arg) for arg in command)} failed with "
            f"exit code {returncode}."
        )
        self.command = command
        self.returncode = returncode
        self.stdout = stdout
        self.stderr = stderr


def _format_command(cmd: Iterable[str]) -> str:
    return " ".join(shlex.quote(part) for part in cmd)


def run_local(command: List[str], dry_run: bool = False) -> None:
    """Run a local command, optionally in dry-run mode."""
    if dry_run:
        print(_format_command(command))
        return

    completed = subprocess.run(command, check=False, capture_output=True, text=True)
    if completed.returncode != 0:
        raise RemoteCommandError(command, completed.returncode, completed.stdout, completed.stderr)

    if completed.stdout:
        print(completed.stdout, end="")
    if completed.stderr:
        print(completed.stderr, end="")


def run_remote(
    host: str,
    remote_command: str,
    *,
    dry_run: bool = False,
    identity_file: Optional[str] = None,
    stream_output: bool = True,
) -> None:
    """Execute an SSH command, streaming output to the console."""
    command: List[str] = ["ssh"]
    if identity_file:
        command.extend(["-i", identity_file])
    command.append(host)
    command.append(remote_command)

    if dry_run:
        print(_format_command(command))
        return

    if stream_output:
        process = subprocess.Popen(command)
        returncode = process.wait()
        if returncode != 0:
            raise RemoteCommandError(command, returncode, "", "")
        return

    completed = subprocess.run(command, check=False, capture_output=True, text=True)
    if completed.returncode != 0:
        raise RemoteCommandError(command, completed.returncode, completed.stdout, completed.stderr)
    if completed.stdout:
        print(completed.stdout, end="")
    if completed.stderr:
        print(completed.stderr, end="")


def scp_files(
    files: List[str],
    destination: str,
    *,
    identity_file: Optional[str] = None,
    dry_run: bool = False,
) -> None:
    """Copy local files to the remote destination using scp."""
    if dry_run:
        cmd = ["scp"]
        if identity_file:
            cmd.extend(["-i", identity_file])
        cmd.extend(files)
        cmd.append(destination)
        print(_format_command(cmd))
        return

    cmd = ["scp"]
    if identity_file:
        cmd.extend(["-i", identity_file])
    cmd.extend(files)
    cmd.append(destination)
    completed = subprocess.run(cmd, check=False, capture_output=True, text=True)
    if completed.returncode != 0:
        raise RemoteCommandError(cmd, completed.returncode, completed.stdout, completed.stderr)
    if completed.stdout:
        print(completed.stdout, end="")
    if completed.stderr:
        print(completed.stderr, end="")
