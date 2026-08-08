# ffmpeg-static

Static FFmpeg binaries for my own projects (sleezer, beatscheck).

The [build workflow](.github/workflows/mirror.yml) runs daily, auto-detects the
**newest stable FFmpeg release** from the official repo's tags, and publishes a
GitHub release tagged `n<version>` (e.g. `n8.1.1`) marked latest. New patch,
minor **and major** releases are picked up automatically — nothing to edit. The
run self-skips when the resulting `SHA256SUMS` is unchanged.

## How the binaries are produced

- **Linux** (`linux64`, `linuxarm64`) — compiled **fully-static from pinned
  upstream source** in an Alpine builder ([`linux/Dockerfile`](linux/Dockerfile)),
  on GitHub's native amd64/arm64 runners. A fully-static binary (no interpreter)
  runs on **both musl (Alpine) and glibc** — which is what the consumers need.
  Audio-focused (lame/opus/vorbis/opencore-amr + native aac/flac/alac/wma/ac3/
  pcm), **LGPL-3.0**. The build self-tests on clean Alpine that the binary is
  statically linked and actually encodes/decodes.
- **Windows** (`win64`, `winarm64`) — mirrored from the FFmpeg-project-recommended
  [BtbN/FFmpeg-Builds][btbn] (Windows has no musl/glibc issue), verified against
  BtbN's `checksums.sha256`, **GPL-3.0**.

Every download is SHA-256 verified, and we publish our own `SHA256SUMS`.

**Assets per release:** `ffmpeg` + `ffprobe` for `linux64`, `linuxarm64`,
`win64`, `winarm64`, plus `SHA256SUMS`. No macOS build. A brand-new FFmpeg
release ships Linux-first and gains its Windows binaries automatically once
[BtbN/FFmpeg-Builds][btbn] publishes that branch, which trails upstream by
a few weeks.

## Licensing

Linux binaries are **LGPL-3.0-or-later** (built from source; only LGPL/BSD
audio libraries linked — no GPL components). Windows binaries are **GPL-3.0**
(BtbN). See [LICENSE](LICENSE) (GPLv3), [COPYING.LGPL](COPYING.LGPL) (LGPLv3),
and [NOTICE.md](NOTICE.md) for provenance and corresponding source.

[btbn]: https://github.com/BtbN/FFmpeg-Builds
