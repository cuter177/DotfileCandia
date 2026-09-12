#!/usr/bin/env bash
set -euo pipefail

FIFO="/tmp/cava-waybar.fifo"
LOCK="/tmp/cava-waybar.lock"
CONF="$HOME/.config/waybar/cava.ini"
bars=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
BAR_COUNT="$(awk -F= '/^[[:space:]]*bars[[:space:]]*=/{gsub(/[[:space:]]/,"",$2); print $2; exit}' "$CONF" 2>/dev/null || true)"
BAR_COUNT="${BAR_COUNT:-8}"
IDLE_BARS="$(printf '▁%.0s' $(seq 1 "$BAR_COUNT"))"

idle() {
  exec sleep infinity
}

primary_monitor() {
  command -v hyprctl >/dev/null 2>&1 || return 1
  command -v jq >/dev/null 2>&1 || return 1
  hyprctl monitors -j 2>/dev/null | jq -r '
    ([.[] | select(.x == 0 and .y == 0)][0].name) // .[0].name // empty
  '
}

is_primary_bar() {
  local output="${WAYBAR_OUTPUT_NAME:-}"
  [[ -z "$output" ]] && return 0

  local primary=""
  primary="$(primary_monitor)" || true
  [[ -z "$primary" ]] && return 0
  [[ "$output" == "$primary" ]]
}

if ! is_primary_bar; then
  idle
fi

exec 9>"$LOCK"
# Wait out the previous instance instead of sleeping forever with no output.
# A reload overlap used to take this path, and hide-empty-text hid the module.
flock 9

CAVA_PID=""
cleanup() {
  trap - EXIT TERM INT
  if [[ -n "${CAVA_PID:-}" ]]; then
    kill "$CAVA_PID" 2>/dev/null || true
    wait "$CAVA_PID" 2>/dev/null || true
  fi
  pkill -f "cava -p ${CONF}" 2>/dev/null || true
}
trap cleanup EXIT TERM INT

pkill -f "cava -p ${CONF}" 2>/dev/null || true

rm -f "$FIFO"
mkfifo "$FIFO"

# Keep a read-write fd so the reader never blocks on open if cava is slow.
exec 8<>"$FIFO"

cava -p "$CONF" >/dev/null 2>&1 &
CAVA_PID=$!

while IFS= read -r line; do
  output=""
  IFS=';' read -ra values <<< "$line"

  for v in "${values[@]}"; do
    [[ -z "$v" ]] && continue
    v=${v//[^0-9]/}
    [[ -z "$v" ]] && continue
    if (( v > 7 )); then
      v=7
    fi
    output+="${bars[$v]}"
  done

  [[ -z "$output" ]] && output="$IDLE_BARS"
  printf '%s\n' "$output"
done <&8
