#!/bin/bash

set -euo pipefail

SCRIPT_PATH="$(dirname "$0")"
PROJECT_ROOT="$(realpath "$SCRIPT_PATH/..")"
JAR_FILE_DEFAULT="$PROJECT_ROOT/HMCL.jar"
ICON_FILE_DEFAULT="$PROJECT_ROOT/.output/HMCL.icns"
OUT_DIR="$PROJECT_ROOT/.output"
TEMPLATE_DIR="$PROJECT_ROOT/src/HMCL"
OUTPUT_FILE="$OUT_DIR/HMCL.app"
VERSION_FILE_DEFAULT="$PROJECT_ROOT/VERSION"

print_help() {
  cat <<'EOF'
用法:
  ./scripts/make-app.sh [--jar <path>] [--icon <path>] [--version <version>]

说明:
  - 默认 jar:  ./HMCL.jar
  - 默认 icon: ./.output/HMCL.icns
  - 默认版本:  读取仓库根目录 VERSION（用于写入 Info.plist 的 CFBundleVersion / CFBundleShortVersionString）
  - 输出:      ./.output/HMCL.app
EOF
}

JAR_FILE="$JAR_FILE_DEFAULT"
ICON_FILE="$ICON_FILE_DEFAULT"
APP_VERSION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      print_help
      exit 0
      ;;
    --jar)
      shift
      JAR_FILE="${1-}"
      ;;
    --icon)
      shift
      ICON_FILE="${1-}"
      ;;
    --version)
      shift
      APP_VERSION="${1-}"
      ;;
    *)
      echo "未知参数: $1" >&2
      print_help >&2
      exit 1
      ;;
  esac
  shift
done

if [[ -z "${JAR_FILE:-}" || -z "${ICON_FILE:-}" ]]; then
  echo "参数缺失：--jar/--icon 需要跟路径" >&2
  print_help >&2
  exit 1
fi

if [[ ! -f "$JAR_FILE" ]]; then
  echo "Jar file not found: $JAR_FILE" >&2
  exit 1
fi

if [[ ! -f "$ICON_FILE" ]]; then
  echo "Icon file not found: $ICON_FILE" >&2
  exit 1
fi

rm -rf "$OUTPUT_FILE"

echo "Copying template to $OUTPUT_FILE"
cp -r "$TEMPLATE_DIR" "$OUTPUT_FILE"
mkdir -p "$OUTPUT_FILE/Contents/Resources"

echo "Copying jar to $OUTPUT_FILE/Contents/Resources/HMCL.jar"
cp -L "$JAR_FILE" "$OUTPUT_FILE/Contents/Resources/HMCL.jar"

echo "Copying icon to $OUTPUT_FILE/Contents/Resources/HMCL.icns"
cp -L "$ICON_FILE" "$OUTPUT_FILE/Contents/Resources/HMCL.icns"

if [[ -z "${APP_VERSION:-}" ]]; then
  if [[ -f "$VERSION_FILE_DEFAULT" ]]; then
    APP_VERSION="$(tr -d ' \r\n' < "$VERSION_FILE_DEFAULT")"
  fi
fi

if [[ -n "${APP_VERSION:-}" ]]; then
  INFO_PLIST="$OUTPUT_FILE/Contents/Info.plist"
  if [[ -f "$INFO_PLIST" ]]; then
    if command -v /usr/libexec/PlistBuddy >/dev/null 2>&1; then
      echo "Updating Info.plist version to $APP_VERSION"
      /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $APP_VERSION" "$INFO_PLIST" \
        || /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $APP_VERSION" "$INFO_PLIST"
      /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $APP_VERSION" "$INFO_PLIST" \
        || /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $APP_VERSION" "$INFO_PLIST"
    else
      echo "Warning: PlistBuddy not found; skipping Info.plist version update." >&2
    fi
  else
    echo "Warning: Info.plist not found; skipping version update: $INFO_PLIST" >&2
  fi
else
  echo "Warning: VERSION not provided and VERSION file not found/empty; leaving Info.plist version unchanged." >&2
fi

echo "App created at $OUTPUT_FILE"
