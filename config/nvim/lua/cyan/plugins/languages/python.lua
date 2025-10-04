return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'python', 'ninja', 'rst' })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        ruff = {
          cmd_env = { RUFF_TRACE = 'messages' },
          init_options = {
            settings = {
              logLevel = 'error',
            },
          },
          on_attach = function(client, buffer)
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false

            -- Add organize imports keymap
            vim.keymap.set('n', '<leader>co', function()
              vim.lsp.buf.code_action {
                apply = true,
                context = { only = { 'source.organizeImports' } },
              }
            end, { desc = 'Ruff: Organize Imports', buffer = buffer })
          end,
        },
        basedpyright = {},
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        python = { 'ruff_format', 'ruff_fix' },
      },
    },
  },
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/neotest-python',
    },
    opts = {
      adapters = {
        ['neotest-python'] = {},
      },
    },
  },
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      {
        'mfussenegger/nvim-dap-python',
        keys = {
          {
            '<leader>dPt',
            function()
              require('dap-python').test_method()
            end,
            desc = 'Debug Method',
            ft = 'python',
          },
          {
            '<leader>dPc',
            function()
              require('dap-python').test_class()
            end,
            desc = 'Debug Class',
            ft = 'python',
          },
        },
        config = function()
          require('dap-python').setup 'debugpy-adapter'
        end,
      },
    },
  },
}
