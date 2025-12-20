
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

-- Flatten LSP hover styling so it follows One Dark Pro
vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
vim.api.nvim_set_hl(0, "FloatBorder", { link = "Normal" })
vim.api.nvim_set_hl(0, "LspReferenceText", { link = "Normal" })
vim.api.nvim_set_hl(0, "LspReferenceRead", { link = "Normal" })
vim.api.nvim_set_hl(0, "LspReferenceWrite", { link = "Normal" })
vim.api.nvim_set_hl(0, "Pmenu", { link = "Normal" })
vim.api.nvim_set_hl(0, "PmenuSel", { link = "Visual" })



vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      
    -- Navigation (perfect - keep)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    
    -- Info
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', '<leader>k', vim.lsp.buf.signature_help, bufopts)  -- Fixed!
    
    -- Refactoring
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
    
    -- Diagnostics
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, bufopts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
    
    -- References
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    
    -- Workspace
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  end,
})



