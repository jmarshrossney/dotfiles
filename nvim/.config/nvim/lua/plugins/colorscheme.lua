return {
  {
    "folke/tokyonight.nvim",
    -- Nvim >= 0.12.5 sets 'background' from the terminal before config loads.
    -- A fixed style = "night" would make tokyonight force it back to dark.
    opts = function()
      return {
        style = vim.o.background == "light" and "day" or "night",
        light_style = "day",
      }
    end,
  },
}
