# NOTICE — FFmpeg redistribution

This repository publishes static FFmpeg binaries from two pipelines with two
licenses.

## Linux binaries (`*-linux64`, `*-linuxarm64`) — LGPL-3.0-or-later

Compiled **from source** by [`linux/Dockerfile`](linux/Dockerfile) in this
repository — no third-party binary is involved. FFmpeg is built `--disable-gpl`
(no GPL components, no x264/x265) with `--enable-version3`, linking only
LGPL/BSD audio libraries, so the result is **LGPL-3.0-or-later**.

**Corresponding source (LGPLv3):**
- **FFmpeg** at the release tag built (e.g. `n8.1.1`):
  https://github.com/FFmpeg/FFmpeg
- **Audio libraries**, at the versions pinned in `linux/Dockerfile`:
  libmp3lame (LGPL), libogg + libvorbis (BSD), libopus (BSD),
  opencore-amr (Apache-2.0) — each from its official upstream.
- **The exact build recipe** is `linux/Dockerfile` in this repository, with all
  versions and SHA-256 checksums pinned inline.

## Windows binaries (`*-win64.exe`, `*-winarm64.exe`) — GPL-3.0

Mirrored **unmodified** from [BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds)
(`--enable-gpl`), verified against BtbN's published `checksums.sha256`.

**Corresponding source (GPLv3):**
- **FFmpeg** at the matching release tag: https://github.com/FFmpeg/FFmpeg
- **BtbN build scripts**: https://github.com/BtbN/FFmpeg-Builds

We never mirror `--enable-nonfree` builds (those are not redistributable).

FFmpeg is a trademark of Fabrice Bellard. This project is not affiliated with
the FFmpeg project or with BtbN.
