#!/bin/bash

SRC="$HOME/.cache/wal/colors.css"
DST="$HOME/.config/waybar/pywal-colors.css"

# Vacía el archivo destino
> "$DST"

# Extrae las líneas entre :root { y }, elimina :root y cambia la sintaxis a válida para Waybar
sed -n '/:root {/,/}/p' "$SRC" | \
  sed '1d;$d' | \
  sed 's/--\([^:]*\): \(#.*\);/* { --\1: \2; }/g' >> "$DST"
