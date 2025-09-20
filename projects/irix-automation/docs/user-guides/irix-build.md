# irix-build CLI User Guide

The `irix-build` command automates syncing demo sources to the IRIX Octane host and compiling them with the MIPSPro toolchain.

## Prerequisites
- macOS workstation with SSH access to `octane` configured per the architecture docs.
- Local sources under `projects/irix-automation/irix_demo_local/`.
- Python 3.11 virtual environment (optional) for CLI dependencies.

## Basic Usage
```
python -m irix_build.cli [--config CONFIG] [--dry-run] <command> [...]
```

### Sync
Copy changed sources to the remote host:
```
python -m irix_build.cli sync
python -m irix_build.cli sync hello_irix.c cpu_count.c
```
Use `--dry-run` to preview the `scp` commands without execution.

### Build
Compile sources on the remote host:
```
python -m irix_build.cli build --sources hello_irix.c --target hello_irix
```
Defaults come from `config.yml` if `--sources` or `--target` are omitted.

### All
Run sync followed by build in one command:
```
python -m irix_build.cli all --dry-run
python -m irix_build.cli all --sources hello_irix.c cpu_count.c --target hello_irix
```

## Configuration
Edit `projects/irix-automation/tools/irix_build/config.yml` to adjust:
- `host`, `user`, and `identity_file` (optional) for SSH
- `local_source_dir`, `remote_source_dir`, `remote_bin_dir`
- `default_sources` and `default_target`

Override with `--config /path/to/config.yml` when running the CLI.

## Manual Validation Steps
1. Run `python -m irix_build.cli sync --dry-run` to confirm the planned file transfers.
2. Execute `python -m irix_build.cli all --sources hello_irix.c cpu_count.c --target hello_irix` to sync and compile.
3. SSH into the Octane and run `~/src/irix_demo/bin/hello_irix` and `~/src/irix_demo/bin/cpu_count` to confirm outputs.
4. Review `/var/adm/SYSLOG` if compilation fails (`ssh octane 'tail -f /var/adm/SYSLOG'`).

Updates to the CLI should keep this guide in sync.
