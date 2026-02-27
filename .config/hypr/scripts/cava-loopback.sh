#!/bin/bash

# Inicia loopback si no está ya corriendo
if ! pgrep -f "node.name=cava-input" > /dev/null; then
  pw-loopback --capture-props='node.name=cava-input' \
              --playback-props='media.class=Stream,media.role=Visualization,node.name=cava-dummy-output' &
fi

# Espera a que Spotify arranque y conecta automáticamente
sleep 5

# Opcional: puedes agregar conexión automática si sabes el nombre del nodo de Spotify
# O simplemente dejarlo así y usar helvum para conectar manualmente si hace falta
