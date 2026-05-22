#!/bin/bash
MUTED=$(pactl get-source-mute @DEFAULT_SOURCE@ | grep -c "yes")

if [ "$MUTED" -eq 1 ]; then
    echo '{"text": "󰍭", "class": "muted"}'
else
    echo '{"text": "󰍬", "class": "active"}'
fi
