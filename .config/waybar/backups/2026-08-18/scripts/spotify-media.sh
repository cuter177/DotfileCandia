#!/usr/bin/env bash

# shellcheck source=media-common.sh
source "$(dirname "$(readlink -f "$0")")/media-common.sh"

escape_markup() {
  echo "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/\"/\&quot;/g' -e "s/'/\&apos;/g"
}

player=$(select_media_player)

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

if echo "$player" | grep -qi "spotify"; then
  icon=""
elif echo "$player" | grep -qiE "chromium|chrome|firefox|zen"; then
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
