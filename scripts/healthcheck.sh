#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib.sh
. "$REPO_DIR/scripts/lib.sh"

status=0
fail() { log_error "$*"; status=1; }

repo_path_for_config_ref() {
  local ref=$1
  ref=${ref#"\""}; ref=${ref%"\""}
  ref=${ref#"'"}; ref=${ref%"'"}
  case "$ref" in
    '~/.config/'*) printf '%s/config/%s\n' "$REPO_DIR" "${ref#\~/.config/}" ;;
    '$HOME/.config/'*) printf '%s/config/%s\n' "$REPO_DIR" "${ref#\$HOME/.config/}" ;;
    /*) printf '%s\n' "$ref" ;;
    *) printf '%s\n' "$ref" ;;
  esac
}

log_info "Dionysus healthcheck"
log_info "repo: $REPO_DIR"

if command_exists Hyprland || command_exists hyprland; then
  log_ok "command: Hyprland"
else
  fail "command missing: Hyprland"
fi
for cmd in hyprctl waybar rofi; do
  if command_exists "$cmd"; then log_ok "command: $cmd"; else fail "command missing: $cmd"; fi
done

if command_exists fc-match; then
  for font in 'JetBrainsMono Nerd Font Mono' 'GohuFont 11 Nerd Font' Terminus; do
    match=$(fc-match "$font" 2>/dev/null || true)
    [[ -n "$match" ]] && log_ok "font $font: $match" || log_warn "font not detectable: $font"
  done
else
  log_warn "fc-match unavailable; font check skipped"
fi

while IFS= read -r link; do
  fail "broken symlink: $link"
done < <(find "$REPO_DIR" -path "$REPO_DIR/.git" -prune -o -path "$REPO_DIR/.remember" -prune -o -path "$REPO_DIR/backup-*" -prune -o -xtype l -print)

while IFS= read -r source_ref; do
  path=$(repo_path_for_config_ref "$source_ref")
  [[ -e "$path" ]] && log_ok "hypr source: $source_ref" || fail "missing hypr source: $source_ref -> $path"
done < <(grep -hE '^\s*source\s*=' "$REPO_DIR/config/hypr/hyprland.conf" | sed 's/^.*=\s*//')

while IFS= read -r wall_ref; do
  path=$(repo_path_for_config_ref "$wall_ref")
  [[ -e "$path" ]] && log_ok "wallpaper: $wall_ref" || fail "missing wallpaper: $wall_ref -> $path"
done < <(grep -hE '^(preload=|wallpaper=)' "$REPO_DIR/config/hypr/hyprpaper.conf" | sed -E 's/^preload=//; s/^wallpaper=[^,]+,//')

while IFS= read -r script_ref; do
  path=$(repo_path_for_config_ref "$script_ref")
  [[ -x "$path" ]] && log_ok "waybar script: $script_ref" || fail "missing/non-executable waybar script: $script_ref -> $path"
done < <(grep -oE "~/.config/waybar/scripts/[^\"' ]+" "$REPO_DIR/config/waybar/config.jsonc" | sort -u)

rofi_image=$(repo_path_for_config_ref '~/.config/rofi/image.png')
[[ -e "$rofi_image" ]] && log_ok "rofi image: ~/.config/rofi/image.png" || fail "missing rofi image: $rofi_image"

grep -R "/home/[^[:space:]\"')]*" "$REPO_DIR/config" >/tmp/dionysus-hardcodes.$$ 2>/dev/null || true
if [[ -s /tmp/dionysus-hardcodes.$$ ]]; then
  fail "hardcoded /home path found under config"
  cat /tmp/dionysus-hardcodes.$$
fi
rm -f /tmp/dionysus-hardcodes.$$

exit "$status"
