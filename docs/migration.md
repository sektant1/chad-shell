# Migration

Pre-refactor backup: `backup-before-refactor-20260618-091840/`.

Moved paths:

- `dotfiles/hypr` -> `config/hypr`
- `dotfiles/waybar` -> `config/waybar`
- `dotfiles/rofi` -> `config/rofi`
- `dotfiles/alacritty` -> `config/alacritty`
- `dotfiles/cava` -> `config/cava`
- `dotfiles/eww` -> `config/eww`
- `dotfiles/neofetch` -> `config/neofetch`
- `dotfiles/zsh` -> `config/zsh`
- `dotfiles/hypr/wallpapers/*` -> `assets/wallpapers/*` and retained in `config/hypr/wallpapers/*`
- `dotfiles/firefox/theme.zip` -> `assets/themes/firefox-theme.zip`

Hyprland split:

- monitor rule -> `config/hypr/conf.d/10-monitors.conf`
- command variables and environment -> `config/hypr/conf.d/00-env.conf`
- autostart -> `config/hypr/conf.d/90-autostart.conf`
- general/decoration -> `config/hypr/conf.d/50-appearance.conf`
- animations plus old post-animation layout/misc blocks -> `config/hypr/conf.d/60-animations.conf`
- input and gesture -> `config/hypr/conf.d/20-input.conf`
- binds -> `config/hypr/conf.d/30-keybinds.conf`
- window/workspace rules -> `config/hypr/conf.d/40-window-rules.conf`

Cleanups:

- Removed stale generated Waybar `.bak.*` files from active source.
- Replaced active `/home/...` hardcodes with `$HOME`, XDG or `~/.config` paths.
- Added root `install.sh`, `uninstall.sh`, reload and healthcheck scripts.
