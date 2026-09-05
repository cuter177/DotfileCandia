#!/bin/bash
# ~/.config/waybar/scripts/keyboard-layout.sh

LAYOUT=$(hyprctl devices | awk '/at-translated-set-2-keyboard/{found=1} found && /active keymap:/{print; exit}' | sed 's/.*active keymap: //')

if echo "$LAYOUT" | grep -qi "latin\|spanish"; then
    echo "󰌌 MX"
else
    echo "󰌌 US"
fi
