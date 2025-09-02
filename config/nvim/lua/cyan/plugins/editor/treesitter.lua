return {
  {
    'windwp/nvim-ts-autotag',
    event = { 'VeryLazy' },
    opts = {},
  },
  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPre', 'BufNewFile' },
    build = ':TSUpdate',
    dependencies = { 'nvim-treesitter/nvim-treesitter-context', 'nvim-treesitter/nvim-treesitter-textobjects' },
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    opts = {
      ensure_installed = {
        'bash',
        'diff',
        'lua',
        'luadoc',
        'luap',
        'printf',
        'query',
        'regex',
        'vim',
        'vimdoc',
        'xml',
        'git_config',
        'gitcommit',
        'git_rebase',
        'gitignore',
        'gitattributes',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-;>',
          node_incremental = '<c-;>',
          scope_incremental = false,
          node_decremental = '<c-,>',
        },
      },
      textobjects = {
        swap = {
          enable = true,
          swap_next = {
            ['<leader>c]'] = { query = '@parameter.inner', desc = 'Swap [N]ext argument' },
            ['<leader>c}'] = { query = '@function.outer', desc = 'Swap [N]ext function' },
          },
          swap_previous = {
            ['<leader>c['] = { query = '@parameter.inner', desc = 'Swap [P]revious argument' },
            ['<leader>c{'] = { query = '@function.outer', desc = 'Swap [N]ext funtion' },
          },
        },
        move = {
          enable = true,
          disable = { 'markdown' },
          goto_next_start = {
            [']f'] = { query = '@function.outer', desc = 'Next function/method start' },
            [']a'] = { query = '@parameter.outer', desc = 'Next argument' },
          },
          goto_next_end = {},
          goto_previous_start = {
            ['[f'] = { query = '@function.outer', desc = 'Previous function/method start' },
            ['[a'] = { query = '@parameter.outer', desc = 'Previous argument' },
          },
          goto_previous_end = {
            ['[F'] = { query = '@function.outer', desc = 'Previous function/method end' },
          },
          goto_next = {
            [']o'] = { query = { '@block.outer', '@conditional.outer', '@loop.outer' }, desc = 'Next code block' },
          },
          goto_previous = {
            ['[o'] = { query = { '@block.outer', '@conditional.outer', '@loop.outer' }, desc = 'Previous code block' },
          },
        },
        lsp_interop = {
          enable = true,
          floating_preview_opts = {
            border = 'rounded',
          },
          peek_definition_code = {
            ['<leader>cp'] = '@function.outer',
            ['<leader>cP'] = '@class.outer',
          },
        },
      },
      additional_vim_regex_highlighting = false,
    },
    config = function(_, opts)
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)

      -- show context of current cursor using parser
      local tsc = require 'treesitter-context'
      tsc.setup {
        mode = 'cursor',
        multiline_threshold = 1,
        max_lines = 3,
      }
      vim.keymap.set('n', '<leader>uc', function()
        tsc.toggle()
      end, { desc = 'Toggle tressiter Context' })
    end,
  },
}
