#!/usr/bin/env bash
set -euo pipefail

mode=${1:-download}
cache="${XDG_RUNTIME_DIR:-/tmp}/dionysus-net-sample"
lock="${cache}.lock"
max_speed="${DIONYSUS_NET_MAX_BYTES:-12500000}"
ttl="${DIONYSUS_NET_SAMPLE_TTL:-2}"

bar() {
  local percent=${1:-0} lines=5 filled row i
  [[ "$percent" =~ ^[0-9]+$ ]] || percent=0
  ((percent > 100)) && percent=100
  filled=$(((percent * lines + 99) / 100))
  ((percent == 0)) && filled=0

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
  IFS=' ' read -r cached_at upload download <"$cache" || return 1
  [[ "${cached_at:-}" =~ ^[0-9]+$ ]] || return 1
  (($(date +%s) - cached_at < ttl)) || return 1
}

iface_name() {
  if [[ -n "${DIONYSUS_NET_IFACE:-}" ]]; then
    printf '%s\n' "$DIONYSUS_NET_IFACE"
  elif command -v ip >/dev/null 2>&1; then
    ip route get 1.1.1.1 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($i == "dev") {print $(i+1); exit}}'
  fi
}

sample() {
  local iface rx1 tx1 rx2 tx2 now

  iface=$(iface_name)
  if [[ -z "$iface" || ! -r /proc/net/dev ]]; then
    printf '%s 0 0\n' "$(date +%s)" >"$cache"
    return
  fi

  read -r rx1 tx1 < <(awk -v iface="$iface" '$1 ~ "^" iface ":" {gsub(":", "", $1); print $2, $10}' /proc/net/dev)
  sleep 1
  read -r rx2 tx2 < <(awk -v iface="$iface" '$1 ~ "^" iface ":" {gsub(":", "", $1); print $2, $10}' /proc/net/dev)

  rx1=${rx1:-0}; tx1=${tx1:-0}; rx2=${rx2:-0}; tx2=${tx2:-0}
  [[ "$max_speed" =~ ^[0-9]+$ ]] || max_speed=12500000
  ((max_speed <= 0)) && max_speed=12500000

  download=$(((rx2 - rx1) * 100 / max_speed))
  upload=$(((tx2 - tx1) * 100 / max_speed))
  ((download > 100)) && download=100
  ((upload > 100)) && upload=100
  ((download < 0)) && download=0
  ((upload < 0)) && upload=0
  now=$(date +%s)
  printf '%s %s %s\n' "$now" "$upload" "$download" >"$cache"
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

upload=${upload:-0}
download=${download:-0}

case "$mode" in
  upload) printf '%s\n' "$upload" ;;
  download) printf '%s\n' "$download" ;;
  upload_bar) bar "$upload" ;;
  download_bar) bar "$download" ;;
  *)
    printf 'usage: %s [upload|download|upload_bar|download_bar]\n' "${0##*/}" >&2
    exit 2
    ;;
esac
