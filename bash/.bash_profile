# Login shells only.

# Source system-wide configuration for login shells
if [ -f /etc/profile ]; then
  source /etc/profile
fi

# Source .bashrc for consistency between login/non-login shells.
# It must come after /etc/profile, which resets PATH.
if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi
