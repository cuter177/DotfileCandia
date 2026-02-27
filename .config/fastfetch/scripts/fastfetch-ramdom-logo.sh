#!/bin/bash

# Busca un PNG aleatorio en la carpeta indicada
LOGO_PATH=$(find "${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch/pngs/" -type f -name "*.png" | shuf -n 1)

# Llama a fastfetch con el logo seleccionado
fastfetch --logo "$LOGO_PATH"
