#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=config/waybar/scripts/common.sh
source "$SCRIPT_DIR/common.sh"

backlight="${DIONYSUS_BACKLIGHT_DEVICE:-}"
if [[ -n "$backlight" ]]; then
  backlight="/sys/class/backlight/$backlight"
else
  for candidate in /sys/class/backlight/*; do
    [[ -r "$candidate/brightness" && -r "$candidate/max_brightness" ]] || continue
    backlight=$candidate
    break
  done
fi

if [[ -z "${backlight:-}" || ! -r "$backlight/brightness" || ! -r "$backlight/max_brightness" ]]; then
  json_text "" "No backlight device detected" "hidden"
  exit 0
fi

IFS= read -r brightness <"$backlight/brightness" 2>/dev/null || brightness=0
IFS= read -r max_brightness <"$backlight/max_brightness" 2>/dev/null || max_brightness=0
[[ "$brightness" =~ ^[0-9]+$ ]] || brightness=0
[[ "$max_brightness" =~ ^[0-9]+$ ]] || max_brightness=0
if ((max_brightness <= 0)); then
  json_text "" "No backlight device detected" "hidden"
  exit 0
fi

percent=$((brightness * 100 / max_brightness))
((percent > 100)) && percent=100
device="${backlight##*/}"

if ((percent < 55)); then
  class="warning"
else
  class="normal"
fi

text="[ <span size='large'></span> ${percent}% ]"
tooltip="Brightness: ${percent}%\nDevice: ${device}"
json_text "$text" "$tooltip" "$class"
