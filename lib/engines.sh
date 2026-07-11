#!/usr/bin/env bash
# engines.sh — one function per backend tool. Each takes <src> <dst> and writes
# a metadata-free copy to <dst>, leaving <src> untouched. Return 0 on success.

# Images: exiftool. Optionally re-add the colour profile so tones don't shift.
engine_image() {
  local src="$1" dst="$2"
  cp -p "$src" "$dst" || return 1
  if [ "$STRIPKIT_KEEP_ICC" = "1" ]; then
    exiftool -q -all= -tagsFromFile @ -ColorSpaceTags -overwrite_original "$dst" >/dev/null 2>&1
  else
    exiftool -q -all= -overwrite_original "$dst" >/dev/null 2>&1
  fi
}

# Video: ffmpeg lossless remux — drops container metadata, no re-encode.
engine_video() {
  local src="$1" dst="$2"
  ffmpeg -nostdin -y -loglevel error -i "$src" \
    -map_metadata -1 -map_chapters -1 -c copy "$dst" >/dev/null 2>&1
}

# PDF: exiftool clears the DocInfo/XMP, then qpdf --linearize rebuilds the file
# so unreferenced metadata and old incremental-save revisions are physically gone.
engine_pdf() {
  local src="$1" dst="$2" tmp="${2}.tmp"
  cp -p "$src" "$tmp" || return 1
  exiftool -q -all= -overwrite_original "$tmp" >/dev/null 2>&1
  qpdf --linearize "$tmp" "$dst" >/dev/null 2>&1
  local rc=$?
  rm -f "$tmp"
  return $rc
}
