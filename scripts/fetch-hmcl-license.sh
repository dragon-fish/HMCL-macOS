#!/bin/bash

set -euo pipefail

SCRIPT_PATH="$(dirname "$0")"
PROJECT_ROOT="$(realpath "$SCRIPT_PATH/..")"

CACHE_DIR="$PROJECT_ROOT/.cache"
OUT_FILE="$CACHE_DIR/LICENSE-HMCL.txt"

# 上游仓库 LICENSE（raw）
LICENSE_URL="https://raw.githubusercontent.com/HMCL-dev/HMCL/main/LICENSE"

mkdir -p "$CACHE_DIR"

if [[ -f "$OUT_FILE" ]]; then
  echo "Cached HMCL license already exists, skipping download: $OUT_FILE"
  exit 0
fi

echo "Downloading HMCL LICENSE to cache: $OUT_FILE"
curl -fL --retry 3 --retry-delay 1 -o "$OUT_FILE" "$LICENSE_URL"

echo "Done."

