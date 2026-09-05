#!/usr/bin/env bash

# Verifica si Spotify está activo y reproduciendo algo
if playerctl -p spotify status &>/dev/null; then
    playerctl -p spotify metadata --format "{{artist}} - {{title}}" 2>/dev/null
else
    echo ""  # No mostrar nada si Spotify no está activo
fi
#!/usr/bin/env bash
playerctl metadata --format "{{artist}} - {{title}}" 2>/dev/null
