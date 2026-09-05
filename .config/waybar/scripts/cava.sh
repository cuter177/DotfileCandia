#!/usr/bin/env bash
set -euo pipefail

FIFO="/tmp/cava.fifo"
LOCK="/tmp/cava-waybar.lock"
bars=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

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
if ! flock -n 9; then
  exec 9>&-
  idle
fi

CAVA_PID=""
cleanup() {
  if [[ -n "${CAVA_PID:-}" ]]; then
    kill "$CAVA_PID" 2>/dev/null || true
    wait "$CAVA_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

rm -f "$FIFO"
mkfifo "$FIFO"

cava >/dev/null 2>&1 &
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

  [[ -z "$output" ]] && output="▁▁▁▁▁▁▁▁"
  printf '%s\n' "$output"
done < "$FIFO"
