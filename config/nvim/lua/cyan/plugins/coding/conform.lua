return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>bf',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = 'n',
      desc = '[F]ormat buffer',
    },
    {
      '<leader>uf',
      function()
        if vim.g.disable_autoformat then
          vim.g.disable_autoformat = false
        else
          vim.g.disable_autoformat = true
        end
      end,
      desc = 'Toggle [F]ormat',
    },
  },
  opts = {
    formatters = {},
    notify_on_error = true,
    format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat then
        return
      end

      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = {}
      local lsp_format_opt
      if disable_filetypes[vim.bo[bufnr].filetype] then
        lsp_format_opt = 'never'
      else
        lsp_format_opt = 'fallback'
      end
      return {
        timeout_ms = 500,
        lsp_format = lsp_format_opt,
      }
    end,
    formatters_by_ft = {},
  },
  config = function(_, opts)
    require('conform').setup(opts)
  end,
}
