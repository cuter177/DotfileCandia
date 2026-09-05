#!/usr/bin/env bash
set -euo pipefail

# Copy live configs into this repo (does not push).

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${HOME}/.config"

log() { printf '==> %s\n' "$*"; }

if [[ ! -d "$REPO/.git" ]]; then
  printf 'error: no parece un clone de DotfileCandia: %s\n' "$REPO" >&2
  exit 1
fi

log "Sincronizando dotfiles hacia $REPO"

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
  gtk-4.0
  qt5ct
  qt6ct
  waypaper
  xdg-desktop-portal
)

for dir in "${configs[@]}"; do
  if [[ -d "$CONFIG/$dir" ]]; then
    log "copiando $dir"
    mkdir -p "$REPO/.config/$dir"
    rsync -a --delete \
      --exclude='.cache' \
      --exclude='*.log' \
      --exclude='*.bak' \
      --exclude='*.save' \
      --exclude='backups/' \
      --exclude='hyprland.local.conf' \
      --exclude='gtk.css' \
      --exclude='gtk-dark.css' \
      --exclude='state.json' \
      "$CONFIG/$dir/" \
      "$REPO/.config/$dir/"
  fi
done

if [[ -f "$REPO/.config/qt6ct/qt6ct.conf" ]]; then
  sed -i "s|$HOME|/REPLACE_HOME|g" "$REPO/.config/qt6ct/qt6ct.conf"
fi

log "copiando zsh"
[[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$REPO/"
[[ -f "$HOME/.p10k.zsh" ]] && cp "$HOME/.p10k.zsh" "$REPO/"

cd "$REPO"
git add -A
log "cambios preparados (git add). Revisa y haz commit cuando quieras."
git status --short
