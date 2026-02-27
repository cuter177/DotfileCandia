#!/bin/bash

# Obtener brillo actual en porcentaje
BRIGHT=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

yad --scale \
  --title="float-brightness" \
  --value="$BRIGHT" \
  --min-value=1 \
  --max-value=100 \
  --step=1 \
  --width=180 \
  --height=20 \
  --hide-value \
  --no-buttons \
  --undecorated \
  --close-on-unfocus \
  --skip-taskbar \
  --fixed \
  --print-partial \
| while read value; do
    brightnessctl set "$value"% > /dev/null
  done
