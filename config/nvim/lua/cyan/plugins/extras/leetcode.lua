return {
  'kawre/leetcode.nvim',
  build = ':TSUpdate html',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  lazy = 'leet' ~= vim.fn.argv()[1],
  opts = { arg = 'leet', lang = 'java' },
}
