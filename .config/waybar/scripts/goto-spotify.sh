#!/bin/bash

info=$(hyprctl clients -j | jq -r '.[] | select(.class=="spotify")')

ws=$(echo "$info" | jq -r '.workspace.id')
monitor=$(echo "$info" | jq -r '.monitor')

if [ -n "$ws" ] && [ -n "$monitor" ]; then
    hyprctl dispatch focusmonitor "$monitor"
    hyprctl dispatch workspace "$ws"
fi
