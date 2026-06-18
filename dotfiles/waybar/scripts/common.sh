#!/usr/bin/env bash

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

json_escape() {
  local value=${1-}
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/}
  printf '%s' "$value"
}

json_text() {
  local text=${1-} tooltip=${2-} class=${3-}
  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
    "$(json_escape "$text")" \
    "$(json_escape "$tooltip")" \
    "$(json_escape "$class")" 2>/dev/null || true
}

bar10() {
  local percent=${1:-0} blocks=${2:-5} filled empty bar pad
  [[ "$percent" =~ ^[0-9]+$ ]] || percent=0
  [[ "$blocks" =~ ^[0-9]+$ ]] || blocks=5
  ((percent > 100)) && percent=100
  ((blocks < 1)) && blocks=1
  filled=$(((percent * blocks + 99) / 100))
  ((percent == 0)) && filled=0
  ((filled > blocks)) && filled=$blocks
  empty=$((blocks - filled))
  bar="$(printf '%*s' "$filled" '' | tr ' ' '=')"
  pad="$(printf '%*s' "$empty" '' | tr ' ' '-')"
  printf '[%s%s]\n' "$bar" "$pad"
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
