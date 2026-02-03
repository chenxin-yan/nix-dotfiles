return {
  'folke/flash.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  lazy = true,
  ---@type Flash.Config
  opts = {},
  keys = {
    {
      's',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash',
    },
    {
      'S',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump {
          search = { mode = 'search', max_length = 0 },
          label = { after = { 0, 0 } },
          pattern = '^',
        }
      end,
      desc = 'Flash to a line',
    },
    {
      '<c-;>',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').treesitter {
          actions = {
            ['<c-;>'] = 'next',
            ['<c-,>'] = 'prev',
          },
        }
      end,
      desc = 'Treesitter Incremental Selection',
    },
    {
      '<c-g>',
      mode = { 'c' },
      function()
        require('flash').toggle()
      end,
      desc = 'Toggle Flash Search',
    },
    {
      'r',
      mode = 'o',
      function()
        require('flash').remote()
      end,
      desc = 'Remote Flash',
    },
    {
      'R',
      mode = { 'o', 'x' },
      function()
        require('flash').treesitter_search()
      end,
      desc = 'Treesitter Search',
    },
    {
      '<leader>*',
      mode = { 'n', 'x' },
      function()
        require('flash').jump {
          pattern = vim.fn.expand '<cword>',
        }
      end,
      desc = 'Flash with word under cursor',
    },
    {
      '<leader>X',
      function()
        require('flash').jump {
          matcher = function(win)
            ---@param diag Diagnostic
            return vim.tbl_map(function(diag)
              return {
                pos = { diag.lnum + 1, diag.col },
                end_pos = { diag.end_lnum + 1, diag.end_col - 1 },
              }
            end, vim.diagnostic.get(vim.api.nvim_win_get_buf(win)))
          end,
          action = function(match, state)
            vim.api.nvim_win_call(match.win, function()
              vim.api.nvim_win_set_cursor(match.win, match.pos)
              vim.diagnostic.open_float()
            end)
            state:restore()
          end,
        }
      end,
      desc = 'Flash Diagnostics',
    },
  },
}
