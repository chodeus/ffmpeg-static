# Fully-static, audio-focused FFmpeg built from pinned upstream source.
#
# A fully-static binary (no ELF interpreter) runs on BOTH musl (Alpine) and
# glibc (Debian/Ubuntu) — which is what our consumers need (hotio/lidarr and
# beatscheck are Alpine/musl). Everything is compiled from official source at
# pinned versions with SHA-256-verified tarballs, so the trust boundary is
# upstream source + this script only — no third-party binaries.
#
# LGPL: only LGPL/BSD audio libraries are linked (no --enable-gpl, no x264/x265),
# so the result is LGPL-3.0-or-later.

# Pinned by digest (multi-arch manifest) so a moved 'alpine:3.21' tag can't
# inject anything. Renovate keeps the digest current.
FROM alpine:3.21@sha256:48b0309ca019d89d40f670aa1bc06e426dc0931948452e8491e3d65087abc07d AS build

# Pinned upstream versions.
ARG FFMPEG_TAG=n8.1.1
ARG LAME_VERSION=3.100
ARG OGG_VERSION=1.3.5
ARG VORBIS_VERSION=1.3.7
ARG OPUS_VERSION=1.5.2
ARG OPENCORE_AMR_VERSION=0.1.6

# SHA-256 of each source tarball (verified before building).
ARG LAME_SHA256=ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e
ARG OGG_SHA256=c4d91be36fc8e54deae7575241e03f4211eb102afb3fc0775fbbc1b740016705
ARG VORBIS_SHA256=b33cc4934322bcbf6efcbacf49e3ca01aadbea4114ec9589d1b1e9d20f72954b
ARG OPUS_SHA256=65c1d2f78b9f2fb20082c38cbe47c951ad5839345876e46941612ee87f9a7ce1
ARG OPENCORE_AMR_SHA256=483eb4061088e2b34b358e47540b5d495a96cd468e361050fae615b1809dc4a1

RUN apk add --no-cache \
    build-base cmake nasm yasm pkgconf git curl tar xz \
    autoconf automake libtool

ENV PREFIX=/opt/ffbuild
ENV PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig
WORKDIR /src

# Helper: download a tarball, verify its SHA-256, extract it.
# Usage handled inline per-library below.

# --- libmp3lame (LGPL) — MP3 encoding ---
RUN curl -fsSL "https://downloads.sourceforge.net/project/lame/lame/${LAME_VERSION}/lame-${LAME_VERSION}.tar.gz" -o lame.tar.gz \
 && echo "${LAME_SHA256}  lame.tar.gz" | sha256sum -c - \
 && tar xf lame.tar.gz && cd "lame-${LAME_VERSION}" \
 && ./configure --prefix="${PREFIX}" --enable-static --disable-shared --disable-frontend \
 && make -j"$(nproc)" && make install

# --- libogg (BSD) — container for Vorbis ---
RUN curl -fsSL "https://downloads.xiph.org/releases/ogg/libogg-${OGG_VERSION}.tar.xz" -o ogg.tar.xz \
 && echo "${OGG_SHA256}  ogg.tar.xz" | sha256sum -c - \
 && tar xf ogg.tar.xz && cd "libogg-${OGG_VERSION}" \
 && ./configure --prefix="${PREFIX}" --enable-static --disable-shared \
 && make -j"$(nproc)" && make install

# --- libvorbis (BSD) — Vorbis encoding ---
RUN curl -fsSL "https://downloads.xiph.org/releases/vorbis/libvorbis-${VORBIS_VERSION}.tar.xz" -o vorbis.tar.xz \
 && echo "${VORBIS_SHA256}  vorbis.tar.xz" | sha256sum -c - \
 && tar xf vorbis.tar.xz && cd "libvorbis-${VORBIS_VERSION}" \
 && ./configure --prefix="${PREFIX}" --enable-static --disable-shared \
 && make -j"$(nproc)" && make install

# --- libopus (BSD) — Opus encoding/decoding ---
RUN curl -fsSL "https://downloads.xiph.org/releases/opus/opus-${OPUS_VERSION}.tar.gz" -o opus.tar.gz \
 && echo "${OPUS_SHA256}  opus.tar.gz" | sha256sum -c - \
 && tar xf opus.tar.gz && cd "opus-${OPUS_VERSION}" \
 && ./configure --prefix="${PREFIX}" --enable-static --disable-shared \
 && make -j"$(nproc)" && make install

