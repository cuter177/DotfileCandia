#!/bin/bash

BRIGHT=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

yad --scale \
  --class="float-brightness" \
  --title="float-brightness" \
  --value="$BRIGHT" \
  --min-value=1 \
  --max-value=100 \
  --step=1 \
  --width=140 \
  --height=40 \
  --no-buttons \
  --undecorated \
  --close-on-unfocus \
  --skip-taskbar \
  --fixed \
  --on-top \
  --hide-value \
  --print-partial \
  --css="$HOME/.config/gtk-3.0/yad-brightness.css" \
| while read -r value; do
    [ -n "$value" ] || continue
    brightnessctl set "$value"% > /dev/null
    pkill -RTMIN+9 waybar
  done
