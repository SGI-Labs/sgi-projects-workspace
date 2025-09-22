#!/bin/sh
# irixfetch - A lightweight neofetch-style system info display for SGI IRIX
#
# This script avoids modern shell features so it can run on the classic IRIX
# /bin/sh. It collects hardware and operating system metadata via utilities
# like `hinv`, `gfxinfo`, `versions`, and `uname`.
#
# Usage: ./irixfetch.sh
# Disable colour by exporting IRIXFETCH_NO_COLOR=1 or NO_COLOR.

command_exists() {
    _cmd="$1"
    if [ "$_cmd" = "" ]; then
        return 1
    fi
    case "$_cmd" in
        */*)
            if [ -x "$_cmd" ]; then
                return 0
            fi
            ;;
        *)
            _oldifs="$IFS"
            IFS=:
            for _dir in $PATH; do
                if [ "$_dir" != "" ] && [ -x "$_dir/$_cmd" ]; then
                    IFS="$_oldifs"
                    return 0
                fi
            done
            IFS="$_oldifs"
            ;;
    esac
    return 1
}

trim() {
    printf '%s' "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

# Detect colour support (basic 8-colour ANSI only for IRIX termcap coverage)
if [ -t 1 ] && [ "${IRIXFETCH_NO_COLOR:-}" != "1" ] && [ "${NO_COLOR:-}" = "" ]; then
    ESC=`printf '\033'`
    RESET="${ESC}[0m"
    BOLD="${ESC}[1m"
    C1="${ESC}[35m"  # magenta
    C2="${ESC}[36m"  # cyan
    C3="${ESC}[34m"  # blue
else
    RESET=""
    BOLD=""
    C1=""
    C2=""
    C3=""
fi

USER_NAME="${USER:-}"
if [ "$USER_NAME" = "" ]; then
    if command_exists id; then
        USER_NAME=`id -un 2>/dev/null`
    fi
fi
if [ "$USER_NAME" = "" ]; then
    USER_NAME="user"
fi

HOST_NAME=`uname -n 2>/dev/null`
if [ "$HOST_NAME" = "" ] && command_exists hostname; then
    HOST_NAME=`hostname 2>/dev/null`
fi
if [ "$HOST_NAME" = "" ]; then
    HOST_NAME="irix"
fi

OS_NAME=`uname -s 2>/dev/null`
OS_RELEASE=`uname -r 2>/dev/null`
OS_VERSION=`uname -v 2>/dev/null`
if [ "$OS_VERSION" != "" ] && [ "$OS_VERSION" != "$OS_RELEASE" ]; then
    OS_DISPLAY="$OS_NAME $OS_RELEASE ($OS_VERSION)"
else
    OS_DISPLAY="$OS_NAME $OS_RELEASE"
fi
OS_DISPLAY=`trim "$OS_DISPLAY"`

MACHINE=`uname -m 2>/dev/null`
MODEL=""
if command_exists hinv; then
    MODEL_LINE=`hinv -m 2>/dev/null | head -1`
    MODEL=`trim "$MODEL_LINE"`
    if [ "$MODEL" = "" ]; then
        MODEL_LINE=`hinv 2>/dev/null | awk '/System:/ {print substr($0, index($0,$2)); exit}'`
        MODEL=`trim "$MODEL_LINE"`
    fi
fi
if [ "$MODEL" = "" ]; then
    MODEL="$MACHINE"
fi
MODEL=`trim "$MODEL"`

CPU_INFO=""
if command_exists hinv; then
    CPU_LINE=`hinv -c processor 2>/dev/null | head -1`
    CPU_INFO=`trim "$CPU_LINE"`
    if [ "$CPU_INFO" = "" ]; then
        CPU_LINE=`hinv 2>/dev/null | awk '/processor/ {print $0; exit}'`
        CPU_INFO=`trim "$CPU_LINE"`
    fi
fi
if [ "$CPU_INFO" = "" ] && command_exists sysinfo; then
    CPU_LINE=`sysinfo -p 2>/dev/null | head -1`
    CPU_INFO=`trim "$CPU_LINE"`
fi
CPU_INFO=`trim "$CPU_INFO"`

GFX_INFO=""
if command_exists hinv; then
    GFX_LINE=`hinv -c gfx 2>/dev/null | head -1`
    GFX_INFO=`trim "$GFX_LINE"`
fi
if [ "$GFX_INFO" = "" ] && command_exists gfxinfo; then
    GFX_LINE=`gfxinfo -v 2>/dev/null | awk 'NR==1 {print; exit}'`
    GFX_INFO=`trim "$GFX_LINE"`
fi
GFX_INFO=`trim "$GFX_INFO"`

MEM_INFO=""
if command_exists hinv; then
    MEM_LINE=`hinv 2>/dev/null | awk '/Main memory size:/ {print $4 " " $5; exit}'`
    MEM_INFO=`trim "$MEM_LINE"`
fi
if [ "$MEM_INFO" = "" ] && command_exists sysinfo; then
    MEM_LINE=`sysinfo -m 2>/dev/null | head -1`
    MEM_INFO=`trim "$MEM_LINE"`
fi
MEM_INFO=`trim "$MEM_INFO"`

UPTIME=""
if command_exists uptime; then
    UPTIME_RAW=`uptime 2>/dev/null`
    UPTIME=`printf '%s' "$UPTIME_RAW" | sed 's/^[[:space:]]*//'`
fi

SHELL_PATH="${SHELL:-/bin/sh}"
SHELL_NAME=${SHELL_PATH##*/}
if [ "$SHELL_NAME" = "" ]; then
    SHELL_NAME="sh"
fi

TERM_INFO="${TERM:-unknown}"

PACKAGES=""
if command_exists versions; then
    PACKAGES_COUNT=`versions 2>/dev/null | awk '/^I/ {count++} END {print count}'`
    if [ "$PACKAGES_COUNT" = "" ]; then
        PACKAGES_COUNT="0"
    fi
    PACKAGES="$PACKAGES_COUNT packages"
fi

if [ "$CPU_INFO" = "" ]; then
    CPU_INFO="(n/a)"
fi
if [ "$GFX_INFO" = "" ]; then
    GFX_INFO="(n/a)"
fi
if [ "$MEM_INFO" = "" ]; then
    MEM_INFO="(n/a)"
fi
if [ "$PACKAGES" = "" ]; then
    PACKAGES="(n/a)"
fi
if [ "$UPTIME" = "" ]; then
    UPTIME="(n/a)"
fi

HEADER="${BOLD}${USER_NAME}${RESET}@${BOLD}${HOST_NAME}${RESET}"

TMPDIR=${TMPDIR:-/tmp}
ASCII_FILE="$TMPDIR/irixfetch_ascii.$$"
INFO_FILE="$TMPDIR/irixfetch_info.$$"
trap 'rm -f "$ASCII_FILE" "$INFO_FILE"' 0 1 2 3 15

cat <<EOF > "$ASCII_FILE"
${C1}         _______${RESET}
${C1}      .-'  _   '-.${RESET}
${C1}    .'   (_)     '.${RESET}
${C1}   /   .-----.     \\${RESET}
${C2}  ;   /  _   \\     ;${RESET}
${C2}  |  ;  (_)   ;    |${RESET}
${C2}  |  |         |   |${RESET}
${C2}  |  ;  _____  ;   |${RESET}
${C3}  ;   \\       /    ;${RESET}
${C3}   \\   '.___.'    /${RESET}
${C3}    '.         .'${RESET}
${C3}      '-.___.-'${RESET}

EOF

cat <<EOF > "$INFO_FILE"
${HEADER}
${BOLD}OS${RESET}: ${OS_DISPLAY}
${BOLD}Model${RESET}: ${MODEL}
${BOLD}CPU${RESET}: ${CPU_INFO}
${BOLD}Graphics${RESET}: ${GFX_INFO}
${BOLD}Memory${RESET}: ${MEM_INFO}
${BOLD}Packages${RESET}: ${PACKAGES}
${BOLD}Uptime${RESET}: ${UPTIME}
${BOLD}Shell${RESET}: ${SHELL_NAME}
${BOLD}Terminal${RESET}: ${TERM_INFO}
EOF

awk -v width=36 '
    FNR==NR { ascii[FNR]=$0; ascii_count=FNR; next }
    { info[FNR]=$0; info_count=FNR }
    END {
        if (ascii_count=="") ascii_count=0
        if (info_count=="") info_count=0
        lines = ascii_count
        if (info_count > lines) lines = info_count
        for (i=1; i<=lines; i++) {
            a = ascii[i]
            info_line = info[i]
            if (info_line == "" || info_line == "\r") {
                if (a != "") {
                    printf "%s\n", a
                }
            } else if (a == "" || a == "\r") {
                printf "%-*s  %s\n", width, "", info_line
            } else {
                printf "%-*s  %s\n", width, a, info_line
            }
        }
    }
' "$ASCII_FILE" "$INFO_FILE"
