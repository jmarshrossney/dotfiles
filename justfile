root := justfile_directory()
home := home_directory()

# Default: list justfile commands
_:
    @just --list

# List the packages in the repo
list:
    @find {{root}} -maxdepth 1 -mindepth 1 -type d -not -name '.git' -printf '%f\n' | sort

# Dry-run: show what a package would link, without actually linking
check package:
    stow --dir={{root}} --target={{home}} --no --verbose=2 {{package}}

# Link a package into $HOME
link package:
    stow --dir={{root}} --target={{home}} --verbose {{package}}

# Remove a package's links from $HOME
unlink package:
    stow --dir={{root}} --target={{home}} --delete --verbose {{package}}

# Re-link a package, cleaning up links that no longer have a source
relink package:
    stow --dir={{root}} --target={{home}} --restow --verbose {{package}}

# Adopt the real files at the target path into the repo, replacing them with links
adopt package:
    # NB: adopt overwrites repo contents with whatever is on disk.
    stow --dir={{root}} --target={{home}} --adopt --verbose {{package}}

# Dry-run every package
check-all:
    #!/usr/bin/env bash
    set -euo pipefail
    for pkg in $(just list); do
        echo "== $pkg"
        just check "$pkg"
    done

# Link every package in the repo
link-all:
    #!/usr/bin/env bash
    set -euo pipefail
    for pkg in $(just list); do
        just link "$pkg"
    done

# Check that the Claude publishing guard still stops what it should
test-hooks:
    {{root}}/claude/.claude/hooks/tests/run.py

# Run pre-commit hooks over the whole repo rather than just staged changes
pre-commit:
    pre-commit run --all-files

# List to-be-published files (read before pushing)
ls-files:
    git ls-files

# List ignored files (excluding obvious ones)
ls-ignored:
    git ls-files --others --ignored --exclude-standard

# Run ls-files, test-hooks, and pre-commit
audit: ls-files test-hooks pre-commit

# Apply the GNOME settings in the dconf package
dconf-load:
    dconf load /org/gnome/ < {{root}}/dconf/.config/dconf/gnome.ini
