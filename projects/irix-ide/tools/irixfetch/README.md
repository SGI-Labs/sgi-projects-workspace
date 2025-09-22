# IRIXfetch

IRIXfetch is a lightweight neofetch-style system information utility tailored
for SGI IRIX workstations. Two delivery options are included:

- `irixfetch` — a small C program built for the stock IRIX toolchain.
- `irixfetch.sh` — a POSIX shell fallback if you prefer not to compile.

Both render an IRIX-inspired ASCII badge alongside hardware and OS metadata
sourced from native utilities (`hinv`, `gfxinfo`, `versions`, etc.).

## Building the native binary

On IRIX, compile the program with the bundled MIPSPro `cc` (or any ANSI C
compiler):

```sh
cc -o irixfetch irixfetch.c
```

On other systems you can test with:

```sh
cc -o irixfetch irixfetch.c    # or clang/gcc
```

Copy the resulting binary to the target IRIX host and invoke it directly. The
binary checks `IRIXFETCH_NO_COLOR` (or `NO_COLOR`) to disable ANSI colours when
needed.

## Using the shell fallback

If compiling is inconvenient, the original shell implementation remains:

```sh
./irixfetch.sh
```

The script honours the same colour-disabling environment variables and targets
IRIX 6.5's `/bin/sh`.

## Features common to both builds

- IRIX-themed ASCII art banner with optional ANSI colour.
- Graceful degradation when optional utilities are unavailable.
- Displays system model, CPU, graphics, memory, uptime, shell, and package
  counts (via `versions`).
- Designed for 80-column terminals and stock IRIX userland.

## Installation tips

1. Copy `irixfetch` (or `irixfetch.sh`) to the IRIX machine, e.g. via `scp`.
2. Mark it executable if necessary: `chmod +x irixfetch`.
3. Drop it somewhere on your `$PATH` (such as `/usr/local/bin`) to launch it
   easily.

> Hint: Set `IRIXFETCH_NO_COLOR=1` or `NO_COLOR=1` when using terminals that do
> not support ANSI escape codes.
