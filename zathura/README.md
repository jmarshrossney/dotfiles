# zathura

PDF viewer.
The config is split so that the colours follow the terminal theme rather than being fixed dark.

| File | Tracked | What it is |
| --- | --- | --- |
| `zathurarc` | yes | settings that do not change with the theme, plus `include themes/current` |
| `themes/tokyonight_night` | yes | dark colours, with `recolor` on |
| `themes/tokyonight_day` | yes | light colours, with `recolor` off |
| `themes/current` | no | a copy of one of the two, written by the toggle |

## Toggling

`Ctrl+Shift+T` in Alacritty runs `~/.config/alacritty/toggle_theme.sh`, which writes both `themes/current.toml` for Alacritty and `themes/current` here.

Zathura reads its config at startup only, so an open window keeps the colours it launched with.
The next document opened gets the new theme.

Within a session, `Ctrl+R` inverts the document itself.
That is `recolor`, and it is the setting that matters for reading a PDF in the dark — the rest is window chrome.
`recolor-keephue` is on, so coloured figures stay recognisable rather than being flattened to grey.

## On a new machine

Run the toggle once to create `themes/current`, which is gitignored and so absent from a fresh clone:

```sh
bash ~/.config/alacritty/toggle_theme.sh
```

Until it exists, zathura starts with its own default colours and logs a warning about the missing include.

## Why not automatic detection

Zathura has no equivalent of Neovim's background query, and no live config reload.
Deriving the theme from whatever Alacritty last wrote is exact and costs nothing, where querying the terminal at launch would need a wrapper script and would still only apply at startup.
