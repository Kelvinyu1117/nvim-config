-- Python types and navigation. Activate your virtualenv before starting nvim
-- (or keep a `.venv` in the project root) so imports resolve.
return {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "standard", -- "basic" | "standard" | "strict" | "all"
        diagnosticMode = "openFilesOnly",
        autoImportCompletions = true,
      },
    },
  },
}
