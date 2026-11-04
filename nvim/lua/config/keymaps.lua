-- Global keymaps. Plugin keymaps are defined next to each plugin (see `keys = {...}`),
-- LSP keymaps in autocmds.lua. Press <Space> and wait to see everything (which-key),
-- or <Space>sk to fuzzy-search all keymaps.
local map = vim.keymap.set

-- Leaving insert mode: <Esc>, <C-[> (built in, works everywhere) or a quick `jk`.
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Save from any mode
map({ "n", "i", "x", "s" }, "<C-s>", "<cmd>write<cr><esc>", { desc = "Save file" })

-- <Esc> in normal mode also clears search highlighting
map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>", { desc = "Clear search highlight" })

-- Windows. <C-h/j/k/l> (move) and <A-h/j/k/l> (resize) are in plugins/editor.lua (smart-splits),
-- so they also move between Zellij/tmux panes. <Space>w gives you every <C-w> command.
map("n", "<leader>-", "<C-w>s", { desc = "Split below" })
map("n", "<leader>|", "<C-w>v", { desc = "Split right" })

-- Buffers (open files)
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>edit #<cr>", { desc = "Switch to alternate buffer" })
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })

-- Keep the cursor centered while scrolling / jumping between search results
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous match (centered)" })

-- Visual mode: move selected lines, keep selection while indenting.
-- Tip: `P` (capital) in visual mode pastes over the selection WITHOUT overwriting your yank.
map("x", "J", ":move '>+1<cr>gv=gv", { desc = "Move selection down", silent = true })
map("x", "K", ":move '<-2<cr>gv=gv", { desc = "Move selection up", silent = true })
map("x", "<", "<gv", { desc = "Indent left" })
map("x", ">", ">gv", { desc = "Indent right" })

-- Diagnostics. `[d` / `]d` (prev/next) and `<C-w>d` (float) are built in.
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Misc
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Plugin manager (Lazy)" })
map("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Tool installer (Mason)" })
