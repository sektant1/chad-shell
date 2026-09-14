#!/usr/bin/env bash
# ── mic.sh ─────────────────────────────────────────────────
# Description: Shows microphone mute/unmute status with icon
# Usage: Called by Waybar `custom/microphone` module every 1s
# Dependencies: wpctl (PipeWire) or pactl (PulseAudio / PipeWire)
# ───────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=config/waybar/scripts/common.sh
source "$SCRIPT_DIR/common.sh"

if { command -v wpctl >/dev/null 2>&1 && wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q 'MUTED'; } || { ! command -v wpctl >/dev/null 2>&1 && command -v pactl >/dev/null 2>&1 && pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | grep -q 'yes'; }; then
    json_text "[ <span size='large'></span> ]" "Mic: Muted" "muted"
else
    json_text "[ <span size='large'></span> ]" "Mic: Active" "normal"
fi
