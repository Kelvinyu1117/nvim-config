-- Language-specific plugins.
return {
  -- Rust: rust-analyzer + debugging + test integration. Install the server with:
  --   rustup component add rust-analyzer
  -- Extra commands: `:RustLsp expandMacro`, `:RustLsp runnables`, `:RustLsp explainError`, ...
  {
    "mrcjkb/rustaceanvim",
    version = "*",
    lazy = false, -- the plugin lazy-loads itself on Rust files
    init = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(_, bufnr)
            vim.keymap.set("n", "K", function()
              vim.cmd.RustLsp({ "hover", "actions" })
            end, { buffer = bufnr, desc = "Rust: hover actions" })
            vim.keymap.set("n", "<leader>ce", function()
              vim.cmd.RustLsp("expandMacro")
            end, { buffer = bufnr, desc = "Rust: expand macro" })
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              check = { command = "clippy" },
            },
          },
        },
      }
    end,
  },

  -- Lean 4: infoview, unicode input (type \alpha -> α), goal view. Needs elan:
  --   https://github.com/leanprover/elan
  -- Lean mappings use the local leader (\), e.g. `\i` toggles the infoview.
  {
    "Julian/lean.nvim",
    event = { "BufReadPre *.lean", "BufNewFile *.lean" },
    dependencies = { "neovim/nvim-lspconfig", "nvim-lua/plenary.nvim" },
    opts = { mappings = true },
  },
}
