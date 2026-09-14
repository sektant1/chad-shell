#!/usr/bin/env bash
set -euo pipefail

home_dir="${HOME:-}"
if [[ -z "$home_dir" ]]; then
    home_dir="$(getent passwd "$(id -un 2>/dev/null || printf '%s' user)" | cut -d: -f6)"
fi
home_dir="${home_dir:-$PWD}"

if command -v xdg-open >/dev/null 2>&1; then
    exec ~/.config/waybar/scripts/open-on-workspace.sh xdg-open "$home_dir"
fi

for file_manager in thunar nautilus dolphin nemo pcmanfm; do
    if command -v "$file_manager" >/dev/null 2>&1; then
        exec ~/.config/waybar/scripts/open-on-workspace.sh "$file_manager" "$home_dir"
    fi
done

if command -v notify-send >/dev/null 2>&1; then
    notify-send "File manager unavailable" "Install xdg-utils or a file manager to open your home directory."
fi
