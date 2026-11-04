-- Editing and navigation helpers.
return {
  -- Jump anywhere on screen: press `s`, type 2 chars, press the label that appears.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "o" }, function() require("flash").treesitter() end, desc = "Flash select syntax node" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
    },
  },

  -- Surround: ys{motion}{char} add, ds{char} delete, cs{old}{new} change, S{char} in visual.
  -- e.g. `ysiw"` wraps a word in quotes, `cs"'` turns "x" into 'x', `ds(` removes parens.
  { "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },

  -- Auto-close brackets and quotes
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- Highlight and list TODO/FIXME/HACK/NOTE comments
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous TODO" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODO list" },
      { "<leader>st", function() require("todo-comments.fzf").todo() end, desc = "TODOs" },
    },
  },

  -- Pretty lists for diagnostics, references, quickfix
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (project)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols outline" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
    },
  },

  -- Sessions: reopen the files/splits you had in a project
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session (this dir)" },
      { "<leader>qS", function() require("persistence").select() end, desc = "Select session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save this session" },
    },
  },

  -- Move/resize across Neovim splits AND Zellij/tmux/WezTerm/Kitty panes with the same keys.
  -- Must not be lazy-loaded so it can talk to the multiplexer.
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    opts = {},
    config = function(_, opts)
      local ss = require("smart-splits")
      ss.setup(opts)
      local map = vim.keymap.set
      map("n", "<C-h>", ss.move_cursor_left, { desc = "Go to left split/pane" })
      map("n", "<C-j>", ss.move_cursor_down, { desc = "Go to lower split/pane" })
      map("n", "<C-k>", ss.move_cursor_up, { desc = "Go to upper split/pane" })
      map("n", "<C-l>", ss.move_cursor_right, { desc = "Go to right split/pane" })
      map("n", "<A-h>", ss.resize_left, { desc = "Resize left" })
      map("n", "<A-j>", ss.resize_down, { desc = "Resize down" })
      map("n", "<A-k>", ss.resize_up, { desc = "Resize up" })
      map("n", "<A-l>", ss.resize_right, { desc = "Resize right" })
    end,
  },
}
