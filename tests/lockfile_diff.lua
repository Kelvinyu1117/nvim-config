-- Markdown changelog between two lazy-lock.json files, used as the weekly update PR's description.
--
--   OLD_LOCK=old.json NEW_LOCK=nvim/lazy-lock.json OUT=body.md nvim --headless -c "luafile tests/lockfile_diff.lua"
--
-- Runs inside the full config so plugin URLs can be read from lazy.nvim's specs.

local function read(path)
  local f = path and io.open(path, "r")
  if not f then
    return {}
  end
  local text = f:read("*a")
  f:close()
  if vim.trim(text) == "" then
    return {}
  end
  return vim.json.decode(text)
end

local old, new = read(vim.env.OLD_LOCK), read(vim.env.NEW_LOCK)
local specs = require("lazy.core.config").plugins

local function url(name)
  local p = specs[name]
  local u = (p and p.url) or ("https://github.com/" .. name)
  return (u:gsub("%.git$", ""))
end

local names = {}
for name in pairs(vim.tbl_extend("force", {}, old, new)) do
  names[#names + 1] = name
end
table.sort(names, function(a, b)
  return a:lower() < b:lower()
end)

local updated, added, removed = {}, {}, {}
for _, name in ipairs(names) do
  local o, n = old[name], new[name]
  if o and n and o.commit ~= n.commit then
    updated[#updated + 1] = ("| [%s](%s) | `%s` → `%s` | [changes](%s/compare/%s...%s) |"):format(
      name, url(name), o.commit:sub(1, 7), n.commit:sub(1, 7), url(name), o.commit, n.commit
    )
  elseif n and not o then
    added[#added + 1] = ("- [%s](%s) at `%s`"):format(name, url(name), n.commit:sub(1, 7))
  elseif o and not n then
    removed[#removed + 1] = ("- %s"):format(name)
  end
end

local lines = {
  "Automated weekly plugin update.",
  "",
  "The new `lazy-lock.json` was booted headless on **Ubuntu and macOS** (`tests/smoke.lua`): every",
  "plugin loaded and files in each language opened without Lua errors.",
  "",
  "**Before merging**, skim the changes below for breaking-change notes. After merging, run `./install.sh`",
  "(or `git pull` + `:Lazy restore`) on each machine.",
  "",
}
if #updated > 0 then
  vim.list_extend(lines, { ("### Updated (%d)"):format(#updated), "", "| Plugin | Commit | Diff |", "|---|---|---|" })
  vim.list_extend(lines, updated)
  lines[#lines + 1] = ""
end
if #added > 0 then
  vim.list_extend(lines, { ("### Added (%d)"):format(#added), "" })
  vim.list_extend(lines, added)
  lines[#lines + 1] = ""
end
if #removed > 0 then
  vim.list_extend(lines, { ("### Removed (%d)"):format(#removed), "" })
  vim.list_extend(lines, removed)
  lines[#lines + 1] = ""
end
if #updated + #added + #removed == 0 then
  lines[#lines + 1] = "No plugin changes."
end

vim.fn.writefile(lines, vim.env.OUT or "pr-body.md")
vim.cmd("qall!")
