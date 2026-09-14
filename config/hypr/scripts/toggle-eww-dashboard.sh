#!/usr/bin/env bash
set -euo pipefail

windows=(
  welcome_text
  active_workspace
  workspace_window_text
  orange_workspace
  four_boxes
  cpu_ram_storage_bars
  power-cooling_header_text
  power_mode_text
  right_fan_data
  ascii_decor_frame
  net_bars
  right_internet_text
)

if ! command -v eww >/dev/null 2>&1; then
  exit 0
fi

if ! eww active-windows >/dev/null 2>&1; then
  eww daemon >/dev/null 2>&1
  sleep 0.2
fi

if eww active-windows 2>/dev/null | grep -q '^welcome_text:'; then
  for window in "${windows[@]}"; do
    eww close "$window" >/dev/null 2>&1 || true
  done
else
  eww open-many "${windows[@]}" >/dev/null 2>&1
fi
