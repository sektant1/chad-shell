#!/usr/bin/env bash
set -euo pipefail

# Open the first available audio configuration UI.
if command -v pavucontrol >/dev/null 2>&1; then
    exec pavucontrol
fi

if command -v pwvucontrol >/dev/null 2>&1; then
    exec pwvucontrol
fi

terminal="${TERMINAL:-alacritty}"
if command -v alsamixer >/dev/null 2>&1 && command -v "$terminal" >/dev/null 2>&1; then
    exec "$terminal" -e alsamixer
fi

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Audio settings unavailable" "Install pavucontrol or pwvucontrol to open a sound settings UI."
fi
