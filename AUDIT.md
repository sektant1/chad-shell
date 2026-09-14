# chadshell Dotfiles Audit

Date: 2026-05-27
Repository: `git@github.com:pewdiepie-archdaemon/dionysus.git`

## Project Structure

- `dotfiles/alacritty`: terminal theme.
- `dotfiles/cava`: CAVA visualizer config and shaders.
- `dotfiles/eww`: Eww widgets and polling scripts.
- `dotfiles/firefox`: Firefox theme archive.
- `dotfiles/hypr`: Hyprland, hyprpaper, wallpaper and helper scripts.
- `dotfiles/neofetch`: animated neofetch config and frames.
- `dotfiles/rofi`: launcher config, theme and image asset.
- `dotfiles/waybar`: Waybar config, style and custom scripts.
- `dotfiles/zsh`: zsh config.
- `assets`: screenshots and demos.
- `scripts`: portable install, lint, doctor and display helpers.

## Critical Files

- `dotfiles/hypr/hyprland.conf`
- `dotfiles/hypr/scripts/waybar_watcher.sh`
- `dotfiles/hypr/hyprpaper.conf`
- `dotfiles/waybar/config`
- `dotfiles/waybar/scripts/*.sh`
- `dotfiles/eww/eww.yuck`
- `dotfiles/eww/scripts/**/*.sh`
- `dotfiles/rofi/config.rasi`
- `dotfiles/rofi/theme.rasi`
- `dotfiles/alacritty/alacritty.toml`
- `scripts/install`
- `scripts/display-autoconfig`
- `scripts/doctor`
- `scripts/lint`

## Findings

- Fixed hardcodes for `/home/pewds`, `eDP-1`, `BAT0`, `wlp4s0`, fixed Waybar width, fixed Rofi pixel size and NordVPN-only IP range.
- Removed `sudo` from polling/status scripts and ASUS keyboard helpers.
- Replaced host-specific Hyprland monitor rules with automatic defaults plus `local.conf` override support.
- Added XDG-aware install, doctor, lint and X11 display autoconfig scripts.
- No i3 or polybar configs exist in this repository, so no synthetic i3/polybar config was added.

## Dependencies

Baseline: `bash`, `coreutils`, `findutils`, `awk`, `grep`, `sed`, `iproute2`.

Optional runtime: `hyprland`, `hyprpaper`, `waybar`, `eww`, `rofi`, `cava`, `alacritty`, `kitty`, `foot`, `wezterm`, `ghostty`, `xterm`, `wpctl`, `pactl`, `brightnessctl`, `playerctl`, `jq`, `bluetoothctl`, `rfkill`, `nordvpn`, `asusctl`, `neofetch`, `fontconfig`.

Optional validation: `shellcheck`, `shfmt`, `rofi`, `hyprctl`, `xrandr`.

## Security

- No obvious secrets, tokens or private keys were found in scanned configs.
- No `curl | sh` install flow was found.
- Install now supports `--dry-run` and refuses replacement without `--force`.
- Power and VPN toggle scripts remain user-triggered actions and should be reviewed per host.

## Remaining Host Specifics

- ASUS keyboard LED path defaults to `/sys/class/leds/asus::kbd_backlight/brightness`, overridable with `DIONYSUS_KBD_BRIGHTNESS_PATH`.
- Eww HUD layout remains an artistic fixed widget composition and may need per-resolution tuning.
- Eww command strings still use `~/.config`, which matches Eww's normal installed location.

