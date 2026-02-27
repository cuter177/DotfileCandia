#!/bin/bash

COLORS_JSON="$HOME/.cache/wal/colors.json"
WAYBAR_CSS="$HOME/.config/waybar/style-generated.css"

FG=$(jq -r '.colors.foreground' "$COLORS_JSON")
BG=$(jq -r '.colors.background' "$COLORS_JSON")
COLOR0=$(jq -r '.colors.color0' "$COLORS_JSON")
COLOR4=$(jq -r '.colors.color4' "$COLORS_JSON")
COLOR6=$(jq -r '.colors.color6' "$COLORS_JSON")

cat > "$WAYBAR_CSS" << EOF
* {
  color: $FG;
  background: transparent;
}

window#waybar {
  background-color: $BG;
  border-radius: 15px;
  margin-top: 2px;
  padding: 2px 4px;
}

#workspaces {
  background: $COLOR0;
  border-radius: 18px;
  margin: 6px;
  padding-left: 12px;
  padding-right: 6px;
}

#workspaces button {
  color: $COLOR4;
  background: transparent;
  margin-right: 10px;
}

#workspaces button.active {
  color: $COLOR6;
  background: transparent;
}
EOF
