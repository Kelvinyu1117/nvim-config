-- Editor options. See `:help option-list`, or `:help 'optionname'` for any line below.
local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true -- relative numbers make `5j`, `3dk`, ... easy to count
opt.cursorline = true
opt.signcolumn = "yes" -- always show, so diagnostics/git signs don't shift text
opt.termguicolors = true
opt.showmode = false -- the statusline already shows the mode
opt.laststatus = 3 -- one global statusline
opt.winborder = "rounded" -- borders on all floating windows (readable with transparent themes)
opt.pumheight = 12 -- max items in the completion menu
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldclose = "", foldsep = " " }
opt.wrap = false
opt.linebreak = true -- when wrap is on, break at word boundaries
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.smoothscroll = true
opt.mouse = "a" -- available, but the goal is to need it less and less

-- Indentation (formatters override this per project)
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.shiftround = true

-- Search
opt.ignorecase = true
opt.smartcase = true -- case-sensitive as soon as you type a capital letter
opt.inccommand = "split" -- live preview of :substitute
opt.grepprg = "rg --vimgrep --smart-case"
opt.grepformat = "%f:%l:%c:%m"

-- Splits
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

-- Behaviour
opt.undofile = true -- persistent undo, survives restarts
opt.confirm = true -- ask instead of failing on :q with unsaved changes
opt.updatetime = 250 -- faster CursorHold (document highlights, git signs)
opt.timeoutlen = 400 -- how long to wait for the next key of a mapping
opt.virtualedit = "block" -- free cursor movement in visual-block mode
opt.jumpoptions = "view"
opt.completeopt = "menu,menuone,noselect"

-- Folding with treesitter; everything open by default. `za` toggles, `zR`/`zM` open/close all.
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.foldlevel = 99

-- Clipboard: share with the OS. Over SSH use OSC 52 so yanks reach the clipboard of the
-- machine you are sitting at (works through Zellij/tmux with an OSC 52-capable terminal).
-- Scheduled because loading the clipboard provider can slow down startup.
vim.schedule(function()
  if vim.env.SSH_TTY then
    local osc52 = require("vim.ui.clipboard.osc52")
    -- Many terminals/multiplexers don't answer OSC 52 paste queries (it hangs), so paste
    -- from Neovim's own register; paste from the OS with your terminal's paste key instead.
    local function paste()
      return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
    end
    vim.g.clipboard = {
      name = "OSC 52",
      copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
      paste = { ["+"] = paste, ["*"] = paste },
    }
  end
  vim.o.clipboard = "unnamedplus"
end)

-- Make cargo-installed tools visible if ~/.cargo/bin exists (portable: no hardcoded user).
local cargo_bin = vim.fs.normalize("~/.cargo/bin")
if vim.fn.isdirectory(cargo_bin) == 1 and not vim.env.PATH:find(cargo_bin, 1, true) then
  local sep = vim.fn.has("win32") == 1 and ";" or ":"
  vim.env.PATH = cargo_bin .. sep .. vim.env.PATH
end

-- Diagnostics (errors/warnings from LSP and linters)
local sev = vim.diagnostic.severity
vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = { spacing = 2, source = "if_many", prefix = "●" },
  float = { source = "if_many" },
  signs = {
    text = {
      [sev.ERROR] = " ",
      [sev.WARN] = " ",
      [sev.INFO] = " ",
      [sev.HINT] = "󰌵 ",
    },
  },
})
