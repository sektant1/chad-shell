#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Prints the status of workspaces 1–4 in Hyprland, marking the active one.
#  Output format: "wsN= [ ACTIVE ]" or "wsN= [INACTIVE]"
# ─────────────────────────────────────────────────────────────────────────────

cache="${XDG_RUNTIME_DIR:-/tmp}/dionysus-eww-workspace"
now=$(date +%s)

if [[ -r "$cache" ]]; then
  IFS=' ' read -r cached_at CURRENT <"$cache" || true
fi

if [[ -z "${CURRENT:-}" || -z "${cached_at:-}" || $((now - cached_at)) -ge 1 ]]; then
  # Get active workspace ID once per second, even when several widgets poll it.
  CURRENT=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id')
  printf '%s %s\n' "$now" "$CURRENT" >"$cache" 2>/dev/null || true
fi

# Fallback if query fails
if [[ -z "$CURRENT" || "$CURRENT" == "null" ]]; then
  echo "[!] Could not determine active workspace."
  exit 1
fi

workspace_value() {
  local workspace=$1

  if [[ "$workspace" -eq "$CURRENT" ]]; then
    printf '[ ACTIVE ]\n'
  else
    printf '[INACTIVE]\n'
  fi
}

case "${1:-all}" in
  current)
    printf '%s\n' "$CURRENT"
    ;;
  ws[1-4])
    workspace_value "${1#ws}"
    ;;
  all)
    for i in {1..4}; do
      printf 'ws%s= %s\n' "$i" "$(workspace_value "$i")"
    done
    ;;
  *)
    printf 'usage: %s [current|ws1|ws2|ws3|ws4|all]\n' "${0##*/}" >&2
    exit 2
    ;;
esac
