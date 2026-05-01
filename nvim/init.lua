-- Set leader key FIRST, before anything else
vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("config.lazy")
vim.cmd("colorscheme onedark")

vim.env.PATH = vim.env.PATH .. ":/home/user/.cargo/bin/"

-- Core options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Ergonomics
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true

-- General keymaps

-- Better escape from insert mode
vim.keymap.set("i", "jk", "<Esc>", { noremap = true })

-- Save / quit
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { noremap = true, silent = true })

-- Clear search highlight
vim.keymap.set("n", "<leader>nh", "<cmd>nohlsearch<CR>", { noremap = true, silent = true })

-- Split navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true })

-- Resize splits
vim.keymap.set("n", "<Up>", "<cmd>resize +2<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Down>", "<cmd>resize -2<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Left>", "<cmd>vertical resize -2<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Right>", "<cmd>vertical resize +2<CR>", { noremap = true, silent = true })

-- Keep cursor centered while scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true })

-- Keep search matches centered
vim.keymap.set("n", "n", "nzzzv", { noremap = true })
vim.keymap.set("n", "N", "Nzzzv", { noremap = true })

-- Move visual selection up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { noremap = true })
vim.keymap.set("v", ">", ">gv", { noremap = true })

-- Paste over selection without overwriting yank register
vim.keymap.set("v", "p", '"_dP', { noremap = true })

-- Delete without polluting default register
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { noremap = true })

-- Signature help in insert mode
vim.keymap.set("i", "<C-s>", function()
  vim.lsp.buf.signature_help()
end)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers["signature_help"],
  {
    border = "single",
    close_events = { "CursorMoved", "BufHidden", "InsertCharPre" },
  }
)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

    -- Navigation
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)

    -- Info
    vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", bufopts)
    vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, bufopts)

    -- Refactoring
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, bufopts)

    -- Diagnostics
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, bufopts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)

    -- References
    vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)

    -- Workspace
    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
  end,
})
