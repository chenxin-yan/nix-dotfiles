return {
  'mikavilpas/yazi.nvim',
  init = function()
    -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
    -- vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  keys = {
    {
      '-',
      '<cmd>Yazi<cr>',
      desc = 'Open yazi at the current file',
    },
    {
      -- Open in the current working directory
      '<c-e>',
      '<cmd>Yazi cwd<cr>',
      desc = "Open the file manager in nvim's working directory",
    },
  },
  opts = {
    yazi_floating_window_border = 'none',
    keymaps = {
      replace_in_directory = '<c-r>',
      grep_in_directory = '<c-g>',
      change_working_directory = '`',
      open_and_pick_window = '<c-p>',
    },
    integrations = {
      grep_in_directory = 'fzf-lua',
      grep_in_selected_files = 'fzf-lua',
    },
  },
}
