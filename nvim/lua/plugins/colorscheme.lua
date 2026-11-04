-- Colorschemes. All three are installed so you can live-preview them with <Space>uC.
-- To change the default, edit COLORSCHEME below (e.g. "tokyonight-moon", "catppuccin-mocha",
-- "onedark_vivid"). Set TRANSPARENT = false for a solid background.
local COLORSCHEME = "tokyonight-night"
local TRANSPARENT = true

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000, -- load before other plugins (the alternates below load just before it)
    opts = {
      style = "night",
      transparent = TRANSPARENT,
      styles = {
        sidebars = TRANSPARENT and "transparent" or "dark",
        floats = TRANSPARENT and "transparent" or "dark",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme(COLORSCHEME)
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1001, -- set up before tokyonight's config applies COLORSCHEME
    opts = { flavour = "mocha", transparent_background = TRANSPARENT },
  },
  {
    "olimorris/onedarkpro.nvim",
    lazy = false,
    priority = 1001,
    opts = { options = { transparency = TRANSPARENT } },
  },
}
