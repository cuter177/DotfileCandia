#!/bin/bash

set -euo pipefail
shopt -s nullglob

if [ $# -eq 0 ]; then
    echo "Uso: $0 *.pdf"
    exit 1
fi

for INPUT in "$@"; do
    echo "=============================="
    echo "Procesando: $INPUT"

    NAME=$(basename "$INPUT" .pdf)
    WORKDIR=$(mktemp -d)

    cleanup() {
        rm -rf "$WORKDIR"
    }
    trap cleanup EXIT

    echo "Convirtiendo PDF a imágenes..."
    pdftoppm -jpeg -jpegopt quality=85 -r 150 "$INPUT" "$WORKDIR/page"

    cd "$WORKDIR"

    echo "Renombrando páginas..."
    i=1
    for f in page-*.jpg; do
        printf -v new "%03d.jpg" "$i"
        mv "$f" "$new"
        ((i++))
    done

    echo "Creando CBZ..."
    zip -rq "$NAME.cbz" *.jpg

    mv "$NAME.cbz" "$OLDPWD"

    cd - > /dev/null

    rm -rf "$WORKDIR"
    trap - EXIT

    # 🔥 BORRAR PDF SOLO SI TODO SALIÓ BIEN
    rm -f "$INPUT"

    echo "✔ CBZ creado y PDF eliminado: $NAME.cbz"
done
