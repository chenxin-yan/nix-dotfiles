return {
  'NickvanDyke/opencode.nvim',
  ---@type opencode.Opts
  opts = {
    -- Your configuration, if any — see lua/opencode/config.lua
  },
  keys = {
    -- Recommended keymaps
    {
      '<leader>ao',
      function()
        require('opencode').ask()
      end,
      desc = 'Ask opencode',
    },
    {
      '<leader>at',
      function()
        require('opencode').ask '@cursor: '
      end,
      desc = 'Ask opencode about this',
      mode = 'n',
    },
    {
      '<leader>at',
      function()
        require('opencode').ask '@selection: '
      end,
      desc = 'Ask opencode about selection',
      mode = 'v',
    },
    {
      '<leader>ab',
      function()
        require('opencode').ask '@buffers: '
      end,
      desc = 'Ask opencode about open buffers',
      mode = 'n',
    },
    {
      '<leader>aa',
      function()
        require('opencode').toggle()
      end,
      desc = 'Toggle embedded opencode',
    },
    {
      '<leader>an',
      function()
        require('opencode').command 'session_new'
      end,
      desc = 'New session',
    },
    {
      '<leader>ay',
      function()
        require('opencode').command 'messages_copy'
      end,
      desc = 'Copy last message',
    },
    {
      '<S-C-u>',
      function()
        require('opencode').command 'messages_half_page_up'
      end,
      desc = 'Scroll messages up',
    },
    {
      '<S-C-d>',
      function()
        require('opencode').command 'messages_half_page_down'
      end,
      desc = 'Scroll messages down',
    },
    {
      '<leader>ap',
      function()
        require('opencode').select_prompt()
      end,
      desc = 'Select prompt',
      mode = { 'n', 'v' },
    },

    -- Example: keymap for custom prompt
    -- { '<leader>oe', function() require('opencode').prompt("Explain @cursor and its context") end, desc = "Explain code near cursor", },
  },
}
