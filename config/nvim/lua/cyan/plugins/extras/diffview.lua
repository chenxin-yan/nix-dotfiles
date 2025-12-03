return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  keys = {
    {
      '<leader>gd',
      desc = '+Diffview',
    },
    { '<leader>gdb', '<cmd>DiffviewOpen origin/main...HEAD --imply-local<cr>', desc = 'Git [D]iff [B]ranch' },
    { '<leader>gdB', '<cmd>DiffviewFileHistory --range=origin/main...HEAD --right-only --no-merges<cr>', desc = 'Git [D]iff [B]ranch files' },
    { '<leader>gdo', '<cmd>DiffviewOpen<cr>', desc = 'Git [D]iffview [O]pen' },
    { '<leader>gdO', '<cmd>DiffviewFileHistory<cr>', desc = 'Git [D]iffview File [O]pen' },
  },
}

