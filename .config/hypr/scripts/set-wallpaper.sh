#!/bin/bash

# Ruta al nuevo fondo (ajústalo)
WALLPAPER="$1"

# Cambiar fondo con swww
swww img "$WALLPAPER" --transition-type any

# Generar colores con pywal
wal -i "$WALLPAPER"

# Recargar Waybar
killall waybar
waybar &
