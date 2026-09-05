#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

ensure_flathub() {
  if ! command -v flatpak >/dev/null 2>&1; then
    warn "flatpak no está instalado; se omite Spotify"
    return 1
  fi
  if flatpak remotes --columns=name 2>/dev/null | grep -qx flathub; then
    return 0
  fi
  log "añadiendo remote Flathub"
  run flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo \
    || run sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

install_spotify() {
  ensure_flathub || return 0
  log "instalando Spotify (Flatpak)"
  run flatpak install -y --user flathub com.spotify.Client \
    || run sudo flatpak install -y flathub com.spotify.Client
  log "override de escala de Spotify"
  run flatpak override --user com.spotify.Client \
    --env=ELECTRON_FORCE_DEVICE_SCALE_FACTOR=0.9 \
    || true
}

install_zen() {
  if command -v zen-browser >/dev/null 2>&1 || command -v zen >/dev/null 2>&1; then
    ok "Zen Browser ya está en PATH"
    return 0
  fi
  if [[ -x "$HOME/.tarball-installations/zen/zen" ]]; then
    ok "Zen Browser ya está en ~/.tarball-installations/zen/zen"
    return 0
  fi
  local helper
  helper="$(aur_helper)"
  if [[ -z "$helper" ]]; then
    warn "no hay yay/paru; instala zen-browser-bin a mano"
    return 0
  fi
  log "instalando zen-browser-bin"
  run "$helper" -S --needed --noconfirm zen-browser-bin
}

install_thunderbird() {
  if command -v thunderbird >/dev/null 2>&1; then
    ok "Thunderbird ya está instalado"
    return 0
  fi
  log "instalando Thunderbird"
  run sudo pacman -S --needed --noconfirm thunderbird
}

usage() {
  cat <<'EOF'
Uso: apps.sh [--dry-run]
Instala Spotify (Flatpak), Zen Browser (AUR) y Thunderbird. Solo Arch.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

parse_common_args "$@" || { usage; exit 1; }

is_arch || die "apps.sh solo funciona en Arch Linux (y derivados)"

install_thunderbird
install_spotify
install_zen
ok "apps extra listas"
