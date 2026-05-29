# Dionysus Dotfiles

Portable Linux desktop dotfiles with a neon/Nord Hyprland, Waybar, Eww, Rofi,
CAVA and Alacritty setup.

## Install

Preview first:

```sh
./scripts/install --dry-run
```

Install selected modules:

```sh
./scripts/install hypr waybar rofi alacritty cava eww
```

Replace existing config directories only after reviewing the backup location:

```sh
./scripts/install --force hypr waybar rofi
```

Backups are stored under `${XDG_STATE_HOME:-~/.local/state}/dionysus/backups/`.

## Rollback

```sh
rm ~/.config/waybar
mv ~/.local/state/dionysus/backups/<timestamp>/waybar ~/.config/waybar
```

Repeat for each module you want to restore.

## Host Overrides

Local environment overrides live in `~/.config/dionysus/local.env`:

```sh
DIONYSUS_PRIMARY_MONITOR=DP-1
DIONYSUS_NET_IFACE=wlan0
DIONYSUS_NET_MAX_BYTES=12500000
DIONYSUS_WALLPAPER_IDLE=$HOME/Pictures/wallpapers/idle.png
DIONYSUS_WALLPAPER_ACTIVE=$HOME/Pictures/wallpapers/active.png
DIONYSUS_KBD_BRIGHTNESS_PATH=/sys/class/leds/asus::kbd_backlight/brightness
```

Hyprland machine-specific monitor rules should go in `~/.config/hypr/local.conf`.

## Display Setup

```sh
./scripts/display-autoconfig --dry-run
./scripts/display-autoconfig
```

On Wayland the script does not force `xrandr`; use compositor-native monitor tools.

## Validate

```sh
./scripts/doctor
./scripts/lint
```

## Dependencies

Arch package setup:

```sh
./scripts/install-packages-arch --dry-run --desktop --optional --aur
./scripts/install-packages-arch --yes --desktop --optional --aur
```

Ubuntu package setup:

```sh
./scripts/install-packages-ubuntu --dry-run --desktop --optional
./scripts/install-packages-ubuntu --yes --desktop --optional
```

Baseline: `bash`, `coreutils`, `findutils`, `awk`, `grep`, `sed`, `iproute2`.

Recommended runtime: `hyprland`, `hyprpaper`, `waybar`, `rofi`, `eww`, `cava`,
`alacritty`, PipeWire tools, `pactl`, `brightnessctl`, `playerctl`, `jq`,
`fontconfig`.

Optional hardware integrations: `asusctl`, `nordvpn`, `bluetoothctl`, `rfkill`.

| Module | Arch | Debian/Ubuntu | Fedora | openSUSE | Void |
| --- | --- | --- | --- | --- | --- |
| Shell lint | `shellcheck shfmt` | `shellcheck shfmt` | `ShellCheck shfmt` | `ShellCheck shfmt` | `ShellCheck shfmt` |
| Display X11 | `xorg-xrandr` | `x11-xserver-utils` | `xrandr` | `xrandr` | `xrandr` |
| Hyprland | `hyprland hyprpaper` | backports/external | `hyprland hyprpaper` | `hyprland hyprpaper` | `Hyprland hyprpaper` |
| Bar/launcher | `waybar rofi` | `waybar rofi` | `waybar rofi` | `waybar rofi` | `waybar rofi` |
| Audio/widgets | `cava eww pipewire wireplumber` | `cava pipewire wireplumber` | `cava pipewire wireplumber` | `cava pipewire wireplumber` | `cava pipewire wireplumber` |

## Troubleshooting

- No battery: Waybar battery returns empty text and does not break the bar.
- No Wi-Fi: network scripts use the active route interface.
- No Nerd Font: core status scripts use ASCII labels.
- No brightness device: brightness widget hides itself.
- ASUS scripts do nothing: configure udev permissions or disable the bindings.
- VM monitor names: X11 helper accepts whatever `xrandr` reports.

## Manual Test Matrix

- 1366x768 laptop, internal monitor only.
- 1920x1080 desktop, no battery.
- 2560x1440 desktop.
- Ultrawide monitor.
- HiDPI laptop.
- VirtualBox/QEMU with `Virtual-*` output.
- Multi-monitor mixed internal/external.
- No Wi-Fi interface.
- No Nerd Font installed.

