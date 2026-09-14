#!/usr/bin/env bash
set -euo pipefail

internal="eDP-1"
external=$(hyprctl monitors 2>/dev/null | awk -v internal="$internal" '/^Monitor / && $2 != internal { print $2; exit }')

best_mode() {
    local monitor=$1 mode

    mode=$(hyprctl monitors all 2>/dev/null | awk -v name="$monitor" '
        $1 == "Monitor" { in_block = ($2 == name); next }
        in_block && /availableModes:/ {
            sub(/^.*availableModes:[[:space:]]*/, "")
            best_mode = ""
            best_hz = -1

            for (i = 1; i <= NF; i++) {
                split($i, parts, "@")
                hz = parts[2]
                sub(/Hz$/, "", hz)

                if ((hz + 0) > best_hz) {
                    best_hz = hz + 0
                    best_mode = parts[1] "@" hz
                }
            }

            print best_mode
            exit
        }
    ')

    printf '%s\n' "${mode:-preferred}"
}

if [[ -n "$external" ]]; then
    external_mode=$(best_mode "$external")

    hyprctl keyword monitor "${external}, ${external_mode}, 0x0, 1" >/dev/null
    hyprctl keyword monitor "${internal}, preferred, 1920x0, 1" >/dev/null

    for workspace in 1 2 3 4; do
        default=
        [[ "$workspace" == 1 ]] && default=", default:true"
        hyprctl keyword workspace "${workspace}, monitor:${external}, persistent:true${default}" >/dev/null
    done

    for workspace in 5 6 7 8 9; do
        hyprctl keyword workspace "${workspace}, monitor:${external}" >/dev/null
    done

    hyprctl dispatch focusmonitor "$external" >/dev/null
    hyprctl dispatch workspace 1 >/dev/null
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
