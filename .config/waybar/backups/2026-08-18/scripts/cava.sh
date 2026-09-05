#!/usr/bin/env bash

FIFO="/tmp/cava.fifo"
bars=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

cleanup() {
  pkill -x cava >/dev/null 2>&1 || true
}
trap cleanup EXIT

# Cierra lectores/escritores viejos para no dejar el FIFO colgado
pkill -x cava >/dev/null 2>&1 || true
rm -f "$FIFO"
mkfifo "$FIFO"

cava >/dev/null 2>&1 &

while IFS= read -r line; do
  output=""
  IFS=';' read -ra values <<< "$line"

  for v in "${values[@]}"; do
    [[ -z "$v" ]] && continue
    v=${v//[^0-9]/}
    [[ -z "$v" ]] && continue
    (( v > 7 )) && v=7
    output+="${bars[$v]}"
  done

  [[ -z "$output" ]] && output="▁▁▁▁▁▁▁▁"
  printf '%s\n' "$output"
done < "$FIFO"
