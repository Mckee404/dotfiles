return {
  on_attach = function(client, _bufnr)
    client.server_capabilities.hoverProvider = false
  end,
}
