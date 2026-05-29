#!/bin/bash
# workspace-6.sh — highlight workspace 6 if active

active=$(hyprctl activeworkspace -j | jq '.id')

if [ "$active" -eq 6 ]; then
    echo "[●]"
else
    echo "[Г]"
fi
