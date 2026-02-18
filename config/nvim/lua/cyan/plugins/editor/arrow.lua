return {
  'otavioschwanck/arrow.nvim',
  event = 'VeryLazy',
  dependencies = {
    { 'nvim-tree/nvim-web-devicons' },
  },
  opts = {
    separate_by_branch = true,
    show_icons = true,
    leader_key = "'",
    buffer_leader_key = 'm', -- Per Buffer Mappings
    mappings = {
      toggle = 's',
      open_vertical = '|',
      open_horizontal = '_',
      next_item = 'j',
      prev_item = 'k',
    },
  },
}
