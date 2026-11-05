return {
  -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
  -- used for completion, annotations and signatures of Neovim apis
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    cmd = 'LazyDev',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'romus204/tree-sitter-manager.nvim',
    opts = { ensure_installed = { 'lua', 'luadoc', 'luap' } },
  },
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        lua_ls = { -- Lua lsp
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = 'Replace',
              },
              doc = {
                privateName = { '^_' },
              },
              diagnostics = { disable = { 'missing-fields' } },
              hint = {
                paramName = 'Disable',
                arrayIndex = 'Disable',
              },
            },
          },
        },
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
      },
    },
  },
}
