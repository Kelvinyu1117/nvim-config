return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      direction = "horizontal",
      size = 20,
      open_mapping = [[<c-\>]],
    })

    -- Remap default Neovim resize keys for bigger steps (width and height)
    vim.keymap.set('n', '<C-w>>', '3<C-w>>', { desc = "Increase width by 3" })
    vim.keymap.set('n', '<C-w><', '3<C-w><', { desc = "Decrease width by 3" })
    vim.keymap.set('n', '<C-w>+', '3<C-w>+', { desc = "Increase height by 3" })
    vim.keymap.set('n', '<C-w>-', '3<C-w>-', { desc = "Decrease height by 3" })

    -- (Optional) Keep your leader mappings for Toggleterm if you want:
    vim.keymap.set('n', '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', { desc = "Toggle Float Terminal" })
    vim.keymap.set('n', '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', { desc = "Toggle Horizontal Terminal" })
    vim.keymap.set('n', '<leader>tv', '<cmd>ToggleTerm direction=vertical<cr>', { desc = "Toggle Vertical Terminal" })
  end,
}
