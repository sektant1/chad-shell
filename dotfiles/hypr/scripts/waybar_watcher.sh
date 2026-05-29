#!/usr/bin/env bash
set -euo pipefail

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
log_dir="$state_home/dionysus"
mkdir -p "$log_dir"
logfile="$log_dir/waybar-watcher.log"

wallpaper_with_window="${DIONYSUS_WALLPAPER_ACTIVE:-/home/gfe/Pictures/how-did-pewdiepie-get-his-waybar-looking-like-this-v0-3vgzbhbnxyze1.webp}"
wallpaper_without_window="${DIONYSUS_WALLPAPER_IDLE:-/home/gfe/Pictures/how-did-pewdiepie-get-his-waybar-looking-like-this-v0-3vgzbhbnxyze1.webp}"
current_wallpaper=""
eww_visible=false
waybar_visible=false
keep_waybar_visible="${DIONYSUS_KEEP_WAYBAR_VISIBLE:-true}"
waybar_hidden_flag="$log_dir/waybar-hidden"

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

log() {
  printf '%s %s\n' "$(date '+%F %T')" "$*" >>"$logfile"
}

primary_monitor() {
  hyprctl monitors -j 2>/dev/null | jq -r 'map(select(.focused == true))[0].name // .[0].name // "auto"' 2>/dev/null
}

set_wallpaper() {
  local wallpaper=$1 monitor
  [[ -f "$wallpaper" ]] || return 0
  has_cmd hyprctl || return 0
  monitor="$(primary_monitor)"
  [[ "$monitor" == "auto" ]] && return 0
  hyprctl hyprpaper preload "$wallpaper" >/dev/null 2>&1 || true
  hyprctl hyprpaper wallpaper "$monitor,$wallpaper,1" >/dev/null 2>&1 || true
}

eww_windows=(
  active_workspace
  ascii_decor_frame
  audio_status
  cpu_ram_storage_bars
  four_boxes
  net_bars
  orange_workspace
  power-cooling_header_text
  power_mode_text
  right_fan_data
  right_internet_text
  visualizer_window
  welcome_text
  workspace_window_text
)

if ! has_cmd hyprctl || ! has_cmd jq; then
  log "hyprctl or jq missing; watcher disabled"
  exit 0
fi

if has_cmd hyprpaper && ! pgrep -x hyprpaper >/dev/null 2>&1; then
  hyprpaper >/dev/null 2>&1 &
  sleep 1
fi

if [[ -f "$waybar_hidden_flag" ]]; then
  waybar_visible=false
elif has_cmd waybar && pgrep -x waybar >/dev/null 2>&1; then
  waybar_visible=true
elif [[ "$keep_waybar_visible" == true ]] && has_cmd waybar; then
  waybar >/dev/null 2>&1 &
  waybar_visible=true
fi

while true; do
  if [[ -f "$waybar_hidden_flag" ]]; then
    waybar_visible=false
  elif has_cmd waybar && pgrep -x waybar >/dev/null 2>&1; then
    waybar_visible=true
  else
    waybar_visible=false
  fi

  active_workspace="$(hyprctl activeworkspace -j | jq -r '.id // 0')"
  window_count="$(hyprctl clients -j | jq "[.[] | select(.workspace.id == $active_workspace and .mapped == true)] | length")"

  if [[ "$window_count" == "0" ]]; then
    if [[ "$current_wallpaper" != "$wallpaper_without_window" ]]; then
      set_wallpaper "$wallpaper_without_window"
      current_wallpaper="$wallpaper_without_window"
    fi

    # Keep the wallpaper clean; do not auto-open the Eww desktop overlay.
    eww_visible=false

    if [[ "$keep_waybar_visible" != true && "$waybar_visible" == true ]]; then
      pkill -x waybar >/dev/null 2>&1 || true
      waybar_visible=false
    fi
  else
    if [[ "$current_wallpaper" != "$wallpaper_with_window" ]]; then
      set_wallpaper "$wallpaper_with_window"
      current_wallpaper="$wallpaper_with_window"
    fi

    if [[ "$eww_visible" == true ]] && has_cmd eww; then
      eww close-all >/dev/null 2>&1 || true
      eww_visible=false
    fi

    if [[ ! -f "$waybar_hidden_flag" && "$waybar_visible" == false ]] && has_cmd waybar; then
      waybar >/dev/null 2>&1 &
      waybar_visible=true
    fi
  fi

  sleep "${DIONYSUS_WATCH_INTERVAL:-0.25}"
done

