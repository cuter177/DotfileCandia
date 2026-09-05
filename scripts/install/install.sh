#!/usr/bin/env bash
set -euo pipefail

# Full Arch rice installer. Reuses shell.sh for Zsh + Kitty.

# shellcheck source=common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

usage() {
  cat <<'EOF'
Uso: install.sh [--dry-run] [--skip-apps]

Instala el rice completo de DotfileCandia (solo Arch Linux):
  paquetes, configs de Hyprland/Waybar/temas, Zsh+Kitty, y apps extra.

  --dry-run     muestra comandos sin ejecutarlos
  --skip-apps   omite Spotify, Zen Browser y Thunderbird extra
  --skip-nvm    se reenvía a shell.sh
  --skip-kitty  se reenvía a shell.sh (no recomendado en el rice completo)

Después:
  - cierra sesión y entra en Hyprland
  - pon fondos en ~/Wallpaper-Bank/wallpapers
  - revisa ~/.config/hypr/hyprland.local.conf si el monitor no coincide
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

parse_common_args "$@" || { usage; exit 1; }

is_arch || die "el rice completo solo se instala en Arch Linux. Para Zsh+Kitty en otra distro usa: scripts/install/shell.sh"

if [[ "$DRY_RUN" -eq 0 ]]; then
  printf 'Se instalarán paquetes (pacman/AUR) y se copiarán configs a %s.\n' "$HOME"
  printf 'Los directorios existentes en ~/.config se respaldan como *.bak-YYYYMMDD.\n'
  printf '¿Continuar? [y/N] '
  read -r answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) die "cancelado" ;;
  esac
fi

log "1/4 paquetes"
pkg_args=()
[[ "$DRY_RUN" -eq 1 ]] && pkg_args+=(--dry-run)
"$INSTALL_DIR/packages.sh" "${pkg_args[@]}"

log "2/4 configs"
"$INSTALL_DIR/link-configs.sh" "${pkg_args[@]}"

log "3/4 shell + Kitty"
shell_args=()
[[ "$DRY_RUN" -eq 1 ]] && shell_args+=(--dry-run)
[[ "$SKIP_KITTY" -eq 1 ]] && shell_args+=(--skip-kitty)
[[ "$SKIP_NVM" -eq 1 ]] && shell_args+=(--skip-nvm)
"$INSTALL_DIR/shell.sh" "${shell_args[@]}"

if [[ "$SKIP_APPS" -eq 1 ]]; then
  warn "omitido: apps extra"
else
  log "4/4 apps extra"
  "$INSTALL_DIR/apps.sh" "${pkg_args[@]}"
fi

ok "instalación terminada"
echo
echo "Siguiente:"
echo "  1. Cierra sesión y entra a Hyprland"
echo "  2. Copia fondos a ~/Wallpaper-Bank/wallpapers"
echo "  3. Si el monitor falla, edita ~/.config/hypr/hyprland.local.conf"
