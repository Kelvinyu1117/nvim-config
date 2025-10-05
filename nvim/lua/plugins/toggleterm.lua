return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      direction = "horizontal",
      size = 20,
      open_mapping = [[<c-\>]], -- Default toggle mapping
      -- You can customize other options here
    })
        
    -- Additional useful mappings
    vim.keymap.set('n', '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', { desc = "Toggle Float Terminal" })
    vim.keymap.set('n', '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', { desc = "Toggle Horizontal Terminal" })
    vim.keymap.set('n', '<leader>tv', '<cmd>ToggleTerm direction=vertical<cr>', { desc = "Toggle Vertical Terminal" })
  end,
}

