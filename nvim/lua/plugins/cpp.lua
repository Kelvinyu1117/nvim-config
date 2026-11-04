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

local function has_cuda_headers(dir)
  return dir ~= nil and dir ~= "" and vim.uv.fs_stat(vim.fs.joinpath(dir, "include", "cuda_runtime.h")) ~= nil
end

-- First folder that contains the CUDA headers: $CUDA_PATH, $CUDA_HOME, wherever `nvcc` lives,
-- /usr/local/cuda, /opt/cuda (Arch). Returns nil on machines without CUDA (e.g. a Mac).
local function find_cuda_toolkit()
  local nvcc = vim.fn.exepath("nvcc")
  local from_nvcc = nvcc ~= "" and vim.fs.dirname(vim.fs.dirname(vim.uv.fs_realpath(nvcc) or nvcc)) or nil
  local candidates = { vim.env.CUDA_PATH, vim.env.CUDA_HOME, from_nvcc, "/usr/local/cuda", "/opt/cuda" }
  for i = 1, 5 do -- not ipairs: entries may be nil
    if has_cuda_headers(candidates[i]) then
      return vim.fs.normalize(candidates[i])
    end
  end
end

local NO_CUDA_HELP = [[
No CUDA toolkit found on this machine
(looked in $CUDA_PATH, $CUDA_HOME, next to nvcc, /usr/local/cuda, /opt/cuda). Nothing was written.

Recommended: edit CUDA code on your GPU machine, where build/run/debug all work:
  ssh <gpu-host>  ->  zellij attach  ->  nvim

To read/write .cu files offline here instead, copy the headers once and pass their folder:
  rsync -a <gpu-host>:/usr/local/cuda/include/ ~/.local/cuda/include/
  :CudaClangdSetup ~/.local/cuda]]

-- :CudaClangdSetup[!] [cuda-folder]
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

  local cuda
  if cmd.args ~= "" then
    cuda = vim.fs.normalize(cmd.args)
    if not has_cuda_headers(cuda) then
      vim.notify(("CudaClangdSetup: %s/include/cuda_runtime.h not found"):format(cuda), vim.log.levels.ERROR)
      return
    end
  else
    cuda = find_cuda_toolkit()
    if not cuda then
      vim.notify(NO_CUDA_HELP, vim.log.levels.WARN)
      return
    end
  end

  local template = vim.fs.joinpath(vim.fn.stdpath("config"), "templates", "clangd-cuda.yaml")

  local function write(arch)
    if not arch or not arch:match("^sm_%d+%a?$") then
      vim.notify("CudaClangdSetup: expected an arch like sm_89, got " .. tostring(arch), vim.log.levels.ERROR)
      return
    end
    local lines = {}
    for _, line in ipairs(vim.fn.readfile(template)) do
      if line:find("@EXTRA_FLAGS@", 1, true) then
        lines[#lines + 1] = "    - --cuda-path=" .. cuda
      else
        lines[#lines + 1] = (line:gsub("sm_XX", arch))
      end
    end
    vim.fn.mkdir(vim.fs.dirname(target), "p")
    if exists then
      vim.uv.fs_copyfile(target, target .. ".bak")
    end
    vim.fn.writefile(lines, target)
    vim.notify(("Wrote %s (CUDA at %s, %s).\nRestart Neovim so clangd picks it up."):format(target, cuda, arch))
  end

  local arch = detect_gpu_arch()
  if arch then
    write(arch)
  else
    -- No GPU here (e.g. a Mac with copied headers): the arch only decides which features clangd
    -- treats as available, so pick the GPU you deploy to.
    vim.ui.input({ prompt = "GPU arch to target (sm_80 A100, sm_89 RTX 40xx, sm_90 H100): ", default = "sm_80" }, write)
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
        nargs = "?", -- optional CUDA folder, e.g. headers copied to a machine without CUDA
        complete = "dir",
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
