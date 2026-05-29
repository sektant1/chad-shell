#!/usr/bin/env bash
set -euo pipefail

internal="eDP-1"
external="HDMI-A-1"

has_external=false
if hyprctl monitors 2>/dev/null | grep -q "^Monitor ${external}"; then
  has_external=true
fi

if [[ "$has_external" == true ]]; then
  hyprctl keyword monitor "${external}, 1920x1080@120.00, 0x0, 1" >/dev/null
  hyprctl keyword monitor "${internal}, preferred, 1920x0, 1" >/dev/null

  for workspace in 1 2 3 4; do
    default=
    [[ "$workspace" == 1 ]] && default=", default:true"
    hyprctl keyword workspace "${workspace}, monitor:${external}, persistent:true${default}" >/dev/null
  done

  for workspace in 5 6 7 8 9; do
    hyprctl keyword workspace "${workspace}, monitor:${internal}" >/dev/null
  done
else
  hyprctl keyword monitor "${internal}, preferred, 0x0, 1" >/dev/null

  for workspace in 1 2 3 4; do
    default=
    [[ "$workspace" == 1 ]] && default=", default:true"
    hyprctl keyword workspace "${workspace}, monitor:${internal}, persistent:true${default}" >/dev/null
  done

  for workspace in 5 6 7 8 9; do
    hyprctl keyword workspace "${workspace}, monitor:${internal}" >/dev/null
  done
fi
