#!/bin/bash

set -euo pipefail

SCRIPT_PATH="$(dirname "$0")"
PROJECT_ROOT="$(realpath "$SCRIPT_PATH/..")"
SRC_FILE="$PROJECT_ROOT/.output/HMCL.app"
OUT_FILE="$HOME/Applications/HMCL.app"
BAK_DIR="$PROJECT_ROOT/.backups/$(date +%Y%m%d%H%M%S)"
BAK_FILE="$BAK_DIR/HMCL.app"

mkdir -p "$BAK_DIR"

# 首先备份原来的 HMCL.app
if [[ -d "$OUT_FILE" ]]; then
  echo "Backing up $OUT_FILE to $BAK_FILE"
  mv "$OUT_FILE" "$BAK_FILE"
fi

# 然后安装新的 HMCL.app
echo "Installing $SRC_FILE to $OUT_FILE"
cp -r "$SRC_FILE" "$OUT_FILE"

# 复制 .hmcl 和 .minecraft 目录到新的 HMCL.app
if [[ -d "$BAK_FILE/Contents/Resources/.hmcl" ]]; then
  echo "Copying .hmcl from $BAK_FILE to $OUT_FILE"
  cp -r "$BAK_FILE/Contents/Resources/.hmcl" "$OUT_FILE/Contents/Resources/.hmcl"
fi
if [[ -d "$BAK_FILE/Contents/Resources/.minecraft" ]]; then
  echo "Copying .minecraft from $BAK_FILE to $OUT_FILE"
  cp -r "$BAK_FILE/Contents/Resources/.minecraft" "$OUT_FILE/Contents/Resources/.minecraft"
fi

echo "App installed at $OUT_FILE"
