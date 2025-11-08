local vault_path = vim.env.OBSIDIAN_VAULT_PATH or ''
return {
  {
    'epwalsh/obsidian.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    event = {
      'BufReadPre ' .. vault_path .. '**.md',
      'BufNewFile ' .. vault_path .. '**.md',
    },
    keys = {
      {
        '<leader>so',
        '<cmd>ObsidianQuickSwitch<cr>',
        desc = 'Obsidian Vault',
      },
      {
        '<leader>sO',
        '<cmd>ObsidianSearch<cr>',
        desc = 'Grep [O]bsidian Vault',
      },
      {
        '<leader>on',
        ':ObsidianNew ',
        desc = 'Obsidian New note',
      },
    },
    config = function()
      -- obsidian plugin setup
      require('obsidian').setup {
        ui = { enable = false },
        workspaces = {
          {
            name = 'Ideaverse',
            path = vault_path,
          },
        },
        completion = {
          nvim_cmp = false,
        },
        mappings = {
          -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
          ['gf'] = {
            action = function()
              return require('obsidian').util.gf_passthrough()
            end,
            opts = { noremap = false, expr = true, buffer = true },
          },
          -- Smart action depending on context, either follow link or toggle checkbox.
          -- ['<cr>'] = {
          --   action = function()
          --     return require('obsidian').util.smart_action()
          --   end,
          --   opts = { buffer = true, expr = true },
          -- },
        },

        templates = {
          folder = 'Miscs/Templates',
          date_format = '%Y-%m-%d',
          time_format = '%H:%M',
        },

        notes_subdir = '+ Inbox',
        new_notes_location = 'notes_subdir',

        note_path_func = function(spec)
          local path = spec.dir / spec.title
          return path:with_suffix '.md'
        end,
        disable_frontmatter = true,
        wiki_link_func = 'use_alias_only',
        open_app_foreground = true,
      }

      -- nvim keymaps
      local function obMap(key, cmd, desc)
        vim.keymap.set({ 'n', 'v' }, '<leader>o' .. key, cmd, { desc = desc })
      end

      obMap('t', '<cmd>ObsidianTemplate<cr>', 'Insert Template')
      obMap('b', '<cmd>ObsidianBacklinks<cr>', 'Search Backlinks')
      obMap('l', '<cmd>ObsidianLinks<cr>', 'Search Links in current note')
      obMap('L', '<cmd>ObsidianLinkNew<cr>', 'Create new note with a Link')
      obMap('f', '<cmd>ObsidianFollowLink vsplit<cr>', 'Follow note to a new window')
      obMap('o', '<cmd>ObsidianOpen<cr>', 'Open in Obsidian')
      obMap('e', ':ObsidianExtractNote ', 'Extract to a new note')
    end,
  },
  {
    'folke/which-key.nvim',
    opts = {
      spec = {
        { '<leader>o', group = 'Obsidian', icon = ' ' },
      },
    },
  },
}
