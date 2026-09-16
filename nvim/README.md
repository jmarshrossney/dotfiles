# nvim-config

A very minimal WIP Neovim configuration based on [LazyVim](https://www.lazyvim.org/).

## Setup

1. Clone the repository
2. Symlink to `~/.config/nvim/`
3. Install the external tools (see below)
4. `nvim` & check for any errors
5. Run `:checkhealth provider`

### External tools

Neovim detects the Python provider through the `pynvim-python` executable installed by `uv`.

Install the Python provider and the LaTeX converter with:

```sh
uv tool install --upgrade pynvim
uv tool install --upgrade pylatexenc
uv tool update-shell
```

Restart your shell after `uv tool update-shell` if the executables are not already on `PATH`.

## Traps

### Pyright doesn't start

Could be that nodejs is too low a version. Update the nodejs version using [`n`](https://www.npmjs.com/package/n).

```sh
sudo npm install -g n
sudo n lts
```

## To do

Unfinished ideas and deferred improvements.

### Treesitter for Quarto/`.qmd` files

Currently `.qmd` files are typed as `quarto`, which has no treesitter parser, so they fall back to the Vim regex syntax engine.
For LaTeX-heavy files (`notes/book/foundations.qmd` in soccatoa-notes) this causes sluggish redraw.

**Idea:** Register `.qmd` / `quarto` to use the `markdown` treesitter parser, and optionally disable the Vim syntax engine for those buffers:

```lua
vim.treesitter.language.register("markdown", "quarto")
```

Turn off Vim syntax as well to avoid redundant double-highlighting:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "quarto",
  callback = function() vim.bo.syntax = "off" end,
})
```

**Status:** Not tested — needs a quick trial in a LaTeX-heavy `.qmd` to confirm highlighting is correct and R/Python code chunks still work.
