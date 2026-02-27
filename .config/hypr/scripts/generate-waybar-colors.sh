#!/bin/bash

# Ruta original
SRC="$HOME/.cache/wal/colors.css"
# Ruta compatible
DST="$HOME/.config/waybar/pywal-colors.css"

# Limpia el archivo destino
> "$DST"

# Extrae solo las variables y las convierte en CSS usable por Waybar
grep -oP '(?<=--)[^:]+:\s*#[0-9a-fA-F]{6}' "$SRC" | while read -r line; do
    name=$(echo "$line" | cut -d: -f1)
    value=$(echo "$line" | cut -d: -f2)
    echo "* { --$name:$value; }" >> "$DST"
done
