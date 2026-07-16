#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot4}"
LOG_DIR="$(mktemp -d)"
SERVER_PID=""

cleanup() {
  if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID" 2>/dev/null || true
  fi
  rm -rf "$LOG_DIR"
}
trap cleanup EXIT

if ! command -v "$GODOT_BIN" >/dev/null 2>&1 && [[ ! -x "$GODOT_BIN" ]]; then
  echo "Godot executable not found: $GODOT_BIN" >&2
  exit 1
fi

"$GODOT_BIN" --headless --path "$ROOT_DIR" -- \
  --server --name=SmokeHost --run-seconds=4 >"$LOG_DIR/server.log" 2>&1 &
SERVER_PID=$!

sleep 0.75

"$GODOT_BIN" --headless --path "$ROOT_DIR" -- \
  --join=127.0.0.1 --name=SmokeGuest --move-right --run-seconds=2 >"$LOG_DIR/client.log" 2>&1

wait "$SERVER_PID"
SERVER_PID=""

grep -q "POND_SERVER_STARTED" "$LOG_DIR/server.log"
grep -q "POND_PLAYER_REGISTERED" "$LOG_DIR/server.log"
grep -q "POND_CONNECTED" "$LOG_DIR/client.log"
grep -q "POND_MOVEMENT_OBSERVED" "$LOG_DIR/client.log"

if grep -qE "SCRIPT ERROR|Parse Error|ERROR:" "$LOG_DIR/server.log" "$LOG_DIR/client.log"; then
  echo "Godot reported an error during the smoke test." >&2
  sed -n '1,200p' "$LOG_DIR/server.log" >&2
  sed -n '1,200p' "$LOG_DIR/client.log" >&2
  exit 1
fi

echo "Pond multiplayer smoke test passed."
