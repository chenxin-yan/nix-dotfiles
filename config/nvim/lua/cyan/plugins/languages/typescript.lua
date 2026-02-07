return {
  {
    'dmmulroy/tsc.nvim',
    cmd = { 'TSC' },
    opts = {},
    keys = {
      { '<leader>ck', '<cmd>TSC<CR>', desc = 'Check TypeScript error' },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'javascript', 'typescript', 'tsx', 'astro', 'json5', 'jsdoc' } },
  },

  { 'b0o/schemastore.nvim', lazy = true, version = false },

  { 'yioneko/nvim-vtsls', lazy = true },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        vtsls = {
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
              tsserver = {
                globalPlugins = {
                  {
                    name = '@astrojs/ts-plugin',
                    location = '~/.local/share/nvim/mason/packages/astro-language-server/node_modules/@astrojs/ts-plugin',
                    enableForWorkspaceTypeScriptVersions = true,
                  },
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = 'always' },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = 'literals' },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = true },
              },
            },
            javascript = {
              updateImportsOnFileMove = { enabled = 'always' },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = 'literals' },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = true },
              },
            },
          },
          on_attach = function(client, buffer)
            -- setup vtsls keymaps for JS/TS
            local vtsls = require 'vtsls'

            vim.keymap.set('n', '<leader>co', function()
              vtsls.commands['organize_imports'](0)
            end, { desc = 'vtsls: [O]rganize imports', buffer = buffer })

            vim.keymap.set('n', '<leader>cC', function()
              vtsls.commands['goto_project_config'](0)
            end, { desc = 'vtsls: Go to Project [C]onfig', buffer = buffer })

            vim.keymap.set('n', '<leader>cf', function()
              vtsls.commands['fix_all'](0)
            end, { desc = 'vtsls: [F]ix all', buffer = buffer })

            vim.keymap.set('n', '<leader>cA', function()
              vtsls.commands['source_actions'](0)
            end, { desc = 'vtsls: Source [A]ction', buffer = buffer })

            vim.keymap.set('n', '<leader>cV', function()
              vtsls.commands['select_ts_version'](0)
            end, { desc = 'vtsls: Select TypeScript [V]ersion', buffer = buffer })

            vim.keymap.set('n', 'gR', function()
              vtsls.commands['file_references'](0)
            end, { desc = 'vtsls: [G]oto file [R]eferences', buffer = buffer })

            vim.keymap.set('n', 'gD', function()
              vtsls.commands['goto_source_definition'](0)
            end, { desc = 'vtsls: [G]oto source [D]efinition', buffer = buffer })

            vim.keymap.set('n', 'cR', function()
              vtsls.commands['restart_tsserver'](0)
            end, { desc = 'vtsls: [R]estart tsserver', buffer = buffer })

            -- setup codelens for JS/TS
            vim.lsp.commands['editor.action.showReferences'] = function(command, ctx)
              local locations = command.arguments[3]
              if locations and #locations > 0 then
                local items = vim.lsp.util.locations_to_items(locations, client.offset_encoding)
                vim.fn.setloclist(0, {}, ' ', { title = 'References', items = items, context = ctx })
                vim.api.nvim_command 'lopen'
              end
            end
          end,
        },
        astro = {}, -- astro lsp
      },
    },
  },
  {
    'nvim-neotest/neotest',
    dependencies = {
      'marilari88/neotest-vitest',
      'arthur944/neotest-bun',
    },
    keys = {
      {
        '<leader>nVW',
        "<cmd>lua require('neotest').run.run({ vim.fn.expand('%'), vitestCommand = 'npx vitest' })<cr>",
        desc = 'Vitest: Run Watch File',
      },
      {
        '<leader>nVw',
        "<cmd>lua require('neotest').run.run({ vitestCommand = 'npx vitest' })<cr>",
        desc = 'Vitest: Run Watch',
      },
    },
    opts = {
      adapters = {
        ['neotest-vitest'] = {},
        ['neotest-bun'] = {},
      },
    },
  },
  {
    'mxsdev/nvim-dap-vscode-js',
    dependencies = { 'mfussenegger/nvim-dap' },
    ft = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
    config = function()
      require('dap-vscode-js').setup {
        debugger_cmd = { 'js-debug' },
        adapters = { 'pwa-node' },
      }

      local js_filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }

      for _, language in ipairs(js_filetypes) do
        require('dap').configurations[language] = {
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch file',
            program = '${file}',
            cwd = '${workspaceFolder}',
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
          },
        }
      end
    end,
  },
}
