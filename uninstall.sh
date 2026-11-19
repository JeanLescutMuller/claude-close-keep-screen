#!/usr/bin/env bash
# uninstall.sh - claude-close-keep-screen: remove the PATH link and the deployed copy.
# Keeps ~/opt/claude-close-keep-screen/data and logs (screen files, close log): delete them by hand if wanted.
# Usage: bash uninstall.sh
set -euo pipefail

OPT="$HOME/opt/claude-close-keep-screen"
LINK="$HOME/.local/bin/claude-close-keep-screen"

# Remove the link only if it points into our deployed copy.
if [[ -L "$LINK" && "$(readlink "$LINK")" == "$OPT/"* ]]; then
    rm -f "$LINK"
fi
if [[ -f "$OPT/bin/claude-close-keep-screen" ]]; then
    rm -f "$OPT/bin/claude-close-keep-screen"
fi
rmdir "$OPT/bin" 2>/dev/null || true
if [[ -f "$OPT/uninstall.sh" ]]; then
    rm -f "$OPT/uninstall.sh"
fi
echo "Uninstalled claude-close-keep-screen (kept: $OPT/data, $OPT/logs)."
