-- Ruff handles linting/formatting; let basedpyright own hover docs.
return {
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
}
