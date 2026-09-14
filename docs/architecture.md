# Architecture

`config/` contains source configs intended for `~/.config` deployment.

`config/hypr/hyprland.conf` is the Hyprland entrypoint. It sources `conf.d/` files in the same parse order as the old single-file config.

`config/waybar/config.jsonc` is canonical Waybar config. `config/waybar/config` is a compatibility symlink so default `waybar` still works. Custom modules call scripts in `config/waybar/scripts/`.

`config/rofi/` contains Rofi config, theme and current image asset. `launchers/` is reserved for launcher wrappers.

`assets/` stores repo-level assets: wallpapers, icons, themes and fonts. Wallpapers are also kept under `config/hypr/wallpapers/` to preserve current Hyprland/hyprpaper runtime paths.

`packages/` lists Ubuntu/Debian package names and optional integrations.

`scripts/` contains installer helpers, reload tooling, healthcheck and legacy wrappers.

Backups are written in repo-local `backup-*` folders and ignored by git.
