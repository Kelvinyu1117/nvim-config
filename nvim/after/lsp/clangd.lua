-- Merged on top of nvim-lspconfig's clangd defaults.
-- clangd is the language server for C, C++ and CUDA. It needs a compile_commands.json at the
-- project root to understand your build:
--   CMake:  <Space>mg (cmake-tools, plugins/cpp.lua) generates and links it for you
--   Make:   bear -- make
-- For CUDA, run :CudaClangdSetup once so clangd understands nvcc's flags.
return {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders=true",
    "--fallback-style=llvm",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
}
