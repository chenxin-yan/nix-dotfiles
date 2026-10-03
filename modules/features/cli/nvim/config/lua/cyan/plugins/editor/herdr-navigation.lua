return {
  'paulbkim-dev/vim-herdr-navigation',
  cond = vim.env.TUIOS_PANE_ID == nil,
  lazy = false,
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  config = function(plugin)
    dofile(plugin.dir .. '/editor/nvim.lua')
  end,
}
