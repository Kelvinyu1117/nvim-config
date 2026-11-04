-- fzf-lua: the fuzzy finder for everything (files, grep, symbols, help, git, ...).
-- Uses the external `fzf` binary, so it stays fast in huge repos. Needs: fzf, ripgrep, fd.
-- Inside a picker: <C-q> sends all results to the quickfix list, <F1> shows help.
local function fzf(cmd, opts)
  return function()
    require("fzf-lua")[cmd](opts or {})
  end
end

return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    winopts = { height = 0.85, width = 0.85, preview = { layout = "flex" } },
    files = { cwd_prompt = false },
    keymap = { fzf = { ["ctrl-q"] = "select-all+accept" } },
  },
  config = function(_, opts)
    require("fzf-lua").setup(opts)
    require("fzf-lua").register_ui_select() -- code actions etc. use fzf-lua
  end,
  init = function()
    -- Load fzf-lua the first time anything calls vim.ui.select (e.g. a code action)
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.select = function(...)
      require("lazy").load({ plugins = { "fzf-lua" } })
      return vim.ui.select(...)
    end
  end,
  keys = {
    -- Most used: one keystroke after <Space>
    { "<leader><space>", fzf("files"), desc = "Find files" },
    { "<leader>/", fzf("live_grep"), desc = "Grep (project)" },
    { "<leader>,", fzf("buffers"), desc = "Open buffers" },
    { "<leader>:", fzf("command_history"), desc = "Command history" },

    -- <Space>f: find
    { "<leader>ff", fzf("files"), desc = "Files" },
    { "<leader>fr", fzf("oldfiles"), desc = "Recent files" },
    { "<leader>fg", fzf("git_files"), desc = "Git files" },
    { "<leader>fb", fzf("buffers"), desc = "Buffers" },
    { "<leader>fc", fzf("files", { cwd = vim.fn.stdpath("config") }), desc = "Config files" },

    -- <Space>s: search
    { "<leader>sg", fzf("live_grep"), desc = "Grep" },
    { "<leader>sw", fzf("grep_cword"), desc = "Word under cursor" },
    { "<leader>sw", fzf("grep_visual"), mode = "x", desc = "Selection" },
    { "<leader>sb", fzf("blines"), desc = "Lines in buffer" },
    { "<leader>sh", fzf("helptags"), desc = "Help pages" },
    { "<leader>sk", fzf("keymaps"), desc = "Keymaps" },
    { "<leader>sc", fzf("command_history"), desc = "Command history" },
    { "<leader>sC", fzf("commands"), desc = "Commands" },
    { "<leader>sd", fzf("diagnostics_document"), desc = "Diagnostics (buffer)" },
    { "<leader>sD", fzf("diagnostics_workspace"), desc = "Diagnostics (workspace)" },
    { "<leader>ss", fzf("lsp_document_symbols"), desc = "Symbols (buffer)" },
    { "<leader>sS", fzf("lsp_live_workspace_symbols"), desc = "Symbols (workspace)" },
    { "<leader>sm", fzf("marks"), desc = "Marks" },
    { "<leader>sR", fzf("registers"), desc = "Registers" },
    { "<leader>sj", fzf("jumps"), desc = "Jump list" },
    { "<leader>sq", fzf("quickfix"), desc = "Quickfix list" },
    { "<leader>sr", fzf("resume"), desc = "Resume last search" },

    -- <Space>g: git pickers (lazygit/gitsigns maps are in snacks.lua and git.lua)
    { "<leader>gs", fzf("git_status"), desc = "Git status" },
    { "<leader>gc", fzf("git_commits"), desc = "Git commits" },

    -- <Space>u: UI
    { "<leader>uC", fzf("colorschemes"), desc = "Colorscheme (live preview)" },
  },
}
