-- Debugging (Debug Adapter Protocol). codelldb (C/C++/CUDA host code/Rust) and debugpy (Python)
-- are installed by Mason. A `.vscode/launch.json` in your project is picked up automatically.
-- Rust debugging goes through rustaceanvim: `:RustLsp debuggables`.
local function dap(fn, ...)
  local args = { ... }
  return function()
    require("dap")[fn](unpack(args))
  end
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        opts = {},
        config = function(_, opts)
          local d, dapui = require("dap"), require("dapui")
          dapui.setup(opts)
          d.listeners.after.event_initialized.dapui = function() dapui.open() end
          d.listeners.before.event_terminated.dapui = function() dapui.close() end
          d.listeners.before.event_exited.dapui = function() dapui.close() end
        end,
      },
      { "theHamsta/nvim-dap-virtual-text", opts = {} }, -- show variable values inline
      {
        "mfussenegger/nvim-dap-python",
        config = function()
          require("dap-python").setup("debugpy-adapter") -- provided by Mason's debugpy
        end,
      },
    },
    keys = {
      { "<leader>db", dap("toggle_breakpoint"), desc = "Toggle breakpoint" },
      {
        "<leader>dB",
        function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
        desc = "Conditional breakpoint",
      },
      { "<leader>dc", dap("continue"), desc = "Start / continue" },
      { "<leader>dC", dap("run_to_cursor"), desc = "Run to cursor" },
      { "<leader>di", dap("step_into"), desc = "Step into" },
      { "<leader>do", dap("step_over"), desc = "Step over" },
      { "<leader>dO", dap("step_out"), desc = "Step out" },
      { "<leader>dl", dap("run_last"), desc = "Run last" },
      { "<leader>dt", dap("terminate"), desc = "Terminate" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debug UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "x" }, desc = "Evaluate expression" },
      -- IDE-style function keys, as an alternative
      { "<F5>", dap("continue"), desc = "Debug: continue" },
      { "<F9>", dap("toggle_breakpoint"), desc = "Debug: breakpoint" },
      { "<F10>", dap("step_over"), desc = "Debug: step over" },
      { "<F11>", dap("step_into"), desc = "Debug: step into" },
      { "<F12>", dap("step_out"), desc = "Debug: step out" },
    },
    config = function()
      local d = require("dap")

      d.adapters.codelldb = { type = "executable", command = "codelldb" }
      local native = {
        {
          name = "Launch executable",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          args = function()
            return vim.split(vim.fn.input("Arguments: "), " ", { trimempty = true })
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }
      d.configurations.c = native
      d.configurations.cpp = native
      d.configurations.cuda = native

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })
    end,
  },
}
