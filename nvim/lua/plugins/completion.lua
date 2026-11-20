-- Completion: blink.cmp (https://cmp.saghen.dev)
--
-- Keys use the "super-tab" preset (Tab accepts, like VS Code), plus Vim's <C-y>:
--   <Tab>        accept the suggestion (the first one if none is selected); inside a
--                snippet with no menu open, jump to the next placeholder; else a normal tab
--   <S-Tab>      jump to the previous snippet placeholder
--   <C-n>/<C-p> or <Up>/<Down>  next/previous item     <C-y>  accept (Vim's key)
--   <C-e>        close menu                <C-space>  open menu / toggle docs
--   <C-b>/<C-f>  scroll docs               <C-k>  toggle function signature help
return {
  "saghen/blink.cmp",
  version = "1.*", -- release tags ship a prebuilt Rust fuzzy matcher
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = { "rafamadriz/friendly-snippets" },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = "super-tab",
      ["<C-y>"] = { "select_and_accept", "fallback" }, -- keep Vim's accept key too
    },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 300 },
      menu = { draw = { treesitter = { "lsp" } } },
    },
    signature = { enabled = true },
    sources = {
      default = { "lazydev", "lsp", "path", "snippets", "buffer" },
      providers = {
        -- Completion for Neovim's Lua API while editing this config
        lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
      },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
