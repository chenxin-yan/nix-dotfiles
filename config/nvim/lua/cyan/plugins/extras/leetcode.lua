return {
  {
    'romus204/tree-sitter-manager.nvim',
    opts = { ensure_installed = { 'html' } },
  },
  {
    'kawre/leetcode.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'romus204/tree-sitter-manager.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    lazy = 'leet' ~= vim.fn.argv()[1],
    opts = { arg = 'leet', lang = 'python3' },
  },
}
