# Bash

Bash configuration: `.bashrc`, `.bash_profile`.
`.inputrc` is the separate `readline` package.

Link it with `just link bash` from the repository root.

## Where things go

`.bashrc` holds everything, including PATH.
That is deliberate rather than the conventional split, because alacritty starts a non-login interactive shell, which never reads `.bash_profile`.
Under a Wayland-only session `~/.profile` may not be read either, so `.bashrc` is the only file that reliably runs in a terminal.

PATH is built above the interactivity guard, since the guard returns early for non-interactive shells and would otherwise leave them with no PATH at all.
`prepend_path` skips directories that do not exist and entries already present, so sourcing `.bashrc` twice does not duplicate anything.

`.bash_profile` sources `/etc/profile` and then `.bashrc`, in that order, because `/etc/profile` resets PATH.

## Machine-specific settings

`~/.bashrc.local` is sourced last if it exists, and is never committed.
