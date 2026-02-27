
#!/bin/bash

ws=$(hyprctl clients -j | jq -r '.[] | select(.class=="Spotify") | .workspace.id')

if [ -n "$ws" ]; then
    hyprctl dispatch workspace "$ws"
fi
