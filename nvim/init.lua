
-- Set leader key FIRST, before anything else
vim.g.mapleader = "."
vim.g.maplocalleader = ","
require("config.lazy")
vim.cmd("colorscheme onedark")

vim.env.PATH = vim.env.PATH .. ":/home/user/.cargo/bin/"

vim.cmd("set number")
vim.cmd("set relativenumber")
vim.cmd("set mouse=a")
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.keymap.set('n', '<leader>h', '<C-w>h')
vim.keymap.set('n', '<leader>l', '<C-w>l')

