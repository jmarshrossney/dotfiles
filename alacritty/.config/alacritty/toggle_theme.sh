#!/bin/bash
# Swap themes/current.toml between the day and night variants.
# alacritty.toml imports current.toml, and live_config_reload watches imports.

set -euo pipefail

themes="$(dirname "$(readlink -f "$0")")/themes"
current="$themes/current.toml"

if cmp -s "$current" "$themes/tokyonight_day.toml"; then
    next="tokyonight_night.toml"
else
    next="tokyonight_day.toml"
fi

cp "$themes/$next" "$current"
