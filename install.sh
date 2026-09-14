#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
. "$REPO_DIR/scripts/lib.sh"

dry_run=false
install_packages=true
copy_mode=false
force=false

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --dry-run      Print actions without changing files
  --no-packages  Skip apt package installation
  --copy         Copy configs instead of symlinking
  --force        Backup and replace existing targets
  --help         Show this help
EOF
}

while (($#)); do
  case "$1" in
    --dry-run) dry_run=true ;;
    --no-packages) install_packages=false ;;
    --copy) copy_mode=true ;;
    --force) force=true ;;
    --help|-h) usage; exit 0 ;;
    *) log_error "unknown option: $1"; usage; exit 2 ;;
  esac
  shift
done

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
backup_root="$REPO_DIR/backup-install-$(date +%Y%m%d-%H%M%S)"
distro="$(detect_distro)"

log_info "repo: $REPO_DIR"
log_info "distro: $distro"
log_info "config target: $config_home"

if [[ "$install_packages" == true ]]; then
  if [[ "$distro" == ubuntu || "$distro" == debian || "$distro" == linuxmint || "$distro" == pop ]]; then
    if command_exists apt-get; then
      mapfile -t apt_packages < <(grep -Ev '^\s*($|#)' "$REPO_DIR/packages/apt.txt" || true)
      if ((${#apt_packages[@]})); then
        if [[ "$dry_run" == true ]]; then
          printf '+ sudo apt-get update\n'
          printf '+ sudo apt-get install -y'
          printf ' %q' "${apt_packages[@]}"
          printf '\n'
        else
          sudo apt-get update
          sudo apt-get install -y "${apt_packages[@]}"
        fi
      fi
    else
      log_warn "apt-get not found; skipping packages"
    fi
  else
    log_warn "non-Debian distro detected; skipping apt packages"
  fi
fi

ensure_dir "$config_home" "$dry_run"

for src in "$REPO_DIR"/config/*; do
  [[ -d "$src" ]] || continue
  name=$(basename -- "$src")
  dest="$config_home/$name"
  if [[ "$copy_mode" == true ]]; then
    copy_path "$src" "$dest" "$backup_root" "$force" "$dry_run"
  else
    link_path "$src" "$dest" "$backup_root" "$force" "$dry_run"
  fi
done

log_ok "install complete"
log_info "backups, if any: $backup_root"
