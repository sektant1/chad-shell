#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib.sh
. "$REPO_DIR/scripts/lib.sh"

if command_exists hyprctl && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  hyprctl reload && log_ok "Hyprland reloaded"
else
  log_warn "Hyprland session not detected; skipped hyprctl reload"
fi

if command_exists waybar; then
  if command_exists pkill; then
    pkill -x waybar 2>/dev/null || true
  fi
  setsid waybar >/tmp/dionysus-waybar.log 2>&1 &
  log_ok "Waybar restarted"
else
  log_warn "waybar not found"
fi

if command_exists rofi; then
  log_ok "Rofi config ready; no daemon reload needed"
else
  log_warn "rofi not found"
fi
