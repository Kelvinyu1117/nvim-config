-- Formatting with conform.nvim. Runs on save (toggle with <Space>uf); <Space>cf formats manually.
-- Run :ConformInfo to see which formatter a buffer uses and why one is missing.
--
-- C/C++/CUDA: format ON SAVE only when the project has a .clang-format file, so saving never
-- reformats a codebase that doesn't use clang-format. <Space>cf always formats: with the project's
-- .clang-format, or LLVM style if there is none.
-- Filetypes without a formatter listed here fall back to the language server's formatting
-- (e.g. neocmakelsp for CMakeLists.txt).

local clang_fts = { c = true, cpp = true, cuda = true }
local clang_files = { ".clang-format", "_clang-format" }

local function has_clang_format(bufnr)
  return vim.fs.root(bufnr, clang_files) ~= nil
end

-- Prettier (web languages, JSON, YAML, Markdown) is installed by Mason only where npm exists
-- (see lsp.lua). Where it's missing, those files fall back to the language server's formatter.
local prettier = { "prettierd", "prettier", stop_after_first = true }

return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cf",
      function()
        local buf = vim.api.nvim_get_current_buf()
        if clang_fts[vim.bo[buf].filetype] and not has_clang_format(buf) then
          vim.notify("No .clang-format in this project: formatting with LLVM style", vim.log.levels.INFO)
        end
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
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        toml = { "taplo" },
        json = prettier,
        jsonc = prettier,
        yaml = prettier,
        markdown = prettier,
        javascript = prettier,
        javascriptreact = prettier,
        typescript = prettier,
        typescriptreact = prettier,
        css = prettier,
        scss = prettier,
        html = prettier,
        vue = prettier,
        graphql = prettier,
      },
      formatters = {
        -- Use the nearest .clang-format; without one, clang-format falls back to LLVM style.
        clang_format = { cwd = require("conform.util").root_file(clang_files) },
      },
      default_format_opts = { lsp_format = "fallback" },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        if clang_fts[vim.bo[bufnr].filetype] and not has_clang_format(bufnr) then
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
