#!/bin/bash

VOL=$(pamixer --get-volume)

yad --scale \
  --vertical \
  --invert \
  --class="float-volume" \
  --title="float-volume" \
  --value="$VOL" \
  --min-value=0 \
  --max-value=100 \
  --step=1 \
  --width=44 \
  --height=120 \
  --no-buttons \
  --undecorated \
  --close-on-unfocus \
  --skip-taskbar \
  --fixed \
  --on-top \
  --hide-value \
  --print-partial \
  --css="$HOME/.config/gtk-3.0/yad-volume.css" \
| while read -r value; do
    [ -n "$value" ] || continue
    pamixer --set-volume "$value"
    pkill -RTMIN+8 waybar
  done
