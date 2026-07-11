#!/usr/bin/env bash
# config.sh — defaults and constants. Every value is overridable via the
# environment, so users can tune behaviour without editing the source.
# Values here are consumed by the other sourced lib files, not this one.
# shellcheck disable=SC2034

# Where the watch-folder mode looks for dropped files.
STRIPKIT_WATCH_DIR="${STRIPKIT_WATCH_DIR:-$HOME/Strip}"

# Subfolder names used by both watch mode (inside WATCH_DIR) and file mode
# (created next to each source file).
STRIPKIT_OUT_DIR="${STRIPKIT_OUT_DIR:-stripped}"
STRIPKIT_ORIG_DIR="${STRIPKIT_ORIG_DIR:-originals}"
STRIPKIT_SKIP_DIR="${STRIPKIT_SKIP_DIR:-skipped}"

# Shared log file.
STRIPKIT_LOG="${STRIPKIT_LOG:-$HOME/Library/Logs/stripkit.log}"

# Behaviour flags (1 = on, 0 = off).
STRIPKIT_KEEP_ICC="${STRIPKIT_KEEP_ICC:-1}"      # preserve colour profile when stripping images
STRIPKIT_CLEAR_XATTR="${STRIPKIT_CLEAR_XATTR:-1}" # also clear macOS extended attributes (download origin, tags)
STRIPKIT_FAIL_CLOSED="${STRIPKIT_FAIL_CLOSED:-1}" # if a privacy tag survives, discard the output instead of emitting it
STRIPKIT_NOTIFY="${STRIPKIT_NOTIFY:-1}"          # post macOS notifications

# File-type groups (space-separated, lowercase, no dot).
STRIPKIT_EXT_IMAGE="jpg jpeg png webp tif tiff heic heif gif"
STRIPKIT_EXT_VIDEO="mp4 mov m4v mkv webm avi"
STRIPKIT_EXT_PDF="pdf"
STRIPKIT_EXT_RAW="cr2 cr3 nef arw dng orf rw2 raf"   # refused: stripping breaks rendering

# Tags treated as privacy-relevant for the verification pass.
STRIPKIT_RISKY_TAGS="-GPS:all -Make -Model -SerialNumber -InternalSerialNumber \
-OwnerName -Artist -Author -Creator -Producer -Software -HostComputer \
-XMP:all -IPTC:all"
