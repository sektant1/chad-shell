#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
    exit 64
fi

if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    workspace="$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // empty')"
    if [[ -n "$workspace" ]]; then
        printf -v command '%q ' "$@"
        exec hyprctl dispatch exec "[workspace ${workspace} silent] ${command% }"
    fi
fi

exec "$@"
