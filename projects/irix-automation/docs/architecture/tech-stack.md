# Tech Stack Overview

The active SGI automation project lives under `projects/irix-automation/`. This stack document applies to that project; other projects added under `projects/` should create their own shards.

## Local Automation (macOS)
- **Language / Runtime:** Python 3.11 installed via Homebrew (`brew install python@3.11`). Treat Python as the only scripting runtime checked into the repo.
- **CLI Framework:** Standard-library `argparse`. Subcommands (`sync`, `build`, `run`, future `diag`) keep the command surface explicit.
- **Process Management:** `subprocess.run` with argument lists (never `shell=True`). All wrappers live in `projects/irix-automation/tools/irix_build/ssh.py` to centralize SGI crypto flags once implemented.
- **Configuration:** YAML file (`projects/irix-automation/tools/irix_build/config.yml`) loaded through a typed `BuildConfig` dataclass. Environment overrides come from `IRIX_BUILD_*` variables only.
- **Packaging / Distribution:** `Makefile` target `make install-cli` installs the CLI to `/usr/local/bin/irix-build`. For development, prefer simple virtualenv environments to keep tooling predictable.
- **Testing:** `pytest <8` with `monkeypatch` fixtures. Optional tooling includes `ruff` for linting and `mypy` in strict optional mode.

## Authentication & Host Profile
- Host alias `octane` is defined in `~/.ssh/config` pointing to the IRIX Octane with username `mario` and identity file `~/.ssh/irix_rsa`.
- Legacy crypto must remain enabled (`PubkeyAcceptedAlgorithms +ssh-rsa`, `KexAlgorithms +diffie-hellman-group1-sha1`, `Ciphers aes128-cbc`, `MACs hmac-sha1`).
- The CLI must respect this host profile—never override it with ad-hoc SSH parameters outside the documented wrappers.
- Remote home permissions must stay SGI-compliant: `/usr/people/mario9501` at `755`, `~/.ssh` at `700`, and `authorized_keys` at `600`.

## Remote Target (IRIX Octane)
- **Hardware / OS:** SGI Octane (IP30) running IRIX64 6.5.
- **Compiler:** MIPSPro `cc`. Default flags: `-O2 -g`. Additional warnings: `-fullwarn`. Capture build flags in the CLI rather than ad-hoc remote commands.
- **Shell Environment:** `tcsh` with guarded `stty` commands so non-interactive sessions remain quiet.
- **Filesystem Layout:** Sources under `~/src/irix_demo/*.c`, binaries in `~/src/irix_demo/bin/`, logs at `/var/adm/SYSLOG`.
- **Manual Baseline:** Earlier workflow used `scp irix_demo_local/*.c mario@octane:src/irix_demo/` followed by `cc -o bin/<target> <sources>`. The CLI should encapsulate these steps.
- **Transport:** OpenSSH using the `octane` host entry. Do not negotiate newer algorithms without hardware validation.

## Observability & Diagnostics
- **Structured Logging:** Python’s `logging` module configured for JSON output when `--verbose` is provided. Keep log levels consistent between modules.
- **Remote Diagnostics:** CLI will surface `tail -f /var/adm/SYSLOG`, `uname -a`, and `hinv -v` via dedicated subcommands (delivered across upcoming stories).
- **Troubleshooting:** Common failure modes include legacy `scp` compatibility (`-O`), permission mismatches on `~/.ssh`, and missing legacy algorithms. The CLI should emit actionable guidance for each case.

## Dependency Matrix
| Area            | Tool / Version           | Notes |
|-----------------|--------------------------|-------|
| Python runtime  | Python 3.11.x            | Single supported interpreter |
| Python testing  | `pytest` 7.x             | Pin in `requirements-dev.txt` |
| Python linting  | `ruff` 0.2.x (optional)  | Run locally before commits |
| Remote compiler | MIPSPro `cc`             | Managed on Octane |
| Secure transport| OpenSSH (macOS Ventura)  | Uses legacy RSA algorithms |

Archived components (`projects/irix-automation/archive/legacy-desktop-demo/`) retained their original dependencies but should not influence new work.
