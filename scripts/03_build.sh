#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DECODED_DIR="${1:-$ROOT_DIR/work/mihon_decoded}"
UNSIGNED_APK="${2:-$ROOT_DIR/dist/mihon-apktool-demo-unsigned.apk}"
ALIGNED_APK="${3:-$ROOT_DIR/dist/mihon-apktool-demo-aligned.apk}"
ANDROID_SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
BUILD_TOOLS_DIR="$(find "$ANDROID_SDK/build-tools" -maxdepth 1 -type d 2>/dev/null | sort -V | tail -1)"
ZIPALIGN="$BUILD_TOOLS_DIR/zipalign"

mkdir -p "$ROOT_DIR/dist"
apktool b "$DECODED_DIR" -o "$UNSIGNED_APK" </dev/null
"$ZIPALIGN" -f -p 4 "$UNSIGNED_APK" "$ALIGNED_APK"

echo "Unsigned APK: $UNSIGNED_APK"
echo "Aligned APK: $ALIGNED_APK"

