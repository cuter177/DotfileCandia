#!/bin/bash

# Inicia swww-daemon si no está corriendo
pgrep -x swww-daemon > /dev/null || swww-daemon &
sleep 0.5

# Extrae el path desde el archivo de Waypaper
FONDO=$(jq -r '.wallpapers[]' "$HOME/.config/waypaper/state.json")

# Verifica que el archivo exista y lo aplica
if [ -f "$FONDO" ]; then
    swww img "$FONDO" --transition-type any
fi

