return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000, -- Make sure to load this before all the other start plugins.
  init = function()
    vim.cmd.colorscheme 'catppuccin-mocha'
  end,
  opts = {
    transparent_background = true,
    float = {
      transparent = true,
    },
  },
}
