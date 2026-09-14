#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
vpn_script="${DIONYSUS_VPN_SCRIPT:-$SCRIPT_DIR/netextender-connect.expect}"

vpn_active=false
if pgrep -x netExtender >/dev/null 2>&1; then
  vpn_active=true
elif command -v ip >/dev/null 2>&1 && ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -Eq '^(tun|tap|ppp|wg|vpn|tailscale|zt)'; then
  vpn_active=true
fi

if [[ "$vpn_active" == true ]]; then
  pkill -x netExtender >/dev/null 2>&1 || true
  exit 0
fi

if [[ ! -x "$vpn_script" ]]; then
  printf 'VPN script is not executable: %s
' "$vpn_script" >&2
  exit 1
fi

nohup "$vpn_script" >/tmp/dionysus-vpn.log 2>&1 &
