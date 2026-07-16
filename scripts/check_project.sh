#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
LOG_FILE="$(mktemp)"

cleanup() {
  rm -f "$LOG_FILE"
}
trap cleanup EXIT

if ! command -v "$GODOT_BIN" >/dev/null 2>&1 && [[ ! -x "$GODOT_BIN" ]]; then
  echo "Godot executable not found: $GODOT_BIN" >&2
  exit 1
fi

if ! "$GODOT_BIN" --headless --editor --path "$ROOT_DIR" --quit >"$LOG_FILE" 2>&1; then
  sed -n '1,240p' "$LOG_FILE" >&2
  exit 1
fi

if grep -qE "SCRIPT ERROR|Parse Error|ERROR:" "$LOG_FILE"; then
  echo "Godot reported an error while loading the project." >&2
  sed -n '1,240p' "$LOG_FILE" >&2
  exit 1
fi

echo "Pond project check passed."
