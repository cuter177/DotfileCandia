#!/usr/bin/env bash
# Shared helpers for waybar media modules.

MEDIA_PLAYER_PATTERN='spotify|chromium|firefox|chrome|zen|brave'

list_media_players() {
  playerctl -l 2>/dev/null | grep -iE "$MEDIA_PLAYER_PATTERN" || true
}

# Prefer a player that is actually Playing, then fall back to the first one.
select_media_player() {
  local p status
  while read -r p; do
    [[ -z "$p" ]] && continue
    status=$(playerctl -p "$p" status 2>/dev/null || true)
    if [[ "$status" == "Playing" ]]; then
      printf '%s\n' "$p"
      return 0
    fi
  done < <(list_media_players)

  list_media_players | head -n1
}
