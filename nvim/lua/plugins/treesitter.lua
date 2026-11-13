-- Treesitter: syntax-aware highlighting, indentation, folding and text objects.
-- Uses the `main` branch of nvim-treesitter. It needs the `tree-sitter` CLI (installed by Mason,
-- see lsp.lua) and a C compiler. Parser installation waits for the CLI to become available.
-- Install more languages any time with `:TSInstall <lang>`.
local parsers = {
  "bash", "c", "cmake", "cpp", "cuda", "diff", "gitcommit", "json", "lua", "luadoc",
  "make", "markdown", "markdown_inline", "python", "query", "regex", "rust", "toml",
  "vim", "vimdoc", "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- the main branch does not support lazy-loading
    dependencies = { "mason-org/mason.nvim" }, -- adds Mason's bin directory to PATH
    build = function()
      -- Lazy's build hook can run before Mason has downloaded the CLI on a fresh machine.
      if vim.fn.executable("tree-sitter") == 1 then
        vim.cmd("TSUpdate")
      end
    end,
    config = function()
      local function install_parsers()
        if vim.fn.executable("tree-sitter") == 0 then
          return false
        end
        require("nvim-treesitter").install(parsers) -- async, no-op if already installed
        return true
      end

      if not install_parsers() then
        -- Covers both mason-tool-installer's startup download and :MasonInstall.
        require("mason-registry"):on("package:install:success", function(pkg)
          if pkg.name == "tree-sitter-cli" then
            vim.schedule(install_parsers)
          end
        end)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(ev)
          -- Start highlighting if a parser exists for this filetype; otherwise do nothing.
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- Code-aware text objects and motions. Combine with any operator:
  --   vaf  select a function     dif  delete function body    cia  change an argument
  --   yac  yank a class          ]f / [f  next/previous function start
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local objects = {
        ["af"] = { "@function.outer", "a function" },
        ["if"] = { "@function.inner", "inner function" },
        ["ac"] = { "@class.outer", "a class" },
        ["ic"] = { "@class.inner", "inner class" },
        ["aa"] = { "@parameter.outer", "an argument" },
        ["ia"] = { "@parameter.inner", "inner argument" },
      }
      for lhs, o in pairs(objects) do
        vim.keymap.set({ "x", "o" }, lhs, function()
          select.select_textobject(o[1], "textobjects")
        end, { desc = o[2] })
      end

      local move = require("nvim-treesitter-textobjects.move")
      local moves = {
        ["]f"] = { move.goto_next_start, "@function.outer", "Next function" },
        ["[f"] = { move.goto_previous_start, "@function.outer", "Previous function" },
        ["]C"] = { move.goto_next_start, "@class.outer", "Next class" },
        ["[C"] = { move.goto_previous_start, "@class.outer", "Previous class" },
      }
      for lhs, m in pairs(moves) do
        vim.keymap.set({ "n", "x", "o" }, lhs, function()
          m[1](m[2], "textobjects")
        end, { desc = m[3] })
      end
    end,
  },
}
