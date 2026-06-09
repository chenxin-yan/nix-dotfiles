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
      local existing = lint.linters[name]
      if type(existing) == 'function' then
        -- Function-style linters resolve their config lazily at lint time, so
        -- merge the override onto the table the original returns.
        lint.linters[name] = function()
          return vim.tbl_deep_extend('force', existing(), config)
        end
      elseif existing then
        lint.linters[name] = vim.tbl_deep_extend('force', existing, config)
      else
        lint.linters[name] = config
      end
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
