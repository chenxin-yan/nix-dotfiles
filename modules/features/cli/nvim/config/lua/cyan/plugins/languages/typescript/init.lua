local toolchain = require 'cyan.plugins.languages.typescript.toolchain'
local js_filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }

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
    'romus204/tree-sitter-manager.nvim',
    opts = { ensure_installed = { 'javascript', 'typescript', 'tsx', 'astro', 'svelte', 'json5', 'jsdoc', 'prisma' } },
  },

  { 'b0o/schemastore.nvim', lazy = true, version = false },

  { 'yioneko/nvim-vtsls', lazy = true },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        vtsls = {
          root_dir = toolchain.root_dir 'vtsls',
          cmd = toolchain.legacy_cmd,
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
                maxTsServerMemory = 8192,
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
              tsserver = {
                maxTsServerMemory = 8192,
              },
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
        tsc = {
          filetypes = js_filetypes,
          root_dir = toolchain.root_dir 'tsc',
          cmd = toolchain.cmd,
          on_attach = function(_, buffer)
            -- A buffer may have used legacy before the user restarted LSP with a native override.
            for _, map in ipairs(vim.api.nvim_buf_get_keymap(buffer, 'n')) do
              if vim.startswith(map.desc or '', 'vtsls:') then
                vim.keymap.del('n', map.lhs, { buffer = buffer })
              end
            end
            -- Native uses standard LSP actions, not vtsls commands.
            vim.keymap.set('n', '<leader>co', function()
              vim.lsp.buf.code_action { context = { only = { 'source.organizeImports' }, diagnostics = {} }, apply = true }
            end, { desc = 'TypeScript: [O]rganize imports', buffer = buffer })
            vim.keymap.set('n', '<leader>cf', function()
              vim.lsp.buf.code_action { context = { only = { 'source.fixAll' }, diagnostics = {} }, apply = true }
            end, { desc = 'TypeScript: [F]ix all', buffer = buffer })
            vim.keymap.set('n', '<leader>cA', function()
              vim.lsp.buf.code_action { context = { only = { 'source' }, diagnostics = {} } }
            end, { desc = 'TypeScript: Source [A]ction', buffer = buffer })
          end,
        },
        denols = {},
        astro = {}, -- astro lsp
        svelte = {},
        prismals = {},
      },
    },
  },
}
