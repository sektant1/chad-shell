#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=dotfiles/waybar/scripts/common.sh
source "$SCRIPT_DIR/common.sh"

if ! has_cmd wpctl; then
    json_text "" "wpctl not installed" "hidden"
    exit 0
fi

volume_line="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
if [[ -z "$volume_line" ]]; then
    json_text "" "No default audio sink" "hidden"
    exit 0
fi

vol_raw="$(awk '{print $2}' <<<"$volume_line")"
vol_int="$(awk -v v="$vol_raw" 'BEGIN {printf "%d", v * 100}')"
((vol_int > 150)) && vol_int=150
bar_percent=$vol_int
((bar_percent > 100)) && bar_percent=100
is_muted=false
[[ "$volume_line" == *MUTED* ]] && is_muted=true

sink="$(wpctl status 2>/dev/null | awk '/Sinks:/,/Sources:/' | awk '/\*/ {sub(/^.*\* */, ""); sub(/\[.*$/, ""); print; exit}')"
sink="${sink:-unknown}"

if [[ "$is_muted" == true ]]; then
    label=""
    vol_int=0
    class="muted"
elif ((vol_int < 50)); then
    label=""
    class="warning"
else
    label=""
    class="normal"
fi

text="[ <span size='large'>$label</span> ${vol_int}% ]"
tooltip="Audio: ${vol_int}%\nOutput: ${sink}"
[[ "$is_muted" == true ]] && tooltip="Audio: Muted\nOutput: ${sink}"
json_text "$text" "$tooltip" "$class"
