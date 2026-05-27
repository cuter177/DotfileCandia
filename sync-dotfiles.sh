#!/bin/bash

set -e

REPO="$HOME/DotfileCandia"
CONFIG="$HOME/.config"

echo "󰚰 Sincronizando dotfiles..."

# =========================
# CONFIGS
# =========================

configs=(
    hypr
    waybar
    kitty
    mako
    nvim
    fastfetch
    cava
    rofi
    wofi
    gtk-3.0
)

for dir in "${configs[@]}"; do
    if [ -d "$CONFIG/$dir" ]; then
        echo "󰉋 Copiando $dir"

        mkdir -p "$REPO/.config/$dir"

        rsync -av --delete \
            --exclude='.cache' \
            --exclude='*.log' \
            "$CONFIG/$dir/" \
            "$REPO/.config/$dir/"
    fi
done

# =========================
# ZSH
# =========================

echo "󰘳 Copiando zsh"

cp "$HOME/.zshrc" "$REPO/"
cp "$HOME/.p10k.zsh" "$REPO/"

# =========================
# GIT
# =========================

cd "$REPO"

git add .

echo "󰜘 Cambios preparados"

# Commit automático con fecha
git commit -m "Update dotfiles $(date '+%Y-%m-%d %H:%M:%S')" || true

echo "󰄬 Dotfiles sincronizados"
