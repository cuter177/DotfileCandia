#!/usr/bin/env bash
# Shared helpers for DotfileCandia install scripts. Sourced, not executed.

if [[ -n "${_DOTFILES_COMMON_LOADED:-}" ]]; then
  return 0
fi
_DOTFILES_COMMON_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")" && pwd)"
# When sourced from scripts/install/*.sh, SCRIPT_DIR should be that folder.
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$INSTALL_DIR/../.." && pwd)"

DRY_RUN=0
SKIP_TERMINAL=0
SKIP_NVM=0
SKIP_APPS=0
FORCE_DISTRO=""
FORCE_TERMINAL=""

SUPPORTED_TERMINALS=(kitty ghostty wezterm alacritty konsole gnome-terminal xterm)

if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BLUE=$'\033[1;34m'
  C_GREEN=$'\033[1;32m'
  C_YELLOW=$'\033[1;33m'
  C_RED=$'\033[1;31m'
else
  C_RESET="" C_BLUE="" C_GREEN="" C_YELLOW="" C_RED=""
fi

log()  { printf '%s==>%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
ok()   { printf '%sOK%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '%s!!%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err()  { printf '%serror:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }

die() {
  err "$*"
  exit 1
}

parse_common_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --skip-kitty|--skip-terminal) SKIP_TERMINAL=1 ;;
      --skip-nvm) SKIP_NVM=1 ;;
      --skip-apps) SKIP_APPS=1 ;;
      --arch) FORCE_DISTRO=arch ;;
      --debian) FORCE_DISTRO=debian ;;
      --wsl) FORCE_DISTRO=wsl ;;
      --gentoo) FORCE_DISTRO=gentoo ;;
      --redhat) FORCE_DISTRO=redhat ;;
      --terminal) shift; FORCE_TERMINAL="${1:-}"; [[ -n "$FORCE_TERMINAL" ]] || { warn "--terminal requiere un valor"; return 2; } ;;
      --terminal=*) FORCE_TERMINAL="${1#*=}" ;;
      -h|--help) return 2 ;;
      *)
        warn "argumento desconocido: $1"
        return 2
        ;;
    esac
    shift
  done
}

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

os_id() {
  local id=""
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    id="$(. /etc/os-release && echo "${ID:-}")"
  fi
  printf '%s\n' "$id"
}

os_like() {
  local like=""
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    like="$(. /etc/os-release && echo "${ID_LIKE:-}")"
  fi
  printf '%s\n' "$like"
}

is_arch() {
  [[ "$FORCE_DISTRO" == "arch" ]] && return 0
  [[ -n "$FORCE_DISTRO" ]] && return 1
  local id like
  id="$(os_id)"
  like="$(os_like)"
  [[ "$id" == "arch" || "$id" == "cachyos" || "$id" == "endeavouros" || "$like" == *arch* ]]
}

is_debian() {
  [[ "$FORCE_DISTRO" == "debian" ]] && return 0
  [[ -n "$FORCE_DISTRO" ]] && return 1
  local id like
  id="$(os_id)"
  like="$(os_like)"
  [[ "$id" == "debian" || "$id" == "ubuntu" || "$id" == "linuxmint" || "$like" == *debian* ]]
}

is_fedora() {
  [[ "$FORCE_DISTRO" == "redhat" ]] && return 0
  [[ -n "$FORCE_DISTRO" ]] && return 1
  local id like
  id="$(os_id)"
  like="$(os_like)"
  [[ "$id" == "fedora" || "$id" == "nobara" || "$like" == *fedora* ]]
}

is_redhat() {
  [[ "$FORCE_DISTRO" == "redhat" ]] && return 0
  [[ -n "$FORCE_DISTRO" ]] && return 1
  local id like
  id="$(os_id)"
  like="$(os_like)"
  [[ "$id" == "fedora" || "$id" == "rhel" || "$id" == "centos" || "$id" == "rocky" || "$id" == "almalinux" || "$id" == "nobara" || "$like" == *fedora* || "$like" == *rhel* ]]
}

is_gentoo() {
  [[ "$FORCE_DISTRO" == "gentoo" ]] && return 0
  [[ -n "$FORCE_DISTRO" ]] && return 1
  local id like
  id="$(os_id)"
  like="$(os_like)"
  [[ "$id" == "gentoo" || "$like" == *gentoo* ]]
}

is_wsl() {
  [[ "$FORCE_DISTRO" == "wsl" ]] && return 0
  [[ -n "$FORCE_DISTRO" ]] && return 1
  [[ -n "${WSL_DISTRO_NAME:-}" || -n "${WSL_INTEROP:-}" ]] && return 0
  [[ -r /proc/version ]] && grep -qiE 'microsoft|wsl' /proc/version
}

terminal_installed() {
  command -v "$1" >/dev/null 2>&1
}

detect_terminal() {
  if [[ -n "$FORCE_TERMINAL" ]]; then
    printf '%s\n' "$FORCE_TERMINAL"
    return 0
  fi
  [[ -n "${KITTY_WINDOW_ID:-}" ]] && { printf 'kitty\n'; return 0; }
  [[ -n "${GHOSTTY_RESOURCES_DIR:-}" || -n "${GHOSTTY_BIN_DIR:-}" || "${TERM_PROGRAM:-}" == "ghostty" ]] && { printf 'ghostty\n'; return 0; }
  [[ -n "${WEZTERM_PANE:-}" || "${TERM_PROGRAM:-}" == "WezTerm" ]] && { printf 'wezterm\n'; return 0; }
  [[ -n "${ALACRITTY_WINDOW_ID:-}" || "${TERM:-}" == "alacritty" ]] && { printf 'alacritty\n'; return 0; }
  [[ -n "${KONSOLE_VERSION:-}" ]] && { printf 'konsole\n'; return 0; }
  [[ -n "${VTE_VERSION:-}" && "${TERM_PROGRAM:-}" == "gnome-terminal" ]] && { printf 'gnome-terminal\n'; return 0; }
  local term
  for term in "${SUPPORTED_TERMINALS[@]}"; do
    terminal_installed "$term" && { printf '%s\n' "$term"; return 0; }
  done
  printf '\n'
}

terminal_package() {
  local term="$1" distro="${2:-}"
  case "$distro:$term" in
    gentoo:kitty) printf 'x11-terms/kitty\n' ;;
    gentoo:ghostty) printf 'x11-terms/ghostty\n' ;;
    gentoo:wezterm) printf 'x11-terms/wezterm\n' ;;
    gentoo:alacritty) printf 'x11-terms/alacritty\n' ;;
    gentoo:konsole) printf 'kde-apps/konsole\n' ;;
    gentoo:gnome-terminal) printf 'x11-terms/gnome-terminal\n' ;;
    gentoo:xterm) printf 'x11-apps/xterm\n' ;;
    *) printf '%s\n' "$term" ;;
  esac
}

aur_helper() {
  if command -v yay >/dev/null 2>&1; then
    printf 'yay\n'
  elif command -v paru >/dev/null 2>&1; then
    printf 'paru\n'
  else
    printf '\n'
  fi
}

backup_path() {
  local src="$1"
  local dest="${src}.bak-$(date +%Y%m%d)"
  if [[ ! -e "$src" ]]; then
    return 0
  fi
  if [[ -e "$dest" ]]; then
    return 0
  fi
  log "backup $src -> $dest"
  run cp -a "$src" "$dest"
}

ensure_dir() {
  run mkdir -p "$1"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "hace falta el comando '$1'"
}
