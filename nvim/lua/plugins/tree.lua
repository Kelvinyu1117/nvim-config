return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons", -- optional
  },
  cmd = "Neotree", -- lazy loads when you open with :Neotree
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle Neo-tree" },
    { "<leader>o", "<cmd>Neotree focus<CR>", desc = "Focus Neo-tree window" }
  },
  opts = {
    filesystem = {
      follow_current_file = { enabled = true },
      hijack_netrw_behavior = "open_default",
      filtered_items = { visible = true },
      window = { position = "left" }, -- or "right"
      -- add other options you wish from https://github.com/nvim-neo-tree/neo-tree.nvim
    },
  },
}

