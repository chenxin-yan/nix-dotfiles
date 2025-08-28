return {
    'gregorias/coerce.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    tag = 'v3.0.0',
    opts = {
      default_mode_keymap_prefixes = {
        normal_mode = 'gcr',
        visual_mode = 'gr',
      },
      default_mode_mask = {
        motion_mode = false,
      },
    },
}

