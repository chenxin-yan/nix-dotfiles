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
        snacks = {
          enabled = true,
          indent_scope_color = "lavender", -- catppuccin color (eg. `lavender`) Default: text
        },
        noice = true,
        grug_far = true,
        lsp_trouble = true,
        which_key = true,
        mason = true,
        blink_cmp = true,
        gitgraph = true,
        octo = true,
        mini = {
          enabled = true
        }
      },
    },
}
