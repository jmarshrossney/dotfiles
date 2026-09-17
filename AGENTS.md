# Instructions for agents

## Purpose

This repository maintains a consistent configuration across the owner's Linux machines.
Assume those machines run Ubuntu 26.04 unless a task says otherwise.

Top-level directories are GNU Stow packages whose contents mirror paths under `$HOME`.
Read `README.md` before changing package layout or linking behavior.

## Principles

- Keep the repository minimal and easy for one person to understand and edit.
- Prefer a small, direct change over a general framework, abstraction, or new dependency, and do not add tools, packages, or automation without a clear need. When the right approach is unclear, ask rather than adding complexity.
- Keep machine-specific, work-specific, and secret configuration outside this repository.
- Preserve existing conventions unless the task explicitly asks to change them.

## Security and privacy

- Treat this public repository as unsuitable for secrets, private keys, tokens, personal data, and sensitive machine details.
- Do not weaken `.gitignore`, pre-commit checks, SSH settings, or other security controls to make a change easier.
- If a change has security or privacy implications, stop and ask the user rather than guessing.

## Packages

- Adding a package means adding `!/<package>/` to the `.gitignore` allowlist. Without that line the new files stay ignored and are never committed, so check `git status` afterwards.
- Package-specific documentation belongs in `<package>/README.md`. Stow's default ignore list covers `^/README.*`, so it is not linked into `$HOME`.
- `just list`, `check <package>`, `check-all`, `ls-files`, `ls-ignored` and `audit` only read; run them freely.
- `just link`, `relink`, `unlink` and `adopt` change `$HOME`, and `adopt` overwrites repo files with whatever is on disk. Do not run them without explicit instruction.

## Working rules

- Do not commit, amend, push, or create a pull request without explicit user instruction.
- Do not overwrite or revert existing user changes that are unrelated to the task.
- Run `just audit` before a change is ready for review.
- Review `git diff` and `git status` after editing, including the list of tracked and ignored files when relevant.
- Run the smallest relevant verification available, and report what was or was not run.
