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
    'luckasRanarison/tailwind-tools.nvim',
    name = 'tailwind-tools',
    build = ':UpdateRemotePlugins',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {}, -- your configuration
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'javascript',
        'typescript',
        'astro',
        'json5',
      },
    },
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
        eslint = { -- linter for javascript
          settings = {
            -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
            workingDirectories = { mode = 'auto' },
            format = true,
          },
          on_attach = function(_, buffer)
            vim.keymap.set('n', '<leader>cF', '<cmd>EslintFixAll<cr>', { desc = 'Eslint: [F]ix all', buffer = buffer })
          end,
        },
        biome = {},
        jsonls = { -- JSON lsp
          on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require('schemastore').json.schemas())
          end,
          settings = {
            json = {
              format = {
                enable = true,
              },
              validate = { enable = true },
            },
          },
        },
      },
    },
  },

  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters = vim.tbl_extend('force', opts.formatters or {}, {
        biome = {
          require_cwd = true,
        },
      })

      -- setup biome & prettier fallback
      local biome_supported = {
        'css',
        'javascript',
        'javascriptreact',
        'json',
        'jsonc',
        'typescript',
        'typescriptreact',
        'vue',
      }

      for _, ft in ipairs(biome_supported) do
        opts.formatters_by_ft[ft] = function(bufnr)
          if require('conform').get_formatter_info('biome', bufnr).available then
            return { 'biome' }
          else
            return { 'prettierd' }
          end
        end
      end

      return opts
    end,
  },
}
