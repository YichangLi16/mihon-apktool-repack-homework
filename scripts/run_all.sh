#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APK_PATH="${1:-/Users/wayne/Desktop/mihon-main/mihon-apks/universal.apk}"

"$ROOT_DIR/scripts/00_check_env.sh"
"$ROOT_DIR/scripts/01_decode.sh" "$APK_PATH"
"$ROOT_DIR/scripts/02_modify_resources.sh"
"$ROOT_DIR/scripts/03_build.sh"
"$ROOT_DIR/scripts/04_sign_verify.sh"

