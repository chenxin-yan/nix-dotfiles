return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    preset = 'helix',
    spec = {
      { ']', group = 'Next' },
      { '[', group = 'Previous' },
      { 'gs', group = 'Surround', mode = { 'n', 'x' } },
      { '<leader>c', group = 'Code', mode = { 'n', 'x' } },
      { '<leader>x', group = 'Diagnostic/QuickFix' },
      { '<leader>t', group = 'Testing' },
      { '<leader>dp', group = '+Debug Print' },
      { '<leader>d', group = 'Debug' },
      { '<leader>s', group = 'Search' },
      { '<leader>r', group = 'Refactor', mode = { 'n', 'x' } },
      { '<leader>u', group = 'Toggle' },
      { '<leader>g', group = 'Git' },
      { '<leader>h', group = 'Hunk', mode = { 'n', 'x' }, icon = ' ' },
      { '<leader>b', group = 'Buffer' },
      { '<leader>S', icon = ' ', group = 'Snippet' },
      { '<leader>a', group = 'AI' },
    },
    plugins = {
      spelling = {
        enabled = false,
      },
      presets = {
        windows = false,
        nav = false,
      },
    },
  },
  config = function(_, opts)
    local wk = require 'which-key'
    wk.setup(opts)

    vim.keymap.set({ 'n', 'x' }, '<leader>?', function()
      require('which-key').show { global = false }
    end, { desc = 'Buffer Local Keymaps (which-key)' })
  end,
}
