return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      direction = "horizontal",
      size = 20,
      open_mapping = [[<c-\>]],
    })

    -- Terminal mode keymaps for easy navigation
    local function set_terminal_keymaps()
      local opts = {buffer = 0}
      vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)        -- Exit terminal mode
      vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts) -- Move left
      vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts) -- Move down
      vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts) -- Move up
      vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts) -- Move right
    end

    vim.api.nvim_create_autocmd('TermOpen', {
      pattern = 'term://*',
      callback = set_terminal_keymaps,
    })

    -- Smart, orientation-aware resizing (works for both horizontal and vertical splits)
    local function smart_resize(delta)
      local win = vim.api.nvim_get_current_win()
      local width = vim.api.nvim_win_get_width(win)
      local height = vim.api.nvim_win_get_height(win)
      if width > height then
        vim.cmd("resize " .. (height + delta))
      else
        vim.cmd("vertical resize " .. (width + delta))
      end
    end

    -- Option+Plus/Minus OS X mappings for resize: always smart!
    vim.keymap.set('n', '<A-=>', function() smart_resize(3) end, { desc = "Smart resize increase" })
    vim.keymap.set('n', '<A-->', function() smart_resize(-3) end, { desc = "Smart resize decrease" })

    -- Leader key mappings for different terminal directions
    vim.keymap.set('n', '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', { desc = "Toggle Float Terminal" })
    vim.keymap.set('n', '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', { desc = "Toggle Horizontal Terminal" })
    vim.keymap.set('n', '<leader>tv', '<cmd>ToggleTerm direction=vertical<cr>', { desc = "Toggle Vertical Terminal" })
  end,
}
