return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'xml', 'html', 'css', 'json5', 'yaml', 'toml' } },
  },

  { -- emmet integration
    'olrtg/nvim-emmet',
    lazy = true,
    keys = { { '<leader>ce', "<cmd>lua require('nvim-emmet').wrap_with_abbreviation()<cr>", desc = 'Emmet: Wrap with abbreviation()', mode = { 'n', 'v' } } },
  },

  { 'b0o/schemastore.nvim', lazy = true, version = false },

  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        html = {}, -- HTML lsp
        cssls = {}, -- CSS lsp
        taplo = {}, -- toml lsp
        emmet_language_server = {}, -- emmet support
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
        yamlls = {
          -- Have to add this for yamlls to understand that we support line folding
          capabilities = {
            textDocument = {
              foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
              },
            },
          },
          -- lazy-load schemastore when needed
          on_new_config = function(new_config)
            new_config.settings.yaml.schemas = vim.tbl_deep_extend('force', new_config.settings.yaml.schemas or {}, require('schemastore').yaml.schemas())
          end,
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              keyOrdering = false,
              format = {
                enable = true,
              },
              validate = true,
              schemaStore = {
                -- Must disable built-in schemaStore support to use
                -- schemas from SchemaStore.nvim plugin
                enable = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = '',
              },
            },
          },
        }, -- YAML lsp
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
        tailwindcss = {},
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
