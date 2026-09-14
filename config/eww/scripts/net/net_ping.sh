#!/usr/bin/env bash
set -euo pipefail
# ─────────────────────────────────────────────────────────────────────────────
#  net_ping.sh
#  Measures ICMP ping latency to 1.1.1.1 and outputs the result in milliseconds.
#  If the host is unreachable, prints "0".
#
#  Usage: ./net_ping.sh
#  Example: ./net_ping.sh → 24   (ms)
#
#  Requires: ping (iputils)
# ─────────────────────────────────────────────────────────────────────────────

mode=${1:-value}
cache="${XDG_RUNTIME_DIR:-/tmp}/dionysus-net-ping"
lock="${cache}.lock"
ttl="${DIONYSUS_PING_SAMPLE_TTL:-8}"

bar() {
  local ms=${1:-0} lines=5 max_ms=200 percent filled row i
  [[ "$ms" =~ ^[0-9]+$ ]] || ms=0
  percent=$((ms * 100 / max_ms))
  ((percent > 100)) && percent=100
  filled=$(((percent * lines + 99) / 100))
  ((ms == 0)) && filled=0

  for ((i = 0; i < lines; i++)); do
    row=$((lines - i))
    if ((row <= filled)); then
      if ((row == filled)); then
        printf '╽\n'
      else
        printf '█\n'
      fi
    else
      printf '│\n'
    fi
  done
}

read_cache() {
  [[ -r "$cache" ]] || return 1
  IFS=' ' read -r cached_at ms <"$cache" || return 1
  [[ "${cached_at:-}" =~ ^[0-9]+$ ]] || return 1
  (($(date +%s) - cached_at < ttl)) || return 1
}

sample() {
  local value
  value=$(ping -c 1 -w 1 1.1.1.1 2>/dev/null | awk -F'time=' '/time=/ {print int($2); found=1} END {if (!found) print 0}')
  printf '%s %s\n' "$(date +%s)" "${value:-0}" >"$cache"
}

if ! read_cache; then
  if mkdir "$lock" 2>/dev/null; then
    trap 'rmdir "$lock" 2>/dev/null || true' EXIT
    sample
    read_cache || true
  else
    for _ in 1 2 3 4 5 6 7 8 9 10; do
      sleep 0.1
      read_cache && break
    done
  fi
fi

ms=${ms:-0}

case "$mode" in
  value) printf '%s\n' "$ms" ;;
  bar) bar "$ms" ;;
  *)
    printf 'usage: %s [value|bar]\n' "${0##*/}" >&2
    exit 2
    ;;
esac
