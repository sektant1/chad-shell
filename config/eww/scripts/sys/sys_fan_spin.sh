#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Script: sys_fan_spin.sh
#  Purpose: Displays fan spinner animation (CPU/GPU)
#  Example:
#      ./sys_fan_spin.sh cpu
# ─────────────────────────────────────────────────────────────────────────────


SPIN=('|' '/' '-' '\\')
fan="$1"

# Simple cache file to track frame index across calls
cache="/tmp/${fan}_fan_frame"

if [ -f "$cache" ]; then
  index=$(<"$cache")
else
  index=0
fi

# Advance frame
index=$(( (index + 1) % ${#SPIN[@]} ))
echo "$index" > "$cache"

echo "${SPIN[$index]}"
