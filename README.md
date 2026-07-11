# stripkit

Strip metadata from images, videos and PDFs on macOS. Three ways to use it: a
drop folder, a Finder right-click, and a CLI — all sharing one engine.

Photos and videos carry GPS coordinates, device model and serial, timestamps
and software fingerprints. PDFs carry author names, editing tools and old
revisions. stripkit removes them before you share.

## What it does

| Type | Tool | Method |
|------|------|--------|
| Images (jpg, png, webp, heic, tiff, gif) | exiftool | remove EXIF/IPTC/XMP, keep colour profile |
| Video (mp4, mov, mkv, webm, avi) | ffmpeg | lossless remux, no re-encode |
| PDF | exiftool + qpdf | clear DocInfo/XMP, rebuild to drop old revisions |
| RAW (cr2, nef, arw, dng…) | — | refused (stripping breaks rendering) |

Originals are never modified. After stripping, each file is re-read and — if any
GPS, serial or author tag survived — the output is discarded rather than shipped.

## Install

Requires [Homebrew](https://brew.sh). The installer pulls in `exiftool`,
`ffmpeg` and `qpdf` if missing.

```sh
git clone https://github.com/IhorMuliar/stripkit
cd stripkit
./install.sh
```

This links the `stripkit` command, installs the Finder Quick Action, and starts
the watch folder at `~/Strip`. Use `./install.sh --no-watch` to skip the folder.

## Use

**Drop folder** — drop files into `~/Strip`. Cleaned copies appear in
`~/Strip/stripped/`, originals move to `~/Strip/originals/`, unsupported files to
`~/Strip/skipped/`.

**Finder** — select files, right-click → Quick Actions → Strip Metadata. Clean
copies go to a `stripped/` folder next to the originals.

**CLI**
```sh
stripkit photo.jpg clip.mov doc.pdf   # clean copies → ./stripped/
stripkit inspect photo.jpg            # show what metadata is present
stripkit watch                        # process the watch folder now
```

## Configure

Override defaults with environment variables (see `lib/config.sh`):

| Variable | Default | Purpose |
|----------|---------|---------|
| `STRIPKIT_WATCH_DIR` | `~/Strip` | watch-folder location |
| `STRIPKIT_KEEP_ICC` | `1` | keep colour profile on images |
| `STRIPKIT_FAIL_CLOSED` | `1` | discard output if a privacy tag survives |
| `STRIPKIT_CLEAR_XATTR` | `1` | also clear macOS extended attributes |
| `STRIPKIT_NOTIFY` | `1` | macOS notifications |

## Uninstall

```sh
./uninstall.sh
```

Removes the command, Quick Action and watch agent. Your files are left alone.

## Layout

```
bin/stripkit          CLI entry point and command dispatch
lib/config.sh         defaults and file-type groups
lib/engines.sh        exiftool / ffmpeg / qpdf wrappers
lib/core.sh           dispatch, verification, logging
integrations/         launchd watch agent + Finder Quick Action
Formula/stripkit.rb   Homebrew formula
```

## License

MIT
