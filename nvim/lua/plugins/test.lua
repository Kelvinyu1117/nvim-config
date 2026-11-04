-- Tests (neotest) and build/run tasks (overseer).
local function nt(fn)
  return function()
    fn(require("neotest"))
  end
end

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python", -- pytest / unittest
      "alfaix/neotest-gtest", -- GoogleTest (C++)
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({ dap = { justMyCode = false } }),
          require("neotest-gtest").setup({}),
          require("rustaceanvim.neotest"), -- cargo test, via rustaceanvim
        },
        status = { virtual_text = true },
        output = { open_on_run = true },
      })
    end,
    keys = {
      { "<leader>tt", nt(function(n) n.run.run() end), desc = "Run nearest test" },
      { "<leader>tf", nt(function(n) n.run.run(vim.fn.expand("%")) end), desc = "Run tests in file" },
      { "<leader>tT", nt(function(n) n.run.run(vim.uv.cwd()) end), desc = "Run all tests" },
      { "<leader>tl", nt(function(n) n.run.run_last() end), desc = "Run last test" },
      { "<leader>td", nt(function(n) n.run.run({ strategy = "dap" }) end), desc = "Debug nearest test" },
      { "<leader>ts", nt(function(n) n.summary.toggle() end), desc = "Test summary" },
      { "<leader>to", nt(function(n) n.output.open({ enter = true, auto_close = true }) end), desc = "Test output" },
      { "<leader>tO", nt(function(n) n.output_panel.toggle() end), desc = "Test output panel" },
      { "<leader>tS", nt(function(n) n.run.stop() end), desc = "Stop tests" },
      { "<leader>tw", nt(function(n) n.watch.toggle(vim.fn.expand("%")) end), desc = "Watch file" },
    },
  },

  -- Task runner: knows cargo, cmake, make, npm, ... templates out of the box
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerTaskAction" },
    opts = {},
    keys = {
      { "<leader>rr", "<cmd>OverseerRun<cr>", desc = "Run a task (build, run, ...)" },
      { "<leader>rt", "<cmd>OverseerToggle<cr>", desc = "Task list" },
      { "<leader>ra", "<cmd>OverseerTaskAction<cr>", desc = "Task action (restart, stop, ...)" },
    },
  },
}
