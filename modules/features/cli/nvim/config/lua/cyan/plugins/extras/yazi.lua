return {
  'mikavilpas/yazi.nvim',
  -- Load at startup so open_for_directories can take over `nvim <dir>`.
  event = 'VeryLazy',
  init = function()
    -- yazi.nvim recommends this with open_for_directories:
    -- https://github.com/mikavilpas/yazi.nvim/issues/802
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
    open_for_directories = true,
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
