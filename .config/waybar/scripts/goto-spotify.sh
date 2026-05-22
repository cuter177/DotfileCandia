#!/bin/bash

player=$(playerctl -l 2>/dev/null | grep -E "spotify|chromium|firefox|chrome" | head -1)

if echo "$player" | grep -qi "spotify"; then
    class="spotify"
elif echo "$player" | grep -qi "chromium"; then
    class="chromium"
elif echo "$player" | grep -qi "chrome"; then
    class="google-chrome"
elif echo "$player" | grep -qi "firefox"; then
    class="firefox"
else
    exit
fi

info=$(hyprctl clients -j | jq -r --arg class "$class" '.[] | select(.class==$class)')
ws=$(echo "$info" | jq -r '.workspace.id')
monitor=$(echo "$info" | jq -r '.monitor')

if [ -n "$ws" ] && [ -n "$monitor" ]; then
    hyprctl dispatch focusmonitor "$monitor"
    hyprctl dispatch workspace "$ws"
fi
