#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib.sh
. "$REPO_DIR/scripts/lib.sh"

backup_dir="$REPO_DIR/backup-manual-$(date +%Y%m%d-%H%M%S)"
ensure_dir "$backup_dir" false
for path in "$@"; do
  [[ -e "$path" || -L "$path" ]] || { log_warn "missing: $path"; continue; }
  backup_path "$path" "$backup_dir" false
done
log_ok "backup: $backup_dir"
