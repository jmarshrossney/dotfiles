return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        list = {
          selection = {
            preselect = false,
          },
        },
      },
      keymap = { -- See :h blink-cmp-config-keymap
        preset = "enter", -- https://cmp.saghen.dev/configuration/keymap.html#presets
      },
    },
    -- TODO: let cmp-latex-symbols behave differently depending on filetype.
    -- For Julia, Python, \alph should autocomplete with α.
    -- For LaTeX (including within Markdown, docstrings etc) it should autocomplete with \alpha.
    -- See https://github.com/kdheepak/cmp-latex-symbols?tab=readme-ov-file#strategy
    -- This may or may not be worth the effort - unicode in LaTeX math environments seems to work ok
    -- with MathJax/KaTeX (Markdown->HTML) and XeLaTex/LuaLaTeX (Tex->PDF). Just avoid pdfLaTeX !
  },
}
