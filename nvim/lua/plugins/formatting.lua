-- Formatting with conform.nvim. Runs on save (toggle with <Space>uf); <Space>cf formats manually.
-- C/C++/CUDA only format when the project has a .clang-format file, so you never
-- reformat a whole file in a codebase that doesn't use clang-format.
return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true })
      end,
      mode = { "n", "x" },
      desc = "Format file/selection",
    },
  },
  opts = function()
    return {
      formatters_by_ft = {
        c = { "clang_format", lsp_format = "never" },
        cpp = { "clang_format", lsp_format = "never" },
        cuda = { "clang_format", lsp_format = "never" },
        python = { "ruff_organize_imports", "ruff_format" },
        rust = { "rustfmt" },
        lua = { "stylua" },
      },
      formatters = {
        -- only run when a .clang-format/_clang-format exists in the project
        clang_format = {
          cwd = require("conform.util").root_file({ ".clang-format", "_clang-format" }),
          require_cwd = true,
        },
      },
      default_format_opts = { lsp_format = "fallback" },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1000 }
      end,
    }
  end,
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" -- `gq` uses conform too
  end,
}
