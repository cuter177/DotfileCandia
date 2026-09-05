#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

PACMAN_PKGS=(
  hyprland waybar kitty neovim zsh fastfetch playerctl brightnessctl
  networkmanager blueman pavucontrol rofi cava eza pacman-contrib
  ttf-jetbrains-mono-nerd papirus-icon-theme noto-fonts mako wofi dolphin
  thunderbird grim slurp jq yad wlogout swww qt5ct qt6ct breeze
  bibata-cursor-theme python pipewire pipewire-pulse wireplumber
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk imagemagick
  inotify-tools python-pywal flatpak rsync git curl
)

AUR_PKGS=(
  waypaper
  networkmanager-dmenu
  pokemon-colorscripts-git
  zen-browser-bin
)

ensure_yay() {
  local helper
  helper="$(aur_helper)"
  if [[ -n "$helper" ]]; then
    ok "AUR helper: $helper"
    return 0
  fi
  log "instalando yay (no hay helper AUR)"
  require_cmd git
  run sudo pacman -S --needed --noconfirm base-devel git
  local tmp
  tmp="$(mktemp -d)"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    warn "dry-run: se clonaría yay y se ejecutaría makepkg -si"
    return 0
  fi
  git clone https://aur.archlinux.org/yay.git "$tmp/yay"
  (cd "$tmp/yay" && makepkg -si --noconfirm)
  rm -rf "$tmp"
}

install_pacman() {
  log "instalando paquetes oficiales"
  run sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
}

install_aur() {
  local helper pkg
  helper="$(aur_helper)"
  [[ -n "$helper" ]] || die "no hay helper AUR (yay/paru)"

  log "instalando paquetes AUR"
  for pkg in "${AUR_PKGS[@]}"; do
    if [[ "$pkg" == "waypaper" ]]; then
      if [[ "$DRY_RUN" -eq 1 ]]; then
        printf '[dry-run] %s -S --needed --noconfirm waypaper || waypaper-git\n' "$helper"
        continue
      fi
      if ! "$helper" -S --needed --noconfirm waypaper; then
        warn "waypaper no disponible, intentando waypaper-git"
        "$helper" -S --needed --noconfirm waypaper-git
      fi
      continue
    fi
    run "$helper" -S --needed --noconfirm "$pkg"
  done
}

usage() {
  cat <<'EOF'
Uso: packages.sh [--dry-run]
Instala dependencias del rice completo (solo Arch).
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

parse_common_args "$@" || { usage; exit 1; }

is_arch || die "packages.sh solo funciona en Arch Linux (y derivados)"

install_pacman
ensure_yay
install_aur
ok "paquetes listos"
