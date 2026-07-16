#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$ROOT_DIR/artifacts/visual}"
BASELINE_DIR="$ROOT_DIR/tests/visual/baselines"
WORK_DIR="$(mktemp -d)"
SERVER_PID=""

cleanup() {
  if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID" 2>/dev/null || true
  fi
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

if ! command -v "$GODOT_BIN" >/dev/null 2>&1 && [[ ! -x "$GODOT_BIN" ]]; then
  echo "Godot executable not found: $GODOT_BIN" >&2
  exit 1
fi

if ! command -v xvfb-run >/dev/null 2>&1; then
  echo "xvfb-run is required for rendered visual tests." >&2
  exit 1
fi

mkdir -p "$ARTIFACT_DIR" "$BASELINE_DIR"
rm -f "$ARTIFACT_DIR"/*.png "$ARTIFACT_DIR"/*.log

render_movie() {
  local output_name="$1"
  local frame_count="$2"
  local capture_index="$3"
  shift 3

  LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a -s "-screen 0 1280x720x24" \
    "$GODOT_BIN" --path "$ROOT_DIR" --rendering-method gl_compatibility \
    --write-movie "$WORK_DIR/$output_name.png" --fixed-fps 30 \
    --quit-after "$frame_count" -- "$@" \
    >"$ARTIFACT_DIR/$output_name.log" 2>&1

  local capture_frame
  printf -v capture_frame '%s/%s%08d.png' "$WORK_DIR" "$output_name" "$capture_index"
  if [[ ! -f "$capture_frame" ]]; then
    echo "Rendered frame $capture_index was not produced for $output_name." >&2
    return 1
  fi
  cp "$capture_frame" "$ARTIFACT_DIR/$output_name.png"
}

render_movie host 12 8 --server --name=VisualHost
render_movie walking 45 34 --server --name=Walker --move-right

"$GODOT_BIN" --headless --path "$ROOT_DIR" -- \
  --server --name=VisualHost --run-seconds=5 \
  >"$ARTIFACT_DIR/joined-server.log" 2>&1 &
SERVER_PID=$!

sleep 0.75
render_movie joined 60 45 --join=127.0.0.1 --name=VisualGuest

wait "$SERVER_PID"
SERVER_PID=""

grep -q "POND_SERVER_STARTED" "$ARTIFACT_DIR/host.log"
grep -q "POND_SERVER_STARTED" "$ARTIFACT_DIR/walking.log"
grep -q "POND_PLAYER_REGISTERED" "$ARTIFACT_DIR/joined-server.log"
grep -q "POND_CONNECTED" "$ARTIFACT_DIR/joined.log"

if grep -qE "SCRIPT ERROR|Parse Error|ERROR:" "$ARTIFACT_DIR"/*.log; then
  echo "Godot reported an error during the visual test." >&2
  grep -nE "SCRIPT ERROR|Parse Error|ERROR:" "$ARTIFACT_DIR"/*.log >&2
  exit 1
fi

for scenario in host joined walking; do
  actual="$ARTIFACT_DIR/$scenario.png"
  baseline="$BASELINE_DIR/$scenario.png"
  difference="$ARTIFACT_DIR/$scenario.diff.png"

  if [[ "${UPDATE_BASELINES:-0}" == "1" ]]; then
    cp "$actual" "$baseline"
    echo "Updated visual baseline: $baseline"
    continue
  fi

  if [[ ! -f "$baseline" ]]; then
    echo "Missing visual baseline: $baseline" >&2
    echo "Review the actual image, then run with UPDATE_BASELINES=1." >&2
    exit 1
  fi

  "$GODOT_BIN" --headless --path "$ROOT_DIR" \
    --script res://tests/visual/compare_images.gd -- \
    "$baseline" "$actual" "$difference"
done

echo "Pond visual regression test passed."
