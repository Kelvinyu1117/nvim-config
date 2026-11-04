-- Language servers. Neovim 0.11+ has LSP support built in (vim.lsp.config / vim.lsp.enable).
--   * nvim-lspconfig ships default server configs (cmd, filetypes, root markers)
--   * Mason installs the server binaries (`:Mason`)
--   * mason-lspconfig enables every installed server automatically
--   * your own per-server tweaks go in after/lsp/<server>.lua
-- Rust is handled by rustaceanvim and Lean by lean.nvim (see lang.lua), not here.
return {
  {
    "mason-org/mason.nvim",
    lazy = false, -- cheap; puts Mason's bin dir on PATH for formatters, debuggers, tree-sitter
    build = ":MasonUpdate",
    opts = {},
  },

  -- Formatters, debuggers and CLIs that aren't language servers
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false, -- installs missing tools on startup
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "clang-format", -- C/C++/CUDA formatter
        "stylua", -- Lua formatter
        "codelldb", -- debugger for C/C++/Rust
        "debugpy", -- debugger for Python
        "tree-sitter-cli", -- builds treesitter parsers
      },
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    opts = {
      ensure_installed = {
        "clangd", -- C, C++, CUDA
        "basedpyright", -- Python types/navigation
        "ruff", -- Python lint + format
        "lua_ls", -- Lua (this config)
        "neocmake", -- CMakeLists.txt
      },
      -- rust-analyzer comes from rustup and is managed by rustaceanvim
      automatic_enable = { exclude = { "rust_analyzer" } },
    },
    config = function(_, opts)
      -- Tell every server what the completion engine supports (snippets, etc.)
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
      require("mason-lspconfig").setup(opts)
    end,
  },

  -- Proper Lua completion/diagnostics for the Neovim API when editing this config
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },
}
