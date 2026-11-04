-- Completion: blink.cmp (https://cmp.saghen.dev)
--
-- Keys use the "default" preset = the same keys as Vim's built-in completion, so your
-- muscle memory works in any Neovim/Vim:
--   <C-n>/<C-p>  next/previous item        <C-y>  accept
--   <C-e>        close menu                <C-space>  open menu / toggle docs
--   <Tab>/<S-Tab>  jump to next/previous snippet placeholder
--   <C-k>        toggle function signature help
return {
  "saghen/blink.cmp",
  version = "1.*", -- release tags ship a prebuilt Rust fuzzy matcher
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = { "rafamadriz/friendly-snippets" },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = "default" },
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
