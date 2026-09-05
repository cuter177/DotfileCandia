#!/usr/bin/env bash

# Control the same player shown by the waybar media module.
source "$(dirname "$(readlink -f "$0")")/media-common.sh"

player=$(select_media_player)
[[ -n "${player:-}" ]] || exit 0

playerctl -p "$player" "$@"
