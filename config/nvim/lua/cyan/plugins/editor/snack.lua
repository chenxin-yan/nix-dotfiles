return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      input = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      indent = {
        enabled = true,
        scope = { enabled = true },
      },
      scope = { enabled = true },
      terminal = {
        win = {
          style = 'minimal',
        },
      },
      gitbrowse = {
        what = 'branch',
      },
      styles = {
        notification = {
          wo = {
            winblend = 0,
            wrap = true,
          },
        },
      },
      image = {
        doc = {
          inline = false,
          float = true,
        },
      },
      explorer = {
        enabled = true,
        layout = {
          cycle = false,
        },
        Config = {
          replace_netrw = true,
        },
      },
      picker = {
        ui_select = true,
      },
      dashboard = {
        enabled = true,
        width = 50,
        preset = {
          keys = {
            { icon = ' ', key = 'e', desc = 'New File', action = ':ene | startinsert' },
            { icon = ' ', key = 'f', desc = 'Find File', action = '<cmd>FzfLua files<cr>' },
            { icon = ' ', key = 'g', desc = 'Find Text', action = '<cmd>FzfLua live_grep<cr>' },
            { icon = ' ', key = 'r', desc = 'Recent Files', action = '<cmd>FzfLua oldfiles<cr>' },
            { icon = ' ', key = 'b', desc = 'Browse Github Repo', action = '<cmd>lua Snacks.gitbrowse()<cr>' },
            { icon = '󰒲 ', key = 'u', desc = 'Update plugins', action = '<cmd>Lazy update<cr>' },
            { icon = ' ', key = 'q', desc = 'Quit NVIM', action = '<cmd>qa<cr>' },
          },
        },
        sections = {
          { section = 'header', padding = 2 },
          { section = 'keys', gap = 1, padding = 2 },
          { section = 'startup', padding = 2 },
        },
      },
    },
    keys = function()
      local Snacks = require 'snacks'
      Snacks.input.enable()
      return {
        {
          '<leader>gB',
          function()
            Snacks.gitbrowse()
          end,
          desc = 'Git Browse',
        },
        {
          '<c-g>',
          function()
            Snacks.lazygit { cwd = Snacks.git.get_root() }
          end,
          desc = 'Lazygit',
        },
        {
          '<leader>gF',
          function()
            Snacks.lazygit.log_file { cwd = Snacks.git.get_root() }
          end,
          desc = 'Lazygit Current File History',
        },
        {
          '<leader>gL',
          function()
            Snacks.lazygit.log { cwd = Snacks.git.get_root() }
          end,
          desc = 'Lazygit Log',
        },
        {
          '<leader>rN',
          function()
            Snacks.rename.rename_file()
          end,
          desc = 'Rename File',
        },
        {
          ']]',
          function()
            Snacks.words.jump(vim.v.count1)
          end,
          desc = 'Next Reference',
          mode = { 'n', 't' },
        },
        {
          '[[',
          function()
            Snacks.words.jump(-vim.v.count1)
          end,
          desc = 'Prev Reference',
          mode = { 'n', 't' },
        },
        {
          '<c-\\>',
          function()
            Snacks.terminal.toggle(nil, {
              win = {
                position = 'float',
                border = 'rounded',
                width = 0.65,
                height = 0.8,
              },
            })
          end,
          desc = 'Toggle Terminal',
          mode = { 'n', 't' },
        },
        {
          '<leader>bd',
          function()
            Snacks.bufdelete.delete()
          end,
          desc = 'Delete current Buffer',
          mode = { 'n' },
        },
        {
          '<leader>bD',
          function()
            Snacks.bufdelete.other()
          end,
          desc = 'Delete Other Buffers',
          mode = { 'n' },
        },
        -- pickers
        {
          '<leader>su',
          function()
            Snacks.picker.undo()
          end,
          desc = 'Undo History',
        },
        {
          '<leader>/',
          function()
            Snacks.picker.lines {}
          end,
          desc = 'Buffer Lines',
        },
        {
          '<leader>s/',
          function()
            Snacks.picker.grep_buffers { layout = { preset = 'ivy', layout = { height = 25 } } }
          end,
          desc = 'Grep Open Buffers',
        },
        {
          '<leader>ss',
          function()
            Snacks.picker.lsp_symbols { layout = { preset = 'ivy', layout = { height = 25 } } }
          end,
          desc = 'LSP Symbols',
        },
        {
          '<leader>sS',
          function()
            Snacks.picker.lsp_workspace_symbols { layout = { preset = 'ivy', layout = { height = 25 } } }
          end,
          desc = 'LSP Workspace Symbols',
        },
        {
          'Z',
          function()
            Snacks.picker.spelling { layout = { layout = { relative = 'cursor' } } }
          end,
          desc = 'Spelling',
        },
        -- others
        {
          '<leader>z',
          function()
            Snacks.zen()
          end,
          desc = 'Toggle Zen Mode',
        },
        {
          '<leader>Z',
          function()
            Snacks.zen.zoom()
          end,
          desc = 'Toggle Zoom',
        },
        -- gh
        {
          '<leader>gi',
          function()
            Snacks.picker.gh_issue()
          end,
          desc = 'GitHub Issues (open)',
        },
        {
          '<leader>gI',
          function()
            Snacks.picker.gh_issue { state = 'all' }
          end,
          desc = 'GitHub Issues (all)',
        },
        {
          '<leader>gp',
          function()
            Snacks.picker.gh_pr()
          end,
          desc = 'GitHub Pull Requests (open)',
        },
        {
          '<leader>gP',
          function()
            Snacks.picker.gh_pr { state = 'all' }
          end,
          desc = 'GitHub Pull Requests (all)',
        },
      }
    end,
  },
}
