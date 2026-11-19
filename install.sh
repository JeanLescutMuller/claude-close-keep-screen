#!/usr/bin/env bash
# install.sh - claude-close-keep-screen: deploy the command to ~/opt/claude-close-keep-screen and link it on the PATH.
#
#   ~/opt/claude-close-keep-screen/bin/claude-close-keep-screen   the deployed copy (from src/claude-close-keep-screen)
#   ~/opt/claude-close-keep-screen/{data,logs}/           screen files and the close log (kept by uninstall.sh)
#   ~/.local/bin/claude-close-keep-screen                 symlink to the deployed copy
#
# No scheduler is installed: when `claude-close-keep-screen idle` runs is not decided yet (README.md).
# Idempotent: safe to re-run at any time. Usage: bash install.sh
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPT="$HOME/opt/claude-close-keep-screen"
BIN_DIR="$HOME/.local/bin"
LINK="$BIN_DIR/claude-close-keep-screen"

command -v python3 >/dev/null || { echo "ERROR: python3 is required." >&2; exit 1; }

# Former name agent-auto-close (until 2026-11-19): its screen files and close log move here; its command and link go.
OLD="$HOME/opt/agent-auto-close"
if [[ -d "$OLD" ]]; then
    mkdir -p "$OPT"
    for d in data logs; do [[ -d "$OLD/$d" && ! -e "$OPT/$d" ]] && mv "$OLD/$d" "$OPT/$d"; done
    [[ -L "$BIN_DIR/agent-auto-close" ]] && rm -f "$BIN_DIR/agent-auto-close"
    rm -f "$OLD/bin/agent-auto-close"
    rm -f "$OLD/uninstall.sh"
    rmdir "$OLD/bin" "$OLD" 2>/dev/null || echo "NOTE: $OLD not empty, left as is." >&2
fi

mkdir -p "$OPT/bin" "$OPT/data/close-screens" "$OPT/logs" "$BIN_DIR"
# Copy through a temp file + rename, so a running command never reads a half-written file.
cp "$SRC/src/claude-close-keep-screen" "$OPT/bin/.claude-close-keep-screen.new"
chmod 755 "$OPT/bin/.claude-close-keep-screen.new"
mv -f "$OPT/bin/.claude-close-keep-screen.new" "$OPT/bin/claude-close-keep-screen"
cp "$SRC/uninstall.sh" "$OPT/uninstall.sh"

# A real file at the link path is not ours to replace: keep it and warn.
if [[ -e "$LINK" && ! -L "$LINK" ]]; then
    echo "WARNING: $LINK is a real file, not a link: left as is; remove it, then re-run." >&2
else
    ln -sfn "$OPT/bin/claude-close-keep-screen" "$LINK"
fi

case ":$PATH:" in *":$BIN_DIR:"*) ;; *) echo "NOTE: $BIN_DIR is not on your PATH." ;; esac
echo "Installed claude-close-keep-screen $("$OPT/bin/claude-close-keep-screen" --version | awk '{print $2}') in $OPT (link: $LINK)."
