-- Statusline, keymap hints, breadcrumbs, LSP progress.
local function lsp_clients()
  local names = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    names[#names + 1] = client.name
  end
  return #names > 0 and (" " .. table.concat(names, ",")) or ""
end

return {
  { "nvim-tree/nvim-web-devicons", lazy = true }, -- icons (needs a Nerd Font in your terminal)

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = "",
        section_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = { "snacks_dashboard" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { lsp_clients, "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      extensions = { "lazy", "quickfix", "trouble", "fzf", "nvim-dap-ui", "man" },
    },
  },

  -- Shows available keys after you press a prefix like <Space>, g, [ or ]
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>gh", group = "hunks" },
        { "<leader>q", group = "quit/session" },
        { "<leader>r", group = "run tasks" },
        { "<leader>s", group = "search" },
        { "<leader>t", group = "test" },
        { "<leader>u", group = "ui toggles" },
        { "<leader>x", group = "diagnostics/quickfix" },
        { "<leader>w", group = "windows", proxy = "<c-w>" },
        { "[", group = "prev" },
        { "]", group = "next" },
        { "g", group = "goto" },
        { "gr", group = "lsp" },
        { "z", group = "fold/scroll" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Keymaps for this buffer",
      },
    },
  },

  -- Breadcrumbs (file > class > function) at the top of each window
  {
    "Bekaboo/dropbar.nvim",
    lazy = false,
    keys = {
      {
        "<leader>;",
        function()
          require("dropbar.api").pick()
        end,
        desc = "Pick breadcrumb",
      },
    },
  },

  -- LSP progress messages (indexing, loading workspace, ...) in the corner
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },
}
