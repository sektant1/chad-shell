#!/usr/bin/env bash

log_info() { printf 'info %s\n' "$*"; }
log_ok() { printf 'ok   %s\n' "$*"; }
log_warn() { printf 'warn %s\n' "$*" >&2; }
log_error() { printf 'err  %s\n' "$*" >&2; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

ensure_dir() {
  local dir=$1 dry_run=${2:-false}
  if [[ "$dry_run" == true ]]; then
    printf '+ mkdir -p %q\n' "$dir"
  else
    mkdir -p "$dir"
  fi
}

detect_distro() {
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    printf '%s\n' "${ID:-unknown}"
  else
    printf 'unknown\n'
  fi
}

backup_path() {
  local src=$1 backup_root=$2 dry_run=${3:-false}
  local base dest
  base=$(basename -- "$src")
  dest="$backup_root/$base"
  if [[ "$dry_run" == true ]]; then
    printf '+ mkdir -p %q\n' "$backup_root"
    printf '+ mv %q %q\n' "$src" "$dest"
  else
    mkdir -p "$backup_root"
    mv "$src" "$dest"
  fi
}

link_path() {
  local src=$1 dest=$2 backup_root=$3 force=${4:-false} dry_run=${5:-false}
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    log_ok "linked: $dest -> $src"
    return 0
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ "$force" != true ]]; then
      log_error "refusing to replace $dest without --force; backup would be $backup_root"
      return 3
    fi
    backup_path "$dest" "$backup_root" "$dry_run"
  fi
  ensure_dir "$(dirname -- "$dest")" "$dry_run"
  if [[ "$dry_run" == true ]]; then
    printf '+ ln -s %q %q\n' "$src" "$dest"
  else
    ln -s "$src" "$dest"
  fi
}

copy_path() {
  local src=$1 dest=$2 backup_root=$3 force=${4:-false} dry_run=${5:-false}
  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ "$force" != true ]]; then
      log_error "refusing to replace $dest without --force; backup would be $backup_root"
      return 3
    fi
    backup_path "$dest" "$backup_root" "$dry_run"
  fi
  ensure_dir "$(dirname -- "$dest")" "$dry_run"
  if [[ "$dry_run" == true ]]; then
    printf '+ cp -a %q %q\n' "$src" "$dest"
  else
    cp -a "$src" "$dest"
  fi
}
