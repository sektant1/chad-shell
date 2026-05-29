#!/usr/bin/env bash
set -euo pipefail

if [[ "$("${BASH_SOURCE%/*}/net_vpn.sh" 2>/dev/null || printf '0')" == "100" ]]; then
  printf '%s\n' 'VPN ON'
else
  printf '%s\n' 'VPN OFF'
fi
