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
