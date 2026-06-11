#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SIGNED_APK="${1:-$ROOT_DIR/dist/mihon-apktool-demo-signed.apk}"

adb install -r "$SIGNED_APK"

