local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- Briefly highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Reload files changed outside of Neovim
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Equalize splits when the terminal is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. tab)
  end,
})

-- Reopen files at the last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_position"),
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "gitcommit" or vim.b[ev.buf].last_pos_restored then
      return
    end
    vim.b[ev.buf].last_pos_restored = true
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close helper windows with `q`
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "checkhealth", "help", "lspinfo", "man", "qf", "notify", "startuptime",
    "neotest-output", "neotest-output-panel", "neotest-summary", "dap-float", "grug-far",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true, desc = "Close window" })
  end,
})

-- Wrap and spell-check prose
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("prose"),
  pattern = { "gitcommit", "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Create missing parent directories when saving a new file
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_mkdir"),
  callback = function(ev)
    if ev.match:match("^%w%w+:[\\/][\\/]") then
      return -- skip URLs like oil:// or scp://
    end
    local file = vim.uv.fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- LSP: keymaps and features when a language server attaches to a buffer.
--
-- Built-in Neovim defaults (no config needed, same on every machine):
--   K    hover docs          grn  rename            gra  code action
--   grr  references          gri  implementation    grt  type definition
--   gO   document symbols    [d ]d  prev/next diagnostic
-- Below we route the "goto" ones through fzf-lua for a previewable list, and add a few extras.
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("lsp_attach"),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local function map(lhs, rhs, desc, mode)
      vim.keymap.set(mode or "n", lhs, rhs, { buffer = ev.buf, desc = "LSP: " .. desc })
    end
    local function fzf(picker)
      return function()
        require("fzf-lua")[picker]({ jump1 = true })
      end
    end

    map("gd", fzf("lsp_definitions"), "Goto definition")
    map("gD", vim.lsp.buf.declaration, "Goto declaration")
    map("grr", fzf("lsp_references"), "References")
    map("gri", fzf("lsp_implementations"), "Goto implementation")
    map("grt", fzf("lsp_typedefs"), "Goto type definition")

    -- Same actions under the <Space>c "code" group for discoverability
    map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })
    map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")

    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf }) -- toggle with <Space>uh
    end
  end,
})
