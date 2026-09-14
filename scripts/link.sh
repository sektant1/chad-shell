#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib.sh
. "$REPO_DIR/scripts/lib.sh"

if (($# != 2)); then
  log_error "usage: scripts/link.sh SRC DEST"
  exit 2
fi

link_path "$1" "$2" "$REPO_DIR/backup-link-$(date +%Y%m%d-%H%M%S)" true false
