-- Entry point. Keep this file tiny: everything lives in lua/config and lua/plugins.
--
--   lua/config/options.lua   editor settings (vim.opt)
--   lua/config/lazy.lua      plugin manager bootstrap (lazy.nvim)
--   lua/config/keymaps.lua   global keymaps (plugin keymaps live next to each plugin)
--   lua/config/autocmds.lua  autocommands (incl. LSP keymaps on attach)
--   lua/plugins/*.lua        one file per area; every file returns lazy.nvim specs
--   after/lsp/*.lua          per-server overrides for the built-in vim.lsp.config

-- Leader keys must be set before lazy.nvim loads so plugin mappings pick them up.
vim.g.mapleader = " " -- <Space> is the leader: both thumbs can reach it
vim.g.maplocalleader = "\\" -- filetype-specific maps (e.g. Lean). Leaves `,` free for its built-in motion.

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
