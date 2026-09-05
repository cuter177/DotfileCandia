#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=media-common.sh
source "$(dirname "$(readlink -f "$0")")/media-common.sh"

player=$(select_media_player)
[[ -n "${player:-}" ]] || exit 0

title=$(playerctl -p "$player" metadata title 2>/dev/null || true)
player_lc=${player,,}

case "$player_lc" in
  *spotify*) class_re='^(spotify|Spotify|com\.spotify\.Client)$' ;;
  *zen*|*firefox*) class_re='^(zen|firefox|zen-alpha|zen-bin|zen-browser)$' ;;
  *chromium*) class_re='^(chromium|Chromium)$' ;;
  *chrome*) class_re='^(google-chrome|Google-chrome|google-chrome-stable|chrome)$' ;;
  *brave*) class_re='^(brave-browser|Brave-browser|brave)$' ;;
  *) class_re="^${player%%.*}$" ;;
esac

pid=""
if [[ "$player" =~ instance[_-]?([0-9]+) ]]; then
  pid="${BASH_REMATCH[1]}"
fi

addr=$(hyprctl clients -j | jq -r --arg title "$title" --arg cre "$class_re" --arg pid "$pid" '
  def matches_class: (.class | test($cre));
  def matches_title:
    ($title != "" and (.title | ascii_downcase | contains(($title | ascii_downcase))));
  (if $pid != "" then [.[] | select((.pid | tostring) == $pid)] else [] end) as $by_pid
  | (if ($by_pid | length) > 0 then $by_pid else [.[] | select(matches_class)] end) as $cands
  | ($cands | map(select(matches_title)) | .[0].address // $cands[0].address // empty)
')

[[ -n "$addr" ]] || exit 0

hyprctl dispatch "hl.dsp.focus({window = 'address:${addr}'})" >/dev/null
