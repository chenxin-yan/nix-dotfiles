-- astro is intentionally absent: oxfmt does not yet support .astro
-- (https://github.com/oxc-project/oxc/issues/15665). svelte needs svelte/compiler
-- installed in the project for oxfmt to work on .svelte files.
local oxfmt_supported = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
  json = true,
  jsonc = true,
  vue = true,
  svelte = true,
  css = true,
  scss = true,
  less = true,
  graphql = true,
}

local biome_supported = {
  css = true,
  javascript = true,
  javascriptreact = true,
  json = true,
  jsonc = true,
  typescript = true,
  typescriptreact = true,
  vue = true,
}

-- treat the project as opted into oxc when any of these exist anywhere up the tree
local oxc_root_markers = {
  '.oxlintrc.json',
  '.oxlintrc.jsonc',
  'oxlint.config.ts',
  '.oxfmtrc.json',
  '.oxfmtrc.jsonc',
  'oxfmt.config.ts',
}

local function has_oxc_config(bufnr)
  return vim.fs.root(bufnr, oxc_root_markers) ~= nil
end

-- union of filetypes any of our formatters can handle
local formatted_fts = { 'css', 'scss', 'less', 'graphql', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'json', 'jsonc', 'vue', 'svelte', 'astro' }

return {
  {
    'romus204/tree-sitter-manager.nvim',
    opts = { ensure_installed = { 'xml', 'html', 'css', 'json', 'json5', 'yaml', 'toml' } },
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
        ---@type lspconfig.settings.oxlint
        oxlint = {
          root_dir = function(bufnr, on_dir)
            -- prefer the top-level oxlint config if it exists (monorepo support)
            local git = vim.fs.root(bufnr, '.git')
            local markers = { '.oxlintrc.json', '.oxlintrc.jsonc', 'oxlint.config.ts' }
            local root = git and vim.fs.root(git, markers) or vim.fs.root(bufnr, markers)
            if root then
              on_dir(root)
            end
          end,
          settings = {
            fixKind = 'all',
          },
        },
        --- disable the oxfmt lsp server since we use conform for formatting
        oxfmt = { enabled = false },
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters = vim.tbl_extend('force', opts.formatters or {}, {
        biome = {
          require_cwd = true,
          -- Use 'biome check' instead of 'biome format' to include organize imports
          args = {
            'check',
            '--write',
            '--stdin-file-path',
            '$FILENAME',
          },
          stdin = true,
        },
      })

      opts.formatters_by_ft = opts.formatters_by_ft or {}
      -- Per-buffer priority: oxfmt (when project opts into oxc) > biome > prettierd
      for _, ft in ipairs(formatted_fts) do
        opts.formatters_by_ft[ft] = function(bufnr)
          if oxfmt_supported[ft] and has_oxc_config(bufnr) then
            return { 'oxfmt' }
          end
          if biome_supported[ft] and require('conform').get_formatter_info('biome', bufnr).available then
            return { 'biome' }
          end
          return { 'prettierd' }
        end
      end

      return opts
    end,
  },
}
