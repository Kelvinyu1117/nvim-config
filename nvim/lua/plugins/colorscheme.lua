-- Colorschemes. All three are installed so you can live-preview them with <Space>uC.
-- The default is One Dark Pro ("onedark", like the VS Code theme). To change it, edit COLORSCHEME
-- below (e.g. "onedark_vivid", "onedark_dark", "tokyonight-night", "catppuccin-mocha").
-- Set TRANSPARENT = false for a solid background, ITALIC = true for italic comments/keywords.
local COLORSCHEME = "onedark"
local TRANSPARENT = true
local ITALIC = false

-- With ITALIC off, also strip italics from every highlight group after any colorscheme loads,
-- so plugins that italicize their own groups (and themes picked with <Space>uC) stay upright.
if not ITALIC then
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("no_italic", { clear = true }),
    callback = function()
      for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
        if hl.italic or (hl.cterm and hl.cterm.italic) then
          hl.italic = nil
          if hl.cterm then
            hl.cterm.italic = nil
          end
          vim.api.nvim_set_hl(0, name, hl)
        end
      end
    end,
  })
end

-- Inlay hints (clangd's `: int` after `auto`, parameter names like `a:`) are drawn almost in the
-- background color by most themes, which makes them invisible on a transparent background. After
-- any colorscheme loads, color them a bit brighter than comments: readable, but still quieter than
-- code. Toggle the hints themselves with <Space>uh.
local function blend(a, b, t) -- mix two 0xRRGGBB colors, t = 0 gives a, t = 1 gives b
  local out = 0
  for shift = 0, 16, 8 do
    local ca, cb = bit.band(bit.rshift(a, shift), 0xff), bit.band(bit.rshift(b, shift), 0xff)
    out = out + bit.lshift(math.floor(ca + (cb - ca) * t + 0.5), shift)
  end
  return out
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("readable_inlay_hints", { clear = true }),
  callback = function()
    local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false }).fg
    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).fg
    if comment and normal then
      vim.api.nvim_set_hl(0, "LspInlayHint", { fg = blend(comment, normal, 0.3) })
    end
  end,
})

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000, -- applies COLORSCHEME; the other two are set up just before it
    opts = {
      style = "night",
      transparent = TRANSPARENT,
      styles = {
        comments = { italic = ITALIC },
        keywords = { italic = ITALIC },
        sidebars = TRANSPARENT and "transparent" or "dark",
        floats = TRANSPARENT and "transparent" or "dark",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme(COLORSCHEME)
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1001, -- set up before COLORSCHEME is applied (in tokyonight's config above)
    opts = { flavour = "mocha", transparent_background = TRANSPARENT, no_italic = not ITALIC },
  },
  {
    "olimorris/onedarkpro.nvim",
    lazy = false,
    priority = 1001,
    opts = {
      options = { transparency = TRANSPARENT },
      styles = ITALIC and {} or { comments = "NONE", keywords = "NONE", virtual_text = "NONE" },
    },
  },
}
