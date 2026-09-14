#!/usr/bin/env bash
set -euo pipefail
# ── brightness-toggle.sh ─────────────────────────────
# Description: Cycle screen brightness between 30%, 60%, and 100%
# Usage: Waybar `custom/brightness` on-click
# Dependencies: brightnessctl
# ─────────────────────────────────────────────────────

if ! command -v brightnessctl >/dev/null 2>&1; then
  exit 0
fi

current=$(brightnessctl get 2>/dev/null || printf '0')
max=$(brightnessctl max 2>/dev/null || printf '0')
[[ "$max" =~ ^[0-9]+$ ]] || max=0
((max > 0)) || exit 0
percent=$((current * 100 / max))

if [ "$percent" -lt 45 ]; then
  brightnessctl set 60%
elif [ "$percent" -lt 85 ]; then
  brightnessctl set 100%
else
  brightnessctl set 30%
fi
