# IRIX Remote Build Workflow

This document summarizes how we set up passwordless SSH from macOS to the IRIX Octane system, compiled sample programs remotely, and silenced non-interactive shell warnings.

## Environment
- **Client:** macOS with Homebrew
- **Server:** IRIX64 6.5 (IP30 Octane)
- **Account:** `mario@octane`

## 1. SSH Access & Key Authentication
1. Install `sshpass` (for initial scripted logins):
   ```bash
   brew install hudochenkov/sshpass/sshpass
   ```
2. Generate a dedicated RSA key on macOS:
   ```bash
   ssh-keygen -t rsa -b 2048 -f ~/.ssh/irix_rsa -N ''
   ```
3. Add a host entry to `~/.ssh/config` enabling legacy algorithms that IRIX’s OpenSSH 6.2 accepts:
   ```
   Host octane
       HostName octane
       User mario
       IdentityFile ~/.ssh/irix_rsa
       PubkeyAcceptedAlgorithms +ssh-rsa
       KexAlgorithms +diffie-hellman-group1-sha1
       HostKeyAlgorithms ssh-rsa,ecdsa-sha2-nistp256
       Ciphers aes128-cbc
       MACs hmac-sha1
   ```
4. Refresh `known_hosts` and prime the connection:
   ```bash
   ssh-keygen -R octane
   sshpass -p '<password>' ssh -T -o StrictHostKeyChecking=accept-new mario@octane "echo ok"
   ```
5. Install the public key on Octane:
   ```bash
   sshpass -p '<password>' scp ~/.ssh/irix_rsa.pub mario@octane:/tmp/irix_rsa.pub
   sshpass -p '<password>' ssh mario@octane <<'REMOTE'
   mkdir -p ~/.ssh
   cat /tmp/irix_rsa.pub >> ~/.ssh/authorized_keys
   rm /tmp/irix_rsa.pub
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   REMOTE
   ```
6. Fix home-directory permissions so `sshd` trusts it:
   ```bash
   sshpass -p '<password>' ssh mario@octane 'chmod 755 /usr/people/mario9501'
   ```
7. Confirm passwordless access:
   ```bash
   ssh -vv octane
   ```
   A successful login shows `Authenticated to octane ... using "publickey"` without prompting for a password.

## 2. Remote Demo Programs
1. Keep source files locally under `irix_demo_local/`:
   - `hello_irix.c` (prints node/sys/version via `uname`).
   - `cpu_count.c` (calls `sysmp(MP_NPROCS, 0)`).
2. Push sources to Octane:
   ```bash
   scp irix_demo_local/*.c mario@octane:src/irix_demo/
   ```
3. Build with the MIPSpro compiler:
   ```bash
   ssh octane 'cd ~/src/irix_demo && mkdir -p bin && cc -o bin/hello_irix hello_irix.c'
   ssh octane 'cd ~/src/irix_demo && cc -o bin/cpu_count cpu_count.c'
   ```
4. Run the binaries remotely:
   ```bash
   ssh octane '~/src/irix_demo/bin/hello_irix'
   ssh octane '~/src/irix_demo/bin/cpu_count'
   ```
   Example output confirms IRIX 6.5 on IP30 and reports `CPUs online: 1`.

## 3. Silencing `stty` Warnings
`tcsh` executed `stty` even during non-interactive sessions, printing `stty: Function not implemented`. We:
1. Backed up the root-owned `~/.tcshrc` to `~/.tcshrc.system`.
2. Uploaded a user-owned `.tcshrc` that guards the command:
   ```tcsh
   if ( $?prompt && -t 0 ) then
       stty intr ^C
   endif
   ```
3. After the change, scripted SSH commands run quietly; interactive shells keep their keybindings/history.

## 4. Handy Checks
- Hardware inventory: `ssh octane 'hinv -v'`
- Kernel/version: `ssh octane 'uname -a'`
- Verbose authentication debug: `ssh -vvv octane`
- Server-side auth logs: `ssh octane 'tail -f /var/adm/SYSLOG'`

## 5. Next Actions
- Add additional IRIX demos under `irix_demo_local/`, sync with `scp`, rebuild via `cc`.
- Wrap the `scp` + compile + run steps in a script for faster iteration.
- If other shell files (`/etc/cshrc`, `/etc/stdcshrc`) echo text, apply similar `-t` guards.

## Troubleshooting
- `send_pubkey_test: no mutual signature algorithm`: ensure `PubkeyAcceptedAlgorithms +ssh-rsa` is present.
- `Authentication refused: bad ownership or modes`: fix permissions on `$HOME`, `.ssh`, and `authorized_keys` (755/700/600).
- `scp` failing with `sftp-server: Command not found`: update `Subsystem sftp` in `sshd_config` to point at `/usr/nekoware/libexec/sftp-server` or force legacy mode with `scp -O`.
