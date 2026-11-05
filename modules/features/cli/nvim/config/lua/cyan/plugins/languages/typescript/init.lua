local toolchain = require 'cyan.plugins.languages.typescript.toolchain'
local js_filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }
local js_ts_settings = {
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
}

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
                    -- Linked by the typescript feature from astro-language-server.
                    name = '@astrojs/ts-plugin',
                    location = vim.fn.stdpath 'data' .. '/astro-ts-plugin',
                    enableForWorkspaceTypeScriptVersions = true,
                  },
                },
              },
            },
            typescript = vim.tbl_extend('force', js_ts_settings, {
              tsserver = {
                maxTsServerMemory = 8192,
              },
            }),
            javascript = js_ts_settings,
          },
          on_attach = function(_, buffer)
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
