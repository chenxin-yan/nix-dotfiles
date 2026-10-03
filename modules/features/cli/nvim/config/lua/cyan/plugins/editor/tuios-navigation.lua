return {
  'Tim4c/tuios-nvim-navigator',
  -- tuios panes also export HERDR_*, so this must win over vim-herdr-navigation there.
  cond = vim.env.TUIOS_PANE_ID ~= nil,
  lazy = false,
  opts = {
    keymaps = { left = '<C-h>', down = '<C-j>', up = '<C-k>', right = '<C-l>' },
  },
}
