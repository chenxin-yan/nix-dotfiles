return {
  {
    "nvim-treesitter/nvim-treesitter",
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
