#!/bin/bash

set -euo pipefail

print_help() {
  cat <<'EOF'
用法:
  ./make-icon.sh <inputfile>
  ./make-icon.sh            # 默认在当前目录查找 icon.png

说明:
  - 输出文件名自动使用输入图片的文件名（去掉扩展名），例如 foo.png -> output/foo.icns
  - 输出目录为当前目录下的 output/

参数:
  -h, --help  显示本帮助
EOF
}

arg1="${1-}"
arg2="${2-}"

if [[ "$arg1" == "-h" || "$arg1" == "--help" ]]; then
  print_help
  exit 0
fi

if [[ -n "$arg2" ]]; then
  echo "参数过多。" >&2
  print_help >&2
  exit 1
fi

if [[ -n "$arg1" ]]; then
  INPUT_FILE="$arg1"
else
  if [[ -f "$PWD/icon.png" ]]; then
    INPUT_FILE="$PWD/icon.png"
  else
    echo "未传入 inputfile，且当前目录找不到 icon.png。" >&2
    print_help >&2
    exit 1
  fi
fi

if [[ ! -f "$INPUT_FILE" ]]; then
  echo "输入文件不存在: $INPUT_FILE" >&2
  print_help >&2
  exit 1
fi

base_name="$(basename "$INPUT_FILE")"
ICON_NAME="${base_name%.*}"

OUTPUT_DIR="$PWD/.output"
TMP_WORK_DIR="$(mktemp -d)"
TMP_ICONSET_DIR="$TMP_WORK_DIR/$ICON_NAME.iconset"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$TMP_ICONSET_DIR"

trap 'rm -rf "$TMP_WORK_DIR"' EXIT

sips -z 16 16     "$INPUT_FILE" --out "$TMP_ICONSET_DIR/icon_16x16.png"
sips -z 32 32     "$INPUT_FILE" --out "$TMP_ICONSET_DIR/icon_16x16@2x.png"
sips -z 32 32     "$INPUT_FILE" --out "$TMP_ICONSET_DIR/icon_32x32.png"
sips -z 64 64     "$INPUT_FILE" --out "$TMP_ICONSET_DIR/icon_32x32@2x.png"
sips -z 128 128   "$INPUT_FILE" --out "$TMP_ICONSET_DIR/icon_128x128.png"
sips -z 256 256   "$INPUT_FILE" --out "$TMP_ICONSET_DIR/icon_128x128@2x.png"
sips -z 256 256   "$INPUT_FILE" --out "$TMP_ICONSET_DIR/icon_256x256.png"
sips -z 512 512   "$INPUT_FILE" --out "$TMP_ICONSET_DIR/icon_256x256@2x.png"
sips -z 512 512   "$INPUT_FILE" --out "$TMP_ICONSET_DIR/icon_512x512.png"
sips -z 1024 1024 "$INPUT_FILE" --out "$TMP_ICONSET_DIR/icon_512x512@2x.png"

iconutil -c icns "$TMP_ICONSET_DIR" -o "$OUTPUT_DIR/$ICON_NAME.icns"

echo "已生成: $OUTPUT_DIR/$ICON_NAME.icns"
