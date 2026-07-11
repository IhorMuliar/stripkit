#!/usr/bin/env bash
# core.sh — orchestration shared by every entry point. Depends on config.sh and
# engines.sh being sourced first.

skt_log() {
  [ -n "${_skt_log_ready:-}" ] || { mkdir -p "${STRIPKIT_LOG%/*}"; _skt_log_ready=1; }
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$STRIPKIT_LOG"
}

skt_notify() {
  # skt_notify <title> <message>
  [ "$STRIPKIT_NOTIFY" = "1" ] || return 0
  command -v osascript >/dev/null 2>&1 || return 0
  osascript -e "display notification \"$2\" with title \"$1\"" >/dev/null 2>&1
}

# Classify a file by extension → image | video | pdf | raw | unsupported.
# Drives off the STRIPKIT_EXT_<KIND> groups so a new type is a config-only change.
skt_kind() {
  local lc pair exts e
  lc=$(printf '%s' "${1##*.}" | tr '[:upper:]' '[:lower:]')
  for pair in "image:$STRIPKIT_EXT_IMAGE" "video:$STRIPKIT_EXT_VIDEO" \
              "pdf:$STRIPKIT_EXT_PDF" "raw:$STRIPKIT_EXT_RAW"; do
    exts="${pair#*:}"
    for e in $exts; do
      [ "$lc" = "$e" ] && { echo "${pair%%:*}"; return; }
    done
  done
  echo unsupported
}

# Count privacy-relevant tags remaining in a file (verification).
skt_risky_tags() {
  # shellcheck disable=SC2086
  exiftool -q -q $STRIPKIT_RISKY_TAGS -s -s "$1" 2>/dev/null | wc -l | tr -d ' '
}

# Collision-safe destination path: <dir>/<base>, else <dir>/<stem>_N.<ext>
skt_dest() {
  local dir="$1" base="$2" stem ext n=1 cand="$1/$2"
  [ ! -e "$cand" ] && { printf '%s' "$cand"; return; }
  stem="${base%.*}"; ext="${base##*.}"
  while :; do
    cand="$dir/${stem}_$n.$ext"
    [ ! -e "$cand" ] && { printf '%s' "$cand"; return; }
    n=$((n+1))
  done
}

# Block until a file's size stops changing (guards against still-copying files).
# Returns 1 if it never settles or vanishes.
skt_wait_stable() {
  local f="$1" prev=-1 size i
  for ((i = 0; i < 30; i++)); do
    size=$(stat -f %z "$f" 2>/dev/null) || return 1
    [ "$size" = "$prev" ] && [ "$size" != "0" ] && return 0
    prev=$size
    sleep 2
  done
  return 1
}

# Strip one file. Writes the clean copy into <outdir> and echoes a status word:
#   cleaned · skipped (raw/unsupported) · failed
skt_strip_one() {
  local src="$1" outdir="$2" base kind out after
  base="${src##*/}"
  kind=$(skt_kind "$base")

  case "$kind" in
    raw)         skt_log "REFUSED (raw): $src";      echo skipped; return ;;
    unsupported) skt_log "SKIP (unsupported): $src"; echo skipped; return ;;
  esac

  mkdir -p "$outdir"
  out=$(skt_dest "$outdir" "$base")

  # Engines are named engine_<kind>, matching what skt_kind returns.
  if ! "engine_$kind" "$src" "$out" || [ ! -s "$out" ]; then
    rm -f "$out"; skt_log "FAILED: $src"; echo failed; return
  fi

  after=$(skt_risky_tags "$out")

  # Fail-closed: never emit a file that still leaks a privacy tag.
  if [ "$STRIPKIT_FAIL_CLOSED" = "1" ] && [ "$after" != "0" ]; then
    rm -f "$out"
    skt_log "FAILED (residual $after tags): $src"
    echo failed; return
  fi

  [ "$STRIPKIT_CLEAR_XATTR" = "1" ] && xattr -c "$out" 2>/dev/null

  skt_log "CLEANED: $src ($after tags remain) -> $out"
  echo cleaned
}
