#!/usr/bin/env bash
set -euo pipefail

state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
flag_dir="$state_home/dionysus"
flag="$flag_dir/waybar-hidden"
logfile="$flag_dir/waybar.log"
mkdir -p "$flag_dir"

start_waybar() {
  command -v waybar >/dev/null 2>&1 || exit 0
  pgrep -x waybar >/dev/null 2>&1 && exit 0
  waybar >>"$logfile" 2>&1 &
}

if pgrep -x waybar >/dev/null 2>&1; then
  touch "$flag"
  pkill -x waybar >/dev/null 2>&1 || true
else
  rm -f "$flag"
  start_waybar
fi
