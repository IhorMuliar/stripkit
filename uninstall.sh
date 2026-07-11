#!/usr/bin/env bash
# uninstall.sh — remove everything install.sh created. Leaves the watch folder
# and its contents in place (your files); delete ~/Strip yourself if you want.
set -euo pipefail

BIN_DIR="$HOME/.local/bin"
SERVICES_DIR="$HOME/Library/Services"
AGENTS_DIR="$HOME/Library/LaunchAgents"

say() { printf '  %s\n' "$1"; }
echo "Uninstalling stripkit"

launchctl bootout "gui/$(id -u)/com.stripkit.watch" 2>/dev/null || true
rm -f "$AGENTS_DIR/com.stripkit.watch.plist"
say "removed watch agent"

rm -rf "$SERVICES_DIR/Strip Metadata.workflow"
/System/Library/CoreServices/pbs -update 2>/dev/null || true
say "removed Finder Quick Action"

rm -f "$BIN_DIR/stripkit"
say "removed CLI symlink"

echo "Done. Your watch folder (~/Strip) and cleaned files were left untouched."
