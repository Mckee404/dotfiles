vim.diagnostic.config({
  virtual_text = true
})

-- augroup for this config file
local augroup = vim.api.nvim_create_augroup('lsp/init.lua', {})
local biome_root_markers = { 'biome.json', 'biome.jsonc' }

local function has_biome_config(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then
    return false
  end

  return vim.fs.root(path, biome_root_markers) ~= nil
end

local function format_filter(bufnr)
  local use_biome = has_biome_config(bufnr)

  return function(client)
    if use_biome then
      return client.name == 'biome'
    end

    return client.name ~= 'biome'
  end
end

local function apply_source_action(client, bufnr, kind)
  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
  params.context = { only = { kind }, diagnostics = {} }

  local function request(method, request_params)
    local response, err = client:request_sync(method, request_params, 5000, bufnr)
    if not response or response.err then
      error(vim.inspect(err or response.err))
    end
    return response.result
  end

  local actions = request('textDocument/codeAction', params) or {}
  for _, action in ipairs(actions) do
    if not action.disabled then
      if not action.edit and action.data and client:supports_method('codeAction/resolve') then
        action = request('codeAction/resolve', action) or action
      end
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
      end
      local command = type(action.command) == 'string' and action or action.command
      if command then
        request('workspace/executeCommand', {
          command = command.command,
          arguments = command.arguments,
        })
      end
      return
    end
  end
end

local function organize_imports(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = 'vtsls' })) do
    apply_source_action(client, bufnr, 'source.addMissingImports.ts')
  end

  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'biome' })
  if #clients == 0 then
    clients = vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/codeAction' })
  end
  for _, client in ipairs(clients) do
    apply_source_action(client, bufnr, 'source.organizeImports')
  end
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    if client:supports_method("textDocument/definition") then
      vim.keymap.set('n', 'grd', function()
        vim.lsp.buf.definition()
      end, { buffer = args.buf, desc = 'vim.lsp.buf.definition()' })
    end

    if client:supports_method("textDocument/codeAction") or client:supports_method("textDocument/formatting") then
      vim.keymap.set('n', '<space>i', function()
        organize_imports(args.buf)

        vim.lsp.buf.format({
          bufnr = args.buf,
          filter = format_filter(args.buf),
        })
      end, { buffer = args.buf, desc = 'Add missing imports, organize imports and format buffer' })
    end
  end,
})

vim.lsp.config('*', {
  root_markers = { '.git' },
  capabilities = require("mini.completion").get_lsp_capabilities(),
})

vim.api.nvim_create_user_command(
  'LspHealth',
  'checkhealth vim.lsp',
  { desc = 'LSP health check' }
)

vim.lsp.enable('lua_ls')

-- python
vim.lsp.enable('pyright')
vim.lsp.enable('ruff')

-- typescript
vim.lsp.enable('vtsls')
vim.lsp.enable('biome')
