return {
  {
    'mfussenegger/nvim-jdtls',
    lazy = true,
    ft = 'java',
    opts = {
      settings = {
        java = {
          inlayHints = {
            parameterNames = {
              enabled = 'all',
            },
          },
        },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        jdtls = {
          handlers = {
            ['$/progress'] = function(_, result, ctx) end,
          },
          on_attach = function(client, buffer)
            local jdtls = require 'jdtls'
            vim.keymap.set('n', '<leader>co', function()
              jdtls.organize_imports()
            end, { desc = 'vtsls: [O]rganize imports', buffer = buffer })
          end,
        },
      },
    },
  },
}
