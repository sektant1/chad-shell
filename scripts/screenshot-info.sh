#!/usr/bin/env bash
set -euo pipefail

dir="$HOME/Pictures/Screenshots"
printf 'screenshot_dir=%s\n' "$dir"
printf 'region_command=grim -g "$(slurp)" "%s/screenshot-$(date +%%Y-%%m-%%d-%%H%%M%%S).png"\n' "$dir"
for cmd in grim slurp; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf 'ok %s\n' "$cmd"
  else
    printf 'missing %s\n' "$cmd"
  fi
done
