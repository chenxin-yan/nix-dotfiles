return {
  {
    'windwp/nvim-ts-autotag',
    event = { 'VeryLazy' },
    opts = {},
  },

  {
    'romus204/tree-sitter-manager.nvim',
    event = { 'VeryLazy' },
    cmd = { 'TSManager' },
    opts_extend = { 'ensure_installed' },
    opts = {
      ensure_installed = {
        'bash',
        'diff',
        'printf',
        'regex',
        'xml',
        'git_config',
        'gitcommit',
        'git_rebase',
        'gitignore',
        'gitattributes',
      },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      mode = 'cursor',
      multiline_threshold = 1,
      max_lines = 3,
    },
    keys = {
      {
        '<leader>uc',
        function()
          require('treesitter-context').toggle()
        end,
        desc = 'Toggle treesitter Context',
      },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = { 'VeryLazy' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        move = { enable = true, set_jumps = true },
        swap = { enable = true },
      }

      local move = require 'nvim-treesitter-textobjects.move'
      local swap = require 'nvim-treesitter-textobjects.swap'

      -- Swap keymaps
      vim.keymap.set('n', '<leader>c]', function()
        swap.swap_next '@parameter.inner'
      end, { desc = 'Swap Next argument' })
      vim.keymap.set('n', '<leader>c}', function()
        swap.swap_next '@function.outer'
      end, { desc = 'Swap Next function' })
      vim.keymap.set('n', '<leader>c[', function()
        swap.swap_previous '@parameter.inner'
      end, { desc = 'Swap Previous argument' })
      vim.keymap.set('n', '<leader>c{', function()
        swap.swap_previous '@function.outer'
      end, { desc = 'Swap Previous function' })

      -- Move keymaps
      vim.keymap.set({ 'n', 'x', 'o' }, ']f', function()
        move.goto_next_start('@function.outer', 'textobjects')
      end, { desc = 'Next function/method start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']a', function()
        move.goto_next_start('@parameter.outer', 'textobjects')
      end, { desc = 'Next argument' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[f', function()
        move.goto_previous_start('@function.outer', 'textobjects')
      end, { desc = 'Previous function/method start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[a', function()
        move.goto_previous_start('@parameter.outer', 'textobjects')
      end, { desc = 'Previous argument' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']F', function()
        move.goto_next_end('@function.outer', 'textobjects')
      end, { desc = 'Next function/method end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[F', function()
        move.goto_previous_end('@function.outer', 'textobjects')
      end, { desc = 'Previous function/method end' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']o', function()
        move.goto_next_start({ '@block.outer', '@conditional.outer', '@loop.outer' }, 'textobjects')
      end, { desc = 'Next code block' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[o', function()
        move.goto_previous_start({ '@block.outer', '@conditional.outer', '@loop.outer' }, 'textobjects')
      end, { desc = 'Previous code block' })
    end,
  },
}
