# ffmpeg-static

A single source of truth for **static FFmpeg binaries**, mirrored from the
FFmpeg-project-recommended builder [BtbN/FFmpeg-Builds][btbn] and republished as
raw, per-platform `ffmpeg` / `ffprobe` executables with **our own checksums**.

Consumed by:

- **[sleezer](https://github.com/chodeus/sleezer)** — downloads the matching
  binary at runtime (auto-updating).
- **[beatscheck](https://github.com/chodeus/beatscheck)** — `COPY`s it in at
  Docker build time.

## Why this exists

Both projects need a current FFmpeg (8.x) and need to *stay* current, on
platforms where the host may ship nothing or an ancient build. Rather than each
project trusting and verifying a third-party binary independently, they consume
**one mirror we control**: same version, one bump point, checksums we generate.

## How it works

The [`mirror`](.github/workflows/mirror.yml) workflow runs daily (and on
demand):

1. Downloads BtbN's static **GPL** builds for the pinned release branch
   (default `n8.1` → latest 8.1.x).
2. **Verifies them against BtbN's published `checksums.sha256`.**
3. Extracts just `ffmpeg` + `ffprobe`, republishes them as **raw binaries**
   (no archive — consumers need no `.tar.xz` / `.zip` handling).
4. Detects the real version from the binary and publishes a GitHub release
   tagged `n<version>` (e.g. `n8.1.1`), marked **latest**, with a
   `SHA256SUMS` we generate.

Patch updates within the pinned branch (8.1.1 → 8.1.2) are picked up
automatically. Moving to a new minor/major (8.1 → 8.2) is a deliberate one-line
change: bump the `branch` input default in the workflow, or run it manually
with `branch: n8.2`.

## Release assets

Each release (`n<version>`) contains raw executables plus `SHA256SUMS`:

| Asset | Platform |
|-------|----------|
| `ffmpeg-linux64`, `ffprobe-linux64` | Linux x86-64 |
| `ffmpeg-linuxarm64`, `ffprobe-linuxarm64` | Linux ARM64 |
| `ffmpeg-win64.exe`, `ffprobe-win64.exe` | Windows x86-64 |
| `ffmpeg-winarm64.exe`, `ffprobe-winarm64.exe` | Windows ARM64 |
| `SHA256SUMS` | checksums for all of the above |

> macOS is intentionally absent — BtbN publishes no macOS build. Consumers fall
> back to a system/Homebrew `ffmpeg` on macOS.

### Consuming a release

```sh
# Latest version + asset for Linux x86-64
gh release download -R chodeus/ffmpeg-static --pattern 'ffmpeg-linux64' --pattern 'SHA256SUMS'
sha256sum --ignore-missing -c SHA256SUMS   # verify before use
chmod +x ffmpeg-linux64
```

To discover the current version programmatically, read the tag of the latest
release: `gh release view -R chodeus/ffmpeg-static --json tagName`.

## Licensing

These are GPLv3 static builds. Redistribution is permitted under the GPL; see
[LICENSE](LICENSE) for the license text and [NOTICE.md](NOTICE.md) for
provenance and the GPL "corresponding source" pointers. Only `-gpl` (never
`-nonfree`) builds are mirrored.

[btbn]: https://github.com/BtbN/FFmpeg-Builds