# --- opencore-amr (Apache-2.0) — AMR-NB encoding (Sleezer AMR target) ---
RUN curl -fsSL "https://downloads.sourceforge.net/opencore-amr/opencore-amr-${OPENCORE_AMR_VERSION}.tar.gz" -o amr.tar.gz \
 && echo "${OPENCORE_AMR_SHA256}  amr.tar.gz" | sha256sum -c - \
 && tar xf amr.tar.gz && cd "opencore-amr-${OPENCORE_AMR_VERSION}" \
 && ./configure --prefix="${PREFIX}" --enable-static --disable-shared \
 && make -j"$(nproc)" && make install

# --- FFmpeg (LGPL) — pinned release tag from the official repo ---
RUN git clone --depth 1 --branch "${FFMPEG_TAG}" https://github.com/FFmpeg/FFmpeg.git ffmpeg \
 && cd ffmpeg \
 && ./configure \
      --prefix="${PREFIX}" \
      --pkg-config-flags=--static \
      --extra-cflags="-I${PREFIX}/include" \
      --extra-ldflags="-L${PREFIX}/lib -static" \
      --extra-libs="-lm" \
      --enable-static --disable-shared \
      --disable-debug --disable-doc --disable-ffplay \
      --enable-version3 \
      --enable-libmp3lame --enable-libopus --enable-libvorbis \
      --enable-libopencore-amrnb --enable-libopencore-amrwb \
 && make -j"$(nproc)" \
 && make install \
 && strip "${PREFIX}/bin/ffmpeg" "${PREFIX}/bin/ffprobe"

# --- Self-test on a CLEAN Alpine (musl, no build deps): proves the binary is
#     fully static and actually runs with nothing else installed. ---
FROM alpine:3.21@sha256:48b0309ca019d89d40f670aa1bc06e426dc0931948452e8491e3d65087abc07d AS test
COPY --from=build /opt/ffbuild/bin/ffmpeg /opt/ffbuild/bin/ffprobe /usr/local/bin/
RUN set -eux; \
    file=$(command -v file || true); \
    apk add --no-cache file >/dev/null; \
    file /usr/local/bin/ffmpeg | grep -q "statically linked" \
      || { echo "NOT statically linked!"; file /usr/local/bin/ffmpeg; exit 1; }; \
    ffmpeg -hide_banner -version | head -1; \
    ffprobe -hide_banner -version | head -1; \
    ffmpeg -hide_banner -f lavfi -i "sine=frequency=440:duration=1" -c:a libopus /tmp/o.opus -y >/dev/null 2>&1; \
    ffmpeg -hide_banner -f lavfi -i "sine=frequency=440:duration=1" -c:a libmp3lame /tmp/o.mp3 -y >/dev/null 2>&1; \
    ffmpeg -hide_banner -f lavfi -i "sine=frequency=440:duration=1" -c:a flac /tmp/o.flac -y >/dev/null 2>&1; \
    ffmpeg -hide_banner -f lavfi -i "sine=frequency=440:duration=1" -c:a alac /tmp/o.m4a -y >/dev/null 2>&1; \
    ffmpeg -hide_banner -f lavfi -i "sine=frequency=440:duration=1" -c:a aac /tmp/o.aac -y >/dev/null 2>&1; \
    ffmpeg -hide_banner -f lavfi -i "sine=frequency=440:duration=1" -ar 8000 -ac 1 -c:a libopencore_amrnb -b:a 12.2k /tmp/o.amr -y >/dev/null 2>&1; \
    ffmpeg -v error -xerror -nostdin -i /tmp/o.flac -map 0:a -f null -; \
    echo "STATIC + RUNS-ON-MUSL + ENCODE(opus/mp3/flac/alac/aac/amrnb)/DECODE OK"

# --- Export stage: raw binaries only, for `--output type=local`. ---
FROM scratch AS export
COPY --from=build /opt/ffbuild/bin/ffmpeg /opt/ffbuild/bin/ffprobe /
