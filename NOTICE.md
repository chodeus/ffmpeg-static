# NOTICE — FFmpeg redistribution

The release binaries published by this repository are **unmodified** FFmpeg
executables produced by the FFmpeg-project-recommended builder
[BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds), configured with
`--enable-gpl`. They are therefore licensed under the **GNU General Public
License, version 3** (see [LICENSE](LICENSE)).

## Corresponding source (GPLv3 §6)

These are static builds of FFmpeg. The complete corresponding source is:

- **FFmpeg source**, at the git tag matching the version in each release
  (e.g. release `n8.1.1` → FFmpeg tag `n8.1.1`):
  - https://github.com/FFmpeg/FFmpeg (tag `n<version>`)
  - https://git.ffmpeg.org/ffmpeg.git
- **Build scripts / configuration** used to compile these binaries:
  - https://github.com/BtbN/FFmpeg-Builds

We redistribute the binaries unmodified. To obtain the exact source for any
binary here, check out the FFmpeg tag equal to that release's version together
with the BtbN build scripts as of the mirror date noted in the release body.

## What this repository adds

We do not modify the binaries. The mirror workflow only:

1. Downloads BtbN's static GPL builds and **verifies them against BtbN's own
   published `checksums.sha256`**.
2. Repackages the `ffmpeg` / `ffprobe` executables as raw per-platform assets
   (no `.tar.xz` / `.zip` wrapper — so consumers need no archive handling).
3. Publishes **our own `SHA256SUMS`** for downstream verification.

We never mirror `--enable-nonfree` builds (those are not redistributable); only
the `-gpl` static builds are used.

FFmpeg is a trademark of Fabrice Bellard. This project is not affiliated with
the FFmpeg project or with BtbN.
