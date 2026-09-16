# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Source system-wide configuration for login shells
if [ -f /etc/profile ]; then
    source /etc/profile
fi

# Source .bashrc for consistency between login/non-login shells
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# ---- Everything below this line is added during the installation of packages ---- #

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
