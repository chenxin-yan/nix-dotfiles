-- blink git customizations
local blink_cmp_kind_name_highlight = {
  Commit = { default = false, fg = '#a6e3a1' },
  Mention = { default = false, fg = '#a6e3a1' },
  openPR = { default = false, fg = '#a6e3a1' },
  openedPR = { default = false, fg = '#a6e3a1' },
  closedPR = { default = false, fg = '#f38ba8' },
  mergedPR = { default = false, fg = '#cba6f7' },
  draftPR = { default = false, fg = '#9399b2' },
  lockedPR = { default = false, fg = '#f5c2e7' },
  openIssue = { default = false, fg = '#a6e3a1' },
  openedIssue = { default = false, fg = '#a6e3a1' },
  reopenedIssue = { default = false, fg = '#a6e3a1' },
  completedIssue = { default = false, fg = '#cba6f7' },
  closedIssue = { default = false, fg = '#cba6f7' },
  not_plannedIssue = { default = false, fg = '#9399b2' },
  duplicateIssue = { default = false, fg = '#9399b2' },
  lockedIssue = { default = false, fg = '#f5c2e7' },
}

for kind_name, hl in pairs(blink_cmp_kind_name_highlight) do
  vim.api.nvim_set_hl(0, 'BlinkCmpGitKind' .. kind_name, hl)
  vim.api.nvim_set_hl(0, 'BlinkCmpGitKindIcon' .. kind_name, hl)
  vim.api.nvim_set_hl(0, 'BlinkCmpGitLabel' .. kind_name .. 'Id', hl)
end

