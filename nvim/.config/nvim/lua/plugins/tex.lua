return {
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_compiler_latexmk_engines = { ["_"] = "-lualatex" }
      vim.g.vimtex_view_method = "zathura"
    end,
  },

  -- texlab renders referenced float captions as inlay hints, which shifts the
  -- line and disrupts cursor navigation. Disable them by default for tex
  -- filetypes; they can still be toggled back on per-buffer with `<leader>uh`.
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        exclude = { "vue", "tex", "plaintex", "bib" },
      },
    },
  },

  -- Autoformat LaTeX with tex-fmt (conform has a builtin definition for it).
  -- `--nowrap` disables tex-fmt's length-based line wrapping so a
  -- one-sentence-per-line source layout is preserved for clean diffs.
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        tex = { "tex-fmt" },
        plaintex = { "tex-fmt" },
      },
      formatters = {
        ["tex-fmt"] = {
          prepend_args = { "--nowrap" },
        },
      },
    },
  },
}
