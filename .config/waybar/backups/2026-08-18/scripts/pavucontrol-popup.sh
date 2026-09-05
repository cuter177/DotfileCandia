#!/bin/bash

VOL=$(pamixer --get-volume)

yad --scale \
  --class="float-volume" \
  --title="float-volume" \
  --value="$VOL" \
  --min-value=0 \
  --hide-value \
  --max-value=100 \
  --step=1 \
  --width=180 \
  --height=20 \
  --no-buttons \
  --undecorated \
  --close-on-unfocus \
  --skip-taskbar \
  --fixed \
  --print-partial \
  --gtkrc="$HOME/.config/gtk-3.0/yad-volume.css" \
| while read value; do
    pamixer --set-volume "$value"
  done
