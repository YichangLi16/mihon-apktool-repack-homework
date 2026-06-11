#!/usr/bin/env bash
set -euo pipefail

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_cmd apktool
require_cmd keytool
require_cmd java

ANDROID_SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
BUILD_TOOLS_DIR="$(find "$ANDROID_SDK/build-tools" -maxdepth 1 -type d 2>/dev/null | sort -V | tail -1)"

if [[ -z "${BUILD_TOOLS_DIR:-}" ]]; then
  echo "Android build-tools not found under $ANDROID_SDK/build-tools" >&2
  exit 1
fi

for tool in apksigner zipalign; do
  if [[ ! -x "$BUILD_TOOLS_DIR/$tool" ]]; then
    echo "Missing $tool in $BUILD_TOOLS_DIR" >&2
    exit 1
  fi
done

echo "apktool: $(apktool --version)"
echo "java: $(java -version 2>&1 | head -1)"
echo "build-tools: $BUILD_TOOLS_DIR"

