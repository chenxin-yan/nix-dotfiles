return {
  {
    'romus204/tree-sitter-manager.nvim',
    opts = {
      ensure_installed = { 'http', 'graphql' },
    },
  },
  {
    'mistweaverco/kulala.nvim',
    event = { 'SessionLoadPost', 'VimLeavePre' },
    ft = { 'http', 'rest' },
    init = function()
      vim.filetype.add {
        extension = {
          http = 'http',
          rest = 'http',
        },
      }
    end,
    opts = {},
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters = {
        kulala = {
          command = 'kulala-fmt',
          args = { 'format', '$FILENAME' },
          stdin = false,
        },
      },
      formatters_by_ft = {
        http = { 'kulala' },
        rest = { 'kulala' },
      },
    },
  },
}
