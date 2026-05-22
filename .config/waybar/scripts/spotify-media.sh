#!/usr/bin/env bash

escape_markup() {
  echo "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/\"/\&quot;/g' -e "s/'/\&apos;/g"
}

# Busca el player que esté Playing primero
player=$(playerctl -l 2>/dev/null | grep -E "spotify|chromium|firefox|chrome" | while read -r p; do
    status=$(playerctl -p "$p" status 2>/dev/null)
    if [[ "$status" == "Playing" ]]; then
        echo "$p"
        break
    fi
done)

# Si ninguno está Playing, toma el primero disponible
if [[ -z "$player" ]]; then
    player=$(playerctl -l 2>/dev/null | grep -E "spotify|chromium|firefox|chrome" | head -1)
fi

if [[ -z "$player" ]]; then
  echo '{"text": ""}'
  exit
fi

status=$(playerctl -p "$player" status 2>/dev/null)
title=$(playerctl -p "$player" metadata --format '{{artist}} - {{title}}' 2>/dev/null)

if [[ -z "$title" ]]; then
  echo '{"text": ""}'
  exit
fi

# Icono según reproductor
if echo "$player" | grep -qi "spotify"; then
  icon=""
elif echo "$player" | grep -qiE "chromium|chrome|firefox"; then
  icon=""
else
  icon="󰎆"
fi

title_escaped=$(escape_markup "$title")

if [[ "$status" == "Playing" ]]; then
  echo "{\"text\": \"$icon $title_escaped\", \"class\": \"playing\"}"
else
  echo "{\"text\": \"$icon $title_escaped\"}"
fi
