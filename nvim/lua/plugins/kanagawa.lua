return {
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    lazy = false,
    opts = { theme = "wave", transparent = true, commentStyle = { italic = true } },
    config = function(_, opts)
      vim.o.laststatus = 3
      vim.o.cmdheight = 1
      require("kanagawa").setup(opts)
      vim.cmd("colorscheme kanagawa")
    end,
  },
}

