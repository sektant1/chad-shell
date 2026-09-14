#!/usr/bin/env bash
set -euo pipefail

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
state_dir="${XDG_RUNTIME_DIR:-/tmp}/dionysus"
mkdir -p "$state_dir"

cava_pid="$state_dir/cava.pid"
visualizer_pid="$state_dir/audio-visualizer.pid"
windows=(audio_status visualizer_window)

pid_alive() {
  local pid_file=$1 pid
  [[ -r "$pid_file" ]] || return 1
  IFS= read -r pid <"$pid_file" || return 1
  [[ "$pid" =~ ^[0-9]+$ ]] || return 1
  kill -0 "$pid" 2>/dev/null
}

stop_visualizer() {
  local pid_file pid

  for pid_file in "$visualizer_pid" "$cava_pid"; do
    if [[ -r "$pid_file" ]]; then
      IFS= read -r pid <"$pid_file" || pid=
      [[ "$pid" =~ ^[0-9]+$ ]] && kill "$pid" 2>/dev/null || true
      rm -f "$pid_file"
    fi
  done
}

start_visualizer() {
  if command -v cava >/dev/null 2>&1 && ! pid_alive "$cava_pid"; then
    cava -p "$config_home/cava/config" >/dev/null 2>&1 &
    printf '%s\n' "$!" >"$cava_pid"
  fi

  if [[ -x "$config_home/eww/scripts/audio/audio_visualizer.py" ]] && ! pid_alive "$visualizer_pid"; then
    "$config_home/eww/scripts/audio/audio_visualizer.py" --fps "${DIONYSUS_VISUALIZER_FPS:-15}" >/dev/null 2>&1 &
    printf '%s\n' "$!" >"$visualizer_pid"
  fi
}

if ! command -v eww >/dev/null 2>&1; then
  exit 0
fi

if ! eww active-windows >/dev/null 2>&1; then
  eww daemon >/dev/null 2>&1
  sleep 0.2
fi

if eww active-windows 2>/dev/null | grep -q '^visualizer_window:'; then
  for window in "${windows[@]}"; do
    eww close "$window" >/dev/null 2>&1 || true
  done
  stop_visualizer
else
  start_visualizer
  eww open-many "${windows[@]}" >/dev/null 2>&1
fi
