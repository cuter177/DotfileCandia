#!/bin/bash

WALLPAPER="$1"

if [ -z "$WALLPAPER" ]; then
  echo "Uso: $0 /ruta/al/fondo.png"
  exit 1
fi

swww img "$WALLPAPER" --transition-type any
wal -i "$WALLPAPER"
~/.config/hypr/scripts/generate-waybar-style.sh
killall waybar
waybar &
