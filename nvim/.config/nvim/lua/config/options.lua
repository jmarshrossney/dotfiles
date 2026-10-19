-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.wrap = true

-- Skip the redundant second inclusion of syntax/tex.vim in Rmd/Quarto buffers.
-- Pandoc's LaTeX highlighting (loaded via rmd.vim -> pandoc.vim) already provides
-- @LATEX highlighting for math blocks; rmd's additional @RmdLaTeX layer is
-- unnecessary and causes lag on LaTeX-heavy .qmd files.
vim.g.rmd_include_latex = 0

-- Don't create the RmdCStr autocmd that calls SetRmdCommentStr() on every
-- CursorMoved. It scans backwards for R chunks to decide whether gq/gc should
-- use # or <!-- --> comments; with no R chunks in the file it's just useless
-- per-move overhead.
vim.g.rmd_dynamic_comments = 0

-- The python3 provider needs an interpreter that can import pynvim, which is
-- not the interpreter of whatever project venv happens to be active. `uv tool
-- install pynvim` provides exactly that: ~/.local/bin/pynvim-python is a shim
-- onto uv's own tool environment, so project environments stay clean.
-- ubuntu-setup's python.sh installs it; the guard keeps :checkhealth quiet on a
-- machine where that has not run yet.
local pynvim = vim.fn.expand("~/.local/bin/pynvim-python")
if vim.uv.fs_stat(pynvim) then
  vim.g.python3_host_prog = pynvim
end

-- No plugins here use the node, perl or ruby remote-plugin hosts. Disabling them
-- skips the host lookup and keeps :checkhealth free of warnings about them.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Use the terminal's OSC 52 clipboard rather than wl-clipboard. GNOME lacks the
-- data-control protocol, so wl-paste must grab focus via a transient surface
-- and, when that fails, blocks nvim indefinitely. Paste needs
-- `terminal.osc52 = "CopyPaste"` in alacritty.toml.
-- NOTE: that setting lets any program writing to the terminal read the system
-- clipboard, including programs on remote hosts reached over ssh. Revert to
-- explicit "+ registers if that becomes a concern.
local osc52 = require("vim.ui.clipboard.osc52")
vim.g.clipboard = {
  name = "OSC 52",
  copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
  paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
}
