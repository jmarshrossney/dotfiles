# Alacritty config

## Installation

Clone the repo and symlink it to `~/.config/alacritty`:

```sh
git clone https://codeberg.org/float/alacritty-config.git
ln -s alacritty-config ~/.config/alacritty
```

Pick a starting theme, which creates the untracked `themes/current.toml` that `alacritty.toml` imports:

```sh
bash ~/.config/alacritty/toggle_theme.sh
```

Set Alacritty as the default terminal (Debian/Ubuntu):

```sh
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(which alacritty)" 50
sudo update-alternatives --config x-terminal-emulator
```

The second command is interactive — pick Alacritty from the list.
`50` is the priority, which only matters when the alternative is left in auto mode.

### Font installation

1. Download and unzip (e.g.) `FiraCode Nerd Font` from https://www.nerdfonts.com/font-downloads
2. Copy contents to `~/.local/share/fonts/`
3. Update cache with `fc-cache -fv`

## Themes

`themes/` holds two vendored theme files: "Tokyo night" and "Tokyo night (day)", copied verbatim from [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim/tree/main/extras/alacritty).

## Toggle light/dark

`Ctrl+Shift+T`, or:

```sh
bash ~/.config/alacritty/toggle_theme.sh
```

The script copies one of the two theme files over the gitignored `themes/current.toml`, and the matching file over zathura's `themes/current` when that config is installed.
`live_config_reload` watches imported files too, so open windows follow immediately and nothing tracked by git is touched.
The exception is a change to the import list itself, which windows opened beforehand ignore until `alacritty.toml` is modified or they are restarted.

## See also

- Configuration: https://alacritty.org/config-alacritty.html
- Themes: https://github.com/folke/tokyonight.nvim/tree/main/extras/alacritty
- Blog post on theme switching: https://shapeshed.com/vim-tmux-alacritty-theme-switcher/
