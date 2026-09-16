return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      latex = {
        enabled = true,
        -- Use the latex2text executable installed by pylatexenc.
        converter = "latex2text",
        position = "center",
      },
    },
  },
}
