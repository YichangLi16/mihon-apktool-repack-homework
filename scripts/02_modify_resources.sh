#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DECODED_DIR="${1:-$ROOT_DIR/work/mihon_decoded}"
STRINGS_XML="$DECODED_DIR/res/values/strings.xml"
NEW_NAME="${2:-Mihon APKTool Demo}"

if [[ ! -f "$STRINGS_XML" ]]; then
  echo "strings.xml not found: $STRINGS_XML" >&2
  exit 1
fi

python3 - "$STRINGS_XML" "$NEW_NAME" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
new_name = sys.argv[2]
text = path.read_text(encoding="utf-8")
old = '<string name="app_name">Mihon</string>'
new = f'<string name="app_name">{new_name}</string>'

if old not in text and new not in text:
    raise SystemExit("Could not locate app_name string to update")

path.write_text(text.replace(old, new), encoding="utf-8")
print(f"Updated app_name in {path} -> {new_name}")
PY

