return {
  'gregorias/coerce.nvim',
  tag = 'v5.0.0',
  dependencies = { 'gregorias/coop.nvim' },
  event = 'VeryLazy',
  config = function()
    require('coerce').setup()
    vim.keymap.set('n', 'gcr', '<Plug>(coerce-normal)', { desc = 'Coerce word' })
    vim.keymap.set('x', 'gr', '<Plug>(coerce-visual)', { desc = 'Coerce selection' })
    local wke = require('coerce.keymaps').which_key_expand
    require('which-key').add {
      { 'gcr', group = 'Coerce word', expand = wke.normal_mode, mode = 'n' },
      { 'gr', group = 'Coerce selection', expand = wke.visual_mode, mode = 'x' },
    }
  end,
}
