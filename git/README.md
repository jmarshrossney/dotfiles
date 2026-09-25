# git

Git configuration: `.config/git/config`, plus per-forge identity files.

Link it with `just link git` from the repository root.

## Identity

`config` sets no `user.name` or `user.email` of its own.
Each forge's identity lives in its own file, pulled in by `includeIf "gitdir:..."`:

| Repository under | Identity file |
|---|---|
| `~/github.com/` | `identity_github` |
| `~/codeberg.org/` | `identity_codeberg` |

`gitdir:` matches on where the repository's `.git` directory is, not on the current directory.
Outside a repository, or in a repository anywhere else, no identity is loaded and `git config user.name` prints nothing.
With `user.useConfigOnly = true`, git refuses to commit there rather than inventing a name from the hostname.
This is deliberate.

To see which identity applies, and where it comes from, run this inside the repository:

```sh
git config --show-origin --get-all user.name
```

Worktrees and `--separate-git-dir` clones keep their `.git` directory elsewhere, so they may not match.

## Cloning

Cloning needs no identity, because only commits and tags are authored.
Clone into the matching path, and the identity applies from the first commit:

```sh
git clone git@github.com:<owner>/<repo> ~/github.com/<owner>/<repo>
```

A clone anywhere else only shows up as a problem at the first commit.

## Keys

The SSH key matters for two things, and identity is not one of them:

- **Authentication.** SSH remotes fail with `Permission denied (publickey)` until the key exists and is registered with the forge. Public repositories can still be cloned over HTTPS.
- **Signing.** `commit.gpgSign` and `tag.gpgSign` are on, and each identity file sets `signingKey` to that forge's public key, so commits fail until the key exists.

On a new machine, generate the keys first; see `ssh/README.md`.