local function pr_or_issue_configure_score_offset(items)
  -- Bonus to make sure items sorted as below:
  local keys = {
    -- place `kind_name` here
    { 'openIssue', 'openedIssue', 'reopenedIssue' },
    { 'openPR', 'openedPR' },
    { 'lockedIssue', 'lockedPR' },
    { 'completedIssue' },
    { 'draftPR' },
    { 'mergedPR' },
    { 'closedPR', 'closedIssue', 'not_plannedIssue', 'duplicateIssue' },
  }
  local bonus = 999999
  local bonus_score = {}
  for i = 1, #keys do
    for _, key in ipairs(keys[i]) do
      bonus_score[key] = bonus * (#keys - i)
    end
  end
  for i = 1, #items do
    local bonus_key = items[i].kind_name
    if bonus_score[bonus_key] then
      items[i].score_offset = bonus_score[bonus_key]
    end
    -- sort by number when having the same bonus score
    local number = items[i].label:match '[#!](%d+)'
    if number then
      if items[i].score_offset == nil then
        items[i].score_offset = 0
      end
      items[i].score_offset = items[i].score_offset + tonumber(number)
    end
  end
end

return {
  {
    'saghen/blink.compat',
    lazy = true,
    opts = {},
  },
  {
    'chrisgrieser/nvim-scissors',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      snippetDir = vim.fn.stdpath 'config' .. '/snippets',
      jsonFormatter = 'jq',
    },
    keys = {

      { '<leader>Se', '<cmd>lua require("scissors").editSnippet()<cr>', desc = 'Snippet: Edit' },
      { '<leader>Sa', '<cmd>lua require("scissors").addNewSnippet()<cr>', desc = 'Snippet: Add' },
    },
  },
  {
    'saghen/blink.cmp',
    dependencies = {
      'rafamadriz/friendly-snippets',
      {
        'supermaven-inc/supermaven-nvim',
        event = 'InsertEnter',
        cmd = {
          'SupermavenUseFree',
          'SupermavenUsePro',
        },
        opts = {
          keymaps = {
            accept_suggestion = nil, -- handled by nvim-cmp / blink.cmp
          },
          disable_inline_completion = true,
          ignore_filetypes = { 'bigfile', 'snacks_input', 'snacks_notif' },
        },
      },
      {
        'Kaiser-Yang/blink-cmp-git',
        dependencies = { 'nvim-lua/plenary.nvim' },
      },
    },
    event = 'InsertEnter',
    version = '*',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' for mappings similar to built-in completion
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      -- See the full "keymap" documentation for information on defining your own keymap.
      keymap = {
        preset = 'none',
        ['<C-n>'] = {
          function(cmp)
            cmp.show { providers = { 'snippets' } }
          end,
        },
        ['<C-a>'] = {
          function(cmp)
            cmp.show { providers = { 'supermaven' } }
          end,
        },
        ['<C-i>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide' },
        ['<C-y>'] = { 'select_and_accept' },

        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<C-j>'] = { 'select_next', 'fallback' },

        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

        ['<C-l>'] = { 'snippet_forward', 'fallback' },
        ['<C-h>'] = { 'snippet_backward', 'fallback' },
      },
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = 'mono',
        kind_icons = {
          Text = '󰉿',
          Method = '󰊕',
          Function = '󰊕',
          Constructor = '󰒓',

          Field = '󰜢',
          Variable = '󰆦',
          Property = '󰖷',

          Class = '󱡠',
          Interface = '󱡠',
          Struct = '󱡠',
          Module = '󰅩',

          Unit = '󰪚',
          Value = '󰦨',
          Enum = '󰦨',
          EnumMember = '󰦨',

          Keyword = '󰻾',
          Constant = '󰏿',

          Snippet = '󱄽',
          Color = '󰏘',
          File = '󰈔',
          Reference = '󰬲',
          Folder = '󰉋',
          Event = '󱐋',
          Operator = '󰪚',
          TypeParameter = '󰬛',
        },
      },
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          draw = {
            treesitter = { 'lsp' },
            columns = {
              { 'label', 'label_description', gap = 1 },
              { 'kind_icon', gap = 1, 'kind' },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
      },
      snippets = {
        preset = 'default',
      },
      cmdline = {
        enabled = true,
      },
      fuzzy = {
        sorts = {
          function(a, b)
            if (a.client_name == nil or b.client_name == nil) or (a.client_name == b.client_name) then
              return
            end
            return b.client_name == 'emmet_language_server'
          end,
          'score',
          'exact',
          'sort_text',
        },
      },
      sources = {
        default = {
          'lsp',
          'path',
          'snippets',
          'buffer',
          'supermaven',
          'git',
        },
        per_filetype = {
          lua = { inherit_defaults = true, 'lazydev' },
        },
        providers = {
          lsp = {
            score_offset = 80,
            max_items = 10,
          },
          path = {
            score_offset = 85,
          },
          snippets = {
            score_offset = 70,
            max_items = 5,
          },
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
          supermaven = {
            name = 'supermaven',
            module = 'blink.compat.source',
            score_offset = -30,
            async = true,
          },
          git = {
            module = 'blink-cmp-git',
            name = 'Git',
            score_offset = 100,
            enabled = function()
              return vim.tbl_contains({ 'octo', 'gitcommit', 'markdown' }, vim.bo.filetype)
            end,
            opts = {
              kind_icons = {
                openPR = '',
                openedPR = '',
                closedPR = '',
                mergedPR = '',
                draftPR = '',
                lockedPR = '',
                openIssue = '',
                openedIssue = '',
                reopenedIssue = '',
                completedIssue = '',
                closedIssue = '',
                not_plannedIssue = '',
                duplicateIssue = '',
                lockedIssue = '',
              },
              git_centers = {
                github = {
                  pull_request = {
                    get_command_args = function(command, token)
                      local args = require('blink-cmp-git.default.github').issue.get_command_args(command, token)
                      local utils = require 'blink-cmp-git.utils'
                      if command == 'curl' then
                        args[#args] = 'https://api.github.com/repos/' .. utils.get_repo_owner_and_repo() .. '/pulls?state=all&per_page=100&sort=updated'
                      else
                        args[#args] = 'repos/' .. utils.get_repo_owner_and_repo() .. '/pulls?state=all&per_page=100&sort=updated'
                      end
                      return args
                    end,
                    get_kind_name = function(item)
                      -- openPR, closedPR, mergedPR, draftPR, lockedPR
                      return item.locked and 'lockedPR' or item.draft and 'draftPR' or item.merged_at and 'mergedPR' or item.state .. 'PR'
                    end,
                    configure_score_offset = pr_or_issue_configure_score_offset,
                  },
                  issue = {
                    get_command_args = function(command, token)
                      local args = require('blink-cmp-git.default.github').issue.get_command_args(command, token)
                      local utils = require 'blink-cmp-git.utils'
                      if command == 'curl' then
                        args[#args] = 'https://api.github.com/repos/' .. utils.get_repo_owner_and_repo() .. '/issues?state=all&per_page=100&sort=updated'
                      else
                        args[#args] = 'repos/' .. utils.get_repo_owner_and_repo() .. '/issues?state=all&per_page=100&sort=updated'
                      end
                      return args
                    end,
                    get_kind_name = function(item)
                      -- openIssue, reopenedIssue, completedIssue
                      -- not_plannedIssue, lockedIssue, duplicateIssue
                      return item.locked and 'lockedIssue' or (item.state_reason or item.state) .. 'Issue'
                    end,
                    configure_score_offset = pr_or_issue_configure_score_offset,
                  },
                },
              },
            },
          },
        },
      },
    },
    opts_extend = { 'sources.default', 'sources.providers' },

    -- Experimental signature help support
    signature = { enabled = true },
  },
}
