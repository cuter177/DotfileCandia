#!/bin/bash

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

# intentar conectar primero (por si ya está guardada)
nmcli device wifi connect "$SSID" &> /dev/null
if [ $? -eq 0 ]; then
    notify-send "WiFi" "Conectado a $SSID"
    exit
fi

sleep 0.2

PASS=$(GTK_THEME=Breeze:dark \
    yad --entry --hide-text \
    --title="yad_wifi" \
    --text="🔒 Contraseña para $SSID" \
    --button="Conectar:0" \
    --button="Cancelar:1" \
    --width=380 \
    --height=130 \
    --fixed \
    --undecorated \
    --borders=24 \
    --gtkrc="$HOME/.config/gtk-3.0/yad-wifi.css" 2>/dev/null)

[ -z "$PASS" ] && exit

nmcli device wifi connect "$SSID" password "$PASS"
if [ $? -eq 0 ]; then
    notify-send "WiFi" "Conectado a $SSID"
else
    notify-send "WiFi" "Error al conectar a $SSID"
fi
