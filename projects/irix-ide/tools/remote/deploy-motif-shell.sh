#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "${SCRIPT_DIR}/../.." && pwd)"
APP_DIR="${REPO_ROOT}/apps/irix"

REMOTE_HOST="${REMOTE_HOST:-mario950@octane}"
REMOTE_ROOT="${REMOTE_ROOT:-/tmp/irix-ide-app}"
REMOTE_APP_DIR="${REMOTE_ROOT}/apps/irix"

CC_FLAGS="${CC_FLAGS:--Isrc -I/usr/include -I/usr/include/X11 -I/usr/include/Xm -O2}"
LD_FLAGS="${LD_FLAGS:--L/usr/lib32 -lXm -lXt -lX11}"

printf "[deploy] syncing %s to %s:%s\n" "$APP_DIR" "$REMOTE_HOST" "$REMOTE_APP_DIR"
LOCAL_RSYNC="${LOCAL_RSYNC:-rsync}"
REMOTE_RSYNC="${REMOTE_RSYNC:-/usr/nekoware/bin/rsync}"
ssh "$REMOTE_HOST" "mkdir -p '$REMOTE_APP_DIR'"
"$LOCAL_RSYNC" -av --delete -e ssh "$APP_DIR/" "${REMOTE_HOST}:${REMOTE_APP_DIR}/" --rsync-path "$REMOTE_RSYNC"

printf "[deploy] building on %s\n" "$REMOTE_HOST"
ssh "$REMOTE_HOST" /bin/sh -s <<__REMOTE_BUILD__
set -eu
REMOTE_APP_DIR="$REMOTE_APP_DIR"
CC_FLAGS="$CC_FLAGS"
LD_FLAGS="$LD_FLAGS"
cd "\$REMOTE_APP_DIR"
mkdir -p build release
cc \$CC_FLAGS -c src/ui_shell.c -o build/ui_shell.o
cc \$CC_FLAGS -c src/main.c -o build/main.o
cc build/main.o build/ui_shell.o \$LD_FLAGS -o release/irix-ide-motif
__REMOTE_BUILD__

printf "[deploy] build complete. Binary: %s:%s\n" "$REMOTE_HOST" "${REMOTE_APP_DIR}/release/irix-ide-motif"
printf "[deploy] apply resources with: xrdb -merge %s/resources/IRIXIDE.ad\n" "$REMOTE_APP_DIR"
