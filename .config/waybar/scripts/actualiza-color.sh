#!/bin/bash

USER_HOME="${HOME}"
CACHE_DIR="$USER_HOME/.cache/swww"
COLORS="$USER_HOME/.config/waybar/colors.css"

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

CACHE=$(resolve_swww_cache) || exit 1

# ─────────────────────────────────────────────
# Leer fondo actual
# ─────────────────────────────────────────────
RAW=$(cat "$CACHE" 2>/dev/null | tr -d '\000')
WALL=$(echo "$RAW" | grep -oE '/[^[:cntrl:]%]+\.(png|jpg|jpeg|webp)' | head -n1)
[[ -z "$WALL" || ! -f "$WALL" ]] && exit 1

# ─────────────────────────────────────────────
# Obtener color dominante
# ─────────────────────────────────────────────
COLOR=$(magick "$WALL" -resize 1x1 txt:- \
  | grep -o '#[A-Fa-f0-9]\{6\}' | head -n1)
[[ -z "$COLOR" ]] && exit 1

# ─────────────────────────────────────────────
# Actualizar solo el token accent
# ─────────────────────────────────────────────
if grep -q '@define-color accent' "$COLORS"; then
  sed -i "s/@define-color accent .*/@define-color accent $COLOR;/" "$COLORS"
else
  echo "@define-color accent $COLOR;" >> "$COLORS"
fi

# ─────────────────────────────────────────────
# Recargar Waybar
# ─────────────────────────────────────────────
pkill -USR2 waybar
