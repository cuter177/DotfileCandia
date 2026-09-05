#!/bin/bash

# Inicia swww-daemon si no está corriendo
pgrep -x swww-daemon > /dev/null || swww-daemon &
sleep 0.5

# Extrae el path desde Waypaper (state.json o config.ini)
if [[ -f "$HOME/.config/waypaper/state.json" ]]; then
    FONDO=$(jq -r '.wallpapers[]' "$HOME/.config/waypaper/state.json")
elif [[ -f "$HOME/.config/waypaper/config.ini" ]]; then
    FONDO=$(awk -F ' *= *' '/^wallpaper / { print $2; exit }' "$HOME/.config/waypaper/config.ini")
    FONDO="${FONDO/#\~/$HOME}"
fi

# Verifica que el archivo exista y lo aplica
if [ -f "$FONDO" ]; then
    swww img "$FONDO" --transition-type any
fi
