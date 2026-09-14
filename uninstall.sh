#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
. "$REPO_DIR/scripts/lib.sh"

dry_run=false

usage() {
  cat <<'EOF'
Usage: ./uninstall.sh [--dry-run] [--help]

Removes only ~/.config symlinks that point into this repository.
Copied configs and user-owned files are never deleted.
EOF
}

while (($#)); do
  case "$1" in
    --dry-run) dry_run=true ;;
    --help|-h) usage; exit 0 ;;
    *) log_error "unknown option: $1"; usage; exit 2 ;;
  esac
  shift
done

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

for src in "$REPO_DIR"/config/*; do
  [[ -d "$src" ]] || continue
  name=$(basename -- "$src")
  dest="$config_home/$name"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    if [[ "$dry_run" == true ]]; then
      printf '+ rm %q\n' "$dest"
    else
      rm "$dest"
    fi
    log_ok "removed repo symlink: $dest"
  elif [[ -e "$dest" || -L "$dest" ]]; then
    log_info "kept non-repo target: $dest"
  fi
done

log_info "restore backups manually from ./backup-install-* or ./backup-before-refactor-* if needed"
