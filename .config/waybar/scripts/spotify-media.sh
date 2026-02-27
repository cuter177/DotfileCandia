#!/usr/bin/env bash

escape_markup() {
  echo "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/\"/\&quot;/g' -e "s/'/\&apos;/g"
}

status=$(playerctl -p spotify status 2>/dev/null)
title=$(playerctl -p spotify metadata --format '{{artist}} - {{title}}' 2>/dev/null)

if [[ -z "$title" ]]; then
  echo '{"text": ""}'
  exit
fi

title_escaped=$(escape_markup "$title")

if [[ "$status" == "Playing" ]]; then
  echo "{\"text\": \" $title_escaped\", \"class\": \"playing\"}"
else
  echo "{\"text\": \" $title_escaped\"}"
fi


