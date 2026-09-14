#!/usr/bin/env bash
set -euo pipefail

if pgrep -x netExtender >/dev/null 2>&1; then
  printf '%s\n' '100'
elif command -v ip >/dev/null 2>&1 && ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -Eq '^(tun|tap|wg|vpn|tailscale|zt)'; then
  printf '%s\n' '100'
else
  printf '%s\n' '0'
fi
