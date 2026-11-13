-- Run from the repo root: nvim --headless -u NONE -l tests/treesitter_startup.lua
-- Exercise the CLI/download race without downloading plugins or parsers.
local available = false
local installs, updates = 0, 0
local listener
local executable = vim.fn.executable
vim.fn.executable = function(name)
  if name == "tree-sitter" then
    return available and 1 or 0
  end
  return executable(name)
end
package.loaded["nvim-treesitter"] = {
  install = function(parsers)
    assert(vim.tbl_contains(parsers, "make") and vim.tbl_contains(parsers, "json"))
    assert(available, "parser installation must not run without the CLI")
    installs = installs + 1
  end,
}
package.loaded["mason-registry"] = {
  on = function(_, event, callback)
    assert(event == "package:install:success")
    listener = callback
  end,
}
vim.api.nvim_create_user_command("TSUpdate", function()
  updates = updates + 1
end, {})

local spec = dofile("nvim/lua/plugins/treesitter.lua")[1]
spec.build()
spec.config()
assert(updates == 0 and installs == 0 and listener, "fresh installs must wait for Mason")

listener({ name = "stylua" })
vim.wait(20)
assert(installs == 0, "unrelated package downloads must not trigger parser builds")

listener({ name = "tree-sitter-cli" })
vim.wait(20)
assert(installs == 0, "recheck executable availability after download")

available = true
listener({ name = "tree-sitter-cli" })
assert(vim.wait(1000, function() return installs == 1 end), "retry after Mason installs the CLI")
spec.build()
assert(updates == 1, "update parsers when the CLI is ready")

listener = nil
spec.config()
assert(installs == 2 and listener == nil, "existing CLI should install parsers immediately")
print("treesitter startup: OK")
