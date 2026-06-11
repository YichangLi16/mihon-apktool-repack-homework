#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEFAULT_APK="/Users/wayne/Desktop/mihon-main/mihon-apks/universal.apk"
APK_PATH="${1:-$DEFAULT_APK}"
OUT_DIR="${2:-$ROOT_DIR/work/mihon_decoded}"

if [[ ! -f "$APK_PATH" ]]; then
  echo "APK not found: $APK_PATH" >&2
  exit 1
fi

mkdir -p "$ROOT_DIR/work"
apktool d "$APK_PATH" -o "$OUT_DIR" -f </dev/null

echo "Decoded APK: $APK_PATH"
echo "Output dir: $OUT_DIR"

