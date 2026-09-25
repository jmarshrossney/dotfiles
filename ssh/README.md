# SSH

SSH client configuration: `.ssh/config`.

Link it with `just link ssh` from the repository root.

## Keys

`.ssh/config` points each host at its own key with `IdentitiesOnly yes`, so SSH will not fall back to any other key.
On a new machine, generate the GitHub key before cloning or pushing over SSH:

```sh
ssh-keygen -t ed25519 -C "<email>" -f ~/.ssh/id_ed25519_github
cat ~/.ssh/id_ed25519_github.pub   # paste into https://github.com/settings/ssh/new
ssh -T git@github.com              # should greet you as <username>
```

The same applies to `id_ed25519_codeberg` and `id_ed25519_desktop`.

## Machine-specific settings

`~/.ssh/config.local` is included first if it exists, and is never committed.
