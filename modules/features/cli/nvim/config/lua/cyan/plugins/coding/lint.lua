return { -- Linting
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  keys = {
    {
      '<leader>bl',
      function()
        require('lint').try_lint()
      end,
      desc = '[L]int buffer',
    },
  },
  opts = {
    linters = {},
    linters_by_ft = {},
  },
  config = function(_, opts)
    local lint = require 'lint'
    -- Clear all default linters and only use explicitly configured ones
    lint.linters_by_ft = opts.linters_by_ft or {}

    -- Extend existing linters with custom configurations
    for name, config in pairs(opts.linters) do
      lint.linters[name] = vim.tbl_deep_extend('force', lint.linters[name] or {}, config)
    end

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        if vim.bo.modifiable then
          lint.try_lint()
        end
      end,
    })
  end,
}
