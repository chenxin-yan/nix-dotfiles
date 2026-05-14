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
    integrations = {
      navic = {
        enabled = true,
      },
      noice = true,
      blink_cmp = true,
      grug_far = true,
      mini = {
        enabled = true,
      },
      snacks = {
        enabled = true,
        indent_scope_color = 'lavender', -- catppuccin color (eg. `lavender`) Default: text
      },
      lsp_trouble = true,
      which_key = true,
      octo = true,
      gitgraph = true,
      dap = true,
    },
  },
}
