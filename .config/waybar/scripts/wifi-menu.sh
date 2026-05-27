#!/bin/bash
LOG="$HOME/wifi_debug.log"
echo "--- $(date) ---" > "$LOG"

# obtener redes sin duplicados
LIST=$(nmcli -t -f SSID,SECURITY,SIGNAL device wifi list | awk -F: '$1!="" && !seen[$1]++')

MENU=$(echo "$LIST" | awk -F: '{
    lock=""
    if($2!="--") lock=" 🔒"
    print $1"  "$3"% "lock
}')

SSID=$(echo "$MENU" | wofi --show dmenu -p "Seleccionar WiFi" --lines 10)
[ -z "$SSID" ] && exit

SSID=$(echo "$SSID" | awk '{print $1}')
echo "SSID: $SSID" >> "$LOG"

# intentar conectar primero (por si ya está guardada)
nmcli device wifi connect "$SSID" &> /dev/null
if [ $? -eq 0 ]; then
    notify-send "WiFi" "Conectado a $SSID"
    exit
fi

sleep 0.2

# pedir contraseña
GTK_THEME=Breeze:dark \
    yad --entry --hide-text \
    --title="" \
    --text="🔒 Contraseña para $SSID" \
    --button="Conectar:0" \
    --button="Cancelar:1" \
    --width=380 \
    --height=130 \
    --fixed \
    --undecorated \
    --borders=24 \
    --gtkrc="$HOME/.config/gtk-3.0/yad-wifi.css" > /tmp/yad-wifi-pass 2>/dev/null &

YAD_PID=$!
sleep 0.3
hyprctl dispatch focuswindow pid:$YAD_PID
hyprctl dispatch moveactive exact 900 20

wait $YAD_PID
PASS=$(cat /tmp/yad-wifi-pass | tr -d '\n')
rm -f /tmp/yad-wifi-pass

[ -z "$PASS" ] && exit
echo "Password ingresado" >> "$LOG"

nmcli device wifi connect "$SSID" password "$PASS"
if [ $? -eq 0 ]; then
    notify-send "WiFi" "Conectado a $SSID"
else
    notify-send "WiFi" "Error al conectar a $SSID"
fi
