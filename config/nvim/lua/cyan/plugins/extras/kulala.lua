return {
  {
    "romus204/tree-sitter-manager.nvim",
    opts = {
      ensure_installed = { "http", "graphql" },
    },
  },
  {
    'mistweaverco/kulala.nvim',
    ft = 'http',
    init = function()
      vim.filetype.add {
        extension = {
          ['http'] = 'http',
        },
      }
    end,
    opts = {},
  }
}
