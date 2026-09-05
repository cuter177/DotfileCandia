#!/bin/bash

USER_HOME="/home/candia"
CACHE="$USER_HOME/.cache/swww/eDP-1"
STYLE="$USER_HOME/.config/waybar/style.css"

# ─────────────────────────────────────────────
# Leer fondo actual
# ─────────────────────────────────────────────
RAW=$(cat "$CACHE" 2>/dev/null | tr -d '\000')
WALL=$(echo "$RAW" | grep -o '/home/[^%]*\.\(png\|jpg\|jpeg\|webp\)')
[[ -z "$WALL" || ! -f "$WALL" ]] && exit 1

# ─────────────────────────────────────────────
# Obtener color dominante
# ─────────────────────────────────────────────
COLOR=$(magick "$WALL" -resize 1x1 txt:- \
  | grep -o '#[A-Fa-f0-9]\{6\}' | head -n1)
[[ -z "$COLOR" ]] && exit 1


MODULES_background=(
  "#backlight"
  "#custom-media"
  "#custom-media.playing"
)

MODULES_color=(
  "#network"
  "#custom-launcher"
  "#custom-bluetooth"
  "#custom-cava"
)

for MOD in "${MODULES_background[@]}"; do
  perl -0777 -i -pe "
    s/($MOD\s*\\{[^}]*background:\s*)#[0-9a-fA-F]{6,8}/\$1$COLOR/s
  " "$STYLE"
done

for MOD in "${MODULES_color[@]}"; do
  perl -0777 -i -pe "
    s/($MOD\s*\\{[^}]*color:\s*)#[0-9a-fA-F]{6,8}/\$1$COLOR/s
  " "$STYLE"
done
# ─────────────────────────────────────────────
# Recargar Waybar
# ─────────────────────────────────────────────
pkill -USR2 waybar

