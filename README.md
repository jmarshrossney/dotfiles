# dotfiles

My dotfiles, linked into place with [GNU Stow](https://www.gnu.org/software/stow/).

Each top-level directory is a *package* whose contents mirror the layout of `$HOME`, e.g.

```
nvim/.config/nvim/init.lua   ->   ~/.config/nvim/init.lua
shell/.bashrc                ->   ~/.bashrc
```

This repo is public because it's nice to share things — I've learnt a lot from other people's dotfiles — but I don't recommend forking it, let alone using it as-is.

## Quick start

### Requirements

- [GNU Stow](https://www.gnu.org/software/stow/) - automates symlinking to the appropriate locations
- [just](https://just.systems/man/en/) - command runner
- [precommit](https://pre-commit.com/) - pre-commit hooks

These aren't strict requirements: if you really wanted to, you could manually symlink files and run the commands in `justfile` and `.pre-commit-config.yaml` directly.

### Setup

Clone the repository, and symlink each package its required location under `$HOME`,

```sh
just check-all  # dry-run (optional, recommended)
just link-all   # actually creates the symlinks
```

### Adding a package

1. Create a new directory `<package>` under the repo root
2. Within it, lay the files out relative to `$HOME` (see #lay-out-files-within-a-package)
3. Add `<package>` to the allowlist in `.gitignore`
4. Link the new package

```sh
just check <package>  # dry-run (optional)
just link <package>   # actually creates the symlinks
```

## How to

### Lay out files within a package

Stow links the shallowest thing it can, which can be either an entire directory or individual files.
For example:

- For `nvim`, assuming `~/.config/nvim` doesn't exist stow would produce a symlink to the whole directory `nvim -> ~/.config/nvim`.
- For `claude`, where a couple of tracked files sit in a directory full of state the tool writes to, stow only links the individual files (`CLAUDE.md`).

### Write a per-package README

Just put it at the top level of the package, as `<package>/README.md`.
Stow's built-in ignore list includes `^/README.*`, so it won't be linked (confirm with `just check <package>`).

If you add a `.stow-local-ignore` to the package or a global `~/.stow-global-ignore`, make sure you include the default list including `README` etc (since this replaces rather than extends the default list).

### Not publish secrets

- `.gitignore` is an allowlist. Everything at the root is ignored unless explicitly named.
- `pre-commit` runs gitleaks and `detect-private-key` over staged changes.
- GitHub push protection blocks recognised credentials server-side.

After adding files, before pushing, run

```sh
just audit   # Lists tracked files, ignored files, and runs pre-commit
```

### Recovering a clobbered symlink

Some tools rewrite their own config in place, replacing the symlink with a real file. Stow then refuses to link the package, reporting `existing target is neither a link nor a directory`.

To recover, run

```sh
just adopt <package>  # moves the real file into the repo, re-creates the symlink
git diff              # shows what the tool changed
```

Nothing under `$HOME` changes — the same bytes are now reached through a symlink again. What changes is the repo: the package's copy of the file is overwritten by whatever was on disk, so always read the diff afterwards, and `git checkout` it if the tool's edits aren't wanted.

Note that adopt only touches paths the package already contains. It won't discover new files.

### Work with machine-specific config

Anything machine-specific, work-specific or secret should stay out of the repo.

- `~/.gitconfig` uses `includeIf` to load a work identity from an untracked file.
- `.bashrc` ends by sourcing `~/.bashrc.local` if it exists.

I find this to be enough machine-specific config.
If you think you need more, you might consider using [chezmoi](https://www.chezmoi.io/).
