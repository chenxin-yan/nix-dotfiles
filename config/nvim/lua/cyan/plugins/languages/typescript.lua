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
}
