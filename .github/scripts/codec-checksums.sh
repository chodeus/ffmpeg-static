#!/usr/bin/env bash
# Rewrite linux/Dockerfile's <LIB>_SHA256 for each <LIB>_VERSION that differs from <base-ref>; prints what changed.
# Unchanged versions are never re-hashed, so a tarball swapped upstream still fails the build's sha256sum -c.
set -euo pipefail

dockerfile=linux/Dockerfile
base=${1:?usage: codec-checksums.sh <base-ref>}
base_file=$(git show "${base}:${dockerfile}")

while IFS='=' read -r var ver; do
  lib=${var%_VERSION}
  grep -q "^ARG ${lib}_SHA256=" "$dockerfile" || continue
  old=$(sed -n "s/^ARG ${var}=//p" <<<"$base_file")
  [ "$ver" = "$old" ] && continue

  template=$(grep -oE "https://[^\"]*\\\$\\{${var}\\}[^\"]*" "$dockerfile" | head -1 || true)
  if [ -z "$template" ]; then
    echo "::error::no download URL in ${dockerfile} uses \${${var}}" >&2
    exit 1
  fi
  url=${template//"\${${var}}"/$ver}
  sha=$(curl -fsSL --retry 3 "$url" | sha256sum | cut -d' ' -f1)

  sed "s/^ARG ${lib}_SHA256=.*/ARG ${lib}_SHA256=${sha}/" "$dockerfile" > "${dockerfile}.tmp"
  mv "${dockerfile}.tmp" "$dockerfile"
  echo "${lib} ${old:-unset} -> ${ver}"
done < <(sed -n 's/^ARG \([A-Z0-9_]*_VERSION\)=\(.*\)$/\1=\2/p' "$dockerfile")
