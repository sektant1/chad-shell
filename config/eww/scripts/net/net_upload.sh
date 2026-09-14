#!/usr/bin/env bash
set -euo pipefail

iface="${DIONYSUS_NET_IFACE:-}"
max_speed="${DIONYSUS_NET_MAX_BYTES:-12500000}"

if [[ -z "$iface" ]] && command -v ip >/dev/null 2>&1; then
  iface="$(ip route get 1.1.1.1 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($i == "dev") {print $(i+1); exit}}')"
fi

if [[ -z "$iface" || ! -r /proc/net/dev ]]; then
  printf '0\n'
  exit 0
fi

tx1="$(awk -v iface="$iface" '$1 ~ "^" iface ":" {gsub(":", "", $1); print $10}' /proc/net/dev)"
sleep 1
tx2="$(awk -v iface="$iface" '$1 ~ "^" iface ":" {gsub(":", "", $1); print $10}' /proc/net/dev)"
tx1="${tx1:-0}"
tx2="${tx2:-0}"
[[ "$max_speed" =~ ^[0-9]+$ ]] || max_speed=12500000
((max_speed <= 0)) && max_speed=12500000

percent=$(((tx2 - tx1) * 100 / max_speed))
((percent > 100)) && percent=100
((percent < 0)) && percent=0
printf '%s\n' "$percent"

