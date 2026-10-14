return {
  'paulbkim-dev/vim-herdr-navigation',
  lazy = false,
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  config = function(plugin)
    dofile(plugin.dir .. '/editor/nvim.lua')
  end,
}
