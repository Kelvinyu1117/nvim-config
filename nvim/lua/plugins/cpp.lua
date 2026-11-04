-- C / C++ / CUDA extras on top of clangd (after/lsp/clangd.lua), clang-format (formatting.lua)
-- and codelldb (dap.lua).
--
--   * cmake-tools.nvim: configure/build/run/debug CMake targets from Neovim (<Space>m...). It also
--     links compile_commands.json into the project root, which clangd needs to understand your code.
--   * clangd_extensions.nvim: AST, type hierarchy, symbol info, source/header switching.
--   * :CudaClangdSetup: one-time setup so clangd understands nvcc's flags in .cu/.cuh files.

local function clangd_user_config()
  if vim.fn.has("mac") == 1 then
    return vim.fs.normalize("~/Library/Preferences/clangd/config.yaml")
  elseif vim.fn.has("win32") == 1 then
    return vim.fs.joinpath(vim.env.LOCALAPPDATA, "clangd", "config.yaml")
  end
  local xdg = vim.env.XDG_CONFIG_HOME or vim.fs.normalize("~/.config")
  return vim.fs.joinpath(xdg, "clangd", "config.yaml")
end

-- "8.9" from nvidia-smi -> "sm_89"
local function detect_gpu_arch()
  if vim.fn.executable("nvidia-smi") == 0 then
    return nil
  end
  local res = vim.system({ "nvidia-smi", "--query-gpu=compute_cap", "--format=csv,noheader" }, { text = true }):wait()
  if res.code ~= 0 then
    return nil
  end
  local major, minor = (res.stdout or ""):match("(%d+)%.(%d+)")
  return major and ("sm_" .. major .. minor) or nil
end

local function cuda_clangd_setup(cmd)
  local target = clangd_user_config()
  local exists = vim.uv.fs_stat(target) ~= nil
  if exists and not cmd.bang then
    vim.notify(
      ("%s already exists.\nMerge %s into it by hand, or run :CudaClangdSetup! to replace it (a .bak copy is kept)."):format(
        target,
        "templates/clangd-cuda.yaml"
      ),
      vim.log.levels.WARN
    )
    return
  end
  local template = vim.fs.joinpath(vim.fn.stdpath("config"), "templates", "clangd-cuda.yaml")
  local lines = vim.fn.readfile(template)

  local function write(arch)
    if not arch or not arch:match("^sm_%d+%a?$") then
      vim.notify("CudaClangdSetup: expected an arch like sm_89, got " .. tostring(arch), vim.log.levels.ERROR)
      return
    end
    for i, line in ipairs(lines) do
      lines[i] = line:gsub("sm_XX", arch)
    end
    vim.fn.mkdir(vim.fs.dirname(target), "p")
    if exists then
      vim.uv.fs_copyfile(target, target .. ".bak")
    end
    vim.fn.writefile(lines, target)
    vim.notify(("Wrote %s for %s.\nRestart Neovim so clangd picks it up."):format(target, arch))
  end

  local arch = detect_gpu_arch()
  if arch then
    write(arch)
  else
    vim.ui.input({ prompt = "GPU arch not detected. Enter it (sm_80 A100, sm_89 RTX 40xx, sm_90 H100): ", default = "sm_80" }, write)
  end
end

return {
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    opts = {
      ast = { highlights = { detail = { fg = "Comment" } } },
      memory_usage = { border = "rounded" },
      symbol_info = { border = "rounded" },
    },
    init = function()
      vim.api.nvim_create_user_command("CudaClangdSetup", cuda_clangd_setup, {
        bang = true,
        desc = "Install clangd config so it understands CUDA (.cu/.cuh) compile commands",
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_clangd_keys", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client or client.name ~= "clangd" then
            return
          end
          local function map(lhs, rhs, desc, mode)
            vim.keymap.set(mode or "n", lhs, rhs, { buffer = ev.buf, desc = "C++: " .. desc })
          end
          map("<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", "Switch source/header")
          map("<leader>ci", "<cmd>ClangdSymbolInfo<cr>", "Symbol info")
          map("<leader>cH", "<cmd>ClangdTypeHierarchy<cr>", "Type hierarchy")
          map("<leader>cA", ":ClangdAST<cr>", "Show AST", { "n", "x" })
          map("<leader>cM", "<cmd>ClangdMemoryUsage<cr>", "clangd memory usage")
        end,
      })
    end,
  },

  {
    "Civitasv/cmake-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "stevearc/overseer.nvim" },
    ft = "cmake",
    cmd = {
      "CMakeGenerate", "CMakeBuild", "CMakeRun", "CMakeDebug", "CMakeRunTest", "CMakeClean",
      "CMakeSelectBuildType", "CMakeSelectBuildTarget", "CMakeSelectLaunchTarget",
      "CMakeSelectConfigurePreset", "CMakeLaunchArgs", "CMakeStopExecutor",
    },
    keys = {
      { "<leader>mg", "<cmd>CMakeGenerate<cr>", desc = "Generate (configure)" },
      { "<leader>mb", "<cmd>CMakeBuild<cr>", desc = "Build" },
      { "<leader>mr", "<cmd>CMakeRun<cr>", desc = "Run launch target" },
      { "<leader>md", "<cmd>CMakeDebug<cr>", desc = "Debug launch target" },
      { "<leader>mT", "<cmd>CMakeRunTest<cr>", desc = "Run tests (ctest)" },
      { "<leader>mc", "<cmd>CMakeClean<cr>", desc = "Clean" },
      { "<leader>mv", "<cmd>CMakeSelectBuildType<cr>", desc = "Select build type (Debug/Release)" },
      { "<leader>mt", "<cmd>CMakeSelectBuildTarget<cr>", desc = "Select build target" },
      { "<leader>ml", "<cmd>CMakeSelectLaunchTarget<cr>", desc = "Select launch target" },
      { "<leader>mp", "<cmd>CMakeSelectConfigurePreset<cr>", desc = "Select configure preset" },
      { "<leader>ma", "<cmd>CMakeLaunchArgs<cr>", desc = "Set launch arguments" },
      { "<leader>ms", "<cmd>CMakeStopExecutor<cr>", desc = "Stop build" },
    },
    opts = {
      cmake_build_directory = "build/${variant:buildType}",
      cmake_regenerate_on_save = true,
      -- link build/<type>/compile_commands.json to the project root so clangd finds it
      cmake_compile_commands_options = { action = "soft_link" },
      cmake_executor = { name = "overseer" },
      cmake_runner = { name = "overseer" },
      -- <Space>md debugs the selected target with codelldb (adapter defined in dap.lua)
      cmake_dap_configuration = { name = "cpp", type = "codelldb", request = "launch", stopOnEntry = false },
    },
  },
}
