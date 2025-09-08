return {
  'andrewferrier/debugprint.nvim',
  event = 'VeryLazy',
  version = '*',
  opts = {
    keymaps = {
      normal = {
        plain_below = 'gpj',
        plain_above = 'gpk',
        variable_below = 'gpv',
        variable_above = 'gpV',
        surround_plain = 'gpsp',
        surround_variable = 'gpsv',
        textobj_below = 'gpo',
        textobj_above = 'gpO',
        textobj_surround = 'gpso',
      },
      visual = {
        variable_below = 'gpv',
        variable_above = 'gpV',
      },
    },
  },
  keys = {
    {
      '<leader>sp',
      '<cmd>Debugprint search<cr>',
      desc = 'Debug Prints',
    },
  },
  config = function(_, opts)
    require('debugprint').setup(opts)
    require('which-key').add { 'gp', group = 'Debug Print', icon = '󱂅 ' }
  end,
}
