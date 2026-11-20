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

-- Run the current file, whatever the language: <Space>rf saves it and shows the output in a
-- floating terminal (`q` closes it). Projects with a build system: <Space>rr (tasks) instead.
local runners = {
  python = "python3 %s",
  lua = "nvim -l %s",
  sh = "bash %s",
  bash = "bash %s",
  zsh = "zsh %s",
  javascript = "node %s",
  typescript = "npx --yes tsx %s",
  go = "go run %s",
  ruby = "ruby %s",
  perl = "perl %s",
  php = "php %s",
  rust = "cargo run", -- runs the crate the file belongs to
  c = "cc -std=c17 -Wall -g %s -o /tmp/nvim-run && /tmp/nvim-run",
  cpp = "c++ -std=c++20 -Wall -g %s -o /tmp/nvim-run && /tmp/nvim-run",
  cuda = "nvcc -g %s -o /tmp/nvim-run && /tmp/nvim-run",
}
map("n", "<leader>rf", function()
  local cmd = runners[vim.bo.filetype]
  if not cmd then
    vim.notify("No runner for filetype '" .. vim.bo.filetype .. "': add one in config/keymaps.lua", vim.log.levels.WARN)
    return
  end
  vim.cmd("update")
  cmd = cmd:format(vim.fn.shellescape(vim.fn.expand("%:p")))
  Snacks.terminal.open(cmd, {
    cwd = vim.fn.expand("%:p:h"),
    -- keep the output on screen after the program exits; `q` closes the window
    interactive = false,
    start_insert = false,
    auto_insert = false,
    auto_close = false,
    win = { position = "float" },
  })
end, { desc = "Run current file" })

-- Misc
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Plugin manager (Lazy)" })
map("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Tool installer (Mason)" })
