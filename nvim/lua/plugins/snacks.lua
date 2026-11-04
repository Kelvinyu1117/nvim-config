-- snacks.nvim: a collection of small QoL modules (https://github.com/folke/snacks.nvim).
-- Pickers are handled by fzf-lua (plugins/fzf.lua); snacks provides the rest.
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true }, -- disable heavy features on huge files
    quickfile = { enabled = true }, -- render `nvim file` before plugins load
    explorer = { enabled = true, replace_netrw = true }, -- `nvim .` opens the explorer
    picker = { enabled = true, ui_select = false }, -- needed by the explorer; vim.ui.select uses fzf-lua
    indent = { enabled = true }, -- indent guides + current scope
    scope = { enabled = true }, -- `ii`/`ai` text objects for the current indent scope
    input = { enabled = true }, -- nicer vim.ui.input (rename prompts, ...)
    notifier = { enabled = true, timeout = 3000 },
    statuscolumn = { enabled = true }, -- signs, folds, git marks in the gutter
    words = { enabled = true }, -- highlight other uses of the word under the cursor (LSP)
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = " ", key = "f", desc = "Find file", action = ":FzfLua files" },
          { icon = " ", key = "g", desc = "Find text", action = ":FzfLua live_grep" },
          { icon = " ", key = "r", desc = "Recent files", action = ":FzfLua oldfiles" },
          { icon = " ", key = "n", desc = "New file", action = ":enew | startinsert" },
          { icon = " ", key = "s", desc = "Restore session", action = ":lua require('persistence').load()" },
          { icon = " ", key = "c", desc = "Config", action = ":FzfLua files cwd=" .. vim.fn.stdpath("config") },
          { icon = "󰒲 ", key = "l", desc = "Plugins (Lazy)", action = ":Lazy" },
          { icon = " ", key = "t", desc = "Vim tutor", action = ":Tutor" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
  },
  keys = {
    { "<leader>e", function() Snacks.explorer() end, desc = "File explorer" },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Git log (lazygit)" },
    { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "File history (lazygit)" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Open on GitHub/GitLab", mode = { "n", "x" } },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete buffer" },
    { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete other buffers" },
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename file (updates imports)" },
    { "<c-/>", function() Snacks.terminal() end, desc = "Toggle terminal", mode = { "n", "t" } },
    { "<c-_>", function() Snacks.terminal() end, desc = "which_key_ignore", mode = { "n", "t" } }, -- some terminals send <c-_> for <c-/>
    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next reference" },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Previous reference" },
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification history" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss notifications" },
    { "<leader>uz", function() Snacks.zen() end, desc = "Zen mode" },
    { "<leader>.", function() Snacks.scratch() end, desc = "Scratch buffer" },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- <Space>u... toggles; which-key shows their current on/off state
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("relativenumber", { name = "Relative numbers" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
        Snacks.toggle({
          name = "Format on save",
          get = function()
            return not vim.g.disable_autoformat
          end,
          set = function(state)
            vim.g.disable_autoformat = not state
          end,
        }):map("<leader>uf")
      end,
    })
  end,
}
