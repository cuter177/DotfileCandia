#!/bin/bash

WATCHFILE="$HOME/.cache/swww/eDP-1"
SCRIPT="$HOME/.config/waybar/scripts/actualiza-color.sh"

# Verificar inotifywait
if ! command -v inotifywait &> /dev/null; then
  echo "❌ inotifywait no está instalado"
  exit 1
fi

# Verificar archivo de swww
if [[ ! -f "$WATCHFILE" ]]; then
  echo "❌ No existe $WATCHFILE"
  exit 1
fi

echo "👀 Monitoreando cambios en $WATCHFILE..."

# Watch continuo
inotifywait -m -e close_write "$WATCHFILE" | while read -r _; do
  echo "🎨 Fondo cambiado, actualizando colores..."
  bash "$SCRIPT"
done

