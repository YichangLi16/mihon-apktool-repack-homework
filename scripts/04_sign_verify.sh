#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ALIGNED_APK="${1:-$ROOT_DIR/dist/mihon-apktool-demo-aligned.apk}"
SIGNED_APK="${2:-$ROOT_DIR/dist/mihon-apktool-demo-signed.apk}"
KEYSTORE="${3:-$ROOT_DIR/keys/mihon-apktool-demo.jks}"
ALIAS="${4:-mihon-demo}"
STOREPASS="${STOREPASS:-android}"
ANDROID_SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
BUILD_TOOLS_DIR="$(find "$ANDROID_SDK/build-tools" -maxdepth 1 -type d 2>/dev/null | sort -V | tail -1)"
APKSIGNER="$BUILD_TOOLS_DIR/apksigner"

mkdir -p "$ROOT_DIR/keys" "$ROOT_DIR/dist"

if [[ ! -f "$KEYSTORE" ]]; then
  keytool -genkeypair \
    -alias "$ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -keystore "$KEYSTORE" \
    -storepass "$STOREPASS" \
    -keypass "$STOREPASS" \
    -dname "CN=Mihon APKTool Demo, OU=Mobile Testing, O=DLUT, L=Dalian, ST=Liaoning, C=CN"
fi

"$APKSIGNER" sign \
  --ks "$KEYSTORE" \
  --ks-pass "pass:$STOREPASS" \
  --ks-key-alias "$ALIAS" \
  --key-pass "pass:$STOREPASS" \
  --out "$SIGNED_APK" \
  "$ALIGNED_APK"

"$APKSIGNER" verify --verbose "$SIGNED_APK"

echo "Signed APK: $SIGNED_APK"

