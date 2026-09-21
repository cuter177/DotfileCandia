#!/bin/bash
# ~/.config/waybar/scripts/keyboard-layout.sh
# Reads the layout from the main keyboard. All keyboards are kept in sync by
# ~/.config/hypr/scripts/sync-keyboard-layout.py, so any keyboard would report
# the same layout.

LAYOUT=$(hyprctl devices -j | jq -r '([.keyboards[] | select(.main == true)][0] // .keyboards[0]).active_keymap')

if echo "$LAYOUT" | grep -qiE "latin|spanish|latam"; then
    echo "󰌌 MX"
else
    echo "󰌌 US"
fi
