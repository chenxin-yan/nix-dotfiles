return {
  'swaits/zellij-nav.nvim',
  event = 'VeryLazy',
  keys = {
    { '<c-h>', '<cmd>ZellijNavigateLeftTab<cr>', { silent = true, desc = 'navigate left or tab' } },
    { '<c-j>', '<cmd>ZellijNavigateDown<cr>', { silent = true, desc = 'navigate down' } },
    { '<c-k>', '<cmd>ZellijNavigateUp<cr>', { silent = true, desc = 'navigate up' } },
    { '<c-l>', '<cmd>ZellijNavigateRightTab<cr>', { silent = true, desc = 'navigate right or tab' } },
  },
  opts = function()
    vim.api.nvim_create_autocmd('VimLeave', {
      pattern = '*',
      command = 'silent !zellij action switch-mode normal',
    })
    return {}
  end,
}
