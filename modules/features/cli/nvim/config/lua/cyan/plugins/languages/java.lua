return {
  {
    'mfussenegger/nvim-jdtls',
    lazy = true,
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        jdtls = {
          settings = {
            java = {
              inlayHints = {
                parameterNames = {
                  enabled = 'all',
                },
              },
            },
          },
          handlers = {
            ['$/progress'] = function(_, result, ctx) end,
          },
          on_attach = function(client, buffer)
            local jdtls = require 'jdtls'
            vim.keymap.set('n', '<leader>co', function()
              jdtls.organize_imports()
            end, { desc = 'jdtls: [O]rganize imports', buffer = buffer })
          end,
        },
      },
    },
  },
}
