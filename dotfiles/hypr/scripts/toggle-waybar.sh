#!/usr/bin/env bash
set -euo pipefail

state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
flag_dir="$state_home/dionysus"
flag="$flag_dir/waybar-hidden"
mkdir -p "$flag_dir"

if pgrep -x waybar >/dev/null 2>&1; then
  touch "$flag"
  pkill -x waybar >/dev/null 2>&1 || true
else
  rm -f "$flag"
  waybar >/dev/null 2>&1 &
fi
