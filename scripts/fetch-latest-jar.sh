#!/bin/bash

set -euo pipefail

SCRIPT_PATH="$(dirname "$0")"
PROJECT_ROOT="$(realpath "$SCRIPT_PATH/..")"

CACHE_DIR="$PROJECT_ROOT/.cache"
API_URL="https://api.github.com/repos/HMCL-dev/HMCL/releases/latest"

mkdir -p "$CACHE_DIR"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq 未安装：本脚本需要 jq 来解析 GitHub API 返回的 JSON。" >&2
  echo "建议安装：brew install jq" >&2
  exit 1
fi

echo "Fetching latest release metadata from GitHub API..."

TMP_JSON="$(mktemp)"
trap 'rm -f "$TMP_JSON"' EXIT

CURL_HEADERS=(
  -H "Accept: application/vnd.github+json"
  -H "X-GitHub-Api-Version: 2022-11-28"
  -H "User-Agent: HMCL-macOS"
)

# 在 GitHub Actions 中传入 GITHUB_TOKEN 可避免匿名请求触发限流（403）
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  CURL_HEADERS+=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi

curl -fsSL "${CURL_HEADERS[@]}" "$API_URL" >"$TMP_JSON"

META_PATH="$CACHE_DIR/hmcl-latest.json"

# 选取“可直接运行”的主 jar：*.jar 且排除 sources/签名等
jq -e '
  def lower: ascii_downcase;
  def is_main_jar:
    (endswith(".jar"))
    and ((contains("sources") | not))
    and ((endswith(".jar.asc") | not))
    and ((endswith(".jar.sig") | not));

  . as $r
  | ($r.assets // [])
  | map(select(.name and (.name|lower|is_main_jar)))
  | .[0] as $a
  | if $a == null or ($a.browser_download_url|not) then
      error("latest release has no suitable .jar assets")
    else
      {
        tag_name: ($r.tag_name // "unknown"),
        release_url: ($r.html_url // ""),
        asset_name: $a.name,
        download_url: $a.browser_download_url
      }
    end
' "$TMP_JSON" >"$META_PATH"

JAR_NAME="$(jq -r '.asset_name' "$META_PATH")"
DOWNLOAD_URL="$(jq -r '.download_url' "$META_PATH")"

JAR_FILE="$CACHE_DIR/$JAR_NAME"

if [[ -f "$JAR_FILE" ]]; then
  echo "Cached jar already exists, skipping download: $JAR_FILE"
else
  echo "Downloading jar to cache: $JAR_FILE"
  curl -fL --retry 3 --retry-delay 1 -o "$JAR_FILE" "$DOWNLOAD_URL"
fi

echo "Updating latest pointer: $CACHE_DIR/HMCL-latest.jar"
ln -sf "$(basename "$JAR_FILE")" "$CACHE_DIR/HMCL-latest.jar"

echo "Done."

