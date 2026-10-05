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
  --
  -- With no conform formatter for bib, conform falls back to texlab, whose
  -- BibTeX formatter rewrites the whole file on save (wrapping, field
  -- alignment, entry-type case). Disable it so edits to JabRef-managed .bib
  -- files stay as small diffs. If a bib formatter is wanted later, conform
  -- has a builtin `bibtex-tidy` that can be configured to match JabRef style.
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        exclude = { "vue", "tex", "plaintex", "bib" },
      },
      servers = {
        texlab = {
          settings = {
            texlab = {
              bibtexFormatter = "none",
            },
          },
        },
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

  -- Without tex-fmt installed, conform falls back to texlab's formatter,
  -- latexindent, which takes ~1.5s per save on a long document.
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "tex-fmt" } },
  },
}
