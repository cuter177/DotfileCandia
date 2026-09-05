#!/usr/bin/env bash
set -euo pipefail

# Session-only HDMI mirror. Boot always uses Hyprland's default (extend).

notify() {
  command -v notify-send >/dev/null 2>&1 || return 0
  notify-send -a Hyprland "Pantalla" "$1"
}

primary_name() {
  hyprctl monitors -j | jq -r \
    '([.[] | select(.x == 0 and .y == 0)][0].name) // .[0].name'
}

extra_names() {
  local primary="$1"
  hyprctl monitors -j | jq -r --arg p "$primary" \
    '.[] | select(.name != $p) | .name'
}

command -v hyprctl >/dev/null 2>&1 || exit 1
command -v jq >/dev/null 2>&1 || exit 1

primary="$(primary_name)"
mapfile -t extras < <(extra_names "$primary")

if [[ ${#extras[@]} -eq 0 ]]; then
  notify "Conecta el HDMI y vuelve a pulsar Super+Shift+H"
  exit 0
fi

for extra in "${extras[@]}"; do
  hyprctl keyword monitor "$extra,preferred,auto,1,mirror,$primary" >/dev/null
done

notify "HDMI en espejo (solo esta sesión)"
