return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        'sql',
      })
    end,
  },
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        sql = { 'sqlfluff' },
        mysql = { 'sqlfluff' },
        plsql = { 'sqlfluff' },
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters = {
        sqlfluff = {
          args = { 'format', '--dialect=ansi', '-' },
        },
      },
      formatters_by_ft = {
        sql = { 'sqlfluff' },
        mysql = { 'sqlfluff' },
        plsql = { 'sqlfluff' },
      },
    },
  },
}
