#!/usr/bin/env bash

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

xdg_config_home() {
  printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}"
}

xdg_data_home() {
  printf '%s\n' "${XDG_DATA_HOME:-$HOME/.local/share}"
}

xdg_cache_home() {
  printf '%s\n' "${XDG_CACHE_HOME:-$HOME/.cache}"
}

xdg_state_home() {
  printf '%s\n' "${XDG_STATE_HOME:-$HOME/.local/state}"
}

dionysus_local_env() {
  printf '%s/dionysus/local.env\n' "$(xdg_config_home)"
}

load_local_env() {
  local env_file
  env_file="$(dionysus_local_env)"
  if [[ -f "$env_file" ]]; then
    # shellcheck disable=SC1090
    source "$env_file"
  fi
}

detect_distro() {
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    printf '%s\n' "${ID:-unknown}"
  else
    printf '%s\n' "unknown"
  fi
}

json_escape() {
  local value=${1-}
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/}
  printf '%s' "$value"
}

clamp_int() {
  local value=${1:-0} min=${2:-0} max=${3:-100}
  [[ "$value" =~ ^-?[0-9]+$ ]] || value=0
  (( value < min )) && value=$min
  (( value > max )) && value=$max
  printf '%s\n' "$value"
}

active_network_interface() {
  local iface
  if has_cmd ip; then
    iface="$(ip route get 1.1.1.1 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($i == "dev") {print $(i+1); exit}}')"
    if [[ -n "$iface" && -d "/sys/class/net/$iface" ]]; then
      printf '%s\n' "$iface"
      return 0
    fi
  fi

  for iface in /sys/class/net/*; do
    [[ -e "$iface" ]] || continue
    iface=${iface##*/}
    [[ "$iface" == "lo" ]] && continue
    [[ -r "/sys/class/net/$iface/operstate" ]] || continue
    if [[ "$(cat "/sys/class/net/$iface/operstate")" == "up" ]]; then
      printf '%s\n' "$iface"
      return 0
    fi
  done
  return 1
}

first_battery() {
  local supply type
  for supply in /sys/class/power_supply/*; do
    [[ -e "$supply/type" ]] || continue
    type="$(cat "$supply/type" 2>/dev/null || true)"
    if [[ "$type" == "Battery" ]]; then
      printf '%s\n' "$supply"
      return 0
    fi
  done
  return 1
}

