#!/bin/bash

set -euo pipefail

SCRIPT_PATH="$(dirname "$0")"
PROJECT_ROOT="$(realpath "$SCRIPT_PATH/..")"

echo "==> 1) 通过 API 查找并缓存下载最新 HMCL jar"
"$PROJECT_ROOT/scripts/fetch-latest-jar.sh"

echo "==> 1.5) 缓存上游 LICENSE（用于随 dmg 一并分发）"
"$PROJECT_ROOT/scripts/fetch-hmcl-license.sh"

echo "==> 2) 由 icon/HMCL.png 生成 icns"
"$PROJECT_ROOT/scripts/make-icon.sh" "$PROJECT_ROOT/icon/HMCL.png"

echo "==> 3) 创建 HMCL.app（复制 jar/icns 到 Resources）"
"$PROJECT_ROOT/scripts/make-app.sh" \
  --jar "$PROJECT_ROOT/.cache/HMCL-latest.jar" \
  --icon "$PROJECT_ROOT/.output/HMCL.icns"

echo "==> 4) 创建 dmg"
"$PROJECT_ROOT/scripts/make-dmg.sh" \
  --app "$PROJECT_ROOT/.output/HMCL.app" \
  --out "$PROJECT_ROOT/.output/HMCL.dmg" \
  --volname HMCL

echo "All done:"
echo "  App: $PROJECT_ROOT/.output/HMCL.app"
echo "  DMG: $PROJECT_ROOT/.output/HMCL.dmg"

