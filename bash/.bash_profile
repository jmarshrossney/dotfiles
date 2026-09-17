# Login shells only. Everything, PATH included, lives in .bashrc: alacritty
# starts a non-login interactive shell, so .bashrc is the only file guaranteed
# to run in a terminal. This file just makes login shells match.

# Source system-wide configuration for login shells
if [ -f /etc/profile ]; then
    source /etc/profile
fi

# Source .bashrc for consistency between login/non-login shells.
# It must come after /etc/profile, which resets PATH.
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi
