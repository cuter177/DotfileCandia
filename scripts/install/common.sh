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
SKIP_KITTY=0
SKIP_NVM=0
SKIP_APPS=0

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
      --skip-kitty) SKIP_KITTY=1 ;;
      --skip-nvm) SKIP_NVM=1 ;;
      --skip-apps) SKIP_APPS=1 ;;
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
  local id like
  id="$(os_id)"
  like="$(os_like)"
  [[ "$id" == "arch" || "$id" == "cachyos" || "$id" == "endeavouros" || "$like" == *arch* ]]
}

is_debian() {
  local id like
  id="$(os_id)"
  like="$(os_like)"
  [[ "$id" == "debian" || "$id" == "ubuntu" || "$id" == "linuxmint" || "$like" == *debian* ]]
}

is_fedora() {
  local id like
  id="$(os_id)"
  like="$(os_like)"
  [[ "$id" == "fedora" || "$id" == "nobara" || "$like" == *fedora* ]]
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
