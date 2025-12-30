#!/bin/bash

set -euo pipefail

SCRIPT_PATH="$(dirname "$0")"
PROJECT_ROOT="$(realpath "$SCRIPT_PATH/..")"
JAR_FILE_DEFAULT="$PROJECT_ROOT/HMCL.jar"
ICON_FILE_DEFAULT="$PROJECT_ROOT/.output/HMCL.icns"
OUT_DIR="$PROJECT_ROOT/.output"
TEMPLATE_DIR="$PROJECT_ROOT/src/HMCL"
OUTPUT_FILE="$OUT_DIR/HMCL.app"

print_help() {
  cat <<'EOF'
用法:
  ./scripts/make-app.sh [--jar <path>] [--icon <path>]

说明:
  - 默认 jar:  ./HMCL.jar
  - 默认 icon: ./.output/HMCL.icns
  - 输出:      ./.output/HMCL.app
EOF
}

JAR_FILE="$JAR_FILE_DEFAULT"
ICON_FILE="$ICON_FILE_DEFAULT"

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

echo "App created at $OUTPUT_FILE"
