#!/usr/bin/env bash
set -euo pipefail

lines=5
value="$("${BASH_SOURCE%/*}/net_vpn.sh" 2>/dev/null || printf '0')"
glyph="|"
[[ "$value" == "100" ]] && glyph="#"

for ((i = 0; i < lines; i++)); do
  printf '%s\n' "$glyph"
done

