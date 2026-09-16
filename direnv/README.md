# direnv

## Setup

1. [Install `direnv`](https://direnv.net/docs/installation.html)
2. Clone this repo
3. Symlink to `$XDG_CONFIG_HOME/direnv` (probably `~/.config/direnv`)

Note - I'm using some functions from the standard library that were only introduced fairly recently. So if `command not found` try installing a more recent `direnv` version.

## Usage

1. In a uv project, create a file `.envrc` with the line

```
use uv
```

2. Run `direnv allow .`

3. `cd` out of and then back into the directory.

## To do

More than just uv / python.
