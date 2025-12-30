#!/bin/bash

set -euo pipefail

SCRIPT_PATH="$(dirname "$0")"
PROJECT_ROOT="$(realpath "$SCRIPT_PATH/..")"

APP_PATH_DEFAULT="$PROJECT_ROOT/.output/HMCL.app"
OUT_DMG_DEFAULT="$PROJECT_ROOT/.output/HMCL.dmg"
VOLNAME_DEFAULT="HMCL"
INSTALL_MD_DEFAULT="$PROJECT_ROOT/INSTALLATION.md"
SOURCE_MD_DEFAULT="$PROJECT_ROOT/SOURCE_CODE.md"
HMCL_META_DEFAULT="$PROJECT_ROOT/.cache/hmcl-latest.json"
HMCL_LICENSE_DEFAULT="$PROJECT_ROOT/.cache/LICENSE-HMCL.txt"

print_help() {
  cat <<'EOF'
用法:
  ./scripts/make-dmg.sh [--app <path>] [--out <path>] [--volname <name>] [--installation <path>]

说明:
  - 默认 app:     ./.output/HMCL.app
  - 默认输出 dmg: ./.output/HMCL.dmg
  - dmg 内容包含: HMCL.app + /Applications 软链接（拖拽安装）
  - 并额外包含（若存在）:
    - INSTALLATION.md
    - SOURCE_CODE.md
    - HMCL-RELEASE.json（来自 .cache/hmcl-latest.json）
    - LICENSE-HMCL.txt（来自 .cache/LICENSE-HMCL.txt）
EOF
}

APP_PATH="$APP_PATH_DEFAULT"
OUT_DMG="$OUT_DMG_DEFAULT"
VOLNAME="$VOLNAME_DEFAULT"
INSTALL_MD="$INSTALL_MD_DEFAULT"
SOURCE_MD="$SOURCE_MD_DEFAULT"
HMCL_META="$HMCL_META_DEFAULT"
HMCL_LICENSE="$HMCL_LICENSE_DEFAULT"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      print_help
      exit 0
      ;;
    --app)
      shift
      APP_PATH="${1-}"
      ;;
    --out)
      shift
      OUT_DMG="${1-}"
      ;;
    --volname)
      shift
      VOLNAME="${1-}"
      ;;
    --installation)
      shift
      INSTALL_MD="${1-}"
      ;;
    *)
      echo "未知参数: $1" >&2
      print_help >&2
      exit 1
      ;;
  esac
  shift
done

if [[ -z "${APP_PATH:-}" || -z "${OUT_DMG:-}" || -z "${VOLNAME:-}" || -z "${INSTALL_MD:-}" ]]; then
  echo "参数缺失：--app/--out/--volname/--installation 需要跟值" >&2
  print_help >&2
  exit 1
fi

if [[ ! -d "$APP_PATH" ]]; then
  echo "App 不存在: $APP_PATH" >&2
  exit 1
fi

OUT_DIR="$(dirname "$OUT_DMG")"
mkdir -p "$OUT_DIR"

STAGE_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGE_DIR"' EXIT

echo "Staging dmg contents..."
cp -R "$APP_PATH" "$STAGE_DIR/HMCL.app"
ln -sf /Applications "$STAGE_DIR/Applications"
if [[ -f "$INSTALL_MD" ]]; then
  cp -f "$INSTALL_MD" "$STAGE_DIR/INSTALLATION.md"
else
  echo "Warning: INSTALLATION.md not found, skipping: $INSTALL_MD" >&2
fi
if [[ -f "$SOURCE_MD" ]]; then
  cp -f "$SOURCE_MD" "$STAGE_DIR/SOURCE_CODE.md"
else
  echo "Warning: SOURCE_CODE.md not found, skipping: $SOURCE_MD" >&2
fi
if [[ -f "$HMCL_META" ]]; then
  cp -f "$HMCL_META" "$STAGE_DIR/HMCL-RELEASE.json"
else
  echo "Warning: hmcl-latest.json not found, skipping: $HMCL_META" >&2
fi
if [[ -f "$HMCL_LICENSE" ]]; then
  cp -f "$HMCL_LICENSE" "$STAGE_DIR/LICENSE-HMCL.txt"
else
  echo "Warning: LICENSE-HMCL.txt not found, skipping: $HMCL_LICENSE" >&2
fi

echo "Creating dmg: $OUT_DMG"
rm -f "$OUT_DMG"
hdiutil create -volname "$VOLNAME" -srcfolder "$STAGE_DIR" -ov -format UDZO "$OUT_DMG" >/dev/null

echo "DMG created at $OUT_DMG"

