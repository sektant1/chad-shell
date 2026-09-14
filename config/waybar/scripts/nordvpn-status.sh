#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=config/waybar/scripts/common.sh
source "$SCRIPT_DIR/common.sh"

vpn_up=false

if pgrep -x netExtender >/dev/null 2>&1; then
    vpn_up=true
elif command -v ip >/dev/null 2>&1; then
    if ip -o link show 2>/dev/null | grep -Eq "^[0-9]+: (tun|tap|ppp|wg|vpn|tailscale|zt)"; then
        vpn_up=true
    fi
fi

if [[ "$vpn_up" == true ]]; then
    json_text "[ <span size='large'>󰖂</span> ]" "VPN connected" "normal"
else
    json_text "[ <span size='large'>󰦝</span> ]" "VPN disconnected" "standby"
fi
