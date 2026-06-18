#!/usr/bin/env bash
set -euo pipefail

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
log_dir="$state_home/dionysus"
mkdir -p "$log_dir"
logfile="$log_dir/waybar-watcher.log"
waybar_logfile="$log_dir/waybar.log"
hyprpaper_config="$config_home/hypr/hyprpaper.conf"

wallpaper_with_window="${DIONYSUS_WALLPAPER_ACTIVE:-/home/gfe/Personal/dionysus/dotfiles/hypr/wallpapers/laptop-wallpaper.webp}"
wallpaper_without_window="${DIONYSUS_WALLPAPER_IDLE:-/home/gfe/Personal/dionysus/dotfiles/hypr/wallpapers/laptop-wallpaper.webp}"
current_wallpaper=""
eww_visible=false
waybar_visible=false
keep_waybar_visible="${DIONYSUS_KEEP_WAYBAR_VISIBLE:-true}"
persist_waybar_hidden="${DIONYSUS_PERSIST_WAYBAR_HIDDEN:-false}"
waybar_hidden_flag="$log_dir/waybar-hidden"

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

log() {
  printf '%s %s\n' "$(date '+%F %T')" "$*" >>"$logfile"
}

start_waybar() {
  has_cmd waybar || return 0
  pgrep -x waybar >/dev/null 2>&1 && return 0
  waybar >>"$waybar_logfile" 2>&1 &
}

monitor_names() {
  hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null
}

set_wallpaper() {
  local wallpaper=$1 monitor
  [[ -f "$wallpaper" ]] || return 1
  has_cmd hyprctl || return 0
  while IFS= read -r monitor; do
    [[ -n "$monitor" ]] || continue
    hyprctl hyprpaper wallpaper "$monitor,$wallpaper" >/dev/null 2>&1 || true
  done < <(monitor_names)
}

start_hyprpaper() {
  has_cmd hyprpaper || return 0
  hyprpaper --config "$hyprpaper_config" >/dev/null 2>&1 &
  sleep 1
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

if [[ "$persist_waybar_hidden" != true ]]; then
  rm -f "$waybar_hidden_flag"
fi

if has_cmd hyprpaper; then
  if ! pgrep -x hyprpaper >/dev/null 2>&1; then
    start_hyprpaper
  elif ! hyprctl hyprpaper listactive >/dev/null 2>&1; then
    log "hyprpaper IPC unavailable; restarting hyprpaper"
    pkill -x hyprpaper >/dev/null 2>&1 || true
    start_hyprpaper
  fi
fi

if [[ -f "$waybar_hidden_flag" ]]; then
  waybar_visible=false
elif has_cmd waybar && pgrep -x waybar >/dev/null 2>&1; then
  waybar_visible=true
elif [[ "$keep_waybar_visible" == true ]] && has_cmd waybar; then
  start_waybar
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
      set_wallpaper "$wallpaper_without_window" || log "failed to set wallpaper: $wallpaper_without_window"
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
      set_wallpaper "$wallpaper_with_window" || log "failed to set wallpaper: $wallpaper_with_window"
      current_wallpaper="$wallpaper_with_window"
    fi

    if [[ "$eww_visible" == true ]] && has_cmd eww; then
      eww close-all >/dev/null 2>&1 || true
      eww_visible=false
    fi

    if [[ ! -f "$waybar_hidden_flag" && "$waybar_visible" == false ]] && has_cmd waybar; then
      start_waybar
      waybar_visible=true
    fi
  fi

  sleep "${DIONYSUS_WATCH_INTERVAL:-2}"
done
