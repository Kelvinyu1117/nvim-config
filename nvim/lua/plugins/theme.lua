-- lua/plugins/colorscheme.lua
return {
  "olimorris/onedarkpro.nvim",
  priority = 1000, -- Ensure it loads first
  config = function()
    require("onedarkpro").setup({
      options = {
        transparency = true,
        terminal_colors = true,
      },
      -- optional: small hover tweak so background matches Normal
      highlights = {
        NormalFloat = { link = "Normal" },
        FloatBorder = { link = "Normal" },
      },
    })

    -- IMPORTANT: actually apply the theme
    vim.cmd("colorscheme onedark_vivid")  -- or "onedarkpro" / another style
  end,
}
