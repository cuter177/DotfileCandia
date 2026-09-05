#!/bin/bash

CACHE_DIR="$HOME/.cache/swww"
SCRIPT="$HOME/.config/waybar/scripts/actualiza-color.sh"

resolve_swww_cache() {
  local mon="" cache=""
  if command -v hyprctl >/dev/null 2>&1; then
    mon=$(hyprctl monitors 2>/dev/null | awk '/^Monitor / { name=$2 } /focused: yes/ { print name; exit }')
  fi
  if [[ -n "$mon" && -f "$CACHE_DIR/$mon" ]]; then
    echo "$CACHE_DIR/$mon"
    return 0
  fi
  for cache in "$CACHE_DIR"/*; do
    [[ -f "$cache" ]] || continue
    [[ "$(basename "$cache")" == "lock" ]] && continue
    echo "$cache"
    return 0
  done
  return 1
}

if ! command -v inotifywait &> /dev/null; then
  echo "inotifywait no está instalado"
  exit 1
fi

WATCHFILE=$(resolve_swww_cache)
if [[ -z "$WATCHFILE" || ! -f "$WATCHFILE" ]]; then
  echo "No hay cache de swww en $CACHE_DIR"
  exit 1
fi

echo "Monitoreando cambios en $WATCHFILE..."

inotifywait -m -e close_write "$WATCHFILE" | while read -r _; do
  echo "Fondo cambiado, actualizando colores..."
  bash "$SCRIPT"
done
