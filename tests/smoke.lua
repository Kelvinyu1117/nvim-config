-- Headless smoke test: does the config start, load every plugin and open files without Lua errors?
--
--   nvim --headless -c "luafile tests/smoke.lua"     (from the repo root, config linked to ~/.config/nvim)
--
-- Exits 1 on failure. Only Lua errors count: missing external tools (rust-analyzer, lean, Mason
-- downloads that haven't finished) are expected on a fresh CI machine and are ignored.

local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local failures = {}
local done = false

local function fail(where, msg)
  failures[#failures + 1] = ("[%s] %s"):format(where, vim.trim(tostring(msg)))
end

local error_patterns = {
  "stack traceback", "stacktrace", "Error executing", "Failed to run", "Failed to load", "E5108", "E5113",
}
local function is_lua_error(msg)
  if type(msg) ~= "string" then
    return false
  end
  for _, p in ipairs(error_patterns) do
    if msg:find(p, 1, true) then
      return true
    end
  end
  return false
end

-- Catch errors reported through vim.notify (lazy.nvim reports plugin config errors this way)
local notify = vim.notify
vim.notify = function(msg, level, opts)
  if (level or 0) >= vim.log.levels.ERROR and is_lua_error(msg) then
    fail("notify", msg)
  end
  return notify(msg, level, opts)
end

local function step(name, fn)
  vim.v.errmsg = ""
  local ok, err = pcall(fn)
  if not ok then
    fail(name, err)
  elseif is_lua_error(vim.v.errmsg) then
    fail(name, vim.v.errmsg)
  end
end

local function check_messages(where)
  local out = vim.api.nvim_exec2("messages", { output = true }).output
  for line in out:gmatch("[^\n]+") do
    if is_lua_error(line) then
      fail(where, line)
    end
  end
end

local function finish()
  if done then
    return
  end
  done = true
  check_messages("messages")
  if #failures == 0 then
    io.stdout:write("smoke test: OK\n")
    vim.cmd("qall!")
  else
    io.stdout:write(("smoke test: %d failure(s)\n"):format(#failures))
    for _, f in ipairs(failures) do
      io.stdout:write("  " .. f .. "\n")
    end
    vim.cmd("cquit 1")
  end
end

local function run()
  -- 1. Force-load every plugin, so broken `config`/`opts` functions of lazy-loaded plugins show up.
  local names = vim.tbl_keys(require("lazy.core.config").plugins)
  table.sort(names)
  for _, name in ipairs(names) do
    step("load " .. name, function()
      require("lazy").load({ plugins = { name } })
    end)
  end

  -- 2. Open one file per language (filetype plugins, treesitter, LSP setup, ...)
  for _, file in ipairs(vim.fn.glob(root .. "/tests/fixtures/*", false, true)) do
    step("open " .. vim.fn.fnamemodify(file, ":t"), function()
      vim.cmd.edit(vim.fn.fnameescape(file))
      vim.wait(300)
    end)
  end

  -- 3. Key mappings that must exist
  for _, lhs in ipairs({ "<Space><Space>", "<Space>/", "<Space>e", "<Space>gg", "<Space>mg", "<Space>uf", "<C-h>", "<C-s>" }) do
    if vim.tbl_isempty(vim.fn.maparg(lhs, "n", false, true)) then
      fail("keymap", lhs .. " is not mapped")
    end
  end

  finish()
end

-- `-c` runs before startup finishes; wait for lazy.nvim's VeryLazy event (fired after VimEnter).
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    vim.schedule(run)
  end,
})
vim.defer_fn(function()
  if not done then
    fail("startup", "timed out waiting for the VeryLazy event")
    finish()
  end
end, 60000)
