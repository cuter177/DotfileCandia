#!/usr/bin/env bash
set -euo pipefail

# Independent Zsh + Kitty installer. Works on Arch, Debian/Ubuntu and Fedora.
# Also called from install.sh for the full Arch rice.

# shellcheck source=common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

NVM_VERSION="v0.39.7"
OMZ_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

usage() {
  cat <<'EOF'
Uso: shell.sh [--dry-run] [--skip-kitty] [--skip-nvm]

Instala Zsh, Oh My Zsh, plugins, .zshrc y (por defecto) Kitty.
Funciona en Arch, Debian/Ubuntu y Fedora. No instala Hyprland.

  --dry-run      muestra comandos sin ejecutarlos
  --skip-kitty   no instala ni copia Kitty
  --skip-nvm     no instala NVM
EOF
}

install_arch_shell_pkgs() {
  local pkgs=(zsh git curl eza kitty ttf-jetbrains-mono-nerd fastfetch playerctl)
  if [[ "$SKIP_KITTY" -eq 1 ]]; then
    pkgs=(zsh git curl eza ttf-jetbrains-mono-nerd fastfetch playerctl)
  fi
  log "paquetes shell (pacman)"
  run sudo pacman -S --needed --noconfirm "${pkgs[@]}"
}

apt_has() {
  apt-cache show "$1" >/dev/null 2>&1
}

install_debian_shell_pkgs() {
  local required=(zsh git curl)
  local optional=(eza fastfetch playerctl fonts-jetbrains-mono)
  if [[ "$SKIP_KITTY" -eq 0 ]]; then
    required+=(kitty)
  fi
  log "apt-get update"
  run sudo apt-get update
  log "paquetes shell (apt)"
  run sudo apt-get install -y "${required[@]}"
  local pkg
  for pkg in "${optional[@]}"; do
    if apt_has "$pkg"; then
      run sudo apt-get install -y "$pkg"
    else
      warn "paquete opcional no disponible: $pkg"
    fi
  done
}

dnf_has() {
  dnf list --available "$1" >/dev/null 2>&1 || dnf list --installed "$1" >/dev/null 2>&1
}

install_fedora_shell_pkgs() {
  local required=(zsh git curl)
  local optional=(eza fastfetch playerctl jetbrains-mono-fonts)
  if [[ "$SKIP_KITTY" -eq 0 ]]; then
    required+=(kitty)
  fi
  log "paquetes shell (dnf)"
  run sudo dnf install -y "${required[@]}"
  local pkg
  for pkg in "${optional[@]}"; do
    if [[ "$DRY_RUN" -eq 1 ]] || dnf_has "$pkg"; then
      run sudo dnf install -y "$pkg" || warn "no se pudo instalar $pkg"
    else
      warn "paquete opcional no disponible: $pkg"
    fi
  done
}

install_shell_packages() {
  if is_arch; then
    install_arch_shell_pkgs
  elif is_debian; then
    install_debian_shell_pkgs
  elif is_fedora; then
    install_fedora_shell_pkgs
  else
    warn "distro no reconocida ($(os_id)); se omiten paquetes"
    warn "instala a mano: zsh git curl kitty eza fastfetch playerctl y una Nerd Font"
  fi
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ok "Oh My Zsh ya está instalado"
    return 0
  fi
  require_cmd curl
  log "instalando Oh My Zsh"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c omz-install\n'
    return 0
  fi
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL "$OMZ_INSTALL_URL")"
}

install_omz_plugin() {
  local name="$1"
  local url="$2"
  local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"
  if [[ -d "$dest" ]]; then
    ok "plugin $name ya está"
    return 0
  fi
  log "clonando $name"
  run git clone --depth=1 "$url" "$dest"
}

install_zsh_plugins() {
  install_omz_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
  install_omz_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
  install_omz_plugin zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search
}

copy_shell_dotfiles() {
  if [[ -f "$REPO_ROOT/.zshrc" ]]; then
    backup_path "$HOME/.zshrc"
    log "copiando .zshrc"
    run cp "$REPO_ROOT/.zshrc" "$HOME/.zshrc"
  fi
  if [[ -f "$REPO_ROOT/.p10k.zsh" ]]; then
    backup_path "$HOME/.p10k.zsh"
    log "copiando .p10k.zsh"
    run cp "$REPO_ROOT/.p10k.zsh" "$HOME/.p10k.zsh"
  fi
}

copy_kitty() {
  [[ "$SKIP_KITTY" -eq 0 ]] || return 0
  local src="$REPO_ROOT/.config/kitty"
  [[ -d "$src" ]] || return 0
  backup_path "$HOME/.config/kitty"
  log "copiando config de Kitty"
  ensure_dir "$HOME/.config/kitty"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] cp -a %s/. %s/\n' "$src" "$HOME/.config/kitty"
  else
    cp -a "$src"/. "$HOME/.config/kitty/"
    rm -f "$HOME/.config/kitty/"*.bak
  fi
}

install_nvm() {
  [[ "$SKIP_NVM" -eq 0 ]] || return 0
  if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    ok "NVM ya está instalado"
    return 0
  fi
  require_cmd curl
  log "instalando NVM $NVM_VERSION"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] curl nvm %s | bash\n' "$NVM_VERSION"
    return 0
  fi
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
}

change_shell() {
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [[ -z "$zsh_path" ]]; then
    warn "zsh no está en PATH; no se cambia el shell"
    return 0
  fi
  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    ok "el shell ya es zsh"
    return 0
  fi
  log "cambiando shell de login a zsh"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] chsh -s %s\n' "$zsh_path"
    return 0
  fi
  if chsh -s "$zsh_path"; then
    ok "shell cambiado a zsh (aplica en el próximo login)"
  else
    warn "chsh falló; ejecuta: chsh -s $zsh_path"
  fi
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

parse_common_args "$@" || { usage; exit 1; }

install_shell_packages
install_oh_my_zsh
install_zsh_plugins
copy_shell_dotfiles
copy_kitty
install_nvm
change_shell
ok "shell listo"
