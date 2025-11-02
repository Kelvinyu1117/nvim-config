return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      direction = "horizontal",
      size = 20,
      open_mapping = [[<c-\>]],
    })

    -- Make <Esc> exit terminal mode to normal (doesn't close/hide terminal)
    vim.api.nvim_create_autocmd('TermOpen', {
      pattern = 'term://*',
      callback = function()
        vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], {buffer = 0})
      end,
    })

    -- Remap default Neovim resize keys for bigger steps (width and height)
    vim.keymap.set('n', '<C-w>>', '5<C-w>>', { desc = "Increase width by 5" })
    vim.keymap.set('n', '<C-w><', '5<C-w><', { desc = "Decrease width by 5" })
    vim.keymap.set('n', '<C-w>+', '5<C-w>+', { desc = "Increase height by 5" })
    vim.keymap.set('n', '<C-w>-', '5<C-w>-', { desc = "Decrease height by 5" })

    -- (Optional) Keep your leader mappings for Toggleterm if you want:
    vim.keymap.set('n', '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', { desc = "Toggle Float Terminal" })
    vim.keymap.set('n', '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', { desc = "Toggle Horizontal Terminal" })
    vim.keymap.set('n', '<leader>tv', '<cmd>ToggleTerm direction=vertical<cr>', { desc = "Toggle Vertical Terminal" })
  end,
}
