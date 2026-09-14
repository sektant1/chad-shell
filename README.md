# Dionysus Dotfiles

Ubuntu/Debian-first Hyprland desktop dotfiles. Current rice uses Hyprland, Waybar, Rofi, CAVA, Eww, Alacritty, Neofetch and shell helpers.

This repo refactor preserves the existing appearance and behavior. Config values, keybinds, Waybar module order, Rofi theme values and wallpaper behavior are carried forward unchanged.

## Install

Preview actions:

```sh
./install.sh --dry-run --no-packages
```

Install packages and symlink configs:

```sh
./install.sh --force
```

Copy configs instead of symlinking:

```sh
./install.sh --copy --force
```

Existing targets are backed up before replacement under `./backup-install-TIMESTAMP/`.

## Reload

```sh
./scripts/reload.sh
```

This runs `hyprctl reload` when inside Hyprland, restarts only `waybar`, and leaves Rofi alone because it is not a daemon.

## Validate

```sh
./scripts/healthcheck.sh
./scripts/lint
```

## Uninstall

```sh
./uninstall.sh --dry-run
./uninstall.sh
```

Uninstall removes only symlinks pointing into this repo. It never deletes copied configs or user files.

## Restore Backups

Pick a backup folder, remove the current target, then move the backup back:

```sh
rm ~/.config/waybar
mv ./backup-install-TIMESTAMP/waybar ~/.config/waybar
```

Pre-refactor source backup lives under `./backup-before-refactor-TIMESTAMP/`.

## Host Overrides

Hyprland machine-specific monitor rules go in `~/.config/hypr/local.conf`.

Optional environment overrides live in `~/.config/dionysus/local.env`:

```sh
DIONYSUS_WALLPAPER_IDLE=$HOME/Pictures/wallpapers/idle.png
DIONYSUS_WALLPAPER_ACTIVE=$HOME/Pictures/wallpapers/active.png
DIONYSUS_KBD_BRIGHTNESS_PATH=/sys/class/leds/asus::kbd_backlight/brightness
```
