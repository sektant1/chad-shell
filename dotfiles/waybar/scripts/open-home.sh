#!/usr/bin/env bash
set -euo pipefail

home_dir="${HOME:-}"
if [[ -z "$home_dir" ]]; then
    user_name="$(id -un 2>/dev/null || printf '%s' user)"
    home_dir="/home/$user_name"
fi

if command -v xdg-open >/dev/null 2>&1; then
    exec xdg-open "$home_dir"
fi

for file_manager in thunar nautilus dolphin nemo pcmanfm; do
    if command -v "$file_manager" >/dev/null 2>&1; then
        exec "$file_manager" "$home_dir"
    fi
done

if command -v notify-send >/dev/null 2>&1; then
    notify-send "File manager unavailable" "Install xdg-utils or a file manager to open your home directory."
fi
