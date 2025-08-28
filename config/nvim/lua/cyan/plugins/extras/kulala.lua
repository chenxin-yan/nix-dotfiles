return {
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

