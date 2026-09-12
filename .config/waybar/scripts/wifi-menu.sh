#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WOFI_CONF="$ROOT/wofi-wifi/config"
WOFI_STYLE="$ROOT/wofi-wifi/style.css"
PASS_PY="$ROOT/scripts/wifi-password.py"
SEP=$'\x1f'
DISCONNECT_KEY="__DISCONNECT__"

notify() {
    notify-send "WiFi" "$1" >/dev/null 2>&1 || true
}

wifi_device() {
    local dev state typ fallback=""
    while IFS=: read -r dev state typ; do
        [ "$typ" = "wifi" ] || continue
        fallback="$dev"
        if [ "$state" = "connected" ]; then
            printf '%s\n' "$dev"
            return 0
        fi
    done < <(nmcli -t -f DEVICE,STATE,TYPE device status)
    if [ -n "$fallback" ]; then
        printf '%s\n' "$fallback"
        return 0
    fi
    return 1
}

ask_password() {
    local ssid="$1"
    local pass rc=0

    pass=$(python3 "$PASS_PY" "$ssid") || rc=$?
    if [ "$rc" -eq 0 ]; then
        printf '%s\n' "$pass"
        return 0
    fi
    if [ "$rc" -eq 2 ]; then
        pass=$(
            yad --entry --hide-text \
                --title="wifi-password" \
                --text="Contraseña para $ssid" \
                --button="Conectar:0" \
                --button="Cancelar:1" \
                --width=400 \
                --height=160 \
                --fixed \
                --undecorated \
                --borders=20 \
                --css="$HOME/.config/gtk-3.0/yad-wifi.css" 2>/dev/null || true
        )
        [ -n "${pass:-}" ] || return 1
        printf '%s\n' "$pass"
        return 0
    fi
    return 1
}

if ! wifi_device >/dev/null; then
    notify "No hay adaptador Wi-Fi"
    exit 1
fi

nmcli device wifi rescan >/dev/null 2>&1 || true

mapfile -t ROWS < <(python3 - <<'PY'
import subprocess

def split_terse(line: str) -> list[str]:
    fields: list[str] = []
    buf: list[str] = []
    esc = False
    for ch in line:
        if esc:
            buf.append(ch)
            esc = False
        elif ch == "\\":
            esc = True
        elif ch == ":":
            fields.append("".join(buf))
            buf = []
        else:
            buf.append(ch)
    fields.append("".join(buf))
    return fields


def signal_icon(strength: int) -> str:
    if strength >= 80:
        return "󰤨"
    if strength >= 60:
        return "󰤥"
    if strength >= 40:
        return "󰤢"
    if strength >= 20:
        return "󰤟"
    return "󰤯"


try:
    raw = subprocess.check_output(
        ["nmcli", "-t", "-f", "IN-USE,SSID,SECURITY,SIGNAL", "device", "wifi", "list"],
        text=True,
        stderr=subprocess.DEVNULL,
    )
except subprocess.CalledProcessError:
    raw = ""

seen: dict[str, tuple[bool, str, int]] = {}
order: list[str] = []

for line in raw.splitlines():
    if not line.strip():
        continue
    parts = split_terse(line)
    while len(parts) < 4:
        parts.append("")
    in_use, ssid, security, signal = parts[0], parts[1], parts[2], parts[3]
    if not ssid:
        continue
    try:
        strength = int(signal)
    except ValueError:
        strength = 0
    active = in_use.strip() == "*"
    prev = seen.get(ssid)
    if prev is None or strength > prev[2] or (active and not prev[0]):
        if ssid not in seen:
            order.append(ssid)
        seen[ssid] = (active or (prev[0] if prev else False), security, strength)

rows = []
current = ""
for ssid in order:
    active, security, strength = seen[ssid]
    if active:
        current = ssid
    lock = "🔒" if security and security != "--" else "·"
    display = f"{signal_icon(strength)}  {strength:>3}%  {lock}  {ssid}"
    if active:
        display = f"● {display}"
    rows.append((display, ssid, strength, active))

rows.sort(key=lambda r: (not r[3], -r[2], r[1].lower()))
if current:
    print(f"CURRENT\x1f{current}")
for display, ssid, *_rest in rows:
    print(f"{display}\x1f{ssid}")
PY
)

CURRENT=""
DISPLAYS=()
declare -A SSID_FOR=()

for row in "${ROWS[@]+"${ROWS[@]}"}"; do
    key="${row%%$SEP*}"
    val="${row#*$SEP}"
    if [ "$key" = "CURRENT" ]; then
        CURRENT="$val"
        continue
    fi
    DISPLAYS+=("$key")
    SSID_FOR["$key"]="$val"
done

MENU=""
if [ -n "$CURRENT" ]; then
    DISCONNECT_LINE="󰖪  Desconectar de $CURRENT"
    MENU+="$DISCONNECT_LINE"$'\n'
    SSID_FOR["$DISCONNECT_LINE"]="$DISCONNECT_KEY"
fi

if [ "${#DISPLAYS[@]}" -eq 0 ]; then
    notify "No se encontraron redes Wi-Fi"
    exit 1
fi

for line in "${DISPLAYS[@]}"; do
    MENU+="$line"$'\n'
done

SELECTED=$(
    printf '%s' "$MENU" | wofi --dmenu \
        --conf "$WOFI_CONF" \
        --style "$WOFI_STYLE" \
        --cache-file /dev/null \
        --prompt "Wi-Fi"
) || true

[ -n "${SELECTED:-}" ] || exit 0

TARGET="${SSID_FOR[$SELECTED]:-}"
[ -n "$TARGET" ] || exit 0

if [ "$TARGET" = "$DISCONNECT_KEY" ]; then
    DEV="$(wifi_device || true)"
    if [ -n "$DEV" ] && nmcli device disconnect "$DEV" >/dev/null 2>&1; then
        notify "Desconectado de $CURRENT"
    else
        notify "No se pudo desconectar"
        exit 1
    fi
    exit 0
fi

SSID="$TARGET"

if nmcli --wait 8 device wifi connect "$SSID" >/dev/null 2>&1; then
    notify "Conectado a $SSID"
    exit 0
fi

PASS="$(ask_password "$SSID" || true)"
[ -n "${PASS:-}" ] || exit 0

if nmcli device wifi connect "$SSID" password "$PASS" >/dev/null 2>&1; then
    notify "Conectado a $SSID"
else
    notify "Error al conectar a $SSID"
    exit 1
fi
