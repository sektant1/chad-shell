#!/usr/bin/env bash
set -euo pipefail

screenshot_dir="$HOME/Pictures/Screenshots"
mkdir -p "$screenshot_dir"
file="$screenshot_dir/screenshot-$(date +%Y-%m-%d-%H%M%S).png"

if ! command -v grim >/dev/null 2>&1; then
  printf 'grim is not installed
' >&2
  exit 1
fi

if command -v slurp >/dev/null 2>&1; then
  area="$(slurp 2>/dev/null || true)"
  [[ -n "$area" ]] || exit 0
  grim -g "$area" "$file"
else
  grim "$file"
fi

if command -v wl-copy >/dev/null 2>&1; then
  wl-copy <"$file" || true
fi

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl notify 1 2500 'rgb(61afef)' "Screenshot saved: ${file##*/}" >/dev/null 2>&1 || true
fi
