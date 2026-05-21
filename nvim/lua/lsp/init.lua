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

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    if client:supports_method("textDocument/definition") then
      vim.keymap.set('n', 'grd', function()
        vim.lsp.buf.definition()
      end, { buffer = args.buf, desc = 'vim.lsp.buf.definition()' })
    end

    if client:supports_method("textDocument/formatting") then
      vim.keymap.set('n', '<space>i', function()
        vim.lsp.buf.format({
          bufnr = args.buf,
          filter = format_filter(args.buf),
        })
      end, { buffer = args.buf, desc = 'Format buffer' })
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
vim.lsp.enable('vtsls')
vim.lsp.enable('biome')
