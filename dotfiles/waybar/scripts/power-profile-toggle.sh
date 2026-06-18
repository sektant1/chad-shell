#!/usr/bin/env bash
set -euo pipefail

if ! command -v powerprofilesctl >/dev/null 2>&1; then
  command -v notify-send >/dev/null 2>&1 && notify-send "Power profile" "powerprofilesctl not found"
  exit 1
fi

current="$(powerprofilesctl get 2>/dev/null || true)"
profiles=()

while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]*\*?[[:space:]]*([a-z-]+): ]]; then
    profiles+=("${BASH_REMATCH[1]}")
  fi
done < <(powerprofilesctl list)

has_profile() {
  local wanted=$1 profile
  for profile in "${profiles[@]}"; do
    [[ "$profile" == "$wanted" ]] && return 0
  done
  return 1
}

next=""
modes=(performance balanced power-saver)

for i in "${!modes[@]}"; do
  [[ "${modes[$i]}" == "$current" ]] || continue
  for offset in 1 2 3; do
    candidate="${modes[$(((i + offset) % ${#modes[@]}))]}"
    if has_profile "$candidate"; then
      next="$candidate"
      break 2
    fi
  done
done

if [[ -z "$next" ]]; then
  for candidate in "${modes[@]}"; do
    if has_profile "$candidate"; then
      next="$candidate"
      break
    fi
  done
fi

[[ -n "$next" ]] || exit 1

powerprofilesctl set "$next"
command -v notify-send >/dev/null 2>&1 && notify-send "Power profile" "$next"
command -v pkill >/dev/null 2>&1 && pkill -RTMIN+10 waybar
