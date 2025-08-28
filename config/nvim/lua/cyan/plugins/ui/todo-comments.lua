return {
  'folke/todo-comments.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {},
  keys = {
    { '<leader>xt', '<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>', desc = 'Todos' },
    { '<leader>xT', '<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>', desc = 'Todo/Fix/Fixme' },
    {
      '<leader>st',
      function()
        Snacks.picker.todo_comments { layout = { preset = 'ivy', layout = { height = 25 } } }
      end,
      desc = 'Todo',
    },
    {
      '<leader>sT',
      function()
        Snacks.picker.todo_comments { keywords = { 'TODO', 'FIX', 'FIXME' }, layout = { preset = 'ivy', layout = { height = 25 } } }
      end,
      desc = 'Todo/Fix/Fixme',
    },
  },
  config = function()
    require('todo-comments').setup()
    -- jump between todo comments
    vim.keymap.set('n', ']t', function()
      require('todo-comments').jump_next()
    end, { desc = 'Next todo comment' })
    vim.keymap.set('n', '[t', function()
      require('todo-comments').jump_prev()
    end, { desc = 'Previous todo comment' })
  end,
}

