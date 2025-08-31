-- delete lsp keyamps and use custom keymap instead
vim.keymap.del('n', 'grr')
vim.keymap.del({ 'n', 'x' }, 'gra')
vim.keymap.del('n', 'gri')
vim.keymap.del('n', 'grn')
vim.keymap.del('n', 'grt')

-- diagnostic config
vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '●',
      [vim.diagnostic.severity.WARN] = '●',
      [vim.diagnostic.severity.HINT] = '●',
      [vim.diagnostic.severity.INFO] = '●',
    },
  },
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    current_line = true,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.

    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

    -- This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header.
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_declaration) then
      map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    end

    -- The following code creates a keymap to toggle inlay hints in your
    -- code, if the language server you are using supports them
    --
    -- This may be unwanted, since they displace some of your code
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map('<leader>uh', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf })
      end, 'Toggle Inlay [H]ints')
      vim.lsp.inlay_hint.enable(true, { buffer = event.buf })
    end

    -- lsp codelens
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens, event.buf) then
      map('<leader>cc', vim.lsp.codelens.run, 'Run [C]odelens', 'n')
      vim.lsp.codelens.refresh { bufnr = event.buf }
      vim.api.nvim_create_autocmd({ 'BufReadPre', 'InsertLeave', 'BufEnter' }, {
        buffer = event.buf,
        callback = function()
          vim.lsp.codelens.refresh { bufnr = event.buf }
        end,
      })
    end

    local navic = require 'nvim-navic'
    if client and client.server_capabilities.documentSymbolProvider then
      navic.attach(client, event.buf)
    end
  end,
})
