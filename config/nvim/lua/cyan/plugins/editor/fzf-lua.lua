return {
  'ibhagwan/fzf-lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  cmd = { 'FzfLua', 'TodoFzflua' },
  opts = function()
    local fzf = require 'fzf-lua'
    local config = fzf.config
    local actions = fzf.actions

    config.defaults.keymap.fzf['ctrl-q'] = 'select-all+accept'
    config.defaults.keymap.fzf['ctrl-u'] = 'half-page-up'
    config.defaults.keymap.fzf['ctrl-d'] = 'half-page-down'
    config.defaults.keymap.fzf['ctrl-x'] = 'jump'
    config.defaults.keymap.fzf['ctrl-f'] = 'preview-page-down'
    config.defaults.keymap.fzf['ctrl-b'] = 'preview-page-up'
    config.defaults.keymap.builtin['<c-f>'] = 'preview-page-down'
    config.defaults.keymap.builtin['<c-b>'] = 'preview-page-up'

    config.defaults.actions.files['ctrl-t'] = require('trouble.sources.fzf').actions.open

    return {
      { 'ivy' },
      fzf_colors = true,
      fzf_opts = {
        ['--no-scrollbar'] = true,
      },
      defaults = {
        formatter = 'path.dirname_first',
      },
      winopts = {
        backdrop = 0,
        preview = {
          scrollchars = { '┃', '' },
        },
      },
      files = {
        cwd_prompt = false,
        hidden = false,
        actions = {
          ['ctrl-i'] = { actions.toggle_ignore },
          ['ctrl-u'] = { actions.toggle_hidden },
        },
      },
      grep = {
        actions = {
          ['ctrl-i'] = { actions.toggle_ignore },
          ['ctrl-u'] = { actions.toggle_hidden },
        },
      },
    }
  end,
  keys = {
    -- files
    {
      '<leader>sf',
      '<cmd>FzfLua files<cr>',
      desc = 'Files',
    },
    {
      '<leader><leader>',
      '<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>',
      desc = 'Open Buffers',
    },
    {
      '<leader>.',
      '<cmd>FzfLua oldfiles<cr>',
      desc = 'Recent Files',
    },

    -- diagnostics
    { '<leader>sd', '<cmd>FzfLua diagnostics_document<cr>', desc = 'Document Diagnostics' },
    { '<leader>sD', '<cmd>FzfLua diagnostics_workspace<cr>', desc = 'Workspace Diagnostics' },

    -- grep
    {
      '<leader>sg',
      '<cmd>FzfLua live_grep<cr>',
      desc = 'Grep project',
    },
    {
      '<leader>s*',
      '<cmd>FzfLua grep_cword<cr>',
      desc = 'Current Word',
    },
    {
      '<leader>s*',
      '<cmd>FzfLua grep_visual<cr>',
      mode = 'v',
      desc = 'Current Word',
    },

    -- git
    { '<leader>gl', '<cmd>FzfLua git_commits<CR>', desc = 'Commits' },
    { '<leader>gs', '<cmd>FzfLua git_status<CR>', desc = 'Status' },
    { '<leader>gb', '<cmd>FzfLua git_branches<CR>', desc = 'Branches' },
    { '<leader>gf', '<cmd>FzfLua git_bcommits<CR>', desc = 'File' },

    -- misc
    { '<leader>sh', '<cmd>FzfLua help_tags<cr>', desc = 'Help Pages' },
    { '<leader>sk', '<cmd>FzfLua keymaps<cr>', desc = 'Key Maps' },
    { '<leader>sn', '<cmd>FzfLua files cwd=' .. vim.fn.stdpath 'config' .. '<cr>', desc = 'Neovim Config' },
  },
}
