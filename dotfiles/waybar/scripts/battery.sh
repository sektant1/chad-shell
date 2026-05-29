#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=dotfiles/waybar/scripts/common.sh
source "$SCRIPT_DIR/common.sh"

if ! battery_path="$(first_battery)"; then
  json_text "" "No battery detected" "hidden"
  exit 0
fi

capacity="$(cat "$battery_path/capacity" 2>/dev/null || printf '0')"
status="$(cat "$battery_path/status" 2>/dev/null || printf 'Unknown')"
[[ "$capacity" =~ ^[0-9]+$ ]] || capacity=0
((capacity > 100)) && capacity=100

if [[ "$status" == "Charging" ]]; then
  icon=""
elif ((capacity >= 90)); then
  icon=""
elif ((capacity >= 65)); then
  icon=""
elif ((capacity >= 40)); then
  icon=""
elif ((capacity >= 20)); then
  icon=""
else
  icon=""
fi

if ((capacity < 20)); then
  class="critical"
elif ((capacity < 55)); then
  class="warning"
else
  class="normal"
fi

tooltip="Battery: ${capacity}%\nStatus: ${status}\nDevice: ${battery_path##*/}"
text="[ <span size='large'>$icon</span> ${capacity}% ]"
json_text "$text" "$tooltip" "$class"

