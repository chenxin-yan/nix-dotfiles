return {
  'vyfor/cord.nvim',
  event = 'VeryLazy',
  build = ':Cord update',
  opts = function()
    return {
      display = {
        theme = 'catppuccin',
      },
      idle = {
        details = function(opts)
          return string.format('Taking a break from %s', opts.workspace)
        end,
      },
      text = {
        editing = function(opts)
          local text = 'Editing ' .. opts.filename
          if vim.bo.modified then
            text = text .. ' [+]'
          end
          return text
        end,
        workspace = function(opts)
          local hour = tonumber(os.date '%H')
          local status = hour >= 22 and '🌙 Late night coding'
            or hour >= 18 and '🌆 Evening session'
            or hour >= 12 and '☀️ Afternoon coding'
            or hour >= 5 and '🌅 Morning productivity'
            or '🌙 Midnight hacking'

          return string.format('%s: %s', status, opts.workspace)
        end,
      },
      buttons = {
        {
          label = function(opts)
            return opts.repo_url and 'View Repository' or 'GitHub'
          end,
          url = function(opts)
            return opts.repo_url or 'https://github.com/chenxin-yan'
          end,
        },
      },
    }
  end,
}

