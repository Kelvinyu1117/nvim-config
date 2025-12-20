return {
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    config = function()
      require("lspsaga").setup({
        ui = { border = "rounded" },  -- uses your onedarkpro colors
      })
    end,
  },
}
