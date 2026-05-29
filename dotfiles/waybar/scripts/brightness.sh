#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=dotfiles/waybar/scripts/common.sh
source "$SCRIPT_DIR/common.sh"

if ! has_cmd brightnessctl; then
  json_text "" "brightnessctl not installed" "hidden"
  exit 0
fi

brightness="$(brightnessctl get 2>/dev/null || printf '0')"
max_brightness="$(brightnessctl max 2>/dev/null || printf '0')"
[[ "$brightness" =~ ^[0-9]+$ ]] || brightness=0
[[ "$max_brightness" =~ ^[0-9]+$ ]] || max_brightness=0
if ((max_brightness <= 0)); then
  json_text "" "No backlight device detected" "hidden"
  exit 0
fi

percent=$((brightness * 100 / max_brightness))
((percent > 100)) && percent=100
device="$(brightnessctl --machine-readable 2>/dev/null | awk -F, 'NR==1 {print $1}')"
device="${device:-unknown}"

if ((percent < 20)); then
  class="critical"
elif ((percent < 55)); then
  class="warning"
else
  class="normal"
fi

text="[ <span size='large'></span> ${percent}% ]"
tooltip="Brightness: ${percent}%\nDevice: ${device}"
json_text "$text" "$tooltip" "$class"

