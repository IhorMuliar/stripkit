#!/usr/bin/env bash
# install.sh — set up stripkit on macOS:
#   1. symlink bin/stripkit into ~/.local/bin
#   2. install the Finder "Strip Metadata" Quick Action
#   3. (optional) load the launchd watch-folder agent
#
# Usage:
#   ./install.sh              full install (CLI + Quick Action + watch folder)
#   ./install.sh --no-watch   skip the watch-folder agent
set -euo pipefail

REPO=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BIN_DIR="$HOME/.local/bin"
SERVICES_DIR="$HOME/Library/Services"
AGENTS_DIR="$HOME/Library/LaunchAgents"
WATCH_DIR="${STRIPKIT_WATCH_DIR:-$HOME/Strip}"
WANT_WATCH=1
[ "${1:-}" = "--no-watch" ] && WANT_WATCH=0

say() { printf '  %s\n' "$1"; }

echo "Installing stripkit from $REPO"

# 1. dependencies -------------------------------------------------------------
missing=()
for t in exiftool ffmpeg qpdf; do command -v "$t" >/dev/null 2>&1 || missing+=("$t"); done
if [ ${#missing[@]} -gt 0 ]; then
  if command -v brew >/dev/null 2>&1; then
    say "installing dependencies: ${missing[*]}"
    brew install "${missing[@]}"
  else
    echo "Missing: ${missing[*]}. Install Homebrew (https://brew.sh) or these tools, then re-run." >&2
    exit 1
  fi
fi

# 2. CLI symlink --------------------------------------------------------------
mkdir -p "$BIN_DIR"
chmod +x "$REPO/bin/stripkit"
ln -sfn "$REPO/bin/stripkit" "$BIN_DIR/stripkit"
say "linked $BIN_DIR/stripkit"
case ":$PATH:" in
  *":$BIN_DIR:"*) : ;;
  *) say "note: add $BIN_DIR to your PATH to run 'stripkit' directly" ;;
esac

# 3. Finder Quick Action ------------------------------------------------------
mkdir -p "$SERVICES_DIR"
rm -rf "$SERVICES_DIR/Strip Metadata.workflow"
cp -R "$REPO/integrations/quickaction/Strip Metadata.workflow" "$SERVICES_DIR/"
/System/Library/CoreServices/pbs -update 2>/dev/null || true
say "installed Finder Quick Action 'Strip Metadata'"

# 4. watch-folder agent -------------------------------------------------------
if [ "$WANT_WATCH" = "1" ]; then
  mkdir -p "$WATCH_DIR" "$AGENTS_DIR"
  plist="$AGENTS_DIR/com.stripkit.watch.plist"
  sed -e "s#__STRIPKIT_BIN__#$BIN_DIR/stripkit#g" \
      -e "s#__WATCH_DIR__#$WATCH_DIR#g" \
      -e "s#__HOME__#$HOME#g" \
      "$REPO/integrations/launchd/com.stripkit.watch.plist.template" > "$plist"
  launchctl bootout "gui/$(id -u)/com.stripkit.watch" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$plist"
  say "watch folder active: $WATCH_DIR"
fi

cat <<EOF

Done.
  Drop files into      $WATCH_DIR
  or right-click files → Quick Actions → Strip Metadata
  or run               stripkit <file>...   /   stripkit inspect <file>

If the Quick Action doesn't appear: System Settings → Keyboard →
Keyboard Shortcuts → Services → Files and Folders → enable "Strip Metadata".
EOF
