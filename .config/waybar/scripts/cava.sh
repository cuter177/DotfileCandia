#!/bin/bash

FIFO="/tmp/cava.fifo"

# crear fifo si no existe
[ -p "$FIFO" ] || mkfifo "$FIFO"

# iniciar cava si no está corriendo
pgrep -x cava >/dev/null || cava &

bars=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

stdbuf -oL cat "$FIFO" | while read -r line; do
    output=""

    # limpiar y separar valores
    IFS=';' read -ra values <<< "$line"

    for v in "${values[@]}"; do
        [[ -z "$v" ]] && continue
        v=${v//[^0-9]/}   # limpiar basura

        (( v > 7 )) && v=7
        output+="${bars[$v]}"
    done

    # si no hay output, mostrar algo mínimo
    [[ -z "$output" ]] && output=" "

    echo "$output"
done
 pkill -x -USR2 waybar
