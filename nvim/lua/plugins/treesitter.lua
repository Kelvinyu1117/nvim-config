-- Treesitter: syntax-aware highlighting, indentation, folding and text objects.
-- Uses the `main` branch of nvim-treesitter. It needs the `tree-sitter` CLI (installed by Mason,
-- see lsp.lua) and a C compiler. On the very first launch, restart Neovim once after Mason finishes.
-- Other languages install automatically the first time you open one (or `:TSInstall <lang>`).
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
    dependencies = { "mason-org/mason.nvim" }, -- tree-sitter CLI on PATH
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.install(parsers) -- async, no-op if already installed
      local available, tried = nil, {}

      local function start(buf, lang)
        if vim.api.nvim_buf_is_valid(buf) and pcall(vim.treesitter.start, buf, lang) then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          return true
        end
        return false
      end

      -- Any language: highlight with the parser if it's installed; if it isn't but one exists,
      -- install it in the background (once per session) and highlight when it's ready.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang or vim.bo[ev.buf].buftype ~= "" or start(ev.buf, lang) or tried[lang] then
            return
          end
          if not available then
            local ok, list = pcall(ts.get_available)
            available = {}
            for _, l in ipairs(ok and list or {}) do
              available[l] = true
            end
          end
          if not available[lang] then
            return
          end
          tried[lang] = true
          local task = ts.install(lang)
          local buf = ev.buf
          if not (task and task.await and pcall(task.await, task, vim.schedule_wrap(function() start(buf, lang) end))) then
            vim.notify(("Installing the %s parser; reopen the file (:e) for highlighting"):format(lang))
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
