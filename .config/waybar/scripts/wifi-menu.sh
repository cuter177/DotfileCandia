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

SSID=$(echo "$MENU" | wofi --dmenu --prompt "Seleccionar WiFi")

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
PASS=$(wofi --dmenu --password --prompt "Contraseña para $SSID" <<< " ")

[ -z "$PASS" ] && exit

echo "Password ingresado" >> "$LOG"

nmcli device wifi connect "$SSID" password "$PASS"

if [ $? -eq 0 ]; then
    notify-send "WiFi" "Conectado a $SSID"
else
    notify-send "WiFi" "Error al conectar"
fi
