#!/bin/bash
# Swap between the day and night variants of the Tokyo Night theme.
#
# Alacritty: themes/current.toml is imported by alacritty.toml, and
# live_config_reload watches imports, so open windows follow immediately.
#
# Zathura: themes/current is included by zathurarc, which is read at startup
# only, so the change applies to the next document opened. Skipped when the
# zathura config is not installed.

set -euo pipefail

themes="$(dirname "$(readlink -f "$0")")/themes"
current="$themes/current.toml"

if cmp -s "$current" "$themes/tokyonight_day.toml"; then
    variant="night"
else
    variant="day"
fi

cp "$themes/tokyonight_$variant.toml" "$current"

zathura_themes="${XDG_CONFIG_HOME:-$HOME/.config}/zathura/themes"
if [ -d "$zathura_themes" ]; then
    cp "$zathura_themes/tokyonight_$variant" "$zathura_themes/current"
fi
